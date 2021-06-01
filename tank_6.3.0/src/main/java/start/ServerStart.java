package start;

import com.game.server.GameServer;
import com.game.util.LogUtil;

import java.io.IOException;
import java.lang.Thread.UncaughtExceptionHandler;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/5/17 11:44
 * @Description :服务器启动入口
 */
public class ServerStart {

    /**
     * @param args
     * @return void
     * @Description: 服务器启动入口
     */
    public static void main(String[] args) {
        setDefaultUncaughtExceptionHandler();
        LogUtil.start("begin tank game server!!!");
        new Thread(GameServer.getInstance()).start();
    }

    /**
     * @Description: 未捕获异常处理
     * void
     */
    public static void setDefaultUncaughtExceptionHandler() {
        Thread.setDefaultUncaughtExceptionHandler(new UncaughtExceptionHandler() {
            @Override
            public void uncaughtException(Thread t, Throwable e) {
                LogUtil.error(t, e);
            }
        });
    }

}
