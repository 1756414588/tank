package com.game.actor.role;

import com.game.actor.role.lsn.CalcStrongestFormLsn;
import com.game.domain.Player;
import com.game.server.Actor.Actor;
import com.game.server.Actor.ActorDataManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: RoleActorSrv
 * @Description:
 * @date 2017-07-06 10:59
 */
@Service
public class PlayerEventService {

    @Autowired
    private ActorDataManager actorDataManager;
    @Autowired
    private CalcStrongestFormLsn calcStrongestFormLsn;

    @PostConstruct
    public void init() {
        for (Map.Entry<Integer, Actor> entry : actorDataManager.getAllPlayerActor().entrySet()) {
            Actor actor = entry.getValue();
            actor.regist(PlayerEvent.ROLE_CALC_STRONGEST_FORM_AND_FIGHT, calcStrongestFormLsn);
        }
    }

    /**
     * 计算玩家最强实力
     *
     * @param player
     */
    public void calcStrongestFormAndFight(Player player) {
//        Actor actor = actorDataManager.getPlayerActor(player);
//        PlayerEvent evt = new PlayerEvent(PlayerEvent.ROLE_CALC_STRONGEST_FORM_AND_FIGHT);
//        evt.setPlayer(player);
//        actor.add(evt);
    }
}
