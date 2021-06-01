package com.game.actor.log;

import com.game.actor.log.lsn.RoleLoginLog2GdpsLsn;
import com.game.domain.Player;
import com.game.server.Actor.Actor;
import com.game.server.Actor.ActorDataManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;

/**
 * @author zhangdh
 * @ClassName: LogEventService
 * @Description: 管理日志记录
 * @date 2017-07-05 15:08
 */
@Service
public class LogEventService {
    
    @Autowired
    private ActorDataManager actorManager;

    @Autowired
    private RoleLoginLog2GdpsLsn roleLoginLog2GdpsLsn;

    @PostConstruct
    public void init(){
        Actor actor = actorManager.getLogActor();
        actor.regist(LogEvent.LOG_ROLE_LOGIN_2_GDPS, roleLoginLog2GdpsLsn);
        actor.regist(LogEvent.LOG_ROLE_CREATE_2_GDPS, roleLoginLog2GdpsLsn);
        actor.regist(LogEvent.LOG_ROLE_UP_2_GDPS, roleLoginLog2GdpsLsn);
    }

    /**
     * 把玩家登陆信息发送到后台管理系统
     *
     * @param player
     */
    public void sendRoleLogin2Gdps(Player player) {
        sendRole2Gdps(player, LogEvent.LOG_ROLE_LOGIN_2_GDPS);
    }
    
    
    /**
     * 角色创建时把玩家信息发送到后台管理系统
     */
    public void sendRoleCreate2Gdps(Player player) {
        sendRole2Gdps(player, LogEvent.LOG_ROLE_CREATE_2_GDPS);
    }
    
    /**
     * 升级时把玩家信息发送到后台管理系统
     */
    public void sendRoleUp2Gdps(Player player) {
        sendRole2Gdps(player, LogEvent.LOG_ROLE_UP_2_GDPS);
    }
    
    /**
     * 把玩家信息发送到后台管理系统
     */
    public void sendRole2Gdps(Player player, String logType) {
        LogEvent evt = new LogEvent(logType, player);
        actorManager.getLogActor().add(evt);
    }
}
