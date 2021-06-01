package com.game.actor.log;

import com.game.domain.Player;
import com.game.server.Actor.IMessage;

/**
 * @author zhangdh
 * @ClassName: LogEvent
 * @Description:
 * @date 2017-07-05 14:26
 */
public class LogEvent implements IMessage{
    //记录玩家日志到本地(暂不启用)
    public static final String LOG_ROLE_LOGIN_2_LOCAL = "LOG_ROLE_LOGIN_2_LOCAL";
    //登录时向帐号服发送统计日志
    public static final String LOG_ROLE_LOGIN_2_GDPS = "LOG_ROLE_LOGIN_2_GDPS";
    //创建角色时通过账号服向SDK发送统计日志
    public static final String LOG_ROLE_CREATE_2_GDPS = "LOG_ROLE_CREATE_2_GDPS";
    //升级时通过账号服向SDK发送统计日志
    public static final String LOG_ROLE_UP_2_GDPS = "LOG_ROLE_UP_2_GDPS";

    private String subject;

    private Player player;

    public LogEvent(){}

    public LogEvent(String subject, Player player){
        this.subject = subject;
        this.player = player;
    }

    @Override
    public String getSubject() {
        return subject;
    }

    @Override
    public Object getData() {
        return player;
    }

    public Player getPlayer() {
        return player;
    }
}
