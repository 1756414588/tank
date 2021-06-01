package com.game.crossminserver.server;

import com.game.util.LogUtil;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/16 17:55
 * @description：启动
 */
public class GameCrossMinServerStart {

    public static void main(String[] args) {
        LogUtil.info("***************************************************************************************");
        LogUtil.info("*                             starting CrossMin server                                *");
        LogUtil.info("***************************************************************************************");
        final GameCrossMinServer gameCrossServer = new GameCrossMinServer();
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
            LogUtil.error("CrossMin start error", e);
        }
    }
}
