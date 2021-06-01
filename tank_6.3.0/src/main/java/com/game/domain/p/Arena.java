/**
 * @Title: Arena.java
 * @Package com.game.domain.p
 * @Description:
 * @author ZhangJun
 * @date 2015年9月7日 上午10:47:24
 * @version V1.0
 */
package com.game.domain.p;

import com.hundredcent.game.aop.annotation.SaveLevel;
import com.hundredcent.game.aop.annotation.SaveOptimize;

/**
 * @ClassName: Arena
 * @Description: 记录玩家竞技场状态
 * @author ZhangJun
 * @date 2015年9月7日 上午10:47:24
 *
 */
@SaveOptimize(level = SaveLevel.IDLE)
public class Arena implements Cloneable {
    private int rank;
    private long lordId;
    private int score;
    private int count;
    private int lastRank;
    private int winCount;
    private int coldTime;
    private int arenaTime;
    private int awardTime;
    private int buyCount;
    private long fight;

    public int getRank() {
        return rank;
    }

    public void setRank(int rank) {
        this.rank = rank;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public int getLastRank() {
        return lastRank;
    }

    public void setLastRank(int lastRank) {
        this.lastRank = lastRank;
    }

    public int getWinCount() {
        return winCount;
    }

    public void setWinCount(int winCount) {
        this.winCount = winCount;
    }

    public int getColdTime() {
        return coldTime;
    }

    public void setColdTime(int coldTime) {
        this.coldTime = coldTime;
    }

    public int getArenaTime() {
        return arenaTime;
    }

    public void setArenaTime(int arenaTime) {
        this.arenaTime = arenaTime;
    }

    @Override
    public Object clone() {
        try {
            return super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
        return null;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public int getAwardTime() {
        return awardTime;
    }

    public void setAwardTime(int awardTime) {
        this.awardTime = awardTime;
    }

    public int getBuyCount() {
        return buyCount;
    }

    public void setBuyCount(int buyCount) {
        this.buyCount = buyCount;
    }

    @Override
    public String toString() {
        return "Arena{" +
                "rank=" + rank +
                ", lordId=" + lordId +
                ", score=" + score +
                ", count=" + count +
                ", lastRank=" + lastRank +
                ", winCount=" + winCount +
                ", coldTime=" + coldTime +
                ", arenaTime=" + arenaTime +
                ", awardTime=" + awardTime +
                ", buyCount=" + buyCount +
                ", fight=" + fight +
                '}';
    }
}
