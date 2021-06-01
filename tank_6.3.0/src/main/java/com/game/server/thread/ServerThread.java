package com.game.server.thread;

import com.game.server.ICommand;
import com.game.server.timer.ITimerEvent;
import com.game.util.LogUtil;

import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author ZhangJun
 * @ClassName: ServerThread
 * @Description: 服务线程   会调用handle的action方法  执行服务器中所有指令  当属性heart>0时 会启动TimerThread来定时执行
 * @date 2015年8月24日 上午9:53:32
 */
public class ServerThread extends Thread {
    // 日志
    // private Logger log = Logger.getLogger(ServerThread.class);
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

    /**
     * Title:
     * Description:
     *
     * @param group      线程组
     * @param threadName 线程名
     * @param heart      心跳间隔
     */
    public ServerThread(ThreadGroup group, String threadName, int heart) {
        super(group, threadName);
        this.threadName = threadName;
        this.heart = heart;
        if (this.heart > 0) {
            timer = new TimerThread(this);
        }

        this.setUncaughtExceptionHandler(new UncaughtExceptionHandler() {
            @Override
            public void uncaughtException(Thread t, Throwable e) {
                LogUtil.error("threadName uncaughtException", e);
                if (timer != null) {
                    timer.stop(true);
                }
                command_queue.clear();
            }
        });
    }

    /**
     * <p>Title: run</p>
     * <p>Description: 不停消费队列中的指令</p>
     *
     * @see java.lang.Thread#run()
     */
    @Override
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
                    LogUtil.error("Thread Wait Exception", e);
                }
            } else {
                try {
                    loop++;
                    processingCompleted = false;
                    long start = System.currentTimeMillis();
                    command.action();
                    long end = System.currentTimeMillis();

                    if (end - start > 50) {
                        String simpleName = command.getClass().getName();
                        LogUtil.haust("任务处理 name=" + this.getName() + " --> className=" + simpleName + " 耗时: " + (end - start));
                    }
                    if (loop > 1000) {
                        loop = 0;
                        try {
                            Thread.sleep(1);
                        } catch (Exception e) {
                            LogUtil.error("Thread Sleep Exception", e);
                        }
                    }
                } catch (Exception e) {
                    LogUtil.error("执行任务处理 "+ command.getClass().getName() + " exception --> ", e);
                }
            }
        }

        stopped = true;
    }

    /**
     * @param flag void
     * @Title: stop
     * @Description: 停止服务
     */
    public void stop(boolean flag) {
        stop = flag;
        if (timer != null) {
            this.timer.stop(flag);
        }
        this.command_queue.clear();
        try {
            synchronized (this) {
                if (processingCompleted) {
                    processingCompleted = false;
                    notify();
                }
            }
        } catch (Exception e) {
            LogUtil.error("Server Thread " + threadName + " Notify Exception", e);
        }
    }


    public void addCommand(ICommand command) {
        try {
            this.command_queue.add(command);
            synchronized (this) {
                notify();
            }
        } catch (Exception e) {
            LogUtil.error("Server Thread " + threadName + " Notify Exception", e);
        }
    }

    /**
     * @param event 定时事件
     *              void
     * @Title: addTimerEvent
     * @Description: 添加事件
     */
    public void addTimerEvent(ITimerEvent event) {
        if (timer != null){
            this.timer.addTimerEvent(event);
        }
    }

    /**
     * @param event void
     * @Title: removeTimerEvent
     * @Description: 移除定时事件
     */
    public void removeTimerEvent(ITimerEvent event) {
        if (timer != null){
            this.timer.removeTimerEvent(event);
        }
    }

    public String getThreadName() {
        return threadName;
    }

    /**
     * @return int
     * @Title: getHeart
     * @Description: 心跳间隔
     */
    public int getHeart() {
        return heart;
    }
}
