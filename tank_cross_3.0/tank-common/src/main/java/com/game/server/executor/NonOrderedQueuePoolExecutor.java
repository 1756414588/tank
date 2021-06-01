package com.game.server.executor;

import com.game.message.handler.Handler;
import com.game.util.LogUtil;

import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class NonOrderedQueuePoolExecutor extends ThreadPoolExecutor {


    public NonOrderedQueuePoolExecutor(int corePoolSize) {
        super(corePoolSize, corePoolSize, 30, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
    }

    public void execute(Handler command) {
        Work work = new Work(command);
        execute(work);
    }

    private class Work implements Runnable {

        private Handler command;

        public Work(Handler command) {
            this.command = command;
        }

        @Override
        public void run() {
            try {
                long start = System.currentTimeMillis();
                command.action();
                long end = System.currentTimeMillis();
                if (end - start > 50) {
                    LogUtil.error("NonOrderedQueuePoolExecutor-->" + command.getClass().getSimpleName() + " run:" + (end - start));
                }
            } catch (Exception e) {
                LogUtil.error(e, e);
            }
        }
    }
}
