/**
 * @Title: TaskQueue.java @Package com.game.server.structs @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月29日 下午7:30:52
 * @version V1.0
 */
package com.game.server.structs;

import java.util.ArrayDeque;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

/**
 * @ClassName: TaskQueue @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年7月29日 下午7:30:52
 */

/** 命令队列 */
public class TasksQueue<V> {

  private Lock lock = new ReentrantLock();
  /** 命令队列 */
  private final ArrayDeque<V> tasksQueue = new ArrayDeque<V>();

  private boolean processingCompleted = true;

  /**
   * 下一执行命令
   *
   * @return
   */
  public V poll() {
    try {
      lock.lock();
      return tasksQueue.poll();
    } finally {
      lock.unlock();
    }
  }

  /**
   * 增加执行指令
   *
   * @param command
   * @return
   */
  public boolean add(V value) {
    try {
      lock.lock();
      return tasksQueue.add(value);
    } finally {
      lock.unlock();
    }
  }

  /** 清理 */
  public void clear() {
    try {
      lock.lock();
      tasksQueue.clear();
    } finally {
      lock.unlock();
    }
  }

  /**
   * 获取指令数量
   *
   * @return
   */
  public int size() {
    return tasksQueue.size();
  }

  public boolean isProcessingCompleted() {
    return processingCompleted;
  }

  public void setProcessingCompleted(boolean processingCompleted) {
    this.processingCompleted = processingCompleted;
  }
}
