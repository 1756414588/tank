package com.game.domain.s;

import java.util.List;

public class StaticActKingRank {
//
//    CREATE TABLE `s_act_king_rank` (
//            `id` int(11) NOT NULL,
//  `awardId` int(11) DEFAULT NULL,
//  `type` int(11) DEFAULT NULL COMMENT 'type:类型 1-叛军榜 2-采集榜 3-军功榜 4-个人榜 5-军团榜',
//            `rankBegin` int(11) DEFAULT NULL COMMENT 'rankBegin:开始名次，闭区间',
//            `rankEnd` int(11) DEFAULT NULL COMMENT 'rankEnd：结束区间',
//            `awardList` varchar(255) DEFAULT NULL COMMENT 'awardList:奖励',
//    PRIMARY KEY (`id`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;
//


    private int id;
    private int awardId;
    private int type;
    private int rankBegin;
    private int rankEnd;
    private List<List<Integer>> awardList;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getAwardId() {
        return awardId;
    }

    public void setAwardId(int awardId) {
        this.awardId = awardId;
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getRankBegin() {
        return rankBegin;
    }

    public void setRankBegin(int rankBegin) {
        this.rankBegin = rankBegin;
    }

    public int getRankEnd() {
        return rankEnd;
    }

    public void setRankEnd(int rankEnd) {
        this.rankEnd = rankEnd;
    }

    public List<List<Integer>> getAwardList() {
        return awardList;
    }

    public void setAwardList(List<List<Integer>> awardList) {
        this.awardList = awardList;
    }
}
