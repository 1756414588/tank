package com.game.domain.s;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/02/28 10:04
 */
public class StaticLaboratorySpy {

//    CREATE TABLE `s_laboratory_spy` (
//            `spyId` int(11) NOT NULL,
//  `name` varchar(255) NOT NULL COMMENT 'name:间谍的名称',
//            `cost` int(11) NOT NULL COMMENT 'cost:雇佣间谍花费金币',
//            `spyAbility` int(11) NOT NULL COMMENT 'spyAbility：间谍的谍报能力，百分数',
//            `spyStar` int(11) NOT NULL COMMENT 'spyStar:谍报能力星星数',
//            `exploreAbility` int(11) NOT NULL COMMENT 'exploreAbility：间谍的探索能力，百分数',
//            `exploreStar` int(11) NOT NULL COMMENT 'exploreStar:谍报能力星星数',
//            `description` varchar(255) NOT NULL COMMENT 'description：间谍描述',
//            `asset` varchar(255) NOT NULL COMMENT 'asset:图片资源文件名',
//    PRIMARY KEY (`spyId`)
//) ENGINE=InnoDB DEFAULT CHARSET=utf8;

    private int spyId;
    private String name;
    private int cost;
    private int spyAbility;
    private int exploreAbility;

    public int getSpyId() {
        return spyId;
    }

    public void setSpyId(int spyId) {
        this.spyId = spyId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public int getCost() {
        return cost;
    }

    public void setCost(int cost) {
        this.cost = cost;
    }

    public int getSpyAbility() {
        return spyAbility;
    }

    public void setSpyAbility(int spyAbility) {
        this.spyAbility = spyAbility;
    }

    public int getExploreAbility() {
        return exploreAbility;
    }

    public void setExploreAbility(int exploreAbility) {
        this.exploreAbility = exploreAbility;
    }
}
