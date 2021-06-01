package com.game.server.rpc.pool;

import com.game.service.rpc.HeartbeatService;
import io.grpc.ManagedChannel;
import org.apache.commons.pool2.BasePooledObjectFactory;
import org.apache.commons.pool2.PooledObject;
import org.apache.commons.pool2.impl.DefaultPooledObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/8 11:46
 * @description：rpc 连接factory
 */
public class GRpcConnectionFactory extends BasePooledObjectFactory<GRpcConnection> {
    private Logger logger = LoggerFactory.getLogger("CROSS");
    private final String ip;
    private final int port;
    private final int nThreads;
    private final String threadsName;
    private final AtomicInteger poolCounter = new AtomicInteger();

    /**
     * rpc client
     *
     * @param ip
     * @param port
     * @param nThreads
     * @param threadsName
     */
    public GRpcConnectionFactory(String ip, int port, int nThreads, String threadsName) {
        this.ip = ip;
        this.port = port;
        this.nThreads = nThreads;
        this.threadsName = threadsName;
    }

    @Override
    public synchronized GRpcConnection create() throws Exception {

        int incrementAndGet = poolCounter.incrementAndGet();
        String name = threadsName + "pool" + incrementAndGet + "-";
        logger.info("创建rpc连接 create threadName={}", name);
        GRpcConnection rpcConnection = new GRpcConnection(incrementAndGet,ip, port, nThreads, name);
        rpcConnection.startUp();
        logger.info("rpc连接创建完成 threadName={},isEffective={}", name, rpcConnection.isEffective());
        return rpcConnection;
    }

    @Override
    public PooledObject<GRpcConnection> wrap(GRpcConnection rpcConnection) {
        return new DefaultPooledObject<>(rpcConnection);
    }

    /**
     * 产生一个连接对象
     *
     * @return
     * @throws Exception
     */
    @Override
    public PooledObject<GRpcConnection> makeObject() throws Exception {
        return wrap(create());
    }

    /**
     * 销毁一个连接对象
     *
     * @param pooledObject
     * @throws Exception
     */
    @Override
    public void destroyObject(PooledObject<GRpcConnection> pooledObject) throws Exception {
        GRpcConnection connection = pooledObject.getObject();
        ManagedChannel channel = connection.getChannel();
        logger.error("rpc 销毁连接:{},isConnected={},idle={} s", channel.toString(), connection.isValidate(), (System.currentTimeMillis() - pooledObject.getLastBorrowTime()) / 1000f);
        connection.shutDown();
    }

    /**
     * 校验方法
     *
     * @param pooledObject
     * @return
     */
    @Override
    public boolean validateObject(PooledObject<GRpcConnection> pooledObject) {
        GRpcConnection connection = pooledObject.getObject();
        ManagedChannel channel = connection.getChannel();
        boolean validate = HeartbeatService.checkChannel(connection.getId(),channel);
        boolean isConnected = connection.isValidate();
        if (validate && isConnected) {
            return true;
        }
        logger.error("rpc 检测连接异常{},validate={},isConnected={},idle={}s", channel.toString(), validate, isConnected, (System.currentTimeMillis() - pooledObject.getLastBorrowTime()) / 1000f);
        return false;
    }

}
