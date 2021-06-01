package com.game.server.thread;


import com.game.util.LogUtil;


public abstract class SaveThread extends Thread {

    // 运行标志
    protected boolean stop;

    protected boolean done;

    protected boolean logFlag = false;

    protected int saveCount = 0;

    // 线程名称
    protected String threadName;

    protected SaveThread(String threadName) {
        super(threadName);
        this.threadName = threadName;
    }

    public abstract void run();


    public abstract void add(Object object);

    public boolean workDone() {
        return done;
    }

    public int getSaveCount() {
        return saveCount;
    }

    public void setLogFlag() {
        logFlag = true;
    }

    public void stop(boolean flag) {
        stop = flag;
        try {
            synchronized (this) {
                notify();
            }
        } catch (Exception e) {
            LogUtil.error(threadName + " Notify Exception:" + e.getMessage());
        }
    }

}
