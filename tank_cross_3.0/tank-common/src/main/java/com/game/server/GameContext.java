package com.game.server;

import com.game.message.pool.MessagePool;
import com.game.pb.*;
import com.game.server.config.gameServer.GameServerConfig;
import com.game.server.config.gameServer.Server;
import com.game.server.util.ChannelUtil;
import com.game.server.work.WWork;
import com.game.service.crossmin.Session;
import com.game.service.crossmin.SessionManager;
import com.game.util.LogUtil;
import com.gamerpc.grpc.server.GRpcServer;
import com.google.protobuf.ExtensionRegistry;
import io.netty.channel.ChannelHandlerContext;
import org.springframework.context.ApplicationContext;

import java.util.Date;
import java.util.HashMap;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/16 19:06
 * @description：
 */
public class GameContext {

    private static GameServerConfig gameServerConfig;
    /**
     * 个人战/跨服战
     */
    private static ConnectServer connectServer;

    /**
     * 组队副本/跨服军矿
     */
    private static CrossMinConnectServer crossMinConnectServer;
    /**
     *
     */
    private static HttpServer httpServer;
    /**
     * 组队副本/跨服军矿 grpc
     */
    private static GRpcServer rpcServer;
    private static LogicServer mainLogicServer;
    private static ApplicationContext ac;
    public static Map<Integer, Server> gameServerMaps = new HashMap<Integer, Server>();
    public static Date OPEN_DATE;
    public static Date CROSS_BEGIN_DATA;
    public static ExtensionRegistry registry = ExtensionRegistry.newInstance();
    private static MessagePool messagePool;
    public static ConcurrentHashMap<Long, ChannelHandlerContext> userChannels = new ConcurrentHashMap<>();

    public static boolean isClose = false;

    static {
        AccountPb.registerAllExtensions(GameContext.registry);
        CommonPb.registerAllExtensions(GameContext.registry);
        GamePb1.registerAllExtensions(GameContext.registry);
        GamePb2.registerAllExtensions(GameContext.registry);
        GamePb3.registerAllExtensions(GameContext.registry);
        GamePb4.registerAllExtensions(GameContext.registry);
        GamePb5.registerAllExtensions(GameContext.registry);
        InnerPb.registerAllExtensions(GameContext.registry);
        CrossGamePb.registerAllExtensions(GameContext.registry);
        CrossMinPb.registerAllExtensions(GameContext.registry);
    }

    public static HttpServer getHttpServer() {
        return httpServer;
    }

    public static void setHttpServer(HttpServer httpServer) {
        GameContext.httpServer = httpServer;
    }

    public static GameServerConfig getGameServerConfig() {
        return gameServerConfig;
    }

    public static void setGameServerConfig(GameServerConfig gameServerConfig) {
        GameContext.gameServerConfig = gameServerConfig;
    }

    public static ConnectServer getConnectServer() {
        return connectServer;
    }

    public static void setConnectServer(ConnectServer connectServer) {
        GameContext.connectServer = connectServer;
    }

    public static ApplicationContext getAc() {
        return ac;
    }

    public static void setAc(ApplicationContext ac) {
        GameContext.ac = ac;
    }

    public static MessagePool getMessagePool() {
        return messagePool;
    }

    public static void setMessagePool(MessagePool messagePool) {
        GameContext.messagePool = messagePool;
    }

    public static LogicServer getMainLogicServer() {
        return mainLogicServer;
    }

    public static void setMainLogicServer(LogicServer mainLogicServer) {
        GameContext.mainLogicServer = mainLogicServer;
    }

    public static CrossMinConnectServer getCrossMinConnectServer() {
        return crossMinConnectServer;
    }

    public static void setCrossMinConnectServer(CrossMinConnectServer crossMinConnectServer) {
        GameContext.crossMinConnectServer = crossMinConnectServer;
    }

    public static GRpcServer getRpcServer() {
        return rpcServer;
    }

    public static void setRpcServer(GRpcServer rpcServer) {
        GameContext.rpcServer = rpcServer;
    }

    public static void sendMsgToPlayer(ChannelHandlerContext ctx, BasePb.Base.Builder baseBuilder) {
        BasePb.Base msg = baseBuilder.build();
        LogUtil.s2sMessage(msg);
        connectServer.sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, msg));
    }

    public static void synMsgToPlayer(ChannelHandlerContext ctx, BasePb.Base.Builder baseBuilder) {
        BasePb.Base msg = baseBuilder.build();
        LogUtil.s2sMessage(msg);
        connectServer.sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, msg));
    }

    public static void sendMsgToGameMin(ChannelHandlerContext ctx, BasePb.Base.Builder baseBuilder) {
        BasePb.Base msg = baseBuilder.build();
        LogUtil.s2sMessage(msg);
        crossMinConnectServer.sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, msg));
    }

    public static void sendMsgToPublic(BasePb.Base.Builder baseBuilder) {
        httpServer.sendPublicMsg(baseBuilder.build());
    }
}
