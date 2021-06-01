package com.game.server.thread;

import com.game.domain.p.DbExtreme;
import com.game.manager.ExtremeDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;

import java.util.HashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author ZhangJun
 * @ClassName: SaveExtremeThread
 * @Description: 极限挑战数据保存线程
 * @date 2015年8月24日 上午9:53:32
 */
public class SaveExtremeThread extends SaveThread {
    // 命令执行队列
    private LinkedBlockingQueue<Integer> extremeQue = new LinkedBlockingQueue<Integer>();

    private HashMap<Integer, DbExtreme> extremeMap = new HashMap<Integer, DbExtreme>();

    private ExtremeDataManager extremeDataManager;

    private static int MAX_SIZE = 10000;


    public SaveExtremeThread(String threadName) {
        super(threadName);
        dataType = 5;
        this.extremeDataManager = GameServer.ac.getBean(ExtremeDataManager.class);
    }


    @Override
    public void run() {
        stop = false;
        done = false;
        while (!stop || extremeQue.size() > 0) {
            DbExtreme data = null;
            synchronized (this) {
                Integer id = extremeQue.poll();
                if (id != null) {
                    data = extremeMap.remove(id);
                }
            }
            if (data == null) {
                try {
                    synchronized (this) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    LogUtil.error("DbExtreme Wait Exception", e);
                }
            } else {
                if (extremeQue.size() > MAX_SIZE) {
                    extremeQue.clear();
                    extremeMap.clear();
                }
                try {

                    extremeDataManager.update(data);
                    if (logFlag) {
                        saveCount++;
                    }
                } catch (Exception e) {
                    LogUtil.error("DbExtreme Save Exception:" + data.getExtremeId(), e);
                    synchronized (this) {
                        if (!extremeMap.containsKey(data.getExtremeId())) {
                            this.extremeQue.add(data.getExtremeId());
                            this.extremeMap.put(data.getExtremeId(), data);
                        }
                    }

                    // 记录出错次数
                    addErrorCount("保存挑战数据出错, extremeId:" + data.getExtremeId());
                }
            }
        }

        done = true;
        LogUtil.stop("SaveExtreme [{}] stopped, save done saveCount = {}", threadName, saveCount);
    }

    @Override
    public void add(Object object) {
        try {
            DbExtreme data = (DbExtreme) object;
            LogUtil.save("DbExtreme插入中， 保存极限副本队列剩余：" + this.extremeQue.size() + "|extremeId:" + data.getExtremeId());

            synchronized (this) {
                if (!extremeMap.containsKey(data.getExtremeId())) {
                    this.extremeQue.add(data.getExtremeId());
                }
                this.extremeMap.put(data.getExtremeId(), data);
                notify();
            }
        } catch (Exception e) {
            LogUtil.error("DbExtreme 数据插入队列异常", e);
        }
    }

}
