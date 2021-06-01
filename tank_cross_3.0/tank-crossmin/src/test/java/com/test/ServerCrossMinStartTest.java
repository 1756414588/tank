package com.test;

import com.game.crossminserver.server.GameCrossMinServerStart;
import com.game.util.LogUtil;

import java.io.IOException;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/20 21:35
 * @description：
 */
public class ServerCrossMinStartTest {
    public static void main(String[] args) {
        GameCrossMinServerStart.main(args);
        terminateForWindows();
    }

    public static void terminateForWindows() {
        if (System.getProperties().getProperty("os.name").toUpperCase().indexOf("WINDOWS") != -1) {
            LogUtil.error("press ENTER to call System.exit() and run the shutdown routine.");
            try {
                System.in.read();
            } catch (IOException e) {
                LogUtil.error(e);
            }
            System.exit(0);
        }
    }
}
