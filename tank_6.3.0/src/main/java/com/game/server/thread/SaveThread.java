package com.game.server.thread;

import com.game.util.LogHelper;
import com.game.util.LogUtil;

/**
 * @author ZhangJun
 * @ClassName: SaveThread
 * @Description: 数据保存线程
 * @date 2015年8月24日 上午9:53:32
 */
public abstract class SaveThread extends Thread {
    // 日志

    // 运行标志
    protected boolean stop;

    protected boolean done;

    protected boolean logFlag = false;

    protected int saveCount = 0;

    protected int errorCount = 0;

    protected int dataType = 0;

    protected String threadName;

    protected SaveThread(String threadName) {
        super(threadName);
        this.threadName = threadName;
    }

    @Override
    abstract public void run();

    abstract public void add(Object object);

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
            LogUtil.error(threadName + " Notify Exception", e);
        }
    }

    public void addErrorCount(String errorDesc) {
        errorCount++;

        if (errorCount % 100 == 1) {
            LogHelper.sendGameSaveErrorLog(dataType, errorCount, errorDesc);
        }
    }

}
