package com.game.crossserver.server;

import com.game.util.LogUtil;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/16 17:55
 * @description：启动
 */
public class GameCrossServerStart {

    public static void main(String[] args) {
        LogUtil.info("=============================================");
        LogUtil.info("");
        LogUtil.info("=                starting server            =");
        LogUtil.info("");
        LogUtil.info("=============================================");
        LogUtil.info("");
        final GameCrossServer gameCrossServer = new GameCrossServer();
        try {
            gameCrossServer.startAsync();
            gameCrossServer.awaitRunning();
            Runtime.getRuntime().addShutdownHook(new Thread() {
                @Override
                public void run() {
                    if (gameCrossServer.isRunning()) {
                        gameCrossServer.stopAsync();
                        gameCrossServer.awaitTerminated();
                    }
                }
            });
        } catch (Throwable e) {
            LogUtil.error("gameServer start error", e);
        }
    }
}
