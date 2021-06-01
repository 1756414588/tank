package com.game.server.Actor;

import com.game.util.LogUtil;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.LinkedBlockingQueue;
import java.util.concurrent.atomic.AtomicBoolean;

/**
 * @author zhangdh
 * @ClassName: Actor
 * @Description: ： actor模型  一个Actor实例将作为一个独立线程中处理一种业务逻辑
 * @date 2017/4/1 09:30
 */
public class Actor implements IActor, Runnable {

    protected String name;

    //消息队列
    protected final LinkedBlockingQueue<IMessage> box;

    //消息处理
    protected Map<String, List<IMessageListener>> listens = new HashMap<>();

    //Actor 是否已经开启
    protected AtomicBoolean isActive;
    
    //Actor 执行状态
    protected boolean isRunning;

    //Actor 管理容器
    protected ActorDataManager manager;

    //Actor 最大处理能力
    protected int maxSize;

    /**
     * 
    * Title: 
    * Description: 
    * @param name 线程名
    * @param maxSize 最大任务数
    * @param manager Actor 管理容器
     */
    public Actor(String name, int maxSize, ActorDataManager manager) {
        this.name = name;
        this.manager = manager;
        this.isActive = new AtomicBoolean(true);
        box = new LinkedBlockingQueue<>(this.maxSize = maxSize);
    }

    /**
     * 
    * <p>Title: regist</p> 
    * <p>Description:  注册 在EventService的init方法中调用  里会注册与消息对应的监听器</p> 
    * @param subject
    * @param listener 
    * @see com.game.server.Actor.IActor#regist(java.lang.String, com.game.server.Actor.IMessageListener)
     */
    @Override
    public void regist(String subject, IMessageListener listener) {
        List<IMessageListener> list = listens.get(subject);
        if (list == null) listens.put(subject, list = new ArrayList<IMessageListener>());
        list.add(listener);
    }

    /**
     * 
    * <p>Title: getName</p> 
    * <p>Description:  线程名</p> 
    * @return 
    * @see com.game.server.Actor.IActor#getName()
     */
    @Override
    public String getName() {
        return this.name;
    }

    
    /**
     * 
    * <p>Title: deactivate</p> 
    * <p>Description: 关闭线程 不再接受任务</p> 
    * @return 
    * @see com.game.server.Actor.IActor#deactivate()
     */
    @Override
    public boolean deactivate() {
        this.isActive.set(false);
        box.clear();
        isRunning = false;
        return true;
    }
    
    /**
     * 
    * <p>Title: add</p> 
    * <p>Description: 消息被加入actor的队列中后   actor会在ThreadPoolExecutor中执行</p> 
    * @param msg 
    * @see com.game.server.Actor.IActor#add(com.game.server.Actor.IMessage)
     */
    @Override
    public void add(IMessage msg) {
        if (isActive.get()) {
            if (box.offer(msg)) {
//                LogUtil.common(String.format("actor name :%s, box size :%d, remain capacity :%d", name, box.size(), box.remainingCapacity()));
                if (!isRunning) {
                    synchronized (this) {
                        if (!isRunning) {
                            isRunning = true;
                            manager.execut(this);
                        }
                    }
                }
            } else {
                if (box.remainingCapacity() == 0) {
                    LogUtil.error(String.format("actor name :%s, box is Full , and  running state :%b", name, isRunning));
                } else {
                    LogUtil.error("add msg fail msg info : " + msg.toString());
                }
            }
        }
    }

    /**
     * 
    * <p>Title: getCount</p> 
    * <p>Description: 当前消息队列长度</p> 
    * @return 
    * @see com.game.server.Actor.IActor#getCount()
     */
    @Override
    public int getCount() {
        return box.size();
    }

    /**
     * 
    * <p>Title: run</p> 
    * <p>Description:  从队列中取出消息  调用对应的所有监听器的onMessage方法执行操作</p>  
    * @see java.lang.Runnable#run()
     */
    @Override
    public void run() {
        IMessage msg;
        while (isActive.get() && (msg = box.poll()) != null) {
            List<IMessageListener> list = listens.get(msg.getSubject());
            if (list != null) {
                for (IMessageListener listener : list) {
                    listener.onMessage(msg);
//                    LogUtil.common(String.format("actor name :%s, box size :%d, remain capacity :%d", name, box.size(), box.remainingCapacity()));
                }
            }
        }
        synchronized (this){
            this.isRunning = false;
        }
    }

    /**
     * 
    * @Title: getMaxSize 
    * @Description: 消息队列最大长度
    * @return  
    * int   

     */
    public int getMaxSize() {
        return maxSize;
    }
}
