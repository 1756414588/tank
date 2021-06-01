package com.game.server.rpc.client;

import com.game.server.rpc.pool.RpcThreadFactory;
import com.game.service.rpc.HeartbeatService;
import com.google.common.util.concurrent.AbstractIdleService;
import io.grpc.ManagedChannel;
import io.grpc.ManagedChannelBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/7 11:13
 * @description：rpc client
 */
public class GRpcClient extends AbstractIdleService {
    private Logger logger = LoggerFactory.getLogger(getClass());

    private ManagedChannel channel;
    private String ip;
    private int port;
    private int nThreads;
    private String threadsName;
    /**
     * grpc 有时候创建的连接是无效的
     */
    private boolean isEffective;

    /**
     * rpc client
     *
     * @param ip
     * @param port
     * @param nThreads
     * @param threadsName
     */
    public GRpcClient(String ip, int port, int nThreads, String threadsName) {
        this.ip = ip;
        this.port = port;
        this.nThreads = nThreads;
        this.threadsName = threadsName;
    }

    @Override
    public void startUp() throws Exception {
        logger.error("rpc client init ip={}, port={},nThreads={},threadsName={}", ip, port, nThreads, threadsName);
        ExecutorService threadPool = Executors.newFixedThreadPool(nThreads, new RpcThreadFactory(threadsName));
        ManagedChannelBuilder<?> managedChannelBuilder = ManagedChannelBuilder.forAddress(ip, port);
        managedChannelBuilder.executor(threadPool);
        this.channel = managedChannelBuilder.usePlaintext().build();

        if (HeartbeatService.checkChannel(0,channel)) {
            isEffective = true;
            logger.error("rpc client 检测到连接无效,rpc服务端未开启");
        }
        logger.error("rpc client success ip={}, port={}", ip, port);

    }

    @Override
    public void shutDown() throws Exception {
        if (channel != null) {
            channel.shutdown().awaitTermination(2, TimeUnit.SECONDS);
        }
    }

    /**
     * 通道是否有效
     *
     * @return
     */
    public boolean isValidate() {
        if (channel == null || channel.isShutdown() || channel.isTerminated()) {
            return false;
        }
        return true;
    }

    /**
     * 获取通道
     *
     * @return
     */
    public ManagedChannel getChannel() {
        return channel;
    }

    public boolean isEffective() {
        return isEffective;
    }
}
