package com.game.server.thread;

import com.game.domain.p.UsualActivity;
import com.game.manager.ActivityDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;

import java.util.HashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author
 * @ClassName: SaveActivityThread
 * @Description: 普通活动数据保存线程
 */
public class SaveActivityThread extends SaveThread {
    // 命令执行队列
    private LinkedBlockingQueue<Integer> activity_queue = new LinkedBlockingQueue<Integer>();

    private HashMap<Integer, UsualActivity> acvitivty_map = new HashMap<Integer, UsualActivity>();

    private ActivityDataManager activityDataManager;

    private static int MAX_SIZE = 10000;

    public SaveActivityThread(String threadName) {
        super(threadName);
        dataType = 3;
        this.activityDataManager = GameServer.ac.getBean(ActivityDataManager.class);
    }

    @Override
    public void run() {
        stop = false;
        done = false;
        while (!stop || activity_queue.size() > 0) {
            UsualActivity activity = null;
            synchronized (this) {
                Integer activityId = activity_queue.poll();
                if (activityId != null) {
                    activity = acvitivty_map.remove(activityId);
                }
            }
            if (activity == null) {
                try {
                    synchronized (this) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    LogUtil.error(threadName + " Wait Exception:" + e.getMessage(), e);
                }
            } else {
                if (activity_queue.size() > MAX_SIZE) {
                    activity_queue.clear();
                    acvitivty_map.clear();
                }

                try {
                    activityDataManager.updateActivityData(activity);

                    if (logFlag) {
                        saveCount++;
                    }
                } catch (Exception e) {
                    LogUtil.error("Activity Exception UPDATE SQL: " + activity.getActivityId(), e);
                    LogUtil.warn("Activity save Exception");

                    // 记录出错次数
                    addErrorCount("保存活动数据出错, activityId:" + activity.getActivityId());
                }
            }
        }

        done = true;
        LogUtil.stop("SaveActivity [{}] stopped, save done saveCount = {}", threadName, saveCount);
    }


    @Override
    public void add(Object object) {
        try {
            UsualActivity activity = (UsualActivity) object;
            synchronized (this) {
                if (!acvitivty_map.containsKey(activity.getActivityId())) {
                    this.activity_queue.add(activity.getActivityId());
                }
                this.acvitivty_map.put(activity.getActivityId(), activity);
                notify();
            }
        } catch (Exception e) {
            LogUtil.error(threadName + " Notify Exception:" + e.getMessage(), e);
        }
    }

}
