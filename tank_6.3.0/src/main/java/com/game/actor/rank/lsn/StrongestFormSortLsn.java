package com.game.actor.rank.lsn;

import com.game.actor.rank.RankEvent;
import com.game.domain.p.Lord;
import com.game.manager.RankDataManager;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @author zhangdh
 * @ClassName: RankStrongestFormLsn
 * @Description:
 * @date 2017-07-06 21:33
 */
@Service
public class StrongestFormSortLsn implements IMessageListener {
    @Autowired
    private RankDataManager rankDataManager;

    @Override
    public void onMessage(IMessage msg) {
//        long start = System.nanoTime();
        String subject = msg.getSubject();
        Lord lord = ((RankEvent) msg).getPlayer().lord;
        rankDataManager.upStrongestFormRankSortInfo(lord);
//        long end = System.nanoTime();
//        LogUtil.common(String.format("upsert :%s, strongest form rank cost :%d", lord.getNick(), (end - start) / NumberHelper.I_MILLION));
    }
}
