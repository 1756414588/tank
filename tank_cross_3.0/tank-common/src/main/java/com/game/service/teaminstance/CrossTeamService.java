package com.game.service.teaminstance;

import com.game.constant.FormType;
import com.game.constant.GameError;
import com.game.datamgr.StaticBountyDataMgr;
import com.game.domain.CrossPlayer;
import com.game.domain.p.Form;
import com.game.domain.s.StaticBountyStage;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.manager.cross.seniormine.CrossMineCache;
import com.game.pb.CommonPb;
import com.game.pb.CrossMinPb;
import com.game.service.crossmin.ServerListConfig;
import com.game.service.crossmin.ServerListManager;
import com.game.service.crossmin.Session;
import com.game.service.crossmin.SessionManager;
import com.game.util.CrossPbHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/22 15:22
 * @description：
 */
@Component
public class CrossTeamService {

    @Autowired
    private StaticBountyDataMgr staticBountyDataMgr;
    @Autowired
    private TeamFightLogic teamFightLogic;


    /**
     * 同步数据
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse synPlayer(CrossTeamProto.RpcSynPlayerRequest request) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        int type = request.getType();
        CrossPlayer player = new CrossPlayer(request);
        switch (type) {
            case 1:
                CrossPlayerCacheLoader.put(player);
                break;
            case 2:
                CrossMineCache.addPlayer(player);
                break;
        }
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 创建队伍
     *
     * @param roleId
     * @param teamType
     * @param fight
     * @return
     */
    public synchronized CrossTeamProto.RpcCreateTeamResponse createTeam(long roleId, int teamType, long fight) {
        CrossTeamProto.RpcCreateTeamResponse.Builder builder = CrossTeamProto.RpcCreateTeamResponse.newBuilder();
        if (TeamManager.getTeamByRoleId(roleId) != null) {
            builder.setCode(GameError.TEAM_HAVE.getCode());
            return builder.build();
        }
        Team team = new Team(roleId, teamType);
        // 保存新增队伍的信息
        TeamManager.increaseTeam(team);
        builder.setTeamId(team.getTeamId());
        CrossPlayer crossPlayer = CrossPlayerCacheLoader.get(roleId);
        if (crossPlayer == null) {
            builder.setCode(GameError.PLAYER_NOT_EXIST.getCode());
            return builder.build();
        }
        Session session = SessionManager.getSession(crossPlayer.getServerId());
        String serverName = "";
        if (session != null) {
            serverName = session.getServerName();
        }
        CrossTeamProto.RpcTeamRoleInfo teamRoleInfo = PbHelper.createTeamRoleInfo(roleId, crossPlayer.getNick(), crossPlayer.getPortrait(), TeamConstant.READY, fight, serverName);
        builder.setRoleInfo(teamRoleInfo);
        return builder.build();
    }


