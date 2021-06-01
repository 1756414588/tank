package com.game.server.rpc.pool;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/8 15:36
 * @description：rpc 管理者
 */
public class GRpcPoolManager {

    private static GRpcPool rpcPool;


    /**
     * 借一个连接 必须有借有还
     *
     * @return
     */
    public static GRpcConnection getRpcConnection() {
        if (rpcPool == null) {
            return null;
        }
        GRpcConnection resource = rpcPool.getResource();
        if (!resource.isEffective() || !resource.isValidate()) {
            //取出的是无效的 必须归还
            GRpcPoolManager.rpcPool.returnResource(resource);
            return null;
        }
        resource.setRpcPool(rpcPool);
        return resource;
    }


    /**
     * 设置连接池
     *
     * @param rpcPool
     */
    public static void setRpcPool(GRpcPool rpcPool) {
        GRpcPoolManager.rpcPool = rpcPool;
    }

    public static GRpcPool getRpcPool() {
        return rpcPool;
    }

}
