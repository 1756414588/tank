package com.game.service.teaminstance;

import com.game.constant.FormType;
import com.game.constant.GameError;
import com.game.constant.SysChatId;
import com.game.dataMgr.StaticBountyDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Form;
import com.game.domain.s.StaticBountyStage;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.message.handler.cs.QueryCrossServerListHandler;
import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.TeamRoleInfo;
import com.game.pb.CrossMinPb;
import com.game.pb.GamePb6.*;
import com.game.server.CrossMinContext;
import com.game.server.GameServer;
import com.game.service.ChatService;
import com.game.service.FightService;
import com.game.util.CrossPbHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author : LiFeng
 * @date : 4.14
 * @description : 赏金猎人，组队相关
 */
@Component
public class TeamService {

    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private ChatService chatService;
    @Autowired
    private FightService fightService;
    @Autowired
    private StaticBountyDataMgr staticBountyDataMgr;
    @Autowired
    private TeamInstanceService teamInstanceService;
    @Autowired
    private TeamFightLogic teamFightLogic;
    @Autowired
    private PartyDataManager partyDataManager;

    /**
     * 玩家主动下线(顶号 也需要退出)
     *
     * @param roleId
     */
    public void logOut(long roleId) {
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.logOut(roleId);
            if (rpcCodeTeamResponse == null) {
                return;
            }
            if (rpcCodeTeamResponse.getCode() != GameError.OK.getCode()) {
                return;
            }
        } else {
            Team team = TeamManager.getTeamByRoleId(roleId);
            if (team == null) {
                return;
            }
            // 队长解散队伍
            if (roleId == team.getCaptainId()) {
                TeamManager.dismissTeam(team);
                for (Long memberId : team.getMembersInfo().keySet()) {
                    if (memberId == team.getCaptainId()) {
                        continue;
                    }
                    Player player = playerDataManager.getPlayer(memberId);
                    // 通知其他队员，队伍已解散
                    synNotifyDismissTeam(player);
                }
            } else {
                // 队员退出队伍
                TeamManager.leaveTeam(roleId);
                updateTeamInfo(team, TeamConstant.LEAVE_TEAM, roleId);
                synTeamInfoToMembers(team, TeamConstant.LEAVE_TEAM, roleId);
            }
        }
    }

    /**
     * 创建队伍
     *
     * @param handler
     * @param req
     */
    public void createTeam(ClientHandler handler, CreateTeamRq req) {
        long roleId = handler.getRoleId();
        int teamType = req.getTeamType();
        Player player = playerDataManager.getPlayer(roleId);
        // 判断是否具有进入关卡的资格
        if (!canEnterBountyStage(handler, req.getTeamType())) {
            return;
        }

        if (player.forms.get(FormType.TEAM) == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NO_FORM);
            return;
        }
        TeamRoleInfo roleInfo = null;
        CreateTeamRs.Builder builder = CreateTeamRs.newBuilder();
        long fight = fightService.calcFormFight(player, player.forms.get(FormType.TEAM));
        if (teamInstanceService.isCrossOpen()) {
            Form form = player.forms.get(FormType.TEAM);
            if (form == null) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_NO_FORM);
                return;
            }
            TeamRpcService.synPlayer(player, partyDataManager, fightService, true, 1);//同步用户基本数据
            CrossTeamProto.RpcCreateTeamResponse rpcCreateTeamResponse = TeamRpcService.createTeam(roleId, teamType, fight);
            if (rpcCreateTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }

            if (rpcCreateTeamResponse.hasCode() && rpcCreateTeamResponse.getCode() == GameError.TEAM_HAVE.getCode()) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_HAVE);
                return;
            }

            CrossTeamProto.RpcTeamRoleInfo teamResponseRoleInfo = rpcCreateTeamResponse.getRoleInfo();
            builder.setTeamId(rpcCreateTeamResponse.getTeamId());
            roleInfo = PbHelper.createTeamRoleInfo(teamResponseRoleInfo);
        } else {
            if (TeamManager.getTeamByRoleId(roleId) != null) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_HAVE);
                return;
            }

            Team team = new Team(roleId, teamType);
            // 保存新增队伍的信息
            TeamManager.increaseTeam(team);
            builder.setTeamId(team.getTeamId());
            roleInfo = PbHelper.createTeamRoleInfo(player, TeamConstant.READY, fight);
        }
        builder.setRoleInfo(roleInfo);
        handler.sendMsgToPlayer(CreateTeamRs.ext, builder.build());
    }


    /**
     * 解散队伍
     *
     * @param handler
     * @description
     */
    public void dismissTeam(ClientHandler handler) {
        long roleId = handler.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.disMissTeam(roleId);
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                handler.sendMsgToPlayer(DismissTeamRs.ext, DismissTeamRs.newBuilder().build());
                return;
            }
            handler.sendErrorMsgCodeToPlayer(rpcCodeTeamResponse.getCode());
        } else {
            Team team = TeamManager.getTeamByRoleId(roleId);
            if (!checkTeamStatus(team, handler)) {
                return;
            }
            if (roleId != team.getCaptainId()) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_RIGHT_LIMIT);
                return;
            }
            TeamManager.dismissTeam(team);
            for (Long memberId : team.getMembersInfo().keySet()) {
                if (memberId == team.getCaptainId()) {
                    continue;
                }
                Player player = playerDataManager.getPlayer(memberId);
                // 通知其他队员，队伍已解散
                synNotifyDismissTeam(player);
            }
            // 客户端收到该协议后，给予队长相应通知
            handler.sendMsgToPlayer(DismissTeamRs.ext, DismissTeamRs.newBuilder().build());
        }
    }

    /**
     * 寻找队伍
     *
     * @param handler
     * @param req
     */
    public void findTeam(ClientHandler handler, FindTeamRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            return;
        }
        if (!canEnterBountyStage(handler, req.getTeamType())) {
            return;
        }
        if (teamInstanceService.isCrossOpen()) {
            Form form = player.forms.get(FormType.TEAM);
            if (form == null) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_NO_FORM);
                return;
            }
            TeamRpcService.synPlayer(player, partyDataManager, fightService, false, 1);//同步用户基本数据
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.findTeam(handler.getRoleId(), req.getTeamType());
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                TeamRpcService.synPlayer(player, partyDataManager, fightService, true, 1);//同步用户基本数据
                handler.sendMsgToPlayer(FindTeamRs.ext, FindTeamRs.newBuilder().build());
                return;
            }
            handler.sendErrorMsgCodeToPlayer(rpcCodeTeamResponse.getCode());

        } else {
            List<Team> teams = new ArrayList<>();
            for (Team team : TeamManager.getAllTeams()) {
                // 队伍类型须一致，且人员未满
                if (req.getTeamType() != team.getTeamType() || team.getMembersInfo().size() >= TeamConstant.TEAM_LIMIT) {
                    continue;
                }
                teams.add(team);
            }
            if (teams.size() <= 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_TEAMS_TO_JOIN);
                return;
            }
            // 从所有队伍中随机一个加入
            Team team = teams.get(new Random().nextInt(teams.size()));
            if (!innerJoinTeam(handler, team)) {
                return;
            }
            // 同步队伍信息
            synTeamInfoToMembers(team, TeamConstant.FIND_TEAM, handler.getRoleId());
            handler.sendMsgToPlayer(FindTeamRs.ext, FindTeamRs.newBuilder().build());
        }
    }

    /**
     * 队员离开队伍
     *
     * @param handler
     */
    public void leaveTeam(ClientHandler handler) {
        long roleId = handler.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.leave(roleId);
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                handler.sendMsgToPlayer(LeaveTeamRs.ext, LeaveTeamRs.newBuilder().build());
            }
            handler.sendMsgToPlayer(LeaveTeamRs.ext, LeaveTeamRs.newBuilder().build());
        } else {
            Team team = TeamManager.getTeamByRoleId(roleId);
            if (!checkTeamStatus(team, handler)) {
                return;
            }
            if (roleId == team.getCaptainId()) {
                return;
            }
            TeamManager.leaveTeam(roleId);
            // 更新该队伍信息
            updateTeamInfo(team, TeamConstant.LEAVE_TEAM, roleId);
            // 同步队伍信息至其他队员
            synTeamInfoToMembers(team, TeamConstant.LEAVE_TEAM, roleId);
            handler.sendMsgToPlayer(LeaveTeamRs.ext, LeaveTeamRs.newBuilder().build());
        }
    }

    /**
     * 踢出队伍
     *
     * @param handler
     * @param req
     */
    public void kickout(ClientHandler handler, KickOutRq req) {
        long captainId = handler.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.kickTeam(captainId, req.getRoleId());
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                handler.sendMsgToPlayer(KickOutRs.ext, KickOutRs.newBuilder().build());
            } else {
                handler.sendErrorMsgCodeToPlayer(rpcCodeTeamResponse.getCode());
            }
        } else {
            Team team = TeamManager.getTeamByRoleId(captainId);
            if (!checkTeamStatus(team, handler)) {
                return;
            }
            if (captainId != team.getCaptainId()) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_RIGHT_LIMIT);
                return;
            }
            long kickId = req.getRoleId();
            if (!team.getMembersInfo().containsKey(kickId)) {
                return;
            }
            TeamManager.leaveTeam(kickId);
            updateTeamInfo(team, TeamConstant.LEAVE_TEAM, kickId);
            // 同步队伍信息
            synTeamInfoToMembers(team, TeamConstant.KICK_OUT, handler.getRoleId());
            // 通知被踢者
            synTeamKickOut(playerDataManager.getPlayer(kickId));
            handler.sendMsgToPlayer(KickOutRs.ext, KickOutRs.newBuilder().build());
        }
    }

    /**
     * 加入队伍
     *
     * @param handler
     * @param req
     */
    public void joinTeam(ClientHandler handler, JoinTeamRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            return;
        }
        int teamId = req.getTeamId();

        if (teamInstanceService.isCrossOpen()) {
            // 读取零散配置中的角色等级限制
            if (staticBountyDataMgr.getBountyConfig().getLv() > player.lord.getLevel()) {
                handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                return;
            }
            Form form = player.forms.get(FormType.TEAM);
            if (form == null) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_NO_FORM);
                return;
            }
            TeamRpcService.synPlayer(player, partyDataManager, fightService, false, 1);//同步用户数据去跨服
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.joinTeam(handler.getRoleId(), teamId);
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                TeamRpcService.synPlayer(player, partyDataManager, fightService, true, 1);//同步用户数据去跨服
                handler.sendMsgToPlayer(KickOutRs.ext, KickOutRs.newBuilder().build());
                return;
            }
            handler.sendErrorMsgCodeToPlayer(rpcCodeTeamResponse.getCode());

        } else {
            Team team = TeamManager.getTeamByTeamId(teamId);
            if (team == null) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_NOT);
                return;
            }
            if (!canEnterBountyStage(handler, team.getTeamType())) {
                return;
            }
            if (!innerJoinTeam(handler, team)) {
                return;
            }
            // 同步队伍信息
            synTeamInfoToMembers(team, TeamConstant.JOIN_TEAM, handler.getRoleId());
            handler.sendMsgToPlayer(JoinTeamRs.ext, JoinTeamRs.newBuilder().build());
        }
    }

    /**
     * 加入队伍方法的抽取
     *
     * @param handler
     * @param team
     */
    private boolean innerJoinTeam(ClientHandler handler, Team team) {
        long roleId = handler.getRoleId();
        if (TeamManager.getTeamByRoleId(roleId) != null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_HAVE);
            return false;
        }
        if (!checkTeamStatus(team, handler) || team.getMembersInfo().size() >= TeamConstant.TEAM_LIMIT) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_FULL);
            return false;
        }
        Player player = playerDataManager.getPlayer(roleId);
        if (player.forms.get(FormType.TEAM) == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NO_FORM);
            return false;
        }
        TeamManager.joinTeam(roleId, team.getTeamId());
        updateTeamInfo(team, TeamConstant.JOIN_TEAM, roleId);
        return true;
    }

    /**
     * 更换队员的准备状态
     *
     * @param handler
     * @description 全员准备时，更改队伍状态
     */
    public void changeMemberStatus(ClientHandler handler) {
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.changeMemberStatus(handler.getRoleId());
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                handler.sendMsgToPlayer(ChangeMemberStatusRs.ext, ChangeMemberStatusRs.newBuilder().build());
            }
        } else {
            Team team = TeamManager.getTeamByRoleId(handler.getRoleId());
            if (team == null || handler.getRoleId() == team.getCaptainId()) {
                return;
            }
            int status = team.getMembersInfo().get(handler.getRoleId());
            status = (status == TeamConstant.READY) ? TeamConstant.UN_READY : TeamConstant.READY;
            if (status == team.getMembersInfo().get(handler.getRoleId())) {
                status = TeamConstant.UN_READY;
            }
            // 将更改后的状态存起来
            team.getMembersInfo().put(handler.getRoleId(), status);
            HashMap<Long, Integer> membersInfo = team.getMembersInfo();
            // 假如全员已准备，更改队伍状态
            if (membersInfo.size() == TeamConstant.TEAM_LIMIT) {
                team.setStatus(TeamConstant.READY);
                for (Integer memberStatus : membersInfo.values()) {
                    if (memberStatus == TeamConstant.READY) {
                        continue;
                    }
                    team.setStatus(TeamConstant.UN_READY);
                    break;
                }
            }
            handler.sendMsgToPlayer(ChangeMemberStatusRs.ext, ChangeMemberStatusRs.newBuilder().build());
            synMemberStatus(team, handler.getRoleId(), status);
        }

    }

    /**
     * 交换队员出战顺序
     *
     * @param handler
     * @param req
     */
    public void exchangeOrder(ClientHandler handler, ExchangeOrderRq req) {
        long roleId = handler.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.changeOrder(roleId, req.getRoleOne(), req.getRoleTwo());
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                handler.sendMsgToPlayer(ExchangeOrderRs.ext, ExchangeOrderRs.newBuilder().build());
            } else {
                handler.sendErrorMsgCodeToPlayer(rpcCodeTeamResponse.getCode());
            }
        } else {
            Team team = TeamManager.getTeamByRoleId(roleId);
            if (!checkTeamStatus(team, handler)) {
                return;
            }
            if (team.getCaptainId() != roleId) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_RIGHT_LIMIT);
                return;
            }

            List<Long> order = team.getOrder();

            // a, b分别表示发生交换的位置序号，客户端以1表示第一个位置
            int a = req.getRoleOne() - 1;
            int b = req.getRoleTwo() - 1;
            int max = a > b ? a : b;
            if (max > TeamConstant.TEAM_LIMIT - 1) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_INVALID_PARAM);
                return;
            }

            Long tempRoleId = order.get(a);
            order.set(a, order.get(b));
            order.set(b, tempRoleId);

            handler.sendMsgToPlayer(ExchangeOrderRs.ext, ExchangeOrderRs.newBuilder().build());
            synTeamInfoToMembers(team, TeamConstant.CHANGE_ORDER, roleId);
        }
    }

    /**
     * 队伍聊天
     *
     * @param handler
     * @param req
     */
    public void teamChat(ClientHandler handler, TeamChatRq req) {
        String message = req.getMessage();
        Long roleId = handler.getRoleId();
        Long time = System.currentTimeMillis();
        if (teamInstanceService.isCrossOpen()) {
       /*     CrossTeamProto.CrossTeamChatResponse crossTeamChatResponse = TeamRpcService.teamChat(roleId, message, time);
            if (crossTeamChatResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (crossTeamChatResponse.getCode() == GameError.OK.getCode()) {
                TeamChatRs.Builder builder = TeamChatRs.newBuilder();
                builder.setTime(crossTeamChatResponse.getTime());
                handler.sendMsgToPlayer(TeamChatRs.ext, builder.build());
                return;
            }
            handler.sendErrorMsgCodeToPlayer(crossTeamChatResponse.getCode());*/
            CrossMinPb.CrossTeamChatRq.Builder msg = CrossMinPb.CrossTeamChatRq.newBuilder();
            msg.setRoleId(roleId);
            msg.setMessage(message);
            msg.setTime(time);
            BasePb.Base.Builder rqBase = PbHelper.createRqBase(CrossMinPb.CrossTeamChatRq.EXT_FIELD_NUMBER, null, CrossMinPb.CrossTeamChatRq.ext, msg.build());
            GameServer.getInstance().sendMsgToCrossMin(rqBase);

            TeamChatRs.Builder builder = TeamChatRs.newBuilder();
            builder.setTime(time);
            handler.sendMsgToPlayer(TeamChatRs.ext, builder.build());

        } else {
            if (TeamManager.getTeamByRoleId(roleId) == null) {
                return;
            }
            TeamChatRs.Builder builder = TeamChatRs.newBuilder();
            builder.setTime(time);
            handler.sendMsgToPlayer(TeamChatRs.ext, builder.build());

            Player player = playerDataManager.getPlayer(roleId);
            synTeamChat(player.lord.getNick(), roleId, time, message);
        }
    }

    /**
     * 查看队员阵型信息
     *
     * @param handler
     * @param req
     */
    public void lookForm(ClientHandler handler, LookMemberInfoRq req) {
        long roleId = req.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.CrossLookFormResponse crossLookFormResponse = TeamRpcService.lookForm(roleId);
            if (crossLookFormResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (crossLookFormResponse.getCode() == GameError.OK.getCode()) {
                LookMemberInfoRs.Builder builder = LookMemberInfoRs.newBuilder();
                builder.setFight(crossLookFormResponse.getFight());
                CrossTeamProto.Form form = crossLookFormResponse.getForm();
                CommonPb.Form formPb = CrossPbHelper.createFormPb(form);
                builder.setForm(formPb);
                handler.sendMsgToPlayer(LookMemberInfoRs.ext, builder.build());
            } else {
                handler.sendErrorMsgCodeToPlayer(crossLookFormResponse.getCode());
            }
        } else {
            Player player = playerDataManager.getPlayer(roleId);
            Form form = player.forms.get(FormType.TEAM);
            // 客户端有自己的一套计算方式，可能值会有些许差异
            long fight = fightService.calcFormFight(player, form);
            LookMemberInfoRs.Builder builder = LookMemberInfoRs.newBuilder();
            builder.setForm(PbHelper.createFormPb(form));
            builder.setFight(fight);
            handler.sendMsgToPlayer(LookMemberInfoRs.ext, builder.build());
        }
    }

    /**
     * 在世界频道发送队伍邀请
     *
     * @param handler
     * @param req
     */
    public void teamInvite(ClientHandler handler, InviteMemberRq req) {
        long roleId = handler.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.RpcCodeTeamResponse rpcCodeTeamResponse = TeamRpcService.teamInvite(handler.getRoleId(), req.getStageId());
            if (rpcCodeTeamResponse == null) {
                handler.sendErrorMsgToPlayer(GameError.CROSS_SERVER_ERR);
                return;
            }
            if (rpcCodeTeamResponse.getCode() == GameError.OK.getCode()) {
                handler.sendMsgToPlayer(InviteMemberRs.ext, InviteMemberRs.newBuilder().build());
            } else {
                handler.sendErrorMsgCodeToPlayer(rpcCodeTeamResponse.getCode());
            }
        } else {
            Team team = TeamManager.getTeamByRoleId(roleId);
            if (team == null) {
                return;
            }
            if (team.getCaptainId() != roleId) {
                handler.sendErrorMsgToPlayer(GameError.CAN_NOT_INVITE);
                return;
            }
            int stageId = req.getStageId();
            // 获取该关卡对应的boss名称
            String bossName = staticBountyDataMgr.getBountyStageConfig(stageId).getName();
            Player player = playerDataManager.getPlayer(roleId);
            // 发送世界消息
            chatService.sendWorldChat(chatService.createTeamInviteChat(SysChatId.BOUNTY_TEAM_INVITE, team.getTeamId(), player.lord.getNick(), bossName));
            handler.sendMsgToPlayer(InviteMemberRs.ext, InviteMemberRs.newBuilder().build());
        }
    }

    /**
     * 队长发起战斗
     *
     * @param handler
     */
    public void teamFightBoss(ClientHandler handler) {
        long roleId = handler.getRoleId();
        if (teamInstanceService.isCrossOpen()) {
            CrossMinPb.CrossFightRq.Builder msg = CrossMinPb.CrossFightRq.newBuilder();
            msg.setRoleId(roleId);
            BasePb.Base.Builder baseBuilder = PbHelper.createRqBase(CrossMinPb.CrossFightRq.EXT_FIELD_NUMBER, null, CrossMinPb.CrossFightRq.ext, msg.build());
            GameServer.getInstance().sendMsgToCrossMin(baseBuilder);
        } else {
            Team team = TeamManager.getTeamByRoleId(roleId);
            if (!checkTeamStatus(team, handler)) {
                return;
            }
            if (!canEnterBountyStage(handler, team.getTeamType())) {
                return;
            }
            if (roleId != team.getCaptainId()) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_RIGHT_LIMIT);
                return;
            }
            if (team.getMembersInfo().size() < TeamConstant.TEAM_LIMIT) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_MEMBER_NOT_ENOUGH);
                return;
            }
            if (team.getStatus() != TeamConstant.READY) {
                handler.sendErrorMsgToPlayer(GameError.TEAM_UNREADY);
                return;
            }
            teamFightLogic.fight(team, team.getTeamType());
            handler.sendMsgToPlayer(TeamFightBossRs.ext, TeamFightBossRs.newBuilder().build());
        }
    }

    /**
     * 更新队伍信息
     *
     * @param team
     * @param actionType 操作类型（加入，退出，解散）
     * @param roleId
     * @description 踢出队伍走退出队伍逻辑
     */
    private void updateTeamInfo(Team team, int actionType, long roleId) {
        List<Long> order = team.getOrder();
        switch (actionType) {
            // 离开队伍与踢出队伍走相同逻辑
            case TeamConstant.LEAVE_TEAM:
                team.getMembersInfo().remove(roleId);
                team.setStatus(TeamConstant.UN_READY);
                order.set(order.indexOf(roleId), 0L);
                break;
            // 加入队伍与寻找队伍走相同逻辑
            case TeamConstant.JOIN_TEAM:
                team.getMembersInfo().put(roleId, TeamConstant.UN_READY);
                team.setStatus(TeamConstant.UN_READY);
                for (long role : order) {
                    if (role == 0L) {
                        order.set(order.indexOf(role), roleId);
                        break;
                    }
                }
                break;
            case TeamConstant.DISMISS_TEAM:
                team.setStatus(TeamConstant.DISMISS);
                break;
            default:
        }
    }

    /**
     * 检查队伍状态（是否为空，是否已出战，是否已解散）
     *
     * @param team, handler
     */
    public boolean checkTeamStatus(Team team, ClientHandler handler) {
        if (team == null) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NOT_HAVE);
            return false;
        }
        if (team.getStatus() == TeamConstant.DISMISS) {
            handler.sendErrorMsgToPlayer(GameError.TEAM_NOT);
            return false;
        }
        return true;
    }

    /**
     * 通知全体队员，队伍已解散
     *
     * @param player
     */
    private void synNotifyDismissTeam(Player player) {
        SynNotifyDisMissTeamRq.Builder builder = SynNotifyDisMissTeamRq.newBuilder();
        BasePb.Base.Builder msg = PbHelper.createSynBase(SynNotifyDisMissTeamRq.EXT_FIELD_NUMBER,
                SynNotifyDisMissTeamRq.ext, builder.build());
        if (player != null && player.ctx != null && player.isLogin) {
            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
        }
    }

    /**
     * 通知某队员被踢出
     *
     * @param player
     */
    private void synTeamKickOut(Player player) {
        SynNotifyKickOutRq.Builder builder = SynNotifyKickOutRq.newBuilder();
        BasePb.Base.Builder msg = PbHelper.createSynBase(SynNotifyKickOutRq.EXT_FIELD_NUMBER, SynNotifyKickOutRq.ext,
                builder.build());
        if (player != null && player.ctx != null && player.isLogin) {
            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
        }
    }

    /**
     * 同步队伍信息方法抽取
     *
     * @param player
     * @param team
     */
    private void synTeamInfo(Player player, Team team, int actionType) {
        SynTeamInfoRq.Builder builder = SynTeamInfoRq.newBuilder();
        builder.setTeamId(team.getTeamId());
        builder.setCaptainId(team.getCaptainId());
        builder.setTeamType(team.getTeamType());
        // 定义是什么操作类型导致队伍信息的更新，参见TeamConstant
        builder.setActionType(actionType);
        for (Long order : team.getOrder()) {
            builder.addOrder(order);
        }
        HashMap<Long, Integer> membersInfo = team.getMembersInfo();
        for (long roleId : membersInfo.keySet()) {
            Player player1 = playerDataManager.getPlayer(roleId);
            long fight = fightService.calcFormFight(player1, player1.forms.get(FormType.TEAM));
            TeamRoleInfo roleInfo = PbHelper.createTeamRoleInfo(player1, membersInfo.get(roleId), fight);
            builder.addTeamInfo(roleInfo);
        }
        BasePb.Base.Builder msg = PbHelper.createSynBase(SynTeamInfoRq.EXT_FIELD_NUMBER, SynTeamInfoRq.ext,
                builder.build());
        if (player != null && player.ctx != null && player.isLogin) {
            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
        }

    }

    /**
     * 同步队伍信息
     *
     * @param team
     */
    public void synTeamInfoToMembers(Team team, int actionType, long roleId) {
        for (Long memberId : team.getMembersInfo().keySet()) {
            Player player = playerDataManager.getPlayer(memberId);
            // 为方便客户端界面跳转，当玩家通过世界频道进入队伍时，对非加入者特殊处理
            if (actionType == TeamConstant.JOIN_TEAM && roleId != memberId) {
                synTeamInfo(player, team, TeamConstant.FIND_TEAM);
                continue;
            }
            synTeamInfo(player, team, actionType);
        }
    }

    /**
     * 同步队员之间的准备状态
     *
     * @param roleId 状态发生切换的队员ID
     * @param team
     */
    private void synMemberStatus(Team team, long roleId, int status) {
        SynChangeStatusRq.Builder builder = SynChangeStatusRq.newBuilder();
        builder.setRoleId(roleId);
        builder.setStatus(status);
        BasePb.Base.Builder msg = PbHelper.createSynBase(SynChangeStatusRq.EXT_FIELD_NUMBER, SynChangeStatusRq.ext, builder.build());
        for (Long memberId : team.getMembersInfo().keySet()) {
            Player player = playerDataManager.getPlayer(memberId);
            if (player != null && player.ctx != null && player.isLogin) {
                GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            }
        }
    }

