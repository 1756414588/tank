package com.game.server.rpc.pool;

import java.util.concurrent.ThreadFactory;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 21019/3/7 10:50
 * @description：rpc线程 factory
 */
public class RpcThreadFactory implements ThreadFactory {

    private final AtomicInteger threadCounter = new AtomicInteger();

    private String threadName;

    public RpcThreadFactory(String name) {
        this.threadName = name;
    }

    @Override
    public Thread newThread(Runnable runnable) {

        String name = threadName + threadCounter.incrementAndGet();

        Thread thread = new Thread(runnable, name);
        if (thread.isDaemon()) {
            thread.setDaemon(false);
        }

        if (thread.getPriority() != Thread.NORM_PRIORITY) {
            thread.setPriority(Thread.NORM_PRIORITY);
        }
        return thread;
    }
}
