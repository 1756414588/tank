/**
 * @Title: ScoreRank.java
 * @Package com.game.domain
 * @Description:
 * @author ZhangJun
 * @date 2016年3月18日 下午3:59:02
 * @version V1.0
 */
package com.game.domain;

import com.game.pb.CommonPb;
import com.game.pb.SerializePb;

/**
 * @author ZhangJun
 * @ClassName: ScoreRank
 * @Description: 军事矿区排名
 * @date 2016年3月18日 下午3:59:02
 */
public class SeniorScoreRank {
    private long lordId;
    private long fight;
    private int score;
    private boolean get;

    public boolean getGet() {
        return get;
    }

    public void setGet(boolean get) {
        this.get = get;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public CommonPb.SeniorScore ser() {
        CommonPb.SeniorScore.Builder builder = CommonPb.SeniorScore.newBuilder();
        builder.setLordId(lordId);
        builder.setFight(fight);
        builder.setScore(score);
        builder.setGet(get);
        return builder.build();
    }

    public SeniorScoreRank(CommonPb.SeniorScore seniorScore) {
        lordId = seniorScore.getLordId();
        fight = seniorScore.getFight();
        score = seniorScore.getScore();
        get = seniorScore.getGet();
    }

    /**
     * 初始化玩家排名
     *
     * @param player
     */
    public SeniorScoreRank(CrossPlayer player) {
        lordId = player.getRoleId();
        fight = player.getFight();
        score = player.getSenScore();
    }

    /**
     * 初始服务器家排名
     */
    public SeniorScoreRank(int serverId) {
        lordId = serverId;
    }


    public SeniorScoreRank(SerializePb.CrossMineServerRank crossServerRank) {
        this.lordId = crossServerRank.getServerId();
        this.score = crossServerRank.getScore();
    }

    public SerializePb.CrossMinePlayerRank dserPlayerRank() {
        SerializePb.CrossMinePlayerRank.Builder rank = SerializePb.CrossMinePlayerRank.newBuilder();
        rank.setRoleId(this.getLordId());
        rank.setGet(this.get);
        rank.setScore(this.score);
        return rank.build();
    }

    public SerializePb.CrossMineServerRank dserServerRank() {
        SerializePb.CrossMineServerRank.Builder rank = SerializePb.CrossMineServerRank.newBuilder();
        rank.setServerId(this.getLordId());
        rank.setScore(this.score);
        return rank.build();
    }


}
