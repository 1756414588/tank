package com.test;

import com.game.crossserver.server.GameCrossServerStart;
import com.game.util.LogUtil;
import java.io.IOException;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/20 21:35
 * @description：
 */
public class ServerCrossStartTest {
    public static void main(String[] args) {
        GameCrossServerStart.main(args);
        terminateForWindows();
    }

    public static void terminateForWindows() {
        if (System.getProperties().getProperty("os.name").toUpperCase().indexOf("WINDOWS") != -1) {
            LogUtil.error("press ENTER to call System.exit() and run the shutdown routine.");
            try {
                System.in.read();
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.exit(0);
        }
    }
}
