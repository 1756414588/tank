package com.test;

import com.game.util.LogUtil;
import start.ServerStart;

import java.io.IOException;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/17 11:44
 * @description：服务器启动入口
 */
public class ServerStartTest {
    public static void main(String[] args) {

        ServerStart.main(args);
        terminateForWindows();
    }

    public static void terminateForWindows() {
        if (System.getProperties().getProperty("os.name").toUpperCase().indexOf("WINDOWS") != -1) {
            LogUtil.info("press ENTER to call System.exit() and run the shutdown routine.");
            try {
                System.in.read();
            } catch (IOException e) {
                e.printStackTrace();
            }
            System.exit(0);
        }
    }
}
