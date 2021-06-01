package com.game.actor.rank;

import com.game.actor.rank.lsn.MilitaryLevelSortLsn;
import com.game.actor.rank.lsn.StrongestFormSortLsn;
import com.game.domain.Player;
import com.game.server.Actor.Actor;
import com.game.server.Actor.ActorDataManager;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import javax.annotation.PostConstruct;

/**
 * @author zhangdh
 * @ClassName: RankEventService
 * @Description:
 * @date 2017-07-06 21:40
 */
@Service
public class RankEventService {
    @Autowired
    private ActorDataManager actorDataManager;

    @Autowired
    private StrongestFormSortLsn strongestFormSortLsn;

    @Autowired
    private MilitaryLevelSortLsn militaryLevelSortLsn;

    @PostConstruct
    public void init(){
        Actor actor = actorDataManager.getRankActor();
        actor.regist(RankEvent.RANK_STRONGEST_FROM, strongestFormSortLsn);
        actor.regist(RankEvent.RANK_MILITARY_LEVEL, militaryLevelSortLsn);
    }

    /**
     * 更新玩家最强实力榜
     * @param player
     */
    public void upsertStrongestFormRank(Player player){
        RankEvent evt = new RankEvent(RankEvent.RANK_STRONGEST_FROM, player);
        actorDataManager.getRankActor().add(evt);
    }

    /**
     * 更新玩家军衔等级榜
     * @param player
     */
    public void upsertMilitaryRankSort(Player player){
        RankEvent evt = new RankEvent(RankEvent.RANK_MILITARY_LEVEL, player);
        actorDataManager.getRankActor().add(evt);
    }
}