    /**
     * 解散队伍
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse disMissTeam(long roleId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (team == null) {
            builder.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return builder.build();
        }
        if (team.getStatus() == TeamConstant.DISMISS) {
            builder.setCode(GameError.TEAM_NOT.getCode());
            return builder.build();
        }
        if (roleId != team.getCaptainId()) {
            builder.setCode(GameError.TEAM_RIGHT_LIMIT.getCode());
            return builder.build();
        }
        TeamManager.dismissTeam(team);
        for (Long memberId : team.getMembersInfo().keySet()) {
            if (memberId == team.getCaptainId()) {
                continue;
            }
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            if (player != null) {
                CrossMinPb.CrossNotifyDisMissTeamRq.Builder rq = CrossMinPb.CrossNotifyDisMissTeamRq.newBuilder();
                rq.setRoleId(player.getRoleId());
                MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossNotifyDisMissTeamRq.EXT_FIELD_NUMBER, CrossMinPb.CrossNotifyDisMissTeamRq.ext, rq.build());
            }
        }
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 寻找队伍
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse findTeam(long roleId, int teamType) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        List<Team> teams = new ArrayList<>();
        for (Team team : TeamManager.getAllTeams()) {
            // 队伍类型须一致，且人员未满
            if (teamType != team.getTeamType() || team.getMembersInfo().size() >= TeamConstant.TEAM_LIMIT) {
                continue;
            }
            teams.add(team);
        }
        if (teams.size() <= 0) {
            builder.setCode(GameError.NO_TEAMS_TO_JOIN.getCode());
            return builder.build();
        }
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
            builder.setCode(GameError.PLAYER_NOT_EXIST.getCode());
            return builder.build();
        }
        // 从所有队伍中随机一个加入
        Team team = teams.get(new Random().nextInt(teams.size()));
        GameError gameError = innerJoinTeam(player, team);
        if (gameError.getCode() != GameError.OK.getCode()) {
            builder.setCode(GameError.NO_TEAMS_TO_JOIN.getCode());
            return builder.build();
        }
        // 同步队伍信息
        synTeamInfoToMembers(team, TeamConstant.FIND_TEAM, roleId);
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 离开队伍
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse leaveTeam(long roleId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (!checkTeamStatus(team)) {
            builder.setCode(GameError.NO_TEAMS_TO_JOIN.getCode());
            return builder.build();
        }
        if (roleId == team.getCaptainId()) {
            builder.setCode(GameError.NO_TEAMS_TO_JOIN.getCode());
            return builder.build();
        }
        TeamManager.leaveTeam(roleId);
        // 更新该队伍信息
        updateTeamInfo(team, TeamConstant.LEAVE_TEAM, roleId);
        // 同步队伍信息至其他队员
        synTeamInfoToMembers(team, TeamConstant.LEAVE_TEAM, roleId);
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 踢出队伍
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse kickTeam(long roleId, long broleId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (!checkTeamStatus(team)) {
            return builder.build();
        }
        if (roleId != team.getCaptainId()) {
            builder.setCode(GameError.TEAM_RIGHT_LIMIT.getCode());
            return builder.build();
        }
        if (!team.getMembersInfo().containsKey(broleId)) {
            builder.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return builder.build();
        }
        CrossPlayer player = CrossPlayerCacheLoader.get(broleId);
        if (player == null) {
            builder.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return builder.build();
        }
        TeamManager.leaveTeam(broleId);
        updateTeamInfo(team, TeamConstant.LEAVE_TEAM, broleId);
        // 同步队伍信息
        synTeamInfoToMembers(team, TeamConstant.KICK_OUT, roleId);
        // 通知被踢者
        synTeamKickOut(player);
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 加入队伍
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse joinTeam(long roleId, int teamId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByTeamId(teamId);
        if (team == null) {
            builder.setCode(GameError.TEAM_NOT.getCode());
            return builder.build();
        }
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
            builder.setCode(GameError.PLAYER_NOT_EXIST.getCode());
            return builder.build();
        }
        GameError gameError = innerJoinTeam(player, team);
        if (gameError.getCode() != GameError.OK.getCode()) {
            builder.setCode(gameError.getCode());
            return builder.build();
        }
        // 同步队伍信息
        synTeamInfoToMembers(team, TeamConstant.JOIN_TEAM, player.getRoleId());
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 更改 状态
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse changeMemberStatus(long roleId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (team == null || roleId == team.getCaptainId()) {
            builder.setCode(GameError.TEAM_RIGHT_LIMIT.getCode());
            return builder.build();
        }
        int status = team.getMembersInfo().get(roleId);
        status = (status == TeamConstant.READY) ? TeamConstant.UN_READY : TeamConstant.READY;
        if (status == team.getMembersInfo().get(roleId)) {
            status = TeamConstant.UN_READY;
        }
        // 将更改后的状态存起来
        team.getMembersInfo().put(roleId, status);
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
        synMemberStatus(team, roleId, status);
        builder.setCode(GameError.OK.getCode());
        return builder.build();

    }

    /**
     * 交换出站顺序
     *
     * @param roleId
     * @param one
     * @param two
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse changeOrder(long roleId, int one, int two) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (!checkTeamStatus(team)) {
            builder.setCode(GameError.NO_TEAMS_TO_JOIN.getCode());
            return builder.build();
        }
        if (team.getCaptainId() != roleId) {
            builder.setCode(GameError.TEAM_RIGHT_LIMIT.getCode());
            return builder.build();
        }
        List<Long> order = team.getOrder();
        // a, b分别表示发生交换的位置序号，客户端以1表示第一个位置
        int a = one - 1;
        int b = two - 1;
        int max = a > b ? a : b;
        if (max > TeamConstant.TEAM_LIMIT - 1) {
            builder.setCode(GameError.TEAM_INVALID_PARAM.getCode());
            return builder.build();
        }
        Long tempRoleId = order.get(a);
        order.set(a, order.get(b));
        order.set(b, tempRoleId);
        synTeamInfoToMembers(team, TeamConstant.CHANGE_ORDER, roleId);
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 查看队员阵型
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.CrossLookFormResponse lookForm(long roleId) {
        CrossTeamProto.CrossLookFormResponse.Builder builder = CrossTeamProto.CrossLookFormResponse.newBuilder();
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
            builder.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return builder.build();
        }
        if (TeamManager.getTeamByRoleId(roleId) == null) {
            builder.setCode(GameError.TEAM_NOT.getCode());
            return builder.build();
        }
        builder.setFight(player.getFight());
        builder.setCode(GameError.OK.getCode());
        Form form = player.getForms().get(FormType.TEAM);
        if (form != null) {
            builder.setForm(CrossPbHelper.createFormPb(form));
        }
        return builder.build();
    }


    /**
     * 世界频道发送聊天(邀请信息)
     *
     * @param roleId
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse teamInvite(long roleId, int stageId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder req = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        Team team = TeamManager.getTeamByRoleId(roleId);
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
            req.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return req.build();
        }
        if (team == null) {
            req.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return req.build();
        }
        if (team.getCaptainId() != roleId) {
            req.setCode(GameError.CAN_NOT_INVITE.getCode());
            return req.build();
        }
        // 获取该关卡对应的boss名称
        String bossName = staticBountyDataMgr.getBountyStageConfig(stageId).getName();
        CrossMinPb.CrossSynTeamInviteRq.Builder builder = CrossMinPb.CrossSynTeamInviteRq.newBuilder();
        builder.setParam(bossName);
        builder.setNickName(player.getNick());
        builder.setSysId(stageId);
        builder.setTeamId(team.getTeamId());
        MsgSender.send2AllGame(CrossMinPb.CrossSynTeamInviteRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynTeamInviteRq.ext, builder.build());
        req.setCode(GameError.OK.getCode());
        return req.build();
    }

    /**
     * 战斗
     *
     * @param roleId
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse fight(long roleId) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
            builder.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return builder.build();
        }
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (!checkTeamStatus(team)) {
            builder.setCode(GameError.NO_TEAMS_TO_JOIN.getCode());
            return builder.build();
        }
        if (roleId != team.getCaptainId()) {
            builder.setCode(GameError.TEAM_RIGHT_LIMIT.getCode());
            return builder.build();
        }
        if (team.getMembersInfo().size() < TeamConstant.TEAM_LIMIT) {
            builder.setCode(GameError.TEAM_MEMBER_NOT_ENOUGH.getCode());
            return builder.build();
        }
        if (team.getStatus() != TeamConstant.READY) {
            builder.setCode(GameError.TEAM_UNREADY.getCode());
            return builder.build();
        }
        teamFightLogic.fight(team);
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 同步阵型和战力
     *
     * @param request
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse synForm(CrossTeamProto.CrossSynFormRequest request) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        long roleId = request.getRoleId();
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
            player = new CrossPlayer(roleId);
            CrossPlayerCacheLoader.put(player);
        }
        Form form = CrossPbHelper.createForm(request.getForm());
        player.getForms().put(form.getType(), form);
        player.setFight(request.getFight());
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (team != null) {
            synTeamInfoToMembers(team, TeamConstant.SET_FORM, roleId);
        }
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }

    /**
     * 玩家退出
     *
     * @param request
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse logOut(CrossTeamProto.CrossLogOutRequest request) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        CrossPlayer player = CrossPlayerCacheLoader.get(request.getRoleId());
        if (player == null) {
            builder.setCode(GameError.TEAM_NOT_HAVE.getCode());
            return builder.build();
        }
        Team team = TeamManager.getTeamByRoleId(player.getRoleId());
        if (team == null) {
            builder.setCode(GameError.TEAM_NOT.getCode());
            return builder.build();
        }
        // 队长解散队伍
        if (player.getRoleId() == team.getCaptainId()) {
            TeamManager.dismissTeam(team);
            for (Long memberId : team.getMembersInfo().keySet()) {
                if (memberId == team.getCaptainId()) {
                    continue;
                }
                CrossPlayer player1 = CrossPlayerCacheLoader.get(memberId);
                // 通知其他队员，队伍已解散
                if (player1 != null) {
                    CrossMinPb.CrossNotifyDisMissTeamRq.Builder rq = CrossMinPb.CrossNotifyDisMissTeamRq.newBuilder();
                    rq.setRoleId(player1.getRoleId());
                    MsgSender.send2Game(player1.getServerId(), CrossMinPb.CrossNotifyDisMissTeamRq.EXT_FIELD_NUMBER, CrossMinPb.CrossNotifyDisMissTeamRq.ext, rq.build());
                }
            }
        } else {
            // 队员退出队伍
            TeamManager.leaveTeam(player.getRoleId());
            updateTeamInfo(team, TeamConstant.LEAVE_TEAM, player.getRoleId());
            synTeamInfoToMembers(team, TeamConstant.LEAVE_TEAM, player.getRoleId());
        }
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }


    /**
     * 跨服组队聊天
     *
     * @param request
     * @return
     */
    public synchronized CrossTeamProto.RpcCodeTeamResponse worldChat(CrossTeamProto.CrossWorldChatRequest request) {
        CrossTeamProto.RpcCodeTeamResponse.Builder builder = CrossTeamProto.RpcCodeTeamResponse.newBuilder();
        long roleId = request.getRoleId();
        CrossMinPb.CrossWorldChatRq.Builder msg = CrossMinPb.CrossWorldChatRq.newBuilder();
        msg.setRoleId(roleId);
        msg.setContent(request.getContent());
        msg.setTime(request.getTime());
        msg.setNickName(request.getNickName());
        msg.setPort(request.getPort());
        msg.setBubble(request.getBubble());
        msg.setIsGm(request.getIsGm());
        msg.setLv(request.getLv());
        msg.setStaffing(request.getStaffing());
        msg.setMilitary(request.getMilitary());
        msg.setVip(request.getVip());
        msg.setServerName(request.getServerName());
        String servName = request.getServerName();
        Session session = SessionManager.getSession(request.getServerId());
        String[] split = null;
        if (session != null) {
            servName = session.getServerName();
            if (servName != null) {
                split = servName.split(" ");
            }
        }
        if (split != null) {
            servName = split[0];
        }
        msg.setServerName(servName);
        msg.setFight(request.getFight());
        msg.setPartyName(request.getPartyName());
        MsgSender.send2AllGame(CrossMinPb.CrossWorldChatRq.EXT_FIELD_NUMBER, CrossMinPb.CrossWorldChatRq.ext, msg.build());
        builder.setCode(GameError.OK.getCode());
        return builder.build();
    }


