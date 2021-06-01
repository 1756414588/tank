/**
 * @Title: OrderedQueuePoolExecutor.java @Package com.game.server.executor @Description: TODO
 * @author ZhangJun
 * @date 2015年7月29日 下午7:42:00
 * @version V1.0
 */
package com.game.server.executor;

import com.game.server.structs.OrderedQueuePool;
import com.game.server.structs.TasksQueue;
import com.game.server.work.AbstractWork;
import com.game.util.LogUtil;

import java.util.Iterator;
import java.util.Map.Entry;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.ThreadPoolExecutor;
import java.util.concurrent.TimeUnit;

public class OrderedQueuePoolExecutor extends ThreadPoolExecutor {


    private OrderedQueuePool<Long, AbstractWork> pool = new OrderedQueuePool<Long, AbstractWork>();

    private String name;

    private int corePoolSize;

    private int maxQueueSize;

    public OrderedQueuePoolExecutor(String name, int corePoolSize, int maxQueueSize) {
        super(
                corePoolSize, 2 * corePoolSize, 30, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
        this.name = name;
        this.corePoolSize = corePoolSize;
        this.maxQueueSize = maxQueueSize;
    }

    public OrderedQueuePoolExecutor(int corePoolSize) {
        this("queue-pool", corePoolSize, 10000);
    }

    /**
     * 增加执行任务
     *
     * @param key
     * @return
     */
    public boolean addTask(Long key, AbstractWork task) {
        key = key % corePoolSize;
        TasksQueue<AbstractWork> queue = pool.getTasksQueue(key);
        boolean run = false;
        boolean result = false;
        synchronized (queue) {
            if (maxQueueSize > 0) {
                if (queue.size() > maxQueueSize) {
                    LogUtil.error("队列" + name + "(" + key + ")" + "抛弃指令!");
                    queue.clear();
                }
            }
            result = queue.add(task);
            if (result) {
                task.setTasksQueue(queue);
                {
                    if (queue.isProcessingCompleted()) {
                        queue.setProcessingCompleted(false);
                        run = true;
                    }
                }

            } else {
                LogUtil.error("orderedqueue队列添加任务失败");
            }
        }
        if (run) {
            execute(queue.poll());
        }
        return result;
    }

    @Override
    protected void afterExecute(Runnable r, Throwable t) {
        super.afterExecute(r, t);

        AbstractWork work = (AbstractWork) r;
        TasksQueue<AbstractWork> queue = work.getTasksQueue();
        if (queue != null) {
            AbstractWork afterWork = null;
            synchronized (queue) {
                afterWork = queue.poll();
                if (afterWork == null) {
                    queue.setProcessingCompleted(true);
                }
            }
            if (afterWork != null) {
                execute(afterWork);
            }
        }

    }


    /**
     * 获取剩余任务数量
     */
    public int getTaskCounts() {
        int count = super.getActiveCount();

        Iterator<Entry<Long, TasksQueue<AbstractWork>>> iter =
                pool.getTasksQueues().entrySet().iterator();
        while (iter.hasNext()) {
            Entry<Long, TasksQueue<AbstractWork>> entry = (Entry<Long, TasksQueue<AbstractWork>>) iter.next();
            TasksQueue<AbstractWork> tasksQueue = entry.getValue();
            count += tasksQueue.size();
        }
        return count;
    }
}
