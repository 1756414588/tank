package com.game.service.crossmin;

import com.game.common.ServerSetting;
import com.game.constant.GameError;
import com.game.domain.CrossPlayer;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb;
import com.game.pb.CrossMinPb;
import com.game.server.GameContext;
import com.game.server.util.ChannelUtil;
import com.game.service.teaminstance.*;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import io.netty.channel.ChannelHandlerContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.concurrent.ConcurrentHashMap;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 10:45
 * @description：跨服
 */
@Component
public class CrossMinService {

    @Autowired
    private TeamFightLogic teamFightLogic;


    /**
     * game服注册
     *
     * @param rq
     * @param handler
     */
    public void connectGameServerReg(CrossMinPb.CrossMinGameServerRegRq rq, ClientHandler handler) {
        int serverId = rq.getServerId();
        String name = rq.getServerName();
        String connectType = rq.getConnectType();

        Session session = SessionManager.getSession(serverId);
        if (session == null) {
            session = new Session();
            session.setServerId(serverId);
            session.setServerName(name);
            SessionManager.addSession(session);
        }
        if (session.getCtx() == null) {
            ChannelHandlerContext ctx = handler.getCtx();
            ChannelUtil.setServerId(ctx, serverId);
            session.setCtx(handler.getCtx());
        }

        if ("socket".equals(connectType)) {
            session.setCrossMinSocket(true);
        }

        if ("rpc".equals(connectType)) {
            session.setCrossMinRpc(true);
        }

        LogUtil.info("游戏服 serverId={},name={},connectType={} 注册成功", serverId, name, connectType);
        ServerSetting serverSetting = GameContext.getAc().getBean(ServerSetting.class);
        CrossMinPb.CrossMinGameServerRegRs.Builder builder = CrossMinPb.CrossMinGameServerRegRs.newBuilder();
        builder.setCrossServerName(serverSetting.getServerName());
        builder.setConnectType(connectType);
        builder.setCrossServerId(serverSetting.getServerID());
        handler.sendMsgToGameMin(CrossMinPb.CrossMinGameServerRegRs.ext, builder.build());


        if ("socket".equals(connectType)) {
            String crossIp = serverSetting.getCrossServerIp();
            int port = Integer.valueOf(serverSetting.getClientPort());
            int rpcPort = GameContext.getRpcServer().getPort();
            ServerListConfig serverListConfig = ServerListManager.getServerListMap().get(serverId);
            sendCrossMinNotifyRq(1, serverListConfig.getUrl(), crossIp, port, rpcPort, serverListConfig.getId(), "rpc");

        }
    }

