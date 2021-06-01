package com.game.service.crossmin;

import com.game.chat.domain.Chat;
import com.game.common.ServerSetting;
import com.game.constant.GameError;
import com.game.constant.SysChatId;
import com.game.domain.Player;
import com.game.manager.ChatDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.InnerHandler;
import com.game.message.handler.crossmin.*;
import com.game.pb.*;
import com.game.server.CrossMinContext;
import com.game.server.GameServer;
import com.game.server.rpc.pool.GRpcClientPoolConfig;
import com.game.server.rpc.pool.GRpcConnectionFactory;
import com.game.server.rpc.pool.GRpcPool;
import com.game.server.rpc.pool.GRpcPoolManager;
import com.game.service.ChatService;
import com.game.service.teaminstance.TeamInstanceService;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Collection;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 16:11
 * @description：
 */
@Component
public class CrossMinService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private ChatService chatService;

    @Autowired
    TeamInstanceService teamInstanceService;

    @Autowired
    private ChatDataManager chatDataManager;

    /**
     * 发送注册消息到cross服务器
     */
    public static void sendGameServerRegMsgToCrossServer(String connectType) {
        CrossMinPb.CrossMinGameServerRegRq.Builder builder = CrossMinPb.CrossMinGameServerRegRq.newBuilder();
        builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
        builder.setServerName(GameServer.ac.getBean(ServerSetting.class).getServerName());
        builder.setConnectType(connectType);
        BasePb.Base.Builder baseBuilder = PbHelper.createRqBase(CrossMinPb.CrossMinGameServerRegRq.EXT_FIELD_NUMBER, null, CrossMinPb.CrossMinGameServerRegRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCrossMin(baseBuilder);

    }


    /**
     * 创建连接
     *
     * @param rq
     */
    public void crossMinNotifyRq(CrossMinPb.CrossMinNotifyRq rq) {

        if (GameServer.getInstance().isStop) {
            LogUtil.crossInfo("游戏服正在关闭中..拒绝连接跨服 crossmin");
            return;
        }

        int type = rq.getType();
        String crossIp = rq.getCrossIp();
        int rpcPort = rq.getRpcPort();
        int serverId = rq.getServerId();
        int port = rq.getPort();
        String connectType = rq.getConnectType();

        LogUtil.crossInfo("crossMin 注册信息 type={},crossIp={},port={},rpcPort={},serverId={},connectType={}", type, crossIp, port, rpcPort, serverId, connectType);


        //创建连接
        if (type == 1) {

            if (GameServer.ac.getBean(ServerSetting.class).getServerID() != serverId) {
                LogUtil.error("crossMin 注册信息错误配置文件中serverId为 {} 与本服的serverId {} 不一致,不注册", serverId, GameServer.ac.getBean(ServerSetting.class).getServerID());
                return;
            }
            //连接socket
            if ("socket".equals(connectType)) {
                LogUtil.crossInfo("crossMin 创建socket");
                CrossMinContext.setCrossMinSocket(false);
                //socket
                GameServer.getInstance().registerToCrossMin(rq);
                CrossMinService.hertRequestTime = System.currentTimeMillis();
                LogUtil.info("crossMin min socket create success");
            }

            if ("rpc".equals(connectType)) {
                //rpc
                LogUtil.crossInfo("crossMin rpc 创建socket");
                CrossMinContext.setCrossMinRpc(false);
                GRpcPool pool = GRpcPoolManager.getRpcPool();
                if (pool != null) {
                    pool.destroy();
                }

                GRpcClientPoolConfig rpcClientPoolConfig = new GRpcClientPoolConfig();
                GRpcConnectionFactory rpcConnectionFactory = new GRpcConnectionFactory(crossIp, rpcPort, 2, "rpc-client-");
                GRpcPool rpcPool = new GRpcPool(rpcClientPoolConfig, rpcConnectionFactory);
                GRpcPoolManager.setRpcPool(rpcPool);
                CrossMinService.sendGameServerRegMsgToCrossServer("rpc");
            }

        }


        if (type == 2) {

            try {
                LogUtil.crossInfo("crossMin 关闭 crossMin socket");
                CrossMinContext.setCrossMinSocket(false);
                GameServer.getInstance().closeCrossMin();
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                LogUtil.crossInfo("crossMin 关闭 crossMin rpc");
                CrossMinContext.setCrossMinRpc(false);
                GRpcPool rpcPool = GRpcPoolManager.getRpcPool();
                if (rpcPool != null) {
                    rpcPool.destroy();
                }
                GRpcPoolManager.setRpcPool(null);
            } catch (Exception e) {
                LogUtil.error(e);
            }

        }

    }

    private long hertTime = 0L;
    /**
     * 心跳返回时间
     */
    public static long hertRequestTime = 0L;

    /**
     * 心跳
     */
    public void crossMinheartRq() {

        long currentTime = System.currentTimeMillis();
        if (Math.abs(currentTime - hertTime) > 40000) {
            hertTime = currentTime;

            if (!isCrossMinAive()) {

                if (GameServer.getInstance().crossMinInnerServer != null && (GameServer.getInstance().crossMinInnerServer.innerCtx != null)) {
                    LogUtil.crossInfo("crossMin 连接已经失效，现在关闭跨服连接 ");
                    GameServer.getInstance().closeCrossMin();
                    CrossMinContext.setCrossMinRpc(false);
                    CrossMinContext.setCrossMinSocket(false);
                    GRpcPool rpcPool = GRpcPoolManager.getRpcPool();
                    if (rpcPool != null) {
                        rpcPool.destroy();
                    }
                    GRpcPoolManager.setRpcPool(null);
                }
                return;
            }

            if (hertRequestTime == 0) {
                hertRequestTime = System.currentTimeMillis();
            }
            //说明跨服没有回复心跳 说明跨服死了
            long ltime = System.currentTimeMillis() - hertRequestTime;
            if (Math.abs(ltime) > 180000) {
                hertRequestTime = System.currentTimeMillis();
                LogUtil.crossInfo("crossMin 跨服已经有3分钟时间没有回复心跳 {}  s", (ltime / 1000));

                CrossMinContext.setCrossMinRpc(false);
                CrossMinContext.setCrossMinSocket(false);
                GameServer.getInstance().closeCrossMin();
                GRpcPool rpcPool = GRpcPoolManager.getRpcPool();
                if (rpcPool != null) {
                    rpcPool.destroy();
                }
                GRpcPoolManager.setRpcPool(null);
                LogUtil.crossInfo("crossMin 跨服已经很久没有回复心跳了 自动关闭跨服入口");
                return;
            }
            LogUtil.crossInfo("crossMin 向crossMin 跨服发送心跳");
            CrossMinPb.CrossMinHeartRq.Builder builder = CrossMinPb.CrossMinHeartRq.newBuilder();
            ServerSetting serverSetting = GameServer.ac.getBean(ServerSetting.class);
            builder.setServerId(serverSetting.getServerID());
            builder.setServerName(serverSetting.getServerName());
            BasePb.Base.Builder baseBuilder = PbHelper.createRqBase(CrossMinPb.CrossMinHeartRq.EXT_FIELD_NUMBER, null, CrossMinPb.CrossMinHeartRq.ext, builder.build());
            GameServer.getInstance().sendMsgToCrossMin(baseBuilder);
        }
    }

    /**
     * 是否和跨服服连接状态
     *
     * @return boolean
     */
    private boolean isCrossMinAive() {
        return GameServer.getInstance().crossMinInnerServer != null && (GameServer.getInstance().crossMinInnerServer.innerCtx != null) && (GameServer.getInstance().crossMinInnerServer.innerCtx.channel().isActive());
    }

    /**
     * 跨服通知游戏服玩家队伍解散
     *
     * @param request
     */
    public void crossDisMissTeam(CrossNotifyDisMissTeamHandler handler, CrossMinPb.CrossNotifyDisMissTeamRq request) {
        long roleId = request.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }
        GamePb6.SynNotifyDisMissTeamRq.Builder builder = GamePb6.SynNotifyDisMissTeamRq.newBuilder();
        handler.sendMsgToPlayer(player, GamePb6.SynNotifyDisMissTeamRq.ext, GamePb6.SynNotifyDisMissTeamRq.EXT_FIELD_NUMBER, builder.build());

    }

    /**
     * 跨服通知游戏服玩家寻找队伍加入
     *
     * @param request
     */
    public void crossFindTeam(CrossFindTeamHandler handler, CrossMinPb.CrossSynTeamInfoRq request) {
        long roleId = request.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }
        GamePb6.SynTeamInfoRq.Builder builder = GamePb6.SynTeamInfoRq.newBuilder();
        builder.setTeamId(request.getTeamId());
        builder.setCaptainId(request.getCaptainId());
        builder.setTeamType(request.getTeamType());
        // 定义是什么操作类型导致队伍信息的更新，参见TeamConstant
        builder.setActionType(request.getActionType());
        for (Long order : request.getOrderList()) {
            builder.addOrder(order);
        }
        for (CommonPb.TeamRoleInfo roleInfo : request.getTeamInfoList()) {
            builder.addTeamInfo(roleInfo);
        }
        handler.sendMsgToPlayer(player, GamePb6.SynTeamInfoRq.ext, GamePb6.SynTeamInfoRq.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 通知被踢出队伍的玩家
     *
     * @param request
     */
    public void crossKickTeam(CrossKickTeamHandler handler, CrossMinPb.CrossSynNotifyKickOutRq request) {
        long roleId = request.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }
        GamePb6.SynNotifyKickOutRq.Builder builder = GamePb6.SynNotifyKickOutRq.newBuilder();
        handler.sendMsgToPlayer(player, GamePb6.SynNotifyKickOutRq.ext, GamePb6.SynNotifyKickOutRq.EXT_FIELD_NUMBER, builder.build());

    }

    /**
     * 通知玩家状态改变
     *
     * @param handler
     * @param request
     */
    public void crossChangeMemberStatus(CrossChangeMemberStatusHandler handler, CrossMinPb.CrossSynChangeStatusRq request) {
        long roleId = request.getRole();
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }
        GamePb6.SynChangeStatusRq.Builder builder = GamePb6.SynChangeStatusRq.newBuilder();
        builder.setRoleId(request.getRoleId());
        builder.setStatus(request.getStatus());
        handler.sendMsgToPlayer(player, GamePb6.SynChangeStatusRq.ext, GamePb6.SynChangeStatusRq.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 通知玩家聊天
     *
     * @param handler
     * @param request
     */
    public void crossTeamChat(CrossTeamChatHandler handler, CrossMinPb.CrossSynTeamChatRq request) {
        long roleId = request.getRole();
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }
        GamePb6.SynTeamChatRq.Builder builder = GamePb6.SynTeamChatRq.newBuilder();
        builder.setRoleId(request.getRoleId());
        builder.setMessage(request.getMessage());
        builder.setTime(request.getTime());
        builder.setName(request.getName());
        builder.setServerName(request.getServerName());
        handler.sendMsgToPlayer(player, GamePb6.SynTeamChatRq.ext, GamePb6.SynTeamChatRq.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 世界频道消息(队伍邀请消息)
     *
     * @param request
     */
    public void crossTeamInvite(CrossMinPb.CrossSynTeamInviteRq request) {
        chatService.sendWorldChat(chatService.createTeamInviteChat(SysChatId.BOUNTY_TEAM_INVITE, request.getTeamId(), request.getNickName(), request.getParam()), null, Chat.CROSSTEAM_CHANNEL);
    }

    /**
     * 通知队伍解散
     *
     * @param Handler
     */
    public void disTeam(CrossDisInvalidTeamHandler Handler, CrossMinPb.CrossSynStageCloseToTeamRq req) {
        Player player = playerDataManager.getPlayer(req.getRoldId());
        if (player == null) {
            return;
        }
        GamePb6.SynStageCloseToTeamRq.Builder builder = GamePb6.SynStageCloseToTeamRq.newBuilder();
        Handler.sendMsgToPlayer(player, GamePb6.SynStageCloseToTeamRq.ext, GamePb6.SynStageCloseToTeamRq.EXT_FIELD_NUMBER, builder.build());
    }

    /**
     * 任务
     *
     * @param request
     */
    public void crossTask(CrossMinPb.CrossSynTaskRq request) {
        long roleId = request.getRoleId();
        Player player = playerDataManager.getPlayer(roleId);
        teamInstanceService.changeTask(player, request.getTaskType(), request.getComNum());
    }

    /**
     * 发送战斗战报
     *
     * @param request
     */
    public void crossRecord(CrossFightRecordHandler Handler, CrossMinPb.CrossSyncTeamFightBossRq request) {
        Player player = playerDataManager.getPlayer(request.getRoleId());
        if (player == null) {
            return;
        }
        GamePb6.SyncTeamFightBossRq.Builder builder = GamePb6.SyncTeamFightBossRq.newBuilder();
        builder.setTankCount(request.getTankCount());
        for (CommonPb.Record record : request.getRecordList()) {
            builder.addRecord(record);
        }
        for (CommonPb.TwoLong twoLong : request.getRecordLordList()) {
            builder.addRecordLord(twoLong);
        }
        teamInstanceService.succFight(player, builder, request.getStageId(), request.getIsSuccess());
        Handler.sendMsgToPlayer(player, GamePb6.SyncTeamFightBossRq.ext, GamePb6.SyncTeamFightBossRq.EXT_FIELD_NUMBER, builder.build());

    }

    /**
     * 向全服发送跨服组队聊天(跨服聊天)
     *
     * @param request
     */
    public void crossWoldChat(CrossMinPb.CrossWorldChatRq request) {
        CommonPb.Chat.Builder chat = CommonPb.Chat.newBuilder();
        chat.setChannel(Chat.CROSSTEAM_CHANNEL);
        chat.setMsg(request.getContent());
        chat.setTime(request.getTime());
        chat.setName(request.getNickName());
        chat.setPortrait(request.getPort());
        chat.setBubble(request.getBubble());
        chat.setIsGm(request.getIsGm());
        chat.setStaffing(request.getStaffing());
        chat.setMilitaryRank(request.getMilitary());
        chat.setVip(request.getVip());
        chat.setRoleId(request.getRoleId());

        CommonPb.crossChatPlayerInfo.Builder playerInfo = CommonPb.crossChatPlayerInfo.newBuilder();
        playerInfo.setFight(request.getFight());
        playerInfo.setPartyName(request.getPartyName());
        playerInfo.setServerName(request.getServerName());
        playerInfo.setLevel(request.getLv());
        chat.setCrossPlayInfo(playerInfo);

        chatDataManager.addCrossChat(chat.build());
        Collection<Player> values = playerDataManager.getAllOnlinePlayer().values();
        GamePb2.SynChatRq.Builder builder = GamePb2.SynChatRq.newBuilder();
        builder.setChat(chat);
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb2.SynChatRq.EXT_FIELD_NUMBER, GamePb2.SynChatRq.ext, builder.build());
        for (Player player : values) {
            if (player.ctx != null && player.isLogin) {
                GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            }
        }
    }

    /**
     * 跨服战斗给发起战斗人返回
     *
     * @param msg
     * @param handler
     */
    public void crossFight(BasePb.Base msg, InnerHandler handler) {
        CrossMinPb.CrossFightRs re = msg.getExtension(CrossMinPb.CrossFightRs.ext);
        Player player = playerDataManager.getPlayer(re.getRoleId());
        if (player == null) {
            return;
        }
        if (msg.getCode() == GameError.OK.getCode()) {
            BasePb.Base.Builder baseBuilder = PbHelper.createRsBase(GameError.OK, GamePb6.TeamFightBossRs.EXT_FIELD_NUMBER, GamePb6.TeamFightBossRs.ext, GamePb6.TeamFightBossRs.newBuilder().build());
            if (player.ctx != null) {
                handler.sendMsgToPlayer(player, baseBuilder);
            }
            return;
        }
        //BasePb.Base message = PbHelper.createRsBase(GamePb6.TeamFightBossRs.EXT_FIELD_NUMBER, msg.getCode());
        BasePb.Base.Builder builder = msg.toBuilder();
        builder.setCmd(GamePb6.TeamFightBossRs.EXT_FIELD_NUMBER);
        handler.sendMsgToPlayer(player, builder);
    }
}
