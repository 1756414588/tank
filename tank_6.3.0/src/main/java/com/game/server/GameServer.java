package com.game.server;

import com.game.common.FilterCmd;
import com.game.common.ServerSetting;
import com.game.common.TankException;
import com.game.domain.GameGlobal;
import com.game.domain.Player;
import com.game.manager.GlobalDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.DealType;
import com.game.message.pool.MessagePool;
import com.game.pb.*;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.NotifyCrossOnLineRq;
import com.game.server.rpc.pool.GRpcPool;
import com.game.server.rpc.pool.GRpcPoolManager;
import com.game.server.util.ChannelUtil;
import com.game.server.work.WWork;
import com.game.service.PlayerLogOutService;
import com.game.util.*;
import com.google.protobuf.ExtensionRegistry;
import io.netty.channel.ChannelHandlerContext;
import org.springframework.beans.BeansException;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;

import java.lang.Thread.UncaughtExceptionHandler;
import java.lang.management.ManagementFactory;
import java.net.URL;
import java.util.Date;
import java.util.concurrent.ConcurrentHashMap;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/5/22 10:24
 * @Description :游戏中各种服务 start
 */
public class GameServer extends Server {
    /**
     * 服务器启动时间
     */
    private static long serverStartTime = System.currentTimeMillis();

    public ConnectServer connectServer;
    public HttpServer httpServer;
    public InnerServer innerServer;
    public CrossMinInnerServer crossMinInnerServer;
    public LogicServer mainLogicServer;
    public SavePlayerServer savePlayerServer;
    public SavePartyServer savePartyServer;
    public SaveExtremeServer saveExtremeServer;
    public SaveGlobalServer saveGlobalServer;
    public SaveUsualActivityServer saveActivityServer;
    public SaveGuyServer saveGuyServer;


    /**   游戏中各种服务 end   */

    /**
     * 跨服战开始时间
     */
    public String crossBeginTime = "";

    /**
     * 0默认 1跨服争霸 2跨服军团
     */
    public int crossType = 0; // 

    /**
     * 记录游戏进程启动是否成功，用于启动失败退出时，跳过数据保存
     */
    public boolean startSuccess = true;//
    /**
     * 记录游戏是否开始关闭
     */
    public boolean isStop = false;//


    /**
     * 开服时间
     */
    public final Date OPEN_DATE = DateHelper.parseDate(GameServer.ac.getBean(ServerSetting.class).getOpenTime());


    //false - 服务器维护中
    public static boolean MAINTE_SERVER_OPEN = true;

    /**
     * 注册protobuff的协议
     */
    static public ExtensionRegistry registry = ExtensionRegistry.newInstance();

    static {
        AccountPb.registerAllExtensions(registry);
        CommonPb.registerAllExtensions(registry);
        GamePb1.registerAllExtensions(registry);
        GamePb2.registerAllExtensions(registry);
        GamePb3.registerAllExtensions(registry);
        GamePb4.registerAllExtensions(registry);
        GamePb5.registerAllExtensions(registry);
        GamePb6.registerAllExtensions(registry);
        InnerPb.registerAllExtensions(registry);
        CrossGamePb.registerAllExtensions(registry);
        CrossMinPb.registerAllExtensions(registry);
    }

    public static long getServerStartTime() {
        return serverStartTime;
    }

    public static ApplicationContext ac = new ClassPathXmlApplicationContext("applicationContext.xml");

    public MessagePool messagePool = new MessagePool();

    public ConcurrentHashMap<Long, ChannelHandlerContext> userChannels = new ConcurrentHashMap<>();


    /**
     * 单例处理
     */
    private GameServer() {
        super("GameServer");
    }

    private static GameServer gameServer;

    public static GameServer getInstance() {
        if (gameServer == null) {
            gameServer = new GameServer();
        }
        return gameServer;
    }

