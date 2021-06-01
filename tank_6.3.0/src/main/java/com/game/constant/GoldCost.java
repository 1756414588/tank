/**   
 * @Title: GoldCost.java    
 * @Package com.game.constant    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月10日 下午1:39:27    
 * @version V1.0   
 */
package com.game.constant;

/**
 * @ClassName: GoldCost
 * @Description: 金币消费操作类型
 * @author ZhangJun
 * @date 2015年8月10日 下午1:39:27
 * 
 */
public enum GoldCost {
	REPAIR(1, "REPAIR TANK") {// 修复坦克
	},
	UP_BUILDING(2, "UP BUILDING") {// 升级建筑
	},
	BUY_PROP(3, "BUY PROP") {// 购买道具
	},
	SPEED_BUILD(4, "SPEED BUILD") {// 加速建筑
	},
	EQUIP_STORE(5, "EXPAND EQUIP STORE") {// 扩展装备仓库
	},
	BUY_EXPLORE(6, "BUY EXPLORE") {// 购买探险
	},
	BUY_POWER(7, "BUY POWER") {// 购买能量
	},
	UP_COMMAND(8, "UP COMMAND") {// 升级统帅
	},
	BUY_PROSP(9, "BUY PROSP") {// 购买繁荣度
	},
	BUY_FAME(10, "BUY FAME") {// 购买声望
	},
	RESET_SKILL(11, "RESET SKILL") {// 重置技能
	},
	BUY_ARENA(12, "BUY ARENA") {// 购买竞技场
	},
	MOVE_HOME(13, "MOVE HOME") {// 搬家
	},
	BUY_BUILD(14, "BUY BUILD") {// 购买建筑位
	},
	ACTIVITY_INVEST(15, "ACTIVITY INVEST") {// 活动-投资计划
	},
	ACTIVITY_QUOTA(16, "ACTIVITY QUOTA") {// 活动-购买类
	},
	ACTIVITY_MECHA(17, "ACTIVITY MECHA") {// 活动-机甲洪流
	},
	LOTTERY_HERO(18, "LOTTERY HERO") {// 抽将
	},
	LOTTERY_EQUIP_GREEN(19, "LOTTERY EQUIP GREEN") {// 绿色单抽装备
	},
	LOTTERY_EQUIP_BLUE(20, "LOTTERY EQUIP BLUE") {// 蓝色单抽装备
	},
	LOTTERY_EQUIP_PURPLE_SINGLE(21, "LOTTERY EQUIP PURPLE SINGLE") {// 紫色单抽装备
	},
	LOTTERY_EQUIP_PURPLE_TEN(22, "LOTTERY EQUIP PURPLE TEN") {// 紫色十连抽装备
	},
	PARTY_CREATE(23, "PARTY CREATE") {// 创建帮派
	},
	PARTY_DONATE_HALL(24, "PARTY DONATE HALL") {// 军团捐献
	},
	PARTY_DONATE_SCIENCE(25, "PARTY DONATE SCIENCE") {// 军团科技捐献
	},
	TASK_REFRESH_DAYIY(26, "TASK REFRESH DAYIY") {// 日常任务刷新
	},
	TASK_QUICK_FINISH(27, "TASK QUICK FINISH") {// 快速完成日常任务
	},
	TASK_RESET_DAYIY(28, "TASK_RESET_DAYIY") {// 日常任务重置
	},
	ACTIVITY_PART_EVOLVE(29, "ACTIVITY_PART_EVOLVE") {// （没有）
	},
	ACTIVITY_FLASH_SALE(30, "ACTIVITY_FLASH_SALE") {// （没有）
	},
	ACTIVITY_DAY_BUY(31, "ACTIVITY_DAY_BUY") {// 活动坦克拉霸
	},
	ACTIVITY_FLASH_META(32, "ACTIVITY_FLASH_META") {//
	},
	ACTIVITY_PAWN(33, "ACTIVITY_PAWN") {// 活动极限单兵
	},
	ACTIVITY_PROFOTO(34, "ACTIVITY_PROFOTO") {// 活动-宝藏
	},
	ACTIVITY_GENERAL(35, "ACTIVITY_GENERAL") {
	},
	BLESS_FIGHT(36, "BLESS FIGHT") {// 世界boss祝福
	},
	BOSS_CD(37, "BOSS CD") {// 消除boss cd
	},
	ACTIVITY_VIP_BUY(38, "ACTIVITY_VIP_BUY") {// 活动-VIP礼包
	},
	ARENA_CD(39, "ARENA CD") {// 消除arena cd
	},
	BUY_AUTO_BUILD(40, "BUY AUTO BUILD") {// 购买自动升级建筑
	},
	BUY_VACATION(41, "BUY VACATION") {// 购买度假胜地
	},
	EXCHANGE_PART(42, "EXCHANGE_PART") {// 配件兑换
	},
	EXCHANGE_EQUIP(43, "EXCHANGE_EQUIP") {// 装备兑换
	},
	TOPUP_GAMBLE(44, "TOPUP_GAMBLE") {// 充值下注
	},
	REFRESH_EQUIP_CASH(45, "REFRESH_EQUIP_CASH") {// 刷新装备公式
	},
	REFRESH_PART_CASH(46, "REFRESH_PART_CASH") {// 刷新配件公式
	},
	BUY_SENIOR(47, "BUY SENIOR") {// 购买军事矿区掠夺次数
	},
	CD_PRAY(48, "CD_PRAY") {// 减少祈福CD
	},
	M1A2_BUY(49, "M1A2_BUY") {// 减少M1A2
	},
	UNLOCK_SCIECE_GRID(50,"UNLOCK_SCIECE_GRID"){// 解锁军工科技格子
	},
	BUY_MILITARY(51,"BUY_MILITARY"){//购买军工探险
	},
	BUY_FORTRESS_CD(52,"BUY_FORTRESS_CD"){// 购买要塞战CD
	},
	UP_FORTRESS_ATTR(53,"UP_FORTRESS_ATTR"){// 进修
	},
	BUY_ENERGY_STONE(54,"BUY_ENERGY_STONE"){//购买能晶副本次数
	},
	ALTAR_BOSS_CD(55,"ALTAR_BOSS_CD"){//清除祭坛BOSS的CD时间
	},
	
	CROSS_BET(70,"CROSS_BET"){ // 下注
	},
	;
	public int getCode() {
		return code;
	}

	public void setCode(int code) {
		this.code = code;
	}

	public String getMsg() {
		return msg;
	}

	public void setMsg(String msg) {
		this.msg = msg;
	}

	private GoldCost(int code, String msg) {
		this.code = code;
		this.msg = msg;
	}

	private int code;
	private String msg;
}
