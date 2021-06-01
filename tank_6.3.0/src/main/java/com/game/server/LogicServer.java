/**
 * @Title: MainLogicServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午7:24:35
 * @version V1.0
 */
package com.game.server;

import com.game.message.handler.DealType;
import com.game.message.handler.Handler;
import com.game.server.thread.ServerThread;
import com.game.server.timer.CloseConnectTimer;
import com.game.server.timer.ITimerEvent;
import io.netty.channel.ChannelHandlerContext;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

/**
 * @author ZhangJun
 * @ClassName: MainLogicServer
 * @Description: 服务端逻辑的服务器 专门处理各种定时任务 会调用TimerEvent实现的 action方法
 * @date 2015年7月29日 下午7:24:35
 */
public class LogicServer implements Runnable {
    static Logger logger = Logger.getLogger(LogicServer.class);
    private long createTime;
    private String serverName;
    private int heart;
    protected HashMap<Integer, ServerThread> threadPool = new HashMap<>();
    private ThreadGroup threadGroup;
    public ScheduledExecutorService timer = Executors.newScheduledThreadPool(1);


    /**
     * <p>
     * Title:
     * </p>
     * <p>
     * Description:初始化
     * </p>
     *
     * @param serverName
     * @param heart
     */
    LogicServer(String serverName, int heart) {
        this.createTime = System.currentTimeMillis();
        this.serverName = serverName;
        this.heart = heart;

        threadGroup = new ThreadGroup(serverName);
        createServerThread(DealType.MAIN);
        // createServerThread(DealType.BUILD_QUE);
        // createServerThread(DealType.TANK_QUE);
        createInnerServerThread(DealType.INNER);// 创建线程用于后台交互

        init();

    }

    /**
     * @param dealType 服务类型 键 void
     * @Title: createServerThread
     * @Description: 创建服务线程 并以键值对形式记录 初始化时调用
     */
    private void createServerThread(DealType dealType) {
        ServerThread serverThread = new ServerThread(threadGroup, dealType.getName(), -1);
        threadPool.put(dealType.getCode(), serverThread);
    }

    /**
     * @Title: createInnerServerThread
     * @Description: 创建用于跨服服务器交互的服务线程 void
     */
    private void createInnerServerThread(DealType dealType) {
        ServerThread serverThread = new ServerThread(threadGroup, dealType.getName(), -1);
        threadPool.put(dealType.getCode(), serverThread);
    }

    /**
     * @Title: init
     * @Description: 初始化杂项 void
     */
    private void init() {

    }

    /**
     * @Title: stop
     * @Description: 停止服务 void
     */
    public void stop() {
        Iterator<ServerThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().stop(true);
        }
    }

    /**
     * @return boolean
     * @Title: isStopped
     * @Description: 判断服务是否停止
     */
    public boolean isStopped() {
        Iterator<ServerThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            if (!it.next().stopped) {
                return false;
            }
        }

        return true;
    }

    /**
     * <p>
     * Title: run
     * </p>
     * <p>
     * Description: 启动各种定时任务
     * </p>
     *
     * @see java.lang.Runnable#run()
     */
    @Override
    public void run() {
        Iterator<ServerThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().start();
        }
    }

    /**
     * @param handler 根据处理器寻找处理队列 void
     * @Title: addCommand
     * @Description: 添加命令
     */
    public void addCommand(Handler handler) {
        // 寻找处理队列
        ServerThread thread = threadPool.get(handler.dealType().getCode());
        if (thread != null) {
            // 添加命令
            thread.addCommand(handler);
        } else {
            handler.action();
        }
    }

    /**
     * @param command  命令
     * @param dealType 处理队列的key void
     * @Title: addCommand
     * @Description: 添加命令
     */
    public void addCommand(ICommand command, DealType dealType) {
        ServerThread thread = threadPool.get(dealType.getCode());
        if (thread != null) {
            // 添加命令
            thread.addCommand(command);
        } else {
            command.action();
        }
    }

    public void addTimerEvent(ITimerEvent event, DealType dealType) {
        ServerThread thread = threadPool.get(dealType.getCode());
        if (event != null) {
            thread.addTimerEvent(event);
        }
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public static Logger getLogger() {
        return logger;
    }

    public static void setLogger(Logger logger) {
        LogicServer.logger = logger;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }

    /**
     * @return int
     * @Title: getHeart
     * @Description: 心跳间隔
     */
    public int getHeart() {
        return heart;
    }

    public void setHeart(int heart) {
        this.heart = heart;
    }

    /**
     * @return ThreadGroup
     * @Title: getThreadGroup
     * @Description: 线程管理器
     */
    public ThreadGroup getThreadGroup() {
        return threadGroup;
    }

    public void setThreadGroup(ThreadGroup threadGroup) {
        this.threadGroup = threadGroup;
    }

    public void addDelayTask(final ChannelHandlerContext ctx) {
        timer.schedule(new Runnable() {
            @Override
            public void run() {
                addCommand(new CloseConnectTimer(ctx), DealType.MAIN);
            }
        }, 1, TimeUnit.SECONDS);
    }

}