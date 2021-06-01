package com.game.domain.s;

import java.util.List;

public class StaticAltarBossAward {

//	CREATE TABLE `s_altar_boss_award` (
//			  `id` int(11) NOT NULL,
//			  `lv` int(11) NOT NULL COMMENT 'lv: 军团boss等级',
//			  `star` int(11) NOT NULL COMMENT 'star：boss星级',
//			  `award` varchar(255) NOT NULL COMMENT 'award:奖励库配置[type,id,amount,weight]',
//			  PRIMARY KEY (`id`)
//			) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    private int id;
    private int lv;
    private int star;
    List<List<Integer>> award;

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public int getStar() {
        return star;
    }

    public void setStar(int star) {
        this.star = star;
    }

    public List<List<Integer>> getAward() {
        return award;
    }

    public void setAward(List<List<Integer>> award) {
        this.award = award;
    }

    @Override
    public String toString() {
        return "StaticAltarBossAward [id=" + id + ", lv=" + lv + ", star=" + star + ", award=" + award + "]";
    }


}
