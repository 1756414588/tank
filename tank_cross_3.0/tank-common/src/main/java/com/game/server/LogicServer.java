package com.game.server;

import com.game.message.handler.DealType;
import com.game.message.handler.Handler;
import com.game.server.thread.ServerThread;
import org.apache.log4j.Logger;

import java.util.HashMap;
import java.util.Iterator;

/**
 * @author ZhangJun
 * @ClassName: MainLogicServer @Description: TODO
 * @date 2015年7月29日 下午7:24:35
 */
public class LogicServer implements Runnable {
    static Logger logger = Logger.getLogger(LogicServer.class);

    private long createTime;
    private String serverName;
    private int heart;

    protected HashMap<Integer, ServerThread> threadPool = new HashMap<>();

    private ThreadGroup threadGroup;

    public LogicServer(String serverName, int heart) {
        this.createTime = System.currentTimeMillis();
        this.serverName = serverName;
        this.heart = heart;

        threadGroup = new ThreadGroup(serverName);
        createServerThread(DealType.MAIN);
        init();
    }

    private void createServerThread(DealType dealType) {
        ServerThread serverThread = new ServerThread(threadGroup, dealType.getName(), heart);
        threadPool.put(dealType.getCode(), serverThread);
    }

    private void init() {
    }

    public void stop() {
        Iterator<ServerThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().stop(true);
        }
    }

    public boolean isStopped() {
        Iterator<ServerThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            if (!it.next().stopped) {
                return false;
            }
        }

        return true;
    }

    @Override
    public void run() {
        Iterator<ServerThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().start();
        }
    }

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

    public void addCommand(ICommand command, DealType dealType) {
        ServerThread thread = threadPool.get(dealType.getCode());
        if (thread != null) {
            // 添加命令
            thread.addCommand(command);
        } else {
            command.action();
        }
    }

    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    public String getServerName() {
        return serverName;
    }

    public void setServerName(String serverName) {
        this.serverName = serverName;
    }
}
