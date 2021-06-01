package com.game.server.Actor;

/**
 * @author zhangdh
 * @ClassName: Message
 * @Description: 消息
 * @date 2017/4/1 11:02
 */
public class Message implements IMessage {
    protected String subJect;
    protected Object data;

    public Message(String subJect, Object data) {
        this.subJect = subJect;
        this.data = data;
    }
    /**
     * 
    * <p>Title: getSubject</p> 
    * <p>Description: 消息对应的业务标识</p> 
    * @return 
    * @see com.game.server.Actor.IMessage#getSubject()
     */
    @Override
    public String getSubject() {
        return subJect;
    }
    /**
     * 
    * <p>Title: getData</p> 
    * <p>Description: 此消息要处理的数据</p> 
    * @return 
    * @see com.game.server.Actor.IMessage#getData()
     */
    @Override
    public Object getData() {
        return data;
    }
}