    /**
     * @param ctx         消息连接上下文
     * @param baseBuilder 协议消息内容（protobuf协议）
     *                    void
     * @Title: sendMsgToPlayer
     * @Description: 向客户端发送协议 使用connectServer
     */
    public void sendMsgToPlayer(ChannelHandlerContext ctx, Base.Builder baseBuilder) {
        Base msg = baseBuilder.build();


        if (!FilterCmd.inOutFilterPrint(msg.getCmd())) {
            LogUtil.c2sMessage(msg, ChannelUtil.getRoleId(ctx));
        }
        connectServer.sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, msg));
    }

    /**
     * @param ctx         消息连接上下文
     * @param baseBuilder 消息内容（protobuf协议）
     *                    void
     * @Title: synMsgToPlayer
     * @Description: 同步数据到客户端 使用connectServer
     */
    public void synMsgToPlayer(ChannelHandlerContext ctx, Base.Builder baseBuilder) {

        Base msg = baseBuilder.build();
        if (ctx != null) {
            int cmd = msg.getCmd();
            if (!FilterCmd.inOutFilterPrint(cmd)) {
                LogUtil.c2sMessage(msg, ChannelUtil.getRoleId(ctx));
            }
            connectServer.sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, msg));
        } else {
            LogUtil.c2sMessage(msg, 0L);
        }

    }

    /**
     * @param baseBuilder 消息内容（protobuf协议）
     *                    void
     * @Title: sendMsgToPublic
     * @Description: 发送消息到账号服务器   使用httpServer
     */
    public void sendMsgToPublic(Base.Builder baseBuilder) {
        // publicConnectServer.sendPublicMsg(baseBuilder.build());
        httpServer.sendPublicMsg(baseBuilder.build());
    }

    /**
     * @param baseBuilder 消息内容（protobuf协议）
     * @param serverId    服务器编号
     *                    void
     * @Title: sendMsgToPublic
     * @Description: 发送消息到账号服务器   使用httpServer
     */
    public void sendMsgToPublic(Base.Builder baseBuilder, int serverId) {
        httpServer.sendPublicMsg(baseBuilder.build(), serverId);
    }


    /**
     * @author
     * @ClassName: GameUncaughtExceptionHandler
     * @Description: 各服务业务的异常处理
     */
    private class GameUncaughtExceptionHandler implements UncaughtExceptionHandler {

        /**
         * <p>Title: uncaughtException</p>
         * <p>Description:  重要线程启动失败，记录日志并立即退出</p>
         *
         * @param t
         * @param e
         * @see java.lang.Thread.UncaughtExceptionHandler#uncaughtException(java.lang.Thread, java.lang.Throwable)
         */
        @Override
        public void uncaughtException(Thread t, Throwable e) {
            LogUtil.error("GameUncaughtExceptionHandler uncaughtException", e);

            GameServer.getInstance().startSuccess = false;
            System.exit(1);// 重要线程启动失败，立即退出
        }

    }

    /**
     * @param runnable void
     * @Title: startServerThread
     * @Description: 启动某一服务业务
     */
    private void startServerThread(Runnable runnable) {
        Thread thread = new Thread(runnable);
        thread.setUncaughtExceptionHandler(new GameUncaughtExceptionHandler());
        thread.start();
    }

    /**
     * <p>Title: run</p>
     * <p>Description: run方法   此方法会:
     * 1.  此方法会加载游戏各种数据，兵进行处理
     * 2. 启动服务器业务线程
     * 3. 启动定时打印connectServer状态的timer
     * 4. 向账号服务器发送游戏服器开启状态
     *
     * @see com.game.server.Server#run()
     */
    @Override
    public void run() {
        super.addHook();
        // 加载数据
        try {
            GameDataLoader.getIns().loadGameData();
        } catch (TankException e) {
            LogUtil.error("数据加载失败，退出", e);
            return;
        }
        // 处理数据
        try {
            GameDataManager.getIns().dataHandle();
        } catch (TankException e) {
            LogUtil.error("数据修复出错，退出", e);
            return;
        }

        LogUtil.start("数据加载完成，开始启动服务器业务线程");

        connectServer = new ConnectServer();
        httpServer = new HttpServer(this);
        mainLogicServer = new LogicServer(ac.getBean(ServerSetting.class).getServerName(), 500);
        savePlayerServer = new SavePlayerServer();
        savePartyServer = new SavePartyServer();
        saveExtremeServer = new SaveExtremeServer();
        saveGlobalServer = new SaveGlobalServer();
        saveActivityServer = new SaveUsualActivityServer();
        saveGuyServer = new SaveGuyServer();

        startServerThread(connectServer);
        startServerThread(httpServer);
        startServerThread(mainLogicServer);

        startServerThread(savePlayerServer);
        startServerThread(savePartyServer);
        startServerThread(saveExtremeServer);
        startServerThread(saveGlobalServer);
        startServerThread(saveActivityServer);
        startServerThread(saveGuyServer);

        httpServer.registerGameToPublic();
        LogUtil.start("GameServer " + GameServer.ac.getBean(ServerSetting.class).getServerName() + " Started");
    }

    private boolean allSaveDone() {
        if (savePlayerServer.saveDone() && savePartyServer.saveDone() && saveExtremeServer.saveDone()
                && saveGlobalServer.saveDone() && saveActivityServer.saveDone() && saveGuyServer.saveDone()) {
            return true;
        }

        return false;
    }

    /**
     * <p>Title: stop</p>
     * <p>Description: 停止服务器 ，此方法会
     * 1. 停服前需要处理的游戏逻辑
     * 2. 保存所有服务业务线程的数据并停止它 </p>
     *
     * @see com.game.server.Server#stop()
     */
    @Override
    protected void stop() {
        try {

            isStop = true;

            long time = System.currentTimeMillis();

            try {
                if (mainLogicServer != null) {
                    mainLogicServer.stop();
                }
            } catch (Exception e) {
                LogUtil.error("关闭mainLogic", e);
            }

            try {
                if (innerServer != null) {
                    innerServer.stop();
                }
                if (crossMinInnerServer != null) {
                    crossMinInnerServer.stop();
                }
            } catch (Exception e) {
                LogUtil.error("关闭连接", e);
            }

            if (mainLogicServer != null) {
                while (!mainLogicServer.isStopped()) {
                    Thread.sleep(500);
                }
            }

            try {
                GRpcPool rpcPool = GRpcPoolManager.getRpcPool();
                if (rpcPool != null) {
                    rpcPool.destroy();
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }

            if (!startSuccess) {
                LogUtil.error("启动异常，不保存数据，直接退出");
                return;
            }


            stopLogic();

            if (savePlayerServer != null) {
                savePlayerServer.setLogFlag();
                savePlayerServer.saveAllPlayer();
                savePlayerServer.stop();
            }

            if (savePartyServer != null) {
                savePartyServer.setLogFlag();
                savePartyServer.saveAllParty();
                savePartyServer.stop();
            }

            if (saveExtremeServer != null) {
                saveExtremeServer.setLogFlag();
                saveExtremeServer.saveAllExtreme();
                saveExtremeServer.stop();
            }

            if (saveGlobalServer != null) {
                saveGlobalServer.setLogFlag();
                saveGlobalServer.saveAllGlobal();
                saveGlobalServer.stop();
            }

            if (saveActivityServer != null) {
                saveActivityServer.setLogFlag();
                saveActivityServer.saveAllActivity();
                saveActivityServer.stop();
            }

            if (saveGuyServer != null) {
                saveGuyServer.setLogFlag();
                saveGuyServer.saveAllGuy();
                saveGuyServer.stop();
            }


            int sleepTime = 0;
            while (!(sleepTime > 5 * 60 * 1000 || allSaveDone())) {
                Thread.sleep(1000);
                sleepTime += 1000;
            }


            LogUtil.stop("save {} has done with save :{}", savePlayerServer.serverName(), savePlayerServer.allSaveCount());
            LogUtil.stop("save {} has done with save :{}", savePartyServer.serverName(), savePartyServer.allSaveCount());
            LogUtil.stop("save {} has done with save :{}", saveExtremeServer.serverName(), saveExtremeServer.allSaveCount());
            LogUtil.stop("save {} has done with save :{}", saveGlobalServer.serverName(), saveGlobalServer.allSaveCount());
            LogUtil.stop("save {} has done with save :{}", saveActivityServer.serverName(), saveActivityServer.allSaveCount());
            LogUtil.stop("save {} has done with save :{}", saveGuyServer.serverName(), saveGuyServer.allSaveCount());

            URL location = getClass().getProtectionDomain().getCodeSource().getLocation();
            String runname = ManagementFactory.getRuntimeMXBean().getName();
            String pid = runname.substring(0, runname.indexOf("@"));

            LogUtil.stop("关闭服务器耗时 {} s", (System.currentTimeMillis() - time) / 1000);

            if (allSaveDone()) {
                LogUtil.stop("GameServer--> {}|{}|{}| all saved!", location, runname, pid);
            } else {
                LogUtil.stop("GameServer--> {}|{}|{}| part saved!", location, runname, pid);
            }

        } catch (Exception e) {
            LogUtil.error("服务器停服异常", e);
        }
    }

    /**
     * @Title: stopLogic
     * @Description: 停服前需要处理的游戏逻辑
     * void
     */
    private void stopLogic() {
        try {
            int now = TimeHelper.getCurrentSecond();
            GameGlobal global = ac.getBean(GlobalDataManager.class).gameGlobal;
            global.setGameStopTime(now);
        } catch (Exception e) {
            LogUtil.error("stopLogic error", e);
        }
    }

    /**
     * @param ctx
     * @param roleId void
     * @Title: registerRoleChannel
     * @Description: 将消息连接上下文和游戏角色编号一对一绑定到一起
     */
    public void registerRoleChannel(ChannelHandlerContext ctx, long roleId) {
        LogUtil.channel(roleId + " login!");
        ChannelUtil.setRoleId(ctx, roleId);
}

    /**
     * @param closeCtx 关闭的连接上下文
     * @param roleId   玩家编号
     *                 void
     * @Title: playerExit
     * @Description: 玩家关闭游戏时调用此方法
     */
    public void playerExit(ChannelHandlerContext closeCtx, final long roleId) {
        final PlayerDataManager playerDataManager = ac.getBean(PlayerDataManager.class);
        Player player = playerDataManager.getPlayer(roleId);
        if (player == null) {
            return;
        }

        if (player.ctx != null && player.ctx != closeCtx) {// 重复登录
            player.immediateSave = true;
            logOut(roleId);
            return;
        }

        playerDataManager.removeOnline(player);
        player.logOut();

        logOut(roleId);
    }


    private void logOut(final long roleId) {
        try {
            GameServer.getInstance().mainLogicServer.addCommand(new ICommand() {
                @Override
                public void action() {
                    ac.getBean(PlayerLogOutService.class).logOut(roleId);
                }
            }, DealType.MAIN);
        } catch (BeansException e) {
            LogUtil.error(e);
        }
    }

    /**
     * <p>Title: getGameType</p>
     * <p>Description: 该业务服务器名</p>
     *
     * @return
     * @see com.game.server.Server#getGameType()
     */
    @Override
    String getGameType() {
        return "game";
    }

    /**
     * @param rq void
     * @Title: registerToCross
     * @Description: 在跨服战中注册
     */
    public void registerToCross(NotifyCrossOnLineRq rq) {
        if (innerServer == null) {
            innerServer = new InnerServer(rq.getCrossIp(), rq.getPort());
            startServerThread(innerServer);
            this.crossBeginTime = rq.getBeginTime();
            this.crossType = rq.getCrossType();
        } else {
            innerServer.stop();
            innerServer = null;
            innerServer = new InnerServer(rq.getCrossIp(), rq.getPort());
            startServerThread(innerServer);
            this.crossBeginTime = rq.getBeginTime();
            this.crossType = rq.getCrossType();
        }
    }

    /**
     * 关闭跨服入口
     */
    public void closeCross() {
        if (innerServer != null) {
            innerServer.stop();
            innerServer = null;
        }
        this.crossBeginTime = "";
        this.crossType = 0;
    }

    /**
     * @param baseBuilder 消息内容（protobuf协议）
     *                    void
     * @Title: sendMsgToCross
     * @Description: 发消息到跨服战服务器
     */
    public void sendMsgToCross(Base.Builder baseBuilder) {
        if (innerServer != null && innerServer.innerCtx != null && innerServer.innerCtx.channel().isActive()) {
            Base msg = baseBuilder.build();
            int cmd = msg.getCmd();
            if (!FilterCmd.inOutFilterPrint(cmd)) {
                LogUtil.s2sMessage(msg);
            }
            innerServer.sendExcutor.addTask(ChannelUtil.getChannelId(innerServer.innerCtx), new WWork(innerServer.innerCtx, msg));
        }
    }


    /**
     * @param rq void
     * @Title: registerToCross
     * @Description: 在组队跨服战中注册
     */
    public void registerToCrossMin(CrossMinPb.CrossMinNotifyRq rq) {
        if (crossMinInnerServer == null) {
            crossMinInnerServer = new CrossMinInnerServer(rq.getCrossIp(), rq.getPort());
            startServerThread(crossMinInnerServer);
        } else {
            crossMinInnerServer.stop();
            crossMinInnerServer = null;
            crossMinInnerServer = new CrossMinInnerServer(rq.getCrossIp(), rq.getPort());
            startServerThread(crossMinInnerServer);
        }
    }

    /**
     * 关闭组队跨服入口
     */
    public void closeCrossMin() {
        if (crossMinInnerServer != null) {
            crossMinInnerServer.stop();
            crossMinInnerServer = null;
        }
    }

    public void sendMsgToCrossMin(Base.Builder baseBuilder) {
        if (crossMinInnerServer != null && crossMinInnerServer.innerCtx != null && crossMinInnerServer.innerCtx.channel().isActive()) {
            Base msg = baseBuilder.build();

            int cmd = msg.getCmd();
            if (!FilterCmd.inOutFilterPrint(cmd)) {
                LogUtil.s2sMessage(msg);
            }
            Long channelId = ChannelUtil.getChannelId(crossMinInnerServer.innerCtx);
            if (channelId == null) {
                channelId = 1L;
            }
            crossMinInnerServer.sendExcutor.addTask(channelId, new WWork(crossMinInnerServer.innerCtx, msg));
        }
    }


}
