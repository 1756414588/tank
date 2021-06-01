/**
 * @Title: AwardType.java
 * @Package com.game.constant
 * @Description:
 * @author ZhangJun
 * @date 2015年8月31日 下午1:43:57
 * @version V1.0
 */
package com.game.constant;

/**
 * @author ZhangJun
 * @ClassName: AwardType
 * @Description:属性/道具类型
 * @date 2015年8月31日 下午1:43:57
 */
public interface AwardType {
    // 经验
    int EXP = 1;

    // 繁荣度
    int PROS = 2;

    // 声望
    int FAME = 3;

    // 荣誉
    int HONOUR = 4;

    // 道具 id对应道具表
    int PROP = 5;

    // 装备 id对应装备表
    int EQUIP = 7;

    // 配件 id对应配件表
    int PART = 8;

    // 碎片 id对应配件表
    int CHIP = 9;

    // 配件材料 id对应关系 1.零件 2.记忆金属 3.设计蓝图 4.金属矿物 5.改造工具 6.改造图纸 7.坦克驱动 8.战车驱动 9.火炮驱动 10.火箭驱动
    int PART_MATERIAL = 10;

    // 竞技场积分
    int SCORE = 11;

    // 军团贡献度
    int CONTRIBUTION = 12;

    // 荒宝碎片
    int HUANGBAO = 13;

    // 坦克 id对应坦克表
    int TANK = 14;

    // 将领 id对应将领表
    int HERO = 15;

    // 金币
    int GOLD = 16;

    // 资源 1.铁 2.石油 3.铜 4.硅 5.宝石
    int RESOURCE = 17;

    // 军团建设度
    int PARTY_BUILD = 18;

    // 能量
    int POWER = 19;

    // 红包(不能通过PlayerDataManager.addAward来增加红包金币，必须使用)
    int RED_PACKET = 20;

    //科技
    int SCIENCE = 21;

    //头像
    int ICON = 22;

    // 军工材料
    int MILITARY_MATERIAL = 23;

    // 能晶
    int ENERGY_STONE = 24;

    // 功勋
    int EXPLOIT = 25;

    // 编制经验
    int STAFFING = 26;

    // 跨服战积分
    int CROSS_JIFEN = 27;

    // 勋章
    int MEDAL = 28;

    // 勋章碎片
    int MEDAL_CHIP = 29;

    // 勋章材料
    int MEDAL_MATERIAL = 30;

    //31 - 觉醒将领
    int AWARK_HERO = 31;

    //军备
    int LORD_EQUIP = 32;

    //军备材料(包含图纸和材料)
    int LORD_EQUIP_METERIAL = 33;

    //35 军备技工(客户端使用)

    //军功
    int MILITARY_EXPLOIT = 36;

    //攻击特效
    int ATTACK_EFFECT = 37;
    
    //作战研究院物品
    int LAB_FIGHT = 38;
    
    //赏金代币
    int BOUNTY = 39;
    
    //世界红包
    int WORLD_RED_BAG = 40;


    //战术
    int TACTICS = 42;
    //战术碎片
    int TACTICS_SLICE = 43;
    //战术材料
    int TACTICS_ITEM = 44;



    // 活动虚拟道具
    int ACTIVITY_PROP = 100;

    // buff
    int BUFF = 2001;

}
