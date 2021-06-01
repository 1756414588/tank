package com.game.server;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/19 10:09
 * @description：
 */
public class CrossMinContext {

    /**
     * socket 是否连接
     */
    private static boolean crossMinSocket = false;
    /**
     * rpc是否连接
     */
    private static boolean crossMinRpc = false;

    public static boolean isCrossMinSocket() {
        return crossMinSocket;
    }

    public static void setCrossMinSocket(boolean crossMinSocket) {
        CrossMinContext.crossMinSocket = crossMinSocket;
    }

    public static boolean isCrossMinRpc() {
        return crossMinRpc;
    }

    public static void setCrossMinRpc(boolean crossMinRpc) {
        CrossMinContext.crossMinRpc = crossMinRpc;
    }
}
