/**   
 * @Title: ScienceId.java    
 * @Package com.game.constant    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年10月9日 下午4:34:25    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: ScienceId
 * @Description: 科技类型
 * @author ZhangJun
 * @date 2015年10月9日 下午4:34:25
 * 
 */
public interface ScienceId {
	// 铁矿精炼,每级增加铁矿产量5%
	final int IRON_REFINE = 101;

	// 石油精炼,每级增加石油产量5%
	final int OIL_REFINE = 102;

	// 铜矿精炼,每级增加铜矿产量5%
	final int COPPER_REFINE = 103;

	// 硅矿精炼,每级增加硅矿产量5%
	final int SILICON_REFINE = 104;

	// 宝石抛光,每级增加宝石产量5%
	final int STONE_REFINE = 105;

	// 坦克维护,每级增加坦克生命5%
	final int TANK_HP = 106;

	// 坦克攒射,每级增加坦克攻击5%
	final int TANK_ATTACK = 107;

	// 战车维护,每级增加战车生命5%
	final int ZHANCHE_HP = 108;

	// 战车攒射,每级增加战车攻击5%
	final int ZHANCHE_ATTACK = 109;

	// 火炮维护,每级增加火炮生命5%
	final int HUOPAO_HP = 110;

	// 火炮攒射,每级增加火炮攻击5%
	final int HUOPAO_ATTACK = 111;

	// 火箭维护,每级增加火箭生命5%
	final int HUOJIAN_HP = 112;

	// 火箭攒射,每级增加火箭攻击5%
	final int HUOJIAN_ATTACK = 113;

	// 存储技术,每级增加所有资源容量5%.增加仓库保护量5%
	final int STORAGE = 114;

	// 战斗经验,每级增加战斗经验5%
	final int FIGHT_EXP = 115;

	// 引擎强化,每级增加行军速度5%
	final int ENGINE = 116;

	// 建筑设计,每级增加建筑升级速度5%
	final int BUILD = 117;

	// 载重技术,每级增加1%部队载重
	final int PAY_LOAD = 201;

	// 命中加成,每级增加1%部队命中
	final int HIT = 202;

	// 闪避加成,每级增加1%部队闪避
	final int DODGE = 203;

	// 暴击加成,每级增加1%部队加成
	final int CRIT = 204;

	// 抗暴加成,每级增加1%部队抗暴
	final int CRIT_DEF = 205;

	// 仓储技术,每级增加1%所有资源容量,并增加仓库保护量1%
	final int PARTY_STORAGE = 206;

	// 基地攻击,守卫基地时,每级增加己方1%伤害
	final int HURT_ADD = 207;

	// 基地防御,守卫基地时,每级减少敌方1%伤害
	final int HURT_REDUCE = 208;

	// 战斗经验,每级增加1%战斗经验
	final int PARTY_FIGHT_EXP = 209;

	// 关卡攻击,攻打关卡时每级增加1%己方伤害
	final int COMBAT_HURT_ADD = 210;

	// 关卡防御,攻打关卡时每级减少1%敌方伤害
	final int COMBAT_HURT_REDUCE = 211;

	// 火线支援,军团驻军,每级增加10%行军速度
	final int PARTY_MARCH_TIME = 212;
	//每级增加0.5%四阶以上部队（风琴火箭等级以上的部队）载重
	final int PAY_LOAD_215 = 215;

	//免除PVE战斗战损
    final int PVE_HAUST_EXEPMT = 100;
}
