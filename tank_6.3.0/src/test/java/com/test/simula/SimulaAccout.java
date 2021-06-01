package com.test.simula;

import io.netty.channel.ChannelHandlerContext;

/**
 * @author zhangdh
 * @ClassName: SimulaAccout
 * @Description: 模拟帐号
 * @date 2017/5/2 10:08
 */
public class SimulaAccout {

    public static String account = "zx4";

    public static String password = "000";

    public static int keyId;

    public static String token;

    public static ChannelHandlerContext ctx;


    public static String getString() {
        return account + "_" + password;
    }
}
