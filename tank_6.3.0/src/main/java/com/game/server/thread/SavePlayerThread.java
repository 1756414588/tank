package com.game.server.thread;

import com.game.domain.Role;
import com.game.manager.PlayerDataManager;
import com.game.server.GameServer;
import com.game.util.LogUtil;

import java.util.HashMap;
import java.util.concurrent.LinkedBlockingQueue;

/**
 * @author ZhangJun
 * @ClassName: SavePlayerThread
 * @Description: 玩家数据保存服务
 * @date 2015年8月24日 上午9:53:32
 */
public class SavePlayerThread extends SaveThread {
    // 命令执行队列
    private LinkedBlockingQueue<Long> role_queue = new LinkedBlockingQueue<Long>();

    private HashMap<Long, Role> role_map = new HashMap<Long, Role>();

    private PlayerDataManager playerDataManager;

    private static int MAX_SIZE = 10000;

    public SavePlayerThread(String threadName) {
        super(threadName);
        dataType = 1;
        this.playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
    }

    @Override
    public void run() {
        stop = false;
        done = false;
        while (!stop || role_queue.size() > 0) {
            Role role = null;
            synchronized (this) {
                Object o = role_queue.poll();
                if (o != null) {
                    long roleId = (Long) o;
                    role = role_map.remove(roleId);
                }
            }
            if (role == null) {
                try {
                    synchronized (this) {
                        wait();
                    }
                } catch (InterruptedException e) {
                    LogUtil.error(threadName + " Wait Exception:" + e.getMessage(), e);
                }
            } else {
                if (role_queue.size() > MAX_SIZE) {
                    role_queue.clear();
                    role_map.clear();
                }
                try {

                    playerDataManager.updateRole(role);

                    if (logFlag) {
                        saveCount++;
                    }

                } catch (Exception e) {
                    LogUtil.error("Role Exception:" + role.getRoleId(), e);
                    LogUtil.warn("Role save Exception:" + role.getRoleId());

                    // 记录出错次数
                    addErrorCount("保存玩家数据出错, roleId:" + role.getRoleId());

                }
            }
        }

        done = true;

        LogUtil.stop("SavePlayer [{}] stopped, save done saveCount = {}", threadName, saveCount);
    }


    @Override
    public void add(Object object) {

        try {
            Role role = (Role) object;
            synchronized (this) {
                if (!role_map.containsKey(role.getRoleId())) {
                    this.role_queue.add(role.getRoleId());
                }
                this.role_map.put(role.getRoleId(), role);
                notify();
            }
        } catch (Exception e) {
            LogUtil.error(threadName + " Notify Exception:" + e.getMessage(), e);
        }
    }

}
