package com.game.server.Actor;

/**
 * @author zhangdh
 * @ClassName: IMessageListener
 * @Description: 监听器  是真正的任务执行者   一个消息会通知多个监听器 去执行任务
 * @date 2017/4/1 10:50
 */
public interface IMessageListener {
    /**
     * 消息处理
     * @param msg
     */
    void onMessage(IMessage msg);
}
