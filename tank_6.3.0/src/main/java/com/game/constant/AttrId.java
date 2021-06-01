/**
 * @Title: AttrId.java
 * @Package com.game.constant
 * @Description:
 * @author ZhangJun
 * @date 2015年8月28日 下午6:02:32
 * @version V1.0
 */
package com.game.constant;

/**
 * @author ZhangJun
 * @ClassName: AttrId
 * @Description: 属性编号
 * @date 2015年8月28日 下午6:02:32
 */
public interface AttrId {
    /**
     * 生命值
     */
    int HP = 1;
    /**
     * 生命百分比
     */
    int HP_F = 2;
    /**
     * 攻击
     */
    int ATTACK = 3;
    /**
     * 攻击百分比
     */
    int ATTACK_F = 4;
    /**
     * 命中
     */
    int HIT = 5;
    ///**命中百分比 */
    // int HIT_F = 6;
    /**
     * 闪避
     */
    int DODGE = 7;
    ///**闪避百分比 */
    // int DODGE_F = 8;
    /**
     * 暴击
     */
    int CRIT = 9;
    ///**百分比 */
    // int CRIT_F = 10;
    /**
     * 抗爆
     */
    int CRITDEF = 11;
    ///** 抗爆百分比 */
    // int CRITDEF_F = 12;
    /**
     * 穿透
     */
    int IMPALE = 13;
    ///** 穿透百分比 */
    // int IMPALE_F = 14;
    /**
     * 防御
     */
    int DEFEND = 15;
    ///** 防御百分比 */
    // int DEFEND_F = 16;
    ///** 减伤 */
    // int INJURED = 17;
    /**
     * 减伤万分比
     */
    int INJURED_F = 18;
    /**
     * 坚韧万分比
     */
    int TENACITY_F = 20;
    /**
     * 爆裂万分比
     */
    int BURST_F = 22;
    /**
     * 掌控(属性集合,暴击，抗暴，命中  实际配置中不存在23)
     */
    int CONTROL = 24;
    /**
     * 生产改造(效率，特殊属性)
     */
    int PRODUCT = 26;
    /**
     * 激活改造(特殊属性)
     */
    int ACTIVATE = 28;
    /**
     * 暴击与抗暴万分比
     */
    int CritAndCritDef_F = 32;
    /**
     * 命中与闪避万分比
     */
    int HitAndDodge_F = 33;
    /**
     * 伤害（增伤）万分比
     */
    int DEMAGE_F = 34;
    /**
     * 穿刺与防护
     */
    int ImpaAndDefend = 35;
    /**
     * 刚毅
     */
    int FORTITUDE = 37;
    /**
     * 震慑
     */
    int FRIGHTEN = 39;


    //***************特殊属性定义***************
    /**
     * 行军速度百分比
     */
    int MARCHING_SPEED = 1011;

    /**
     * 载重百分比
     */
    int LOAD_CAPACITY_ALL = 1020;
    int LOAD_CAPACITY_1 = 1021;
    int LOAD_CAPACITY_2 = 1022;
    int LOAD_CAPACITY_3 = 1023;
    int LOAD_CAPACITY_4 = 1024;



    //****************生产加速属性组****************
    /**
     * 部队生产速度加成百分比
     */
    int PRODUCT_SPEED_ALL = 1030;
    /**
     * 部队生产坦克的速度加成百分比
     */
    int PRODUCT_SPEED_1 = 1031;
    /**
     * 部队生产战车的速度加成百分比
     */
    int PRODUCT_SPEED_2 = 1032;
    /**
     * 部队生产火炮的速度加成百分比
     */
    int PRODUCT_SPEED_3 = 1033;
    /**
     * 部队生产火箭的速度加成百分比
     */
    int PRODUCT_SPEED_4 = 1034;

    //****************改造加速属性组****************
    /**
     * 部队改造速度加成百分比
     */
    int REFIT_SPEED_ALL = 1040;

    /**
     * 部队改造坦克速度加成百分比
     */
    int REFIT_SPEED_1 = 1041;
    /**
     * 部队改造战车速度加成百分比
     */
    int REFIT_SPEED_2 = 1042;
    /**
     * 部队改造火炮速度加成百分比
     */
    int REFIT_SPEED_3 = 1043;
    /**
     * 部队改造火箭速度加成百分比
     */
    int REFIT_SPEED_4 = 1044;

    //带兵量
    int SOLDER = 1051;

}
