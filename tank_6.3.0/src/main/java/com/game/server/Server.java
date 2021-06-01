/**
 * @Title: Server.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午3:29:46
 * @version V1.0
 */
package com.game.server;

import com.game.util.LogUtil;


/**
 * @author ZhangJun
 * @ClassName: Server
 * @Description: 服务线程基类
 * @date 2015年7月29日 下午3:29:46
 */
public abstract class Server implements Runnable {
    //public static final String DEFAULT_MAIN_THREAD = "Main";
    protected String name;
    /**
     * Title:
     * Description:
     *
     * @param name 服务名
     */
    protected Server(String name) {
        this.name = name;
    }

    /**
     * @return String
     * @Title: getGameType
     * @Description: 服务器类型
     */
    abstract String getGameType();

    /**
     * @Title: stop
     * @Description: 停止服务
     * void
     */
    protected abstract void stop();

    /**
     * @author
     * @ClassName: CloseByExit
     * @Description: 停止服务线程
     */
    private class CloseByExit implements Runnable {
        private String serverName;

        public CloseByExit(String serverName) {
            this.serverName = serverName;
        }

        @Override
        public void run() {
            Server.this.stop();
            LogUtil.stop(this.serverName + " Stop!!");
        }
    }

    /**
     * 启动加钩子.
     */
    public void addHook() {
        Runtime.getRuntime().addShutdownHook(new Thread(new CloseByExit(name)));
    }
}
