package com.game.actor.system;

import com.game.server.Actor.IMessage;

/**
 * @author zhangdh
 * @ClassName: ServerEvent
 * @Description:
 * @date 2018-01-15 14:41
 */
public class ServerEvent implements IMessage {
    /**
     * 更新服务器维护时间
     */
    public static final String UPDATE_SERVER_MAINTE = "UPDATE_SERVER_MAINTE";

    private String subject;

    public ServerEvent(String subject){
        this.subject = subject;
    }

    @Override
    public String getSubject() {
        return subject;
    }

    @Override
    public Object getData() {
        return null;
    }
}
