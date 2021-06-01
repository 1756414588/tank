package com.game.server.thread;

import com.game.domain.p.TipGuy;
import com.game.manager.PlayerDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;

import java.util.HashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author
 * @ClassName: SaveGuyThread
 * @Description: 新玩家数据保存线程
 */
public class SaveGuyThread extends SaveThread {
    // 命令执行队列
    private LinkedBlockingQueue<Long> guy_queue = new LinkedBlockingQueue<Long>();

    private HashMap<Long, TipGuy> guy_map = new HashMap<Long, TipGuy>();

    private PlayerDataManager playerDataManager;

    private static int MAX_SIZE = 10000;


    public SaveGuyThread(String threadName) {
        super(threadName);
        dataType = 6;
        this.playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
    }


    @Override
    public void run() {
        stop = false;
        done = false;
        while (!stop || guy_queue.size() > 0) {
            TipGuy guy = null;
            synchronized (this) {
                Long lordId = guy_queue.poll();
                if (lordId != null) {
                    guy = guy_map.remove(lordId);
                }
            }
            if (guy == null) {
                try {
                    synchronized (this) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    LogUtil.error(threadName + " Wait Exception:" + e.getMessage(), e);
                }
            } else {
                if (guy_queue.size() > MAX_SIZE) {
                    guy_queue.clear();
                    guy_map.clear();
                }

                try {
                    playerDataManager.updatGuy(guy);

                    if (logFlag) {
                        saveCount++;
                    }
                } catch (Exception e) {
                    LogUtil.error("Tip guy Exception UPDATE SQL: " + guy.getLordId(), e);
                    LogUtil.warn("Tip guy save Exception");

                    // 记录出错次数
                    addErrorCount("保存举报相关数据出错, roleId:" + guy.getLordId());
                }
            }
        }

        done = true;
        LogUtil.stop("SaveGuy [{}] stopped, save done saveCount = {}", threadName, saveCount);
    }


    @Override
    public void add(Object object) {
        try {
            TipGuy guy = (TipGuy) object;
            synchronized (this) {
                if (!guy_map.containsKey(guy.getLordId())) {
                    this.guy_queue.add(guy.getLordId());
                }
                this.guy_map.put(guy.getLordId(), guy);
                notify();
            }
        } catch (Exception e) {
            LogUtil.error(threadName + " Notify Exception:" + e.getMessage(), e);
        }
    }

}
