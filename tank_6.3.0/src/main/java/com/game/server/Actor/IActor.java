package com.game.server.Actor;

/**
 * @author zhangdh
 * @ClassName: IActor
 * @Description: Actor接口
 * @date 2017/4/1 10:20
 */
public interface IActor {

    /**
     * Actor 名字
     * @return
     */
    String getName();

    /**
     * 关闭Actor actor 不再接受任务
     * @return
     */
    boolean deactivate();

    /**
     * 往Actor 中添加一个消息, 消息将在接下来某个时刻被处理
     * @param msg
     */
    void add(IMessage msg);

    /**
     * 当前消息delay 数量
     * @return
     */
    int getCount();

    /**
     * 注册消息的处理器
     * @param subject 消息的标签栏目
     * @param listener 消息处理器
     */
    void regist(String subject, IMessageListener listener);

}
