package com.game.server.rpc.pool;


/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/8 11:41
 * @description：rpc 连接池
 */
public class GRpcPool extends Pool<GRpcConnection> {

    public GRpcPool(GRpcClientPoolConfig poolConfig, GRpcConnectionFactory factory) {
        super(poolConfig, factory);
    }

}
