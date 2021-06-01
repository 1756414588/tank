package com.account.manager;

import java.util.concurrent.atomic.AtomicInteger;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/3/11 12:01
 * @Description :创建保存线程
 */
public class ServerListThreadFactory implements java.util.concurrent.ThreadFactory {
    public final String name;
    private final AtomicInteger threadCounter = new AtomicInteger(1);

    @Override
    public Thread newThread(Runnable runnable) {
        StringBuilder threadName = new StringBuilder(name);

        threadName.append("-").append(threadCounter.getAndIncrement());

        Thread thread = new Thread(group, runnable, threadName.toString());
        if (thread.isDaemon()) {
            thread.setDaemon(false);
        }

        if (thread.getPriority() != Thread.NORM_PRIORITY) {
            thread.setPriority(Thread.NORM_PRIORITY);
        }

        return thread;
    }

    final ThreadGroup group;

    public ServerListThreadFactory(String name) {
        SecurityManager securitymanager = System.getSecurityManager();
        this.group = securitymanager == null ? Thread.currentThread().getThreadGroup() : securitymanager.getThreadGroup();
        this.name = name;
    }
}
