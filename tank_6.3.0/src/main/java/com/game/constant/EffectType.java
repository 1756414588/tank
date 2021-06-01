/**
 * @Title: EffectType.java
 * @Package com.game.constant
 * @Description:
 * @author ZhangJun
 * @date 2015年10月9日 下午1:57:50
 * @version V1.0
 */
package com.game.constant;

/**
 * @ClassName: EffectType
 * @Description: 道具buff
 * @author ZhangJun
 * @date 2015年10月9日 下午1:57:50
 *
 */
public interface EffectType {
    // 增加5种资源50%的基础产量
    int ALL_PRODUCT = 1;

    // 增加宝石50%的基础产量
    int STONE_PRODUCT = 2;

    // 增加铁50%的基础产量
    int IRON_PRODUCT = 3;

    // 增加石油50%的基础产量
    int OIL_PRODUCT = 4;

    // 增加铜50%的基础产量
    int COPPER_PRODUCT = 5;

    // 增加硅50%的基础产量
    int SILICON_PRODUCT = 6;

    // 增加己方部队20%伤害
    int ADD_HURT = 7;

    // 降低敌方部队20%伤害
    int REDUCE_HURT = 8;

    // 部队在世界地图行军速度提升100%
    int MARCH_SPEED = 9;

    // 保护基地免受攻击/侦查.攻击他人后状态取消
    int ATTACK_FREE = 10;

    // 使用改变基地外观.命中+15%.闪避暴击抗暴+5%
    int CHANGE_SURFACE_1 = 11;

    // 使用改变基地外观.5种资源基础产量+25%
    int CHANGE_SURFACE_2 = 12;

    // 使用改变基地外观.增加1个建筑位
    int CHANGE_SURFACE_3 = 13;

    // 使用获得一个暗黑风格的基地外观(有效时间7天)
    int CHANGE_SURFACE_4 = 14;

    // 使用获得一个荒漠风格的基地外观(有效时间7天)
    int CHANGE_SURFACE_5 = 15;

    // 使用获得一个茅草屋基地外观(有效时间7天)
    int CHANGE_SURFACE_6 = 16;

    // 使用获得一个宝石基地外观(有效时间7天)
    int CHANGE_SURFACE_7 = 17;

    // 增加5种资源50%的基础产量
    int WAR_CHAMPION = 18;

    // 增加己方部队30%伤害
    int ADD_HURT_SUPUR = 19;

    // 降低敌方部队30%伤害
    int REDUCE_HURT_SUPER = 20;

    // 部队在世界地图行军速度提升150%
    int MARCH_SPEED_SUPER = 21;

    // 采集加速20%
    int COLLECT_SPEED_SUPER = 22;

    // 建筑建造速度增加5%
    int ADD_BUILD_SPEED_PS = 23;

    // 科技研发速度增加5%
    int ADD_SCIENCE_SPEED_PS = 24;

    // 生产改造坦克速度5%
    int ADD_PRODUCE_SPEED_PS = 25;

    // 每小时获取金币10
    int ADD_GOLD_PER_HOUR_PS = 26;

    // 行军速度增加5%
    int ADD_MARCH_SPEED_PS = 27;

    // 采集速度增加5%
    int ADD_Collect_SPEED_PS = 28;

    // 增加资源生产速度5%
    int ADD_RESOURCE_SPEED_PS = 29;

    // 使用增加一个建筑位
    int ADD_BUILD_POS = 30;

    // 带兵量增加10
    int ADD_LEAD_SOLIDER_NUM = 31;

    /** 采集获得的编制经验增加10% */
    int ADD_STAFFING_COLLECT = 32;

    /** 战斗获得的编制经验增加10% */
    int ADD_STAFFING_FIGHT = 33;

    /** 所有获得的编制经验增加10% */
    int ADD_STAFFING_ALL = 34;

    // 获得1%的广告编制经验加成
    int ADD_STAFFING_AD1 = 35;

    // 获得2%的广告编制经验加成
    int ADD_STAFFING_AD2 = 36;

    // 获得3%的广告编制经验加成
    int ADD_STAFFING_AD3 = 37;

    // 获得4%的广告编制经验加成
    int ADD_STAFFING_AD4 = 38;

    // 获得5%的广告编制经验加成
    int ADD_STAFFING_AD5 = 39;

    // 获得0.4%的广告人物经验加成
    int ADD_STAFFING_ADEXP1 = 40;

    // 获得0.8%的广告人物经验加成
    int ADD_STAFFING_ADEXP2 = 41;

    // 获得1.2%的广告人物经验加成
    int ADD_STAFFING_ADEXP3 = 42;

    // 获得1.6%的广告人物经验加成
    int ADD_STAFFING_ADEXP4 = 43;

    // 获得2%的广告人物经验加成
    int ADD_STAFFING_ADEXP5 = 44;

    // 获得2%的回归人物经验加成
    int ADD_BACK_EXP = 45;

    // 获得20%编制经验加成
    int ADD_STAFFING_ALL2 = 46;

    // 回归玩家增加5种资源50%的基础产量
    int BACK_ALL_PRODUCT = 47;

    // 低等级玩家经验加成
    int LEVEL_EXP_UP = 48;

    // 带兵量减少10
    int SUB_LEAD_SOLIDER_NUM = 122;

    // 建筑建造速度减少10%
    int SUB_BUILD_SPEED_PS = 123;

    // 科技研发速度减少10%
    int SUB_SCIENCE_SPEED_PS = 124;

    // 生产改造坦克速度减少10%
    int SUB_PRODUCE_SPEED_PS = 125;

    // 行军速度减少50%
    int SUB_MARCH_SPEED_PS = 127;

    // 采集速度减少10%
    int SUB_Collect_SPEED_PS = 128;

    // 增加资源生产减少10%
    int SUB_RESOURCE_SPEED_PS = 129;


    // 活动： 建筑升级资源消耗减半 50%
    int ACTIVITY_BUILD_SUB_COST = 200;

    // 活动： 建筑升级加速 100%
    int ACTIVITY_BUILD_ADD_SPEED = 201;

    // 活动： 生产坦克加速 100%
    int ACTIVITY_BUILD_TANK_ADD_SPEED = 202;

    // 活动： 改装坦克加速 100%
    int ACTIVITY_REFIT_TANK_ADD_SPEED = 203;

    // 活动： 资源产量翻倍 100%
    int ACTIVITY_RESOURCE_ADD_SPEED = 204;


    // 基地外观 991
    int CHANGE_SURFACE_991 = 1001;

    // 基地外观 992      命中，抗暴 +20%      闪避，暴击 +10%  5种资源基础产量+60%
    int CHANGE_SURFACE_992 = 1002;
    int CHANGE_SURFACE_2005 = 2015;

    // 使用改变基地外观,持续7天
    int CHANGE_SURFACE_993 = 1003;

    int CHANGE_SURFACE_2001 = 2011;

    //圣诞雪地皮肤
    int CHANGE_SURFACE_2002 = 2012;

    //圣诞雪地皮肤
    int NEW_YEAR_2003 = 2013;
    //叛军 军备buff
    int REBEL_3001 = 3001;


}
