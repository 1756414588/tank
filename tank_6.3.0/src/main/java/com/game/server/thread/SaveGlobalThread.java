package com.game.server.thread;

import com.game.domain.p.DbGlobal;
import com.game.manager.GlobalDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;

import java.util.HashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author ZhangJun
 * @ClassName: SaveGlobalThread
 * @Description: 全局数据保存线程
 * @date 2015年8月24日 上午9:53:32
 */
public class SaveGlobalThread extends SaveThread {
    /**
     * 命令执行队列
     */
    private LinkedBlockingQueue<Integer> global_queue = new LinkedBlockingQueue<Integer>();

    private HashMap<Integer, DbGlobal> global_map = new HashMap<Integer, DbGlobal>();

    private GlobalDataManager globalDataManager;

    private static int MAX_SIZE = 1000;

    public SaveGlobalThread(String threadName) {
        super(threadName);
        dataType = 4;
        this.globalDataManager = GameServer.ac.getBean(GlobalDataManager.class);
    }

    @Override
    public void run() {
        stop = false;
        done = false;
        while (!stop || global_queue.size() > 0) {
            DbGlobal dbGlobal = null;
            synchronized (this) {
                Integer globalId = global_queue.poll();
                if (globalId != null) {
                    dbGlobal = global_map.remove(globalId);
                }
            }
            if (dbGlobal == null) {
                try {
                    synchronized (this) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    LogUtil.error("DbGlobal Wait Exception", e);
                }
            } else {
                if (global_queue.size() > MAX_SIZE) {
                    global_queue.clear();
                    global_map.clear();
                }
                try {

                    globalDataManager.updateGlobal(dbGlobal);
                    if (logFlag) {
                        saveCount++;
                    }
                } catch (Exception e) {
                    LogUtil.error("DbGlobal Save Exception:" + dbGlobal.getGlobalId(), e);

                    // 记录出错次数
                    addErrorCount("保存全局数据出错");
                }
            }
        }

        done = true;
        LogUtil.stop("SaveGlobal [{}] stopped, save done saveCount = {}", threadName, saveCount);
    }


    @Override
    public void add(Object object) {
        try {
            DbGlobal dbGlobal = (DbGlobal) object;
            LogUtil.save("DbGlobal插入中， 保存极限副本队列剩余：" + this.global_queue.size() + "|globalId:" + dbGlobal.getGlobalId());

            synchronized (this) {
                if (!global_map.containsKey(dbGlobal.getGlobalId())) {
                    this.global_queue.add(dbGlobal.getGlobalId());
                }
                this.global_map.put(dbGlobal.getGlobalId(), dbGlobal);
                notify();
            }
        } catch (Exception e) {
            LogUtil.error("DbGlobal 数据插入队列异常", e);
        }
    }

}
