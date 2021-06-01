package com.game.domain.s.tactics;

import java.util.List;

public class StaticTacticsBreak {
//
//    CREATE TABLE `s_tactics_break` (
//            `keyId` int(11) NOT NULL COMMENT 'ID',
//            `quality` int(11) NOT NULL COMMENT '品质，1-绿色，2-蓝色，3-紫色，4-橙色',
//            `tacticsType` int(11) NOT NULL COMMENT '战术类型',
//            `lv` int(11) NOT NULL DEFAULT '0' COMMENT '当前等级需要突破才可升级',
//            `breakNeed` varchar(255) NOT NULL COMMENT '突破消耗的道具',
//    PRIMARY KEY (`keyId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;


    private int keyId;
    private int quality;
    private int tacticsType;
    private int lv;
    private List<List<Integer>> breakNeed;
    private int breakChips;


    public int getKeyId() {
        return keyId;
    }

    public void setKeyId(int keyId) {
        this.keyId = keyId;
    }

    public int getQuality() {
        return quality;
    }

    public void setQuality(int quality) {
        this.quality = quality;
    }

    public int getTacticsType() {
        return tacticsType;
    }

    public void setTacticsType(int tacticsType) {
        this.tacticsType = tacticsType;
    }

    public int getLv() {
        return lv;
    }

    public void setLv(int lv) {
        this.lv = lv;
    }

    public List<List<Integer>> getBreakNeed() {
        return breakNeed;
    }

    public void setBreakNeed(List<List<Integer>> breakNeed) {
        this.breakNeed = breakNeed;
    }

    public int getBreakChips() {
        return breakChips;
    }

    public void setBreakChips(int breakChips) {
        this.breakChips = breakChips;
    }
}