    /**
     * 加入队伍方法的抽取
     *
     * @param team
     */
    private GameError innerJoinTeam(CrossPlayer player, Team team) {
        if (TeamManager.getTeamByRoleId(player.getRoleId()) != null) {
            return GameError.TEAM_HAVE;
        }
        if (!checkTeamStatus(team) || team.getMembersInfo().size() >= TeamConstant.TEAM_LIMIT) {
            return GameError.TEAM_FULL;
        }
        if (player.getForms().get(FormType.TEAM) == null) {
            return GameError.TEAM_NO_FORM;
        }
        TeamManager.joinTeam(player.getRoleId(), team.getTeamId());
        updateTeamInfo(team, TeamConstant.JOIN_TEAM, player.getRoleId());
        return GameError.OK;
    }

    /**
     * 检查队伍状态（是否为空，是否已出战，是否已解散）
     *
     * @param team, handler
     */
    public boolean checkTeamStatus(Team team) {
        if (team == null) {
            return false;
        }
        if (team.getStatus() == TeamConstant.DISMISS) {
            return false;
        }
        return true;
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
     * 同步队伍信息
     *
     * @param team
     */
    public void synCloseInfoToMembers(Team team, int actionType, int serverId) {
        for (Long memberId : team.getMembersInfo().keySet()) {
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            if (player != null && player.getServerId() != serverId) {
                synTeamInfo(player, team, actionType);
            }
        }
    }


    /**
     * 同步队伍信息
     *
     * @param team
     */
    public void synTeamInfoToMembers(Team team, int actionType, long roleId) {
        for (Long memberId : team.getMembersInfo().keySet()) {
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            // 为方便客户端界面跳转，当玩家通过世界频道进入队伍时，对非加入者特殊处理
            if (actionType == TeamConstant.JOIN_TEAM && roleId != memberId) {
                synTeamInfo(player, team, TeamConstant.FIND_TEAM);
                continue;
            }
            synTeamInfo(player, team, actionType);
        }
    }

    /**
     * 同步队伍信息方法抽取
     *
     * @param player
     * @param team
     */
    private void synTeamInfo(CrossPlayer player, Team team, int actionType) {
        CrossMinPb.CrossSynTeamInfoRq.Builder builder = CrossMinPb.CrossSynTeamInfoRq.newBuilder();
        builder.setRoleId(player.getRoleId());
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
            CrossPlayer player1 = CrossPlayerCacheLoader.get(roleId);
            if (player1 != null) {
                String serverName = "";
                long fight = player1.getFight();
                Session session = SessionManager.getSession(player1.getServerId());
                if (session != null) {
                    serverName = session.getServerName();
                }
                CommonPb.TeamRoleInfo roleInfo = PbHelper.createTeamRoleInfo(player1, membersInfo.get(roleId), fight, serverName);
                builder.addTeamInfo(roleInfo);
            }

        }
        MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossSynTeamInfoRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynTeamInfoRq.ext, builder.build());
    }

    /**
     * 通知某队员被踢出
     *
     * @param player
     */
    private void synTeamKickOut(CrossPlayer player) {
        CrossMinPb.CrossSynNotifyKickOutRq.Builder builder = CrossMinPb.CrossSynNotifyKickOutRq.newBuilder();
        builder.setRoleId(player.getRoleId());
        MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossSynNotifyKickOutRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynNotifyKickOutRq.ext, builder.build());
    }

    /**
     * 同步队员之间的准备状态
     *
     * @param roleId 状态发生切换的队员ID
     * @param team
     */
    private void synMemberStatus(Team team, long roleId, int status) {
        CrossMinPb.CrossSynChangeStatusRq.Builder builder = CrossMinPb.CrossSynChangeStatusRq.newBuilder();
        builder.setRoleId(roleId);
        builder.setStatus(status);
        for (Long memberId : team.getMembersInfo().keySet()) {
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            if (player != null) {
                builder.setRole(player.getRoleId());
                MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossSynChangeStatusRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynChangeStatusRq.ext, builder.build());
            }
        }
    }

    /**
     * 同步队伍聊天信息
     *
     * @param roleId  讲话者ID
     * @param time    聊天发起时间
     * @param message 聊天信息
     */
    @Deprecated
    private void synTeamChat(String name, long roleId, Long time, String message, String serverName) {
        Team team = TeamManager.getTeamByRoleId(roleId);
        CrossMinPb.CrossSynTeamChatRq.Builder builder = CrossMinPb.CrossSynTeamChatRq.newBuilder();
        builder.setRoleId(roleId);
        builder.setMessage(message);
        builder.setTime(time);
        builder.setName(name);
        builder.setServerName(serverName);
        for (Long memberId : team.getMembersInfo().keySet()) {
            if (memberId == roleId) {
                continue;
            }
            builder.setRole(memberId);
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            if (player != null) {
                MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossSynTeamChatRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynTeamChatRq.ext, builder.build());
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
        CrossMinPb.CrossSynStageCloseToTeamRq.Builder msg = CrossMinPb.CrossSynStageCloseToTeamRq.newBuilder();
        for (long roleId : team.getMembersInfo().keySet()) {
            CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
            if (player != null) {
                msg.setRoldId(roleId);
                MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossSynStageCloseToTeamRq.EXT_FIELD_NUMBER, CrossMinPb.CrossSynStageCloseToTeamRq.ext, msg.build());
            }
        }
    }

    /**
     * 跨服关闭主动通知各个游戏服玩家队伍解散
     */
    public void closeNotifyGameServer() {
        try {
            List<Team> allTeams = TeamManager.getAllTeams();
            if (allTeams != null && !allTeams.isEmpty()) {
                for (Team allTeam : allTeams) {
                    for (Long memberId : allTeam.getMembersInfo().keySet()) {
                        CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
                        if (player != null) {
                            CrossMinPb.CrossNotifyDisMissTeamRq.Builder rq = CrossMinPb.CrossNotifyDisMissTeamRq.newBuilder();
                            rq.setRoleId(player.getRoleId());
                            MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossNotifyDisMissTeamRq.EXT_FIELD_NUMBER, CrossMinPb.CrossNotifyDisMissTeamRq.ext, rq.build());
                        }
                    }
                }

            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
    }

    /**
     * 移除该服下所有玩家
     *
     * @param serverId
     */
    public void removeServerCrossPlayer(int serverId) {
        LogUtil.error("游戏服与跨服断开连接 serverId:{}", serverId);
        List<Team> allTeams = TeamManager.getAllTeams();
        for (Team team : allTeams) {
            long capId = team.getCaptainId();
            CrossPlayer player = CrossPlayerCacheLoader.get(capId);
            if (player.getServerId() == serverId) {
                closeCpTeam(team, serverId);
            } else {
                exitTeam(team, serverId);
            }
        }
    }

    public void exitTeam(Team team, int serverId) {
        List<Long> idList = new ArrayList<>(team.getMembersInfo().keySet());
        for (Long memberId : idList) {
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            if (player.getServerId() == serverId) {
                TeamManager.leaveTeam(player.getRoleId());
                // 更新该队伍信息
                updateTeamInfo(team, TeamConstant.LEAVE_TEAM, player.getRoleId());
                // 同步队伍信息至其他队员
                synCloseInfoToMembers(team, TeamConstant.LEAVE_TEAM, serverId);
            }
        }
    }

    public void closeCpTeam(Team team, int serverId) {
        TeamManager.dismissTeam(team);
        for (Long memberId : team.getMembersInfo().keySet()) {
            CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
            if (memberId == team.getCaptainId() || player.getServerId() == serverId) {
                continue;
            }
            if (player != null) {
                CrossMinPb.CrossNotifyDisMissTeamRq.Builder rq = CrossMinPb.CrossNotifyDisMissTeamRq.newBuilder();
                rq.setRoleId(player.getRoleId());
                MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossNotifyDisMissTeamRq.EXT_FIELD_NUMBER, CrossMinPb.CrossNotifyDisMissTeamRq.ext, rq.build());
            }
        }
    }


    /**
     * 游戏服获取跨服服务器列表
     *
     * @return
     */
    public CrossTeamProto.CrossServerListResponse queryServerList() {
        CrossTeamProto.CrossServerListResponse.Builder msg = CrossTeamProto.CrossServerListResponse.newBuilder();
        for (ServerListConfig server : ServerListManager.getServerListMap().values()) {
            CrossTeamProto.GameServerInfo.Builder gs = CrossTeamProto.GameServerInfo.newBuilder();
            gs.setServerId(server.getId());
            gs.setServerName(server.getName());
            msg.addListInfo(gs.build());
        }
        return msg.build();
    }

    /**
     * 跨服活动结束,所有玩家退出队伍
     */
    public void closeAllTeam() {
        List<Team> allTeams = TeamManager.getAllTeams();
        for (Team team : allTeams) {
            TeamManager.dismissTeam(team);
            for (Long memberId : team.getMembersInfo().keySet()) {
                CrossPlayer player = CrossPlayerCacheLoader.get(memberId);
                if (player != null) {
                    CrossMinPb.CrossNotifyDisMissTeamRq.Builder rq = CrossMinPb.CrossNotifyDisMissTeamRq.newBuilder();
                    rq.setRoleId(player.getRoleId());
                    MsgSender.send2Game(player.getServerId(), CrossMinPb.CrossNotifyDisMissTeamRq.EXT_FIELD_NUMBER, CrossMinPb.CrossNotifyDisMissTeamRq.ext, rq.build());
                }
            }
        }
    }
}
