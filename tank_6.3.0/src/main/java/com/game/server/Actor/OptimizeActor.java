package com.game.server.Actor;

import com.game.actor.role.PlayerEvent;
import com.game.domain.Player;
import com.game.util.LogUtil;

import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.concurrent.ConcurrentHashMap;
import java.util.concurrent.ConcurrentSkipListSet;

/**
 * @author zhangdh
 * @ClassName: OptimizeActor 
 * @Description: 优化版本的Actor   会记录消息该消息对应玩家的关系  避免一个时间点内 针对一个玩家处理了多个相同类型的消息
 * @date 2017-07-06 16:04
 */
public class OptimizeActor extends Actor {
    private Map<String, Set<Long>> players = new ConcurrentHashMap<>();

    public OptimizeActor(String name, int maxSize, ActorDataManager manager) {
        super(name, maxSize, manager);
    }

    /**
     * 
    * <p>Title: add</p> 
    * <p>Description:    会先判断队列中有没有该玩家的该消息 没有才会将该消息添加进队列 </p> 
    * @param msg 
    * @see com.game.server.Actor.Actor#add(com.game.server.Actor.IMessage)
     */
    @Override
    public void add(IMessage msg) {
        if (!doSimilarity(msg)) {
            if (isActive.get()) {
                if (box.offer(msg)) {
                    addPlayerMsgRelation(msg);//记录队列中玩家消息信息
                    LogUtil.common(String.format("actor name :%s, box size :%d, remain capacity :%d", name, box.size(), box.remainingCapacity()));
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
    }

    /**
     * 记录消息与玩家对应的关系
     *
     * @param msg
     */
    private void addPlayerMsgRelation(IMessage msg) {
        //记录消息与玩家的关系
        Set<Long> set = players.get(msg.getSubject());
        if (set == null) players.put(msg.getSubject(), set = new ConcurrentSkipListSet<Long>());
        set.add(((PlayerEvent) msg).getPlayer().roleId);
    }

    /**
     *      删除消息类型与玩家的关系
     * @param msg
     */
    private void removePlayerMsgRelation(IMessage msg) {
        Set<Long> set = players.get(msg.getSubject());
        if (set != null) {
            Player player = ((PlayerEvent) msg).getPlayer();
            set.remove(player.roleId);
        }
    }

    /**
     * 判断消息是否重复(有些消息同一个时间点只需要执行一次)
     *
     * @param msg
     * @return true - 去重复成功不需要加入队列处理
     */
    private boolean doSimilarity(IMessage msg) {
        PlayerEvent evt = (PlayerEvent) msg;
        if (evt.needSimilarity()) {
            Set<Long> playersSet = players.get(msg.getSubject());
            if (playersSet != null) {
                return playersSet.contains(evt.getPlayer().roleId);
            }
        }
        return false;
    }

    /**
     * 
    * <p>Title: run</p> 
    * <p>Description: 在通知监听执行了任务后 删除该消息与玩家对应的关系</p>  
    * @see com.game.server.Actor.Actor#run()
     */
    @Override
    public void run() {
        IMessage msg;
        while (isActive.get() && (msg = box.poll()) != null) {
            List<IMessageListener> list = listens.get(msg.getSubject());
            if (list != null) {
                for (IMessageListener listener : list) {
                    listener.onMessage(msg);
                    removePlayerMsgRelation(msg);
                    LogUtil.common(String.format("actor name :%s, box size :%d, remain capacity :%d", name, box.size(), box.remainingCapacity()));
                }
            }
        }
        this.isRunning = false;
    }
}
