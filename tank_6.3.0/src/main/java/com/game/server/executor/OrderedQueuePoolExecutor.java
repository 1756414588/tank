/**
 * @Title: OrderedQueuePoolExecutor.java
 * @Package com.game.server.executor
 * @Description:
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

/**
 * @author ZhangJun
 * @ClassName: OrderedQueuePoolExecutor
 * @Description: 消息处理队列  父类ThreadPoolExecutor的excute方法来执行work
 * @date 2015年7月29日 下午7:42:00
 */
public class OrderedQueuePoolExecutor extends ThreadPoolExecutor {

    // protected static Logger log = Logger.getLogger(OrderedQueuePoolExecutor.class);

    private OrderedQueuePool<Long, AbstractWork> pool = new OrderedQueuePool<Long, AbstractWork>();

    private String name;

    private int corePoolSize;

    private int maxQueueSize;

    /**
     * Title:
     * Description:
     *
     * @param name         队列名 目前有 “消息发送队列” 和 “消息接受队列”
     * @param corePoolSize 核心线程池数
     * @param maxQueueSize 最大线程数
     */
    public OrderedQueuePoolExecutor(String name, int corePoolSize, int maxQueueSize) {
        super(corePoolSize, 2 * corePoolSize, 30, TimeUnit.SECONDS, new LinkedBlockingQueue<Runnable>());
        this.name = name;
        this.corePoolSize = corePoolSize;
        this.maxQueueSize = maxQueueSize;
    }

    /**
     * Title:
     * Description:
     *
     * @param corePoolSize 核心线程池数    队列名queue-pool  最大线程数10000
     */
    public OrderedQueuePoolExecutor(int corePoolSize) {
        this("queue-pool", corePoolSize, 10000);
    }

    /**
     * 增加执行任务
     *
     * @param key  这里是ChannelHandlerContext的唯一编号
     * @param task
     * @return
     */
    public boolean addTask(Long key, AbstractWork task) {
        key = key % corePoolSize;
        TasksQueue<AbstractWork> queue = pool.getTasksQueue(key);
        boolean run = false;
        boolean result;
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

    /**
     * <p>Title: afterExecute</p>
     * <p>Description: 执行完后把指令的状态设置为已执行 并执行下一条指令</p>
     *
     * @param r
     * @param t
     * @see java.util.concurrent.ThreadPoolExecutor#afterExecute(java.lang.Runnable, java.lang.Throwable)
     */
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
     * @return int
     * @Title: getTaskCounts
     * @Description: 获取任务数量
     */
    public int getTaskCounts() {
        int count = super.getActiveCount();

        Iterator<Entry<Long, TasksQueue<AbstractWork>>> iter = pool.getTasksQueues().entrySet().iterator();
        while (iter.hasNext()) {
            Entry<Long, TasksQueue<AbstractWork>> entry = (Entry<Long, TasksQueue<AbstractWork>>) iter.next();
            TasksQueue<AbstractWork> tasksQueue = entry.getValue();
            count += tasksQueue.size();
        }
        return count;
    }
}
