package com.gamerpc.grpc.server;

import com.gamerpc.grpc.thread.RpcThreadFactory;
import com.google.common.util.concurrent.AbstractIdleService;
import io.grpc.BindableService;
import io.grpc.Server;
import io.grpc.ServerBuilder;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import java.util.List;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/7 10:18
 * @description：prc server端
 */
public class GRpcServer extends AbstractIdleService {
    private Logger logger = LoggerFactory.getLogger(getClass());
    private Server server;
    private int port;
    private int nThreads;
    private String threadsName;
    private List<BindableService> serviceList;

    /**
     * 创建 rpc server
     *
     * @param port        端口 如果为0 则系统默认分配
     * @param nThreads    线程池数量
     * @param threadsName 线程名称前缀 thread-rpc-server-
     * @param serviceList services
     */
    public GRpcServer(int port, int nThreads, String threadsName, List<BindableService> serviceList) {
        this.port = port;
        this.nThreads = nThreads;
        this.threadsName = threadsName;
        this.serviceList = serviceList;
    }

    @Override
    protected void startUp() throws Exception {
        logger.info("rpc server init port={},nThreads={},threadsName={}", port, nThreads, threadsName);
        ExecutorService threadPool = Executors.newFixedThreadPool(nThreads, new RpcThreadFactory(threadsName));
        ServerBuilder<?> serverBuilder = ServerBuilder.forPort(port);
        for (BindableService server : serviceList) {
            serverBuilder.addService(server);

        }
        serverBuilder.executor(threadPool);
        server = serverBuilder.build().start();
        this.port = server.getPort();
        logger.info("rpc server success rpc port={},nThreads={},threadsName={}", port, nThreads, threadsName);
//        if (server != null) {
//            logger.error("rpc server await...");
//            server.awaitTermination();
//        }
    }

    @Override
    protected void shutDown() throws Exception {
        if (server != null) {
            logger.info("rpc server close rpc port={}", port);
            server.shutdown();
        }
    }

    public Server getServer() {
        return server;
    }

    public int getPort() {
        return port;
    }
}
