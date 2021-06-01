/**
 * @Title: SaveServer.java @Package com.game.server @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月26日 下午2:34:16
 * @version V1.0
 */
package com.game.server;

import com.game.server.thread.SaveThread;

import java.util.HashMap;
import java.util.Iterator;

/**
 * @ClassName: SaveServer @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月26日 下午2:34:16
 */
public abstract class SaveServer implements Runnable {
  private long createTime;

  protected HashMap<Integer, SaveThread> threadPool = new HashMap<>();

  protected int threadNum;

  protected String name;

  public SaveServer(String name, int threadNum) {
    this.createTime = System.currentTimeMillis();
    this.name = name;
    this.threadNum = threadNum;

    createThreads();
    init();
  }

  public String serverName() {
    return name;
  }

  public void createThreads() {
    for (int i = 0; i < threadNum; i++) {
      threadPool.put(i, createThread(name + " thread " + i));
    }
  }

  public void init() {}

  public abstract void saveData(Object object);

  public boolean saveDone() {
    Iterator<SaveThread> it = threadPool.values().iterator();
    while (it.hasNext()) {
      if (!it.next().workDone()) {
        return false;
      }
    }

    return true;
  }

  public int allSaveCount() {
    int saveCount = 0;
    Iterator<SaveThread> it = threadPool.values().iterator();
    while (it.hasNext()) {
      saveCount += it.next().getSaveCount();
    }
    return saveCount;
  }

  public void stop() {
    Iterator<SaveThread> it = threadPool.values().iterator();
    while (it.hasNext()) {
      it.next().stop(true);
    }
  }

  public void setLogFlag() {
    Iterator<SaveThread> it = threadPool.values().iterator();
    while (it.hasNext()) {
      it.next().setLogFlag();
    }
  }

  public void run() {
    Iterator<SaveThread> it = threadPool.values().iterator();
    while (it.hasNext()) {
      it.next().start();
    }
  }

  public long getCreateTime() {
    return createTime;
  }

  public void setCreateTime(long createTime) {
    this.createTime = createTime;
  }

  public abstract SaveThread createThread(String name);
}
