package com.game.actor.logplayer;

import com.game.actor.logplayer.lsn.LogPlayerLsn;
import com.game.domain.p.saveplayerinfo.LogPlayer;
import com.game.server.Actor.Actor;
import com.game.server.Actor.ActorDataManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.List;

/**
 * @ClassName:LogPlayerService
 * @author zc
 * @Description:
 * @date 2017年9月25日
 */

@Service
public class LogPlayerService {
	@Autowired
    private ActorDataManager actorManager;

    @Autowired
    private LogPlayerLsn lsn;

    @PostConstruct
    public void init(){
        Actor actor = actorManager.getLogPlayerActor();
        actor.regist(LogPlayerEvent.LOG_PLAYER_ACT, lsn);
    }
    
    /**
    * @Title: logPlayers 
    * @Description: 记录玩家日志 包括基本信息 勋章 装备
    * @param list  
    * void   
     */
    public void logPlayers(List<LogPlayer> list) {
    	LogPlayerEvent event = new LogPlayerEvent(LogPlayerEvent.LOG_PLAYER_ACT, list);
    	actorManager.getLogPlayerActor().add(event);
    }
}
