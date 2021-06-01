package com.game.server.Actor;

/**
 * @author zhangdh
 * @ClassName: IMessage
 * @Description:  消息接口
 * @date 2017/4/1 10:47
 */
public interface IMessage {
    /**
     * 消息的标识
     * @return
     */
    String getSubject();

    /**
     * 消息锁携带的数据
     * @return
     */
    Object getData();
}
