package com.game.crossminserver.server;

import com.game.common.ServerConfig;
import com.game.common.ServerSetting;
import com.game.manager.cross.seniormine.CrossMineDataManager;
import com.game.message.pool.MessagePool;
import com.game.server.CrossMinConnectServer;
import com.game.server.GameContext;
import com.game.server.HttpServer;
import com.game.server.LogicServer;
import com.game.server.config.ServerConfigXmlLoader;
import com.game.server.config.gameServer.GameServerConfig;
import com.game.server.config.gameServer.Server;
import com.game.service.LoadService;
import com.game.service.crossmin.CrossMinService;
import com.game.service.teaminstance.CrossTeamService;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
import com.game.util.StringUtil;
import com.gamemysql.core.entity.DataRepository;
import com.gamerpc.grpc.server.GRpcServer;
import com.google.common.base.Stopwatch;
import com.google.common.util.concurrent.AbstractIdleService;
import io.grpc.BindableService;
import org.springframework.context.ApplicationContext;
import org.springframework.context.support.ClassPathXmlApplicationContext;
import org.springframework.core.io.FileSystemResource;

import java.io.FileInputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.util.List;
import java.util.Timer;
import java.util.TimerTask;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/16 16:17
 * @description：
 */
public class GameCrossMinServer extends AbstractIdleService {

    private ApplicationContext ac;
    private CrossMinConnectServer connectServer;
    private HttpServer httpServer;
    private GRpcServer rpcServer;
    private LogicServer mainLogicServer;
    private final Stopwatch stopwatch = Stopwatch.createUnstarted();


    @Override
    protected void startUp() throws Exception {

        try {

            Stopwatch all = Stopwatch.createStarted();

            initSpringConfig();

            //initGameServerConfig();

            initGameModule();

            initGameNet();

            initMonitor();

            LogUtil.info("服务器启动完成共耗时 {}", all.stop());

        } catch (Exception e) {
            LogUtil.error("", e);
            LogUtil.error("");
            LogUtil.error("***************************************************************************************");
            LogUtil.error("*                                                                                     *");
            LogUtil.error("*                             CrossMin started failed. error                          *");
            LogUtil.error("*                                                                                     *");
            LogUtil.error("***************************************************************************************");
            System.exit(0);
        }
        LogUtil.info("");
        LogUtil.info("****************************************************************************************");
        LogUtil.info("*                                                                                      *");
        LogUtil.info("*                             version [{}]                                 *", ac.getBean(ServerConfig.class).getVersion());
        LogUtil.info("*                             ServerName [{}                    *", StringUtil.strFormat(ac.getBean(ServerSetting.class).getServerName() + "]"));
        LogUtil.info("*                          CrossMin Started successfully                               *");
        LogUtil.info("*                                                                                      *");
        LogUtil.info("****************************************************************************************");

    }


    private void initMonitor() {
        // 发送任务使用
        new Timer("Send-Task-Timer").schedule(new TimerTask() {
            @Override
            public void run() {
                LogUtil.save("等待发送个数:{}", connectServer.sendExcutor.getTaskCounts());
                LogUtil.save("等待解码个数:{}", connectServer.recvExcutor.getTaskCounts());
            }
        }, 30000, 30000);

        // 消息数量用
        new Timer("AllMessage-Timer").schedule(
                new TimerTask() {
                    @Override
                    public void run() {
                        LogUtil.save("接收消息个数:{}", connectServer.maxMessage.get());

                    }
                }, 10000, 60 * 1000);

    }

    /**
     * inti game
     */
    private void initGameNet() {
        LogUtil.info("initGame net 加载通信模块");
        LogUtil.info("初始化TCP服务开始");
        stopwatch.reset().start();
        connectServer = new CrossMinConnectServer();
        connectServer.startAsync().awaitRunning();
        LogUtil.info("初始化TCP服务完毕 {}", stopwatch.stop());

        LogUtil.info("初始化Http服务开始");
        stopwatch.reset().start();
        MessagePool messagePool = new CrossMinMessagePool();
        httpServer = new HttpServer(messagePool);
        httpServer.startAsync().awaitRunning();
        LogUtil.info("初始化Http服务完毕 {}", stopwatch.stop());

        LogUtil.info("初始化Rpc服务开始");
        stopwatch.reset().start();
        List<BindableService> services = RpcCrossImpl.serviceList;
        rpcServer = new GRpcServer(0, 2, "rpc-server-", services);
        rpcServer.startAsync().awaitRunning();
        LogUtil.info("初始化Rpc服务完毕 {} rpc port {}", stopwatch.stop(), rpcServer.getPort());

        GameContext.setMessagePool(messagePool);
        GameContext.setCrossMinConnectServer(connectServer);
        GameContext.setHttpServer(httpServer);
        GameContext.setRpcServer(rpcServer);
    }