    /**
     * 通知没有连上cross服务器的game服连
     */
    public void watchGameServerTimerLogic() {

        if (GameContext.isClose) {
            return;
        }

        ConcurrentHashMap<Integer, ServerListConfig> serverListMap = ServerListManager.getServerListMap();

        //如果有连接 但是不在列表中就中断连接
        for (Session session : SessionManager.getSessionMap()) {

            if (session.getCtx() == null) {
                SessionManager.removeSession(session);
            }

            try {
                if (!session.getCtx().channel().isActive()) {
                    SessionManager.removeSession(session);
                    session.getCtx().close();
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }

            try {
                if (!serverListMap.containsKey(session.getServerId())) {
                    session.getCtx().close();
                    SessionManager.removeSession(session);
                    LogUtil.info("关闭连接 {}", session.getServerId());
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }

        }

        ServerSetting serverSetting = GameContext.getAc().getBean(ServerSetting.class);
        String crossIp = serverSetting.getCrossServerIp();
        int port = Integer.valueOf(serverSetting.getClientPort());
        int rpcPort = GameContext.getRpcServer().getPort();

        // 判断是否在线,若不在线,通知游戏服来注册
        for (ServerListConfig server : serverListMap.values()) {
            try {

                if (System.currentTimeMillis() - server.getSendTime() < 30000) {
                    continue;
                }
                server.setSendTime(System.currentTimeMillis());
                Session session = SessionManager.getSession(server.getId());
                if (session != null && session.isCrossMinSocket()) {
                    continue;
                }

                LogUtil.info("game服未注册,发送注册请求: setverId={},url={}", server.getId(), server.getUrl());
                sendCrossMinNotifyRq(1, server.getUrl(), crossIp, port, rpcPort, server.getId(), "socket");
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }
    }

    private static void sendCrossMinNotifyRq(int type, String url, String crossIp, int port, int rpcPort, int serverId, String connectType) {
        String gameServerURL = "http://" + url;
        CrossMinPb.CrossMinNotifyRq.Builder builder = CrossMinPb.CrossMinNotifyRq.newBuilder();
        builder.setCrossIp(crossIp);
        builder.setPort(port);
        builder.setRpcPort(rpcPort);
        builder.setServerId(serverId);
        builder.setType(type);
        builder.setConnectType(connectType);
        BasePb.Base.Builder baseBuilder = BasePb.Base.newBuilder();
        baseBuilder.setCmd(CrossMinPb.CrossMinNotifyRq.EXT_FIELD_NUMBER);
        baseBuilder.setExtension(CrossMinPb.CrossMinNotifyRq.ext, builder.build());
        BasePb.Base msg = baseBuilder.build();
        GameContext.getHttpServer().sendHttpMsg(gameServerURL, msg);
    }

    /**
     * 跨服关闭通知游戏服
     */
    public static void crossClose() {
        ServerSetting serverSetting = GameContext.getAc().getBean(ServerSetting.class);
        String crossIp = serverSetting.getCrossServerIp();
        int port = Integer.valueOf(serverSetting.getClientPort());
        int rpcPort = GameContext.getRpcServer().getPort();
        // 判断是否在线,若不在线,通知游戏服来注册
        for (ServerListConfig server : ServerListManager.getServerListMap().values()) {
            try {
                Session session = SessionManager.getSession(server.getId());
                if (session == null) {
                    continue;
                }
                LogUtil.info("crossMin 跨服关闭通知游戏服: setverId={},url={}", server.getId(), server.getUrl());
                sendCrossMinNotifyRq(2, server.getUrl(), crossIp, port, rpcPort, server.getId(), "");
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }
    }


    /**
     * 心跳
     *
     * @param handler
     */
    public void crossMinHeart(CrossMinPb.CrossMinHeartRq rq, ClientHandler handler) {
        LogUtil.crossInfo("crossMin 跨服组队收到心跳  serverId={},serverName={}", rq.getServerId(), rq.getServerName());
        CrossMinPb.CrossMinHeartRs.Builder builder = CrossMinPb.CrossMinHeartRs.newBuilder();
        ServerSetting serverSetting = GameContext.getAc().getBean(ServerSetting.class);
        builder.setCrossServerName(serverSetting.getServerName());
        builder.setCrossServerId(serverSetting.getServerID());
        BasePb.Base.Builder msg = PbHelper.createSynBase(CrossMinPb.CrossMinHeartRs.EXT_FIELD_NUMBER, CrossMinPb.CrossMinHeartRs.ext, builder.build());
        handler.sendMsgToGameMin(msg);
    }


    /**
     * 战斗
     *
     * @param roleId
     * @param handler
     */
    public void fight(long roleId, ClientHandler handler) {
        CrossMinPb.CrossFightRs.Builder builder = CrossMinPb.CrossFightRs.newBuilder();
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        builder.setRoleId(roleId);
        if (player == null) {
            handler.sendMsgToGameMin(GameError.TEAM_NOT_HAVE, CrossMinPb.CrossFightRs.ext, builder.build());
            return;
        }
        Team team = TeamManager.getTeamByRoleId(roleId);
        if (!checkTeamStatus(team)) {
            handler.sendMsgToGameMin(GameError.NO_TEAMS_TO_JOIN, CrossMinPb.CrossFightRs.ext, builder.build());
            return;
        }
        if (roleId != team.getCaptainId()) {
            handler.sendMsgToGameMin(GameError.TEAM_RIGHT_LIMIT, CrossMinPb.CrossFightRs.ext, builder.build());
            return;
        }
        if (team.getMembersInfo().size() < TeamConstant.TEAM_LIMIT) {
            handler.sendMsgToGameMin(GameError.TEAM_MEMBER_NOT_ENOUGH, CrossMinPb.CrossFightRs.ext, builder.build());
            return;
        }
        if (team.getStatus() != TeamConstant.READY) {
            handler.sendMsgToGameMin(GameError.TEAM_UNREADY, CrossMinPb.CrossFightRs.ext, builder.build());
            return;
        }
        handler.sendMsgToGameMin(GameError.OK, CrossMinPb.CrossFightRs.ext, builder.build());
        teamFightLogic.fight(team);
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
     * 跨服队伍聊天
     * @return
     */
    public synchronized void teamChat(CrossMinPb.CrossTeamChatRq rq) {
        long roleId = rq.getRoleId();
        String message = rq.getMessage();
        long time = rq.getTime();
        CrossTeamProto.CrossTeamChatResponse.Builder builder = CrossTeamProto.CrossTeamChatResponse.newBuilder();
        CrossPlayer player = CrossPlayerCacheLoader.get(roleId);
        if (player == null) {
        }
        if (TeamManager.getTeamByRoleId(roleId) == null) {
        }
        String serverName = "";
        Session session = SessionManager.getSession(player.getServerId());
        if (session != null) {
            serverName = session.getServerName();
        }
        synTeamChat(player.getNick(), roleId, time, message, serverName);
        builder.setCode(GameError.OK.getCode());
        builder.setTime(time);
    }

    /**
     * 同步队伍聊天信息
     *
     * @param roleId  讲话者ID
     * @param time    聊天发起时间
     * @param message 聊天信息
     */
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
}
