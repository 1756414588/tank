package com.game.domain.s.tactics;

import java.util.List;

public class StaticTactics {

//    CREATE TABLE `s_tactics` (
//            `tacticsId` int(11) NOT NULL COMMENT 'ID',
//            `tacticsName` varchar(255) NOT NULL COMMENT '战术名字',
//            `quality` int(11) NOT NULL COMMENT '战术品质：1-绿，2-蓝，3-紫，4-橙',
//            `attrtype` int(11) DEFAULT NULL COMMENT '属性类型，1-命中，2-震慑，用于标识',
//            `tacticstype` int(11) DEFAULT NULL COMMENT '战术类型，1-攻击，2-协防，3-协攻-4-防御',
//            `tanktype` int(11) DEFAULT NULL COMMENT '兵种类型，1-战车，2-坦克，3-火炮，4-火箭，5-全兵种',
//            `attrBase` varchar(255) DEFAULT NULL COMMENT '基础属性',
//            `attrLv` varchar(255) DEFAULT NULL COMMENT '每升1级增加的属性',
//            `asset` varchar(255) DEFAULT NULL COMMENT '战术图标',
//    PRIMARY KEY (`tacticsId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    private int tacticsId;
    private String tacticsName;
    private int quality;
    private int attrtype;
    private int tacticstype;
    private int tanktype;
    private int chipCount;
    private int chipExpOffer;
    private List<List<Integer>> attrBase;
    private List<List<Integer>> attrLv;

    public int getTacticsId() {
        return tacticsId;
    }

    public void setTacticsId(int tacticsId) {
        this.tacticsId = tacticsId;
    }

    public String getTacticsName() {
        return tacticsName;
    }

    public void setTacticsName(String tacticsName) {
        this.tacticsName = tacticsName;
    }

    public int getQuality() {
        return quality;
    }

    public void setQuality(int quality) {
        this.quality = quality;
    }

    public int getAttrtype() {
        return attrtype;
    }

    public void setAttrtype(int attrtype) {
        this.attrtype = attrtype;
    }

    public int getTacticstype() {
        return tacticstype;
    }

    public void setTacticstype(int tacticstype) {
        this.tacticstype = tacticstype;
    }

    public int getTanktype() {
        return tanktype;
    }

    public void setTanktype(int tanktype) {
        this.tanktype = tanktype;
    }

    public List<List<Integer>> getAttrBase() {
        return attrBase;
    }

    public void setAttrBase(List<List<Integer>> attrBase) {
        this.attrBase = attrBase;
    }

    public List<List<Integer>> getAttrLv() {
        return attrLv;
    }

    public void setAttrLv(List<List<Integer>> attrLv) {
        this.attrLv = attrLv;
    }

    public int getChipExpOffer() {
        return chipExpOffer;
    }

    public void setChipExpOffer(int chipExpOffer) {
        this.chipExpOffer = chipExpOffer;
    }

    public int getChipCount() {
        return chipCount;
    }

    public void setChipCount(int chipCount) {
        this.chipCount = chipCount;
    }
}
