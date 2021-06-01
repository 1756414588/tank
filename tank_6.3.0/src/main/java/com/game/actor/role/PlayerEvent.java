package com.game.actor.role;

import com.game.domain.Player;
import com.game.server.Actor.Message;

/**
 * @author zhangdh
 * @ClassName: PlayerEvent
 * @Description:
 * @date 2017-07-06 10:46
 */
public class PlayerEvent extends Message {

    //计算玩家最强战力
    public static final String ROLE_CALC_STRONGEST_FORM_AND_FIGHT = "ROLE_CALC_STRONGEST_FORM_AND_FIGHT";

    private Player player;

    public PlayerEvent(String subJect) {
        super(subJect, null);
    }

    public Player getPlayer() {
        return player;
    }

    public void setPlayer(Player player) {
        this.player = player;
    }


    /**
     * 消息是否需要去重优化
     *
     * @return
     */
    public boolean needSimilarity() {
        return ROLE_CALC_STRONGEST_FORM_AND_FIGHT.equals(subJect);
    }

}
