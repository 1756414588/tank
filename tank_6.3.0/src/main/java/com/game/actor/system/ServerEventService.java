package com.game.actor.system;

import com.game.actor.system.lsn.ServerLsn;
import com.game.server.Actor.Actor;
import com.game.server.Actor.ActorDataManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;

/**
 * @author zhangdh
 * @ClassName: ServerEventService
 * @Description:
 * @date 2018-01-15 19:37
 */
@Service
public class ServerEventService {

    @Autowired
    private ServerLsn serverLsn;
    @Autowired
    private ActorDataManager actorManager;

    @PostConstruct
    public void init() {
        Actor actor = actorManager.getServerActor();
        actor.regist(ServerEvent.UPDATE_SERVER_MAINTE, serverLsn);
    }

    public void updateServerMainte() {
        ServerEvent event = new ServerEvent(ServerEvent.UPDATE_SERVER_MAINTE);
        actorManager.getServerActor().add(event);
    }
}