    /**
     * spring
     */
    private void initSpringConfig() {
        LogUtil.info("initSpringConfig 加载 applicationContext.xml");
        stopwatch.reset().start();
        ac = new ClassPathXmlApplicationContext("com/game/crossminserver/config/applicationContext.xml");
        GameContext.setAc(ac);
        GameContext.OPEN_DATE = DateHelper.parseDate(ac.getBean(ServerSetting.class).getOpenTime());
        GameContext.CROSS_BEGIN_DATA = DateHelper.parseDate(ac.getBean(ServerSetting.class).getCrossBeginTime());
        LogUtil.info("initSpringConfig CrossBeginTime={}, {}", ac.getBean(ServerSetting.class).getCrossBeginTime(), stopwatch.stop());
    }

/*    private void initGameServerConfig() throws IOException {

        LogUtil.info("需要获取跨服配置");
        stopwatch.reset().start();

        LogUtil.info("需要获取跨服配置 {}", stopwatch.stop());
    }*/

    private void initGameModule() {

        LogUtil.info("initGameModule 加载业务模块");
        stopwatch.reset().start();
        LoadService loadService = ac.getBean(LoadService.class);
        loadService.reloadAll();
        loadService.loadSystem();

        CrossMineDataManager crossMineDataManager = ac.getBean(CrossMineDataManager.class);
        crossMineDataManager.initCrossMine();


        //定时器
        mainLogicServer = new CrossMinLogicServer(ac.getBean(ServerSetting.class).getServerName(), 500);
        GameContext.setMainLogicServer(mainLogicServer);
        Thread thread = new Thread(mainLogicServer);
        thread.setUncaughtExceptionHandler(new GameUncaughtExceptionHandler());
        thread.start();

        LogUtil.info("initGameModule 加载业务模块完成 {}", stopwatch.stop());
    }


    /**
     * game-server.xml
     */
    private void initGameServerConfig() throws IOException {

        LogUtil.info("initGameServerConfig 加载 game-server.xml");
        stopwatch.reset().start();

        GameServerConfig gameServerConfig = null;
        URL url = GameCrossMinServer.class.getClassLoader().getResource("cross-config/game-server.xml");
        if (url != null) {
            FileInputStream fileInputStream = new FileInputStream(url.getPath());
            gameServerConfig = new ServerConfigXmlLoader().load(fileInputStream);
        }

        if (gameServerConfig == null) {
            FileSystemResource fileSystemResource = new FileSystemResource("cross-config/game-server.xml");
            InputStream inputStream = fileSystemResource.getInputStream();
            if (inputStream != null) {
                gameServerConfig = new ServerConfigXmlLoader().load(inputStream);
            }
        }

        GameContext.setGameServerConfig(gameServerConfig);
        for (Server server : gameServerConfig.getList()) {
            GameContext.gameServerMaps.put(server.getId(), server);
            LogUtil.error("server list info --> {}", server.toString());
        }
        LogUtil.info("initGameServerConfig {}", stopwatch.stop());
    }

    @Override
    protected void shutDown() throws Exception {

        LogUtil.error("***************************************************************************************");
        LogUtil.error("*                             stopping CrossMin server                                *");
        LogUtil.error("***************************************************************************************");
        GameContext.isClose = true;
        //通知游戏服玩家队伍解散
        ac.getBean(CrossTeamService.class).closeNotifyGameServer();

        //通知游戏服跨服关闭
        CrossMinService.crossClose();
        rpcServer.stopAsync().awaitTerminated();
        LogUtil.info("rpc server stop ...");

        connectServer.stopAsync().awaitTerminated();
        LogUtil.info("socket server stop ...");

        httpServer.stopAsync().awaitTerminated();
        LogUtil.info("http server stop ...");

        if (mainLogicServer != null) {
            mainLogicServer.stop();
            while (!mainLogicServer.isStopped()) {
                Thread.sleep(1);
            }
        }

        LogUtil.info("服务器关闭网络端口后,服务器需要等待已提交的任务继续完成");
        LogUtil.info("5s 后开始处理数据保存数据到数据库");
        Thread.sleep(5000);
        LogUtil.info("正在保存数据到数据库...");
        DataRepository dataRepository = ac.getBean(DataRepository.class);
        dataRepository.getDataCacheManager().shutdown();
        LogUtil.info("数据保存完成");

        LogUtil.error("***************************************************************************************");
        LogUtil.error("*                            CrossMin Server Stop {}           *", StringUtil.strFormat(ac.getBean(ServerSetting.class).getServerName()));
        LogUtil.error("***************************************************************************************");

    }

    private class GameUncaughtExceptionHandler implements Thread.UncaughtExceptionHandler {
        @Override
        public void uncaughtException(Thread t, Throwable e) {
            LogUtil.error(e);
        }
    }


}