//	/**
//	 * 同步队伍出战顺序
//	 * @param team
//	 */
//	private void synTeamOrder(Team team) {
//		SynTeamOrderRq.Builder builder = SynTeamOrderRq.newBuilder();
//		for (Long roleId : team.getOrder()) {
//			builder.addOrder(roleId);
//		}
//		BasePb.Base.Builder msg = PbHelper.createSynBase(SynTeamOrderRq.EXT_FIELD_NUMBER, SynTeamOrderRq.ext,
//				builder.build());
//		for (Long memberId : team.getMembersInfo().keySet()) {
//			Player player = playerDataManager.getPlayer(memberId);
//			if (player != null && player.ctx != null && player.isLogin) {
//				GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
//			}
//		}
//	}

    /**
     * 同步队伍聊天信息
     *
     * @param roleId  讲话者ID
     * @param time    聊天发起时间
     * @param message 聊天信息
     */
    private void synTeamChat(String name, long roleId, Long time, String message) {
        Team team = TeamManager.getTeamByRoleId(roleId);
        SynTeamChatRq.Builder builder = SynTeamChatRq.newBuilder();
        builder.setRoleId(roleId);
        builder.setMessage(message);
        builder.setTime(time);
        builder.setName(name);
        BasePb.Base.Builder msg = PbHelper.createSynBase(SynTeamChatRq.EXT_FIELD_NUMBER, SynTeamChatRq.ext, builder.build());
        for (Long memberId : team.getMembersInfo().keySet()) {
            if (memberId == roleId) {
                continue;
            }
            Player player = playerDataManager.getPlayer(memberId);
            if (player != null && player.ctx != null && player.isLogin) {
                GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            }
        }
    }

    /**
     * 每天24:00解散第二天不开放的关卡队伍
     */
    public void disInvalidTeamLogic() {
        List<Team> allTeams = TeamManager.getAllTeams();
        // 不开放的关卡ID
        List<Integer> stageIds = new ArrayList<>();
        int dayOfWeek = TimeHelper.getCNDayOfWeek();
        // 获取明天是星期几
        int tomorrow = dayOfWeek == 7 ? 1 : dayOfWeek + 1;
        Map<Integer, StaticBountyStage> bountyStageConfig = staticBountyDataMgr.getBountyStageConfigMap();
        for (StaticBountyStage stage : bountyStageConfig.values()) {
            // 如果该关卡明天不开放
            if (!stage.getOpenTime().contains(tomorrow)) {
                stageIds.add(stage.getId());
            }
        }
        for (Team team : allTeams) {
            // 如果该队伍属于明天不开放的类型，解散
            if (stageIds.contains(team.getTeamType())) {
                TeamManager.dismissTeam(team);
                team.setStatus(TeamConstant.DISMISS);
                // 给全体队员发通知
                synStageCloseToTeam(team);
            }
        }
    }

    /**
     * 通知整个队伍，关卡已关闭
     *
     * @param team
     */
    private void synStageCloseToTeam(Team team) {
        SynStageCloseToTeamRq.Builder builder = SynStageCloseToTeamRq.newBuilder();
        BasePb.Base.Builder msg = PbHelper.createSynBase(SynStageCloseToTeamRq.EXT_FIELD_NUMBER,
                SynStageCloseToTeamRq.ext, builder.build());
        for (long roleId : team.getMembersInfo().keySet()) {
            Player player = playerDataManager.getPlayer(roleId);
            if (player != null && player.ctx != null && player.isLogin) {
                GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            }
        }
    }

    /**
     * 判断玩家是否可以进入关卡
     *
     * @param teamType
     * @param handler
     */
    public boolean canEnterBountyStage(ClientHandler handler, int teamType) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        // 如果该关卡未开放
        if (!teamInstanceService.isOpen(teamType)) {
            handler.sendErrorMsgToPlayer(GameError.STAGE_NOT_OPEN);
            return false;
        }
        // 读取零散配置中的角色等级限制
        if (staticBountyDataMgr.getBountyConfig().getLv() > player.lord.getLevel()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return false;
        }
        return true;
    }

    /**
     * 获取服务器列表
     *
     * @param handler
     */
    public void queryServerList(QueryCrossServerListHandler handler) {
        GetCrossServerInfoRs.Builder msg = GetCrossServerInfoRs.newBuilder();
        msg.setState(1);
        if (teamInstanceService.isCrossOpen()) {
            CrossTeamProto.CrossServerListResponse crossResponse = TeamRpcService.queryServerList();
            if (crossResponse != null) {
                List<CrossTeamProto.GameServerInfo> listInfoList = crossResponse.getListInfoList();
                if (listInfoList != null && !listInfoList.isEmpty()) {
                    msg.setState(2);
                    for (CrossTeamProto.GameServerInfo gameServerInfo : listInfoList) {
                        CommonPb.GameServerInfo.Builder builder = CommonPb.GameServerInfo.newBuilder();
                        builder.setServerId(gameServerInfo.getServerId());
                        builder.setServerName(gameServerInfo.getServerName());
                        msg.addInfo(builder.build());
                    }
                }
            }
        }
        msg.setCrossMineState(1);
        if (CrossMinContext.isCrossMinSocket()) {
            msg.setCrossMineState(2);
        }
        handler.sendMsgToPlayer(GetCrossServerInfoRs.ext, msg.build());
    }

    /**
     * 推送服务器 开启状态
     */
    public void synServerList(int state) {
        SynCrossServerInfoRq.Builder msg = SynCrossServerInfoRq.newBuilder();
        msg.setState(state);
        msg.setCrossMineState(state);
        if (state == 1 && CrossMinContext.isCrossMinSocket()) {
            msg.setCrossMineState(2);
        }
        BasePb.Base.Builder builder = PbHelper.createSynBase(SynCrossServerInfoRq.EXT_FIELD_NUMBER, SynCrossServerInfoRq.ext, msg.build());
        Map<String, Player> allOnlinePlayer = playerDataManager.getAllOnlinePlayer();
        for (Player player : allOnlinePlayer.values()) {
            if (player.ctx != null) {
                GameServer.getInstance().sendMsgToPlayer(player.ctx, builder);
            }
        }
        //跨服开启,所以组队玩家退出
        if (state == 2) {
            try {
                List<Team> allTeams = TeamManager.getAllTeams();
                for (Team team : allTeams) {
                    TeamManager.dismissTeam(team);
                    for (Long memberId : team.getMembersInfo().keySet()) {
                        Player player = playerDataManager.getPlayer(memberId);
                        // 通知其他队员，队伍已解散
                        synNotifyDismissTeam(player);
                    }
                }
            } catch (Exception e) {
                LogUtil.error("跨服开启,解散非跨服队伍出错");
            }
        }
    }
}
