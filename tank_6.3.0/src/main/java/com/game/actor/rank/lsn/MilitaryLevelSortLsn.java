package com.game.actor.rank.lsn;

import com.game.actor.rank.RankEvent;
import com.game.manager.RankDataManager;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @author zhangdh
 * @ClassName: MilitaryLevelSortLsn
 * @Description: 军衔等级排行
 * @date 2017-07-06 21:54
 */
@Service
public class MilitaryLevelSortLsn implements IMessageListener{

    @Autowired
    private RankDataManager rankDataManager;

    @Override
    public void onMessage(IMessage msg) {
        RankEvent evt = (RankEvent)msg;
        rankDataManager.upMilitaryRankSort(evt.getPlayer().lord);
    }
}
