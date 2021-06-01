package com.game.server.rpc.pool;

import com.game.server.rpc.client.GRpcClient;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/8 11:44
 * @description：rpc连接
 */
public class GRpcConnection extends GRpcClient {


    private int id;
    private GRpcPool rpcPool;

    /**
     * rpc client
     *
     * @param ip
     * @param port
     * @param nThreads
     * @param threadsName
     */
    public GRpcConnection(int id, String ip, int port, int nThreads, String threadsName) {
        super(ip, port, nThreads, threadsName);
        this.id = id;
    }


    /**
     * 归还连接
     */
    public void close() {
        if (rpcPool != null) {
            rpcPool.returnResource(this);
        }

    }

    void setRpcPool(GRpcPool rpcPool) {
        this.rpcPool = rpcPool;
    }

    public int getId() {
        return id;
    }
}
