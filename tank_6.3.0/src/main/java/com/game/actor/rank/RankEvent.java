package com.game.actor.rank;

import com.game.domain.Player;
import com.game.server.Actor.Message;

/**
 * @author zhangdh
 * @ClassName: RankEvent
 * @Description:
 * @date 2017-07-06 21:28
 */
public class RankEvent extends Message{
    //最强阵容排行榜
    public static final String RANK_STRONGEST_FROM = "RANK_STRONGEST_FROM";
    //军衔等级排行榜
    public static final String RANK_MILITARY_LEVEL = "RANK_MILITARY_LEVEL";

    private Player player;

    public RankEvent(String subJect, Player player) {
        super(subJect, player);
        this.player = player;
    }

    public Player getPlayer() {
        return player;
    }
}
