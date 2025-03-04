package com.game.server.thread;

import com.game.server.ICommand;
import com.game.server.timer.ITimerEvent;
import com.game.util.LogUtil;

import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author ZhangJun
 * @ClassName: ServerThread @Description: TODO
 * @date 2015年8月24日 上午9:53:32
 */
public class ServerThread extends Thread {
    // 命令执行队列
    private LinkedBlockingQueue<ICommand> command_queue = new LinkedBlockingQueue<ICommand>();
    // 计时线程
    private TimerThread timer;
    // 线程名称
    protected String threadName;
    // 心跳间隔
    protected int heart;

    // 运行标志
    private boolean stop;

    public boolean stopped = false;

    private boolean processingCompleted = false;

    public ServerThread(ThreadGroup group, String threadName, int heart) {
        super(group, threadName);
        this.threadName = threadName;
        this.heart = heart;
        if (this.heart > 0) {
            timer = new TimerThread(this);
        }

        this.setUncaughtExceptionHandler(
                new UncaughtExceptionHandler() {
                    @Override
                    public void uncaughtException(Thread t, Throwable e) {
                        LogUtil.error(e, e);
                        if (timer != null) timer.stop(true);
                        command_queue.clear();
                    }
                });
    }

    public void run() {
        if (this.heart > 0 && timer != null) {
            // 启动计时线程
            timer.start();
        }

        stop = false;
        int loop = 0;
        while (!stop) {
            ICommand command = command_queue.poll();
            if (command == null) {
                try {
                    synchronized (this) {
                        loop = 0;
                        processingCompleted = true;
                        wait();
                    }
                } catch (Exception e) {
                    LogUtil.error(e, e);
                }
            } else {
                try {
                    loop++;
                    processingCompleted = false;
                    long start = System.currentTimeMillis();
                    command.action();
                    long end = System.currentTimeMillis();

                    if (end - start > 10)
                        LogUtil.error(
                                this.getName()
                                        + "-->"
                                        + command.getClass().getSimpleName()
                                        + " haust:"
                                        + (end - start));
                    if (loop > 1000) {
                        loop = 0;
                        try {
                            Thread.sleep(1);
                        } catch (Exception e) {
                            LogUtil.error(e, e);
                        }
                    }
                } catch (Exception e) {
                    e.printStackTrace();
                    LogUtil.error("", e);

                }
            }
        }

        stopped = true;
    }

    public void stop(boolean flag) {
        stop = flag;
        if (timer != null) this.timer.stop(flag);
        this.command_queue.clear();
        try {
            synchronized (this) {
                if (processingCompleted) {
                    processingCompleted = false;
                    notify();
                }
            }
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }

    /**
     * 添加命令
     *
     * @param command 命令
     */
    public void addCommand(ICommand command) {
        try {
            this.command_queue.add(command);
            synchronized (this) {
                notify();
            }
        } catch (Exception e) {
            LogUtil.error("", e);

        }
    }

    /**
     * 添加定时事件
     *
     * @param event 定时事件
     */
    public void addTimerEvent(ITimerEvent event) {
        if (timer != null) this.timer.addTimerEvent(event);
    }

    /**
     * 移除定时事件
     *
     * @param event 定时事件
     */
    public void removeTimerEvent(ITimerEvent event) {
        if (timer != null) this.timer.removeTimerEvent(event);
    }

    public String getThreadName() {
        return threadName;
    }

    public int getHeart() {
        return heart;
    }
}
