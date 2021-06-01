/**
 * @Title: Guard.java
 * @Package com.game.domain.p
 * @Description:
 * @author ZhangJun
 * @date 2015年9月15日 下午3:25:45
 * @version V1.0
 */
package com.game.domain.p;

import com.game.domain.Player;

/**
 * @ClassName: Guard
 * @Description: 防守方
 * @author ZhangJun
 * @date 2015年9月15日 下午3:25:45
 *
 */
public class Guard {
    private Player player;
    private Army army;



    public Army getArmy() {
        return army;
    }

    public void setArmy(Army army) {
        this.army = army;
    }

    public Player getPlayer() {
        return player;
    }

    public void setPlayer(Player player) {
        this.player = player;
    }

    /**
     * @param army
     * @param player
     */
    public Guard(Player player, Army army) {
        super();
        this.army = army;
        this.player = player;
    }

    @Override
    public String toString() {
        return "Guard [lordId=" + player.lord.getLordId() + ", army=" + army + "]";
    }

    public long getFreeWarTime() {
        return army.getFreeWarTime();
    }

    public void setFreeWarTime(long freeWarTime) {

//        LogUtil.info("================="+DateHelper.formatDateTime(new Date(freeWarTime),"yyyy-MM-dd HH:mm:ss"));

        army.setFreeWarTime(freeWarTime);
    }

    public boolean isFreeWar() {
        return System.currentTimeMillis() < army.getFreeWarTime();
    }

    public long getStartFreeWarTime() {
        return army.getStartFreeWarTime();
    }

    public void setStartFreeWarTime(long startFreeWarTime) {
        army.setStartFreeWarTime(startFreeWarTime);
    }
}
