/**   
 * @Title: SaveServer.java    
 * @Package com.game.server    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月26日 下午2:34:16    
 * @version V1.0   
 */
package com.game.server;

import com.game.server.thread.SaveThread;

import java.util.HashMap;
import java.util.Iterator;

/**
 * @ClassName: SaveServer
 * @Description: 数据保存队列
 * @author ZhangJun
 * @date 2015年9月26日 下午2:34:16
 * 
 */
public abstract class SaveServer implements Runnable {
    private long createTime;

    protected HashMap<Integer, SaveThread> threadPool = new HashMap<>();

    protected int threadNum;

    protected String name;

    /**
     * 
     * <p>
     * Title:
     * </p>
     * <p>
     * Description:
     * </p>
     * 
     * @param name 服务器名
     * @param threadNum 最大线程数
     */
    public SaveServer(String name, int threadNum) {
        this.createTime = System.currentTimeMillis();
        this.name = name;
        this.threadNum = threadNum;

        createThreads();
        init();
    }

    /**
     * 
     * @Title: serverName
     * @Description: 服务器名
     * @return String

     */
    public String serverName() {
        return name;
    }

    /**
     * 
     * @Title: createThreads
     * @Description: 初始化线程池 void

     */
    public void createThreads() {
        for (int i = 0; i < threadNum; i++) {
            threadPool.put(i, createThread(name + "-thread-" + i));
        }
    }

    /**
     * 
     * @Title: init
     * @Description:初始化方法 void

     */
    public void init() {

    }

    /**
     * 
     * @Title: saveData
     * @Description: 保存数据方法 由各线程实现
     * @param object 要保存的数据 void

     */
    abstract public void saveData(Object object);

    /**
     * 
     * @Title: saveDone
     * @Description: 检测各线程是否已完成任务
     * @return boolean

     */
    public boolean saveDone() {
        Iterator<SaveThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            if (!it.next().workDone()) {
                return false;
            }
        }
        return true;
    }

    /**
     * 
     * @Title: allSaveCount
     * @Description: 保存的所有数据行数
     * @return int

     */
    public int allSaveCount() {
        int saveCount = 0;
        Iterator<SaveThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            saveCount += it.next().getSaveCount();
        }
        return saveCount;
    }

    /**
     * 
     * @Title: stop
     * @Description: 停止所有线程 void

     */
    public void stop() {
        Iterator<SaveThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().stop(true);
        }
    }

    /**
     * 
     * @Title: setLogFlag
     * @Description: 开启所有线程记录日志 void

     */
    public void setLogFlag() {
        Iterator<SaveThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().setLogFlag();
        }
    }

    /**
     * 
     * <p>
     * Title: run
     * </p>
     * <p>
     * Description: run启动所有线程方法
     * </p>
     * 
     * @see java.lang.Runnable#run()
     */
    @Override
    public void run() {
        Iterator<SaveThread> it = threadPool.values().iterator();
        while (it.hasNext()) {
            it.next().start();
        }
    }

    /**
     * 
     * @Title: getCreateTime
     * @Description: 服务器启动时间
     * @return long

     */
    public long getCreateTime() {
        return createTime;
    }

    public void setCreateTime(long createTime) {
        this.createTime = createTime;
    }

    /**
     * 
     * @Title: createThread
     * @Description: 创建线程方法
     * @param name
     * @return SaveThread

     */
    abstract public SaveThread createThread(String name);
}
