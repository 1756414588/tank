package com.game.constant;

import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;

import com.alibaba.fastjson.JSONArray;
import com.game.service.LoadService;
import com.game.util.SentryHelper;

/**
 * @ClassName Constant.java
 * @Description 杂项 * @author TanDonghai
 * @date 创建时间：2016年9月12日 下午7:28:53
 */
public class Constant {
	private Constant() {
	}



	// 不在线玩家保存间隔的变化的周期 （秒）
	public static  int OFFLINE_SAVE_CHANGE_PERIOD = 60 * 60;

	// 不在线玩家保存间隔的变化的基数（秒）
	public static  int OFFLINE_SAVE_CHANGE_TIME = 60;
	/**
	 * 服务器当前玩家等级上限
	 */
	public static int MAX_ROLE_LEVEL;

	// /** 配件淬炼提升上升概率次数 */
	// public static int SMELT_MAX_TIMES;
	// /** 配件淬炼提升上升概率系数 */
	// public static float SMELT_UP_RADIO;
	/**
	 * 配件淬炼要求角色等级
	 */
	public static int SMELT_PLAYER_LV = 75;

	/**
	 * 配件最高改造等级
	 */
	public static int MAX_PART_REFIT_LV = 4;

	/**
	 * 配件最高强化等级
	 */
	public static int MAX_PART_UP_LV = 80;

	/**
	 * 奥古斯特复活部队数量权重
	 */
	public static List<List<Integer>> HERO_REBORN_WEIGHT;

	/**
	 * 角色最高等级
	 */
	public static int PLAYER_OPEN_LV;

	/**
	 * 装备等级上限
	 */
	public static int EQUIP_OPEN_LV;
	/**
	 * 装备星级上限
	 */
	public static int EQUIP_STAR_LV = 5;

	/**
	 * 科技等级上限
	 */
	public static int SCIENCE_OPEN_LV;

	/**
	 * 废墟影响载重减少率 万分率
	 */
	public static int RUINS_LOAD_REDUCE;

	/**
	 * 废墟状态金币恢复所需值
	 */
	public static int RUINS_RECOVER;

	/**
	 * 侦查水晶消耗等级差系数
	 */
	public static int SCOUT_lV_DIFF_RATIO;

	/**
	 * 侦查水晶消耗次数梯度系数
	 */
	public static List<List<Integer>> SCOUT_COUNT_RATIO;

	/**
	 * 每日军功获取上限
	 */
	public static int MPLT_LIMIT_EVERY_DAY;

	public static long STRONGEST_FORM_FIGHT_CALC_F;

	/**
	 * 设备侦查、攻击矿点记录日志打印阈值，小于该数值时不打印
	 */
	public static int LOG_SCOUT_MINE_COUNT;

	/**
	 * Sentry服务器URL
	 */
	public static String SENTRY_DSN;

	/**
	 * 秘密武器开启等级
	 */
	public static int SECRET_WEAPON_OPEN_LEVEL;

	/**
	 * 10(配置)分钟之内扫描矿点大于3次(配置)
	 */
	public static int SCOUT_MINE_PLUG_IN_COUNT = 3;

	/**
	 * 10(配置)分钟之内扫描矿点大于3次(配置)
	 */
	public static int SCOUT_MINE_PLUG_IN_TIME_SEC = 600;

	/**
	 * IP白名单
	 */
	public static Set<String> WHITE_IPS = new HashSet<>();

	public static int CROSS_REG_LEVEL;

	/**
	 * 保存优化功能开关
	 */
	public static int SAVE_OPTIMIZE_SWITCH = 1;

	/**
	 * 保存优化功能配置
	 */
	// public static PersistenceConfig persistenceConfig;

	/**
	 * 服务器状态日志打印周期
	 */
	public static int SERVER_STATUS_LOG_PERIOD = 60 * 1000;

	/**
	 * 低等级经验加成BUFF <等级， 加成比率>
	 */
	public static List<List<Float>> LEVEL_EXP_BUFF = new ArrayList<>();

	public static int LAST_MAX_LEVEL = 90;

	public static int MEDAL_RATE = 0;
	public static int HERO_GOLD = 0;

	/**  */
	public static float AD_MIN_COUNT = 8;//进入监测范围的最小内容字符数
	public static float AD_RATE = 0.7f;//相似比率70%则视为一样
	public static int AD_COMPARE_COUNT = 3;//对最近3条进行比较
	public static int AD_SILENCE_TIME = 5;//禁言时间


	public static int NEW_HERO_CD = 0;
	public static int NEW_HERO_COUNT = 0;
	public static int NEW_HERO_CD_PRICE = 0;
	public static int VCODE_SCOUT_COUNT = 0;



	public static void loadSystem(LoadService loadService) {


		VCODE_SCOUT_COUNT = loadService.getIntegerSystemValue(SystemId.VCODE_SCOUT_COUNT, 50);

		NEW_HERO_CD = loadService.getIntegerSystemValue(SystemId.NEW_HERO_CD, 0);
		NEW_HERO_COUNT = loadService.getIntegerSystemValue(SystemId.NEW_HERO_COUNT, 0);
		NEW_HERO_CD_PRICE = loadService.getIntegerSystemValue(SystemId.NEW_HERO_CD_PRICE, 0);

		MAX_ROLE_LEVEL = loadService.getIntegerSystemValue(SystemId.MAX_ROLE_LEVEL, 80);
		// SMELT_MAX_TIMES = loadService.getIntegerSystemValue(SystemId.SMELT_MAX_TIMES, 0);
		// int radio = loadService.getIntegerSystemValue(SystemId.SMELT_UP_RADIO, 0);
		// SMELT_UP_RADIO = 1f - radio / 100f;
		loadHeroSystem(loadService);
		MAX_PART_REFIT_LV = loadService.getIntegerSystemValue(SystemId.MAX_PART_REFIT_LV, 4);
		MAX_PART_UP_LV = loadService.getIntegerSystemValue(SystemId.MAX_PART_UP_LV, 80);
		PLAYER_OPEN_LV = loadService.getIntegerSystemValue(SystemId.PLAYER_OPEN_LV, 80);
		EQUIP_OPEN_LV = loadService.getIntegerSystemValue(SystemId.EQUIP_OPEN_LV, 80);
		SCIENCE_OPEN_LV = loadService.getIntegerSystemValue(SystemId.SCIENCE_OPEN_LV, 80);
		RUINS_LOAD_REDUCE = loadService.getIntegerSystemValue(SystemId.RUINS_LOAD_REDUCE, 5000);
		RUINS_RECOVER = loadService.getIntegerSystemValue(SystemId.RUINS_RECOVER, 10000);
		SCOUT_lV_DIFF_RATIO = loadService.getIntegerSystemValue(SystemId.SCOUT_lV_DIFF_RATIO, 10000);
		SCOUT_COUNT_RATIO = loadService.getListListIntSystemValue(SystemId.SCOUT_COUNT_RATIO, "");
		MPLT_LIMIT_EVERY_DAY = loadService.getIntegerSystemValue(SystemId.MPLT_LIMIT_EVERY_DAY, 100000);
		STRONGEST_FORM_FIGHT_CALC_F = loadService.getLongSystemValue(SystemId.STRONGEST_FORM_FIGHT_CALC_F, 12345);
		LOG_SCOUT_MINE_COUNT = loadService.getIntegerSystemValue(SystemId.LOG_SCOUT_MINE_COUNT, 20);
		CROSS_REG_LEVEL = loadService.getIntegerSystemValue(SystemId.CROSS_REG_LEVEL, 50);
		SENTRY_DSN = loadService.getStringSystemValue(SystemId.SENTRY_DSN, null);
		LAST_MAX_LEVEL = loadService.getIntegerSystemValue(SystemId.LAST_MAX_LEVEL, 90);
		MEDAL_RATE = loadService.getIntegerSystemValue(SystemId.MEDAL_RATE, 0);
		HERO_GOLD = loadService.getIntegerSystemValue(SystemId.HERO_GOLD, 0);
		// 初始化Sentry
		SentryHelper.initSentry(SENTRY_DSN);
		SECRET_WEAPON_OPEN_LEVEL = loadService.getIntegerSystemValue(SystemId.SECRET_WEAPON, 60);
		String plugIn = loadService.getStringSystemValue(SystemId.SCOUT_MINE_PLUG_IN, "600,3");
		String[] plugInArr = plugIn.split(",");
		SCOUT_MINE_PLUG_IN_TIME_SEC = Integer.parseInt(plugInArr[0]);
		SCOUT_MINE_PLUG_IN_COUNT = Integer.parseInt(plugInArr[1]);
		String ipstr = loadService.getStringSystemValue(SystemId.WHITE_IPS, "");
		WHITE_IPS.clear();
		if (!"".equals(ipstr)) {
			String[] ips = ipstr.split(",");
			for (String ip : ips) {
				WHITE_IPS.add(ip);
			}
		}

		// 保存优化
		// SAVE_OPTIMIZE_SWITCH = loadService.getIntegerSystemValue(SystemId.SAVE_OPTIMIZE_SWITCH, 1);
		// String configStr = loadService.getStringSystemValue(SystemId.SAVE_OPTIMIZE_CONFIG, "{}");
		// try {
		// persistenceConfig = JSON.parseObject(configStr, PersistenceConfig.class);
		// } catch (Exception e) {
		// LogUtil.error("保存优化相关配置错误:" + persistenceConfig, e);
		// persistenceConfig = null;
		// }
		SERVER_STATUS_LOG_PERIOD = loadService.getIntegerSystemValue(SystemId.SERVER_STATUS_LOG_PERIOD, 60) * 1000;
		LEVEL_EXP_BUFF = loadLevelExpBuff(loadService);
	}

	private static void loadHeroSystem(LoadService loadService) {
		String str = loadService.getStringSystemValue(SystemId.HERO_REBORN_WEIGHT, "[[1,70],[2,30]]");
		JSONArray arr = JSONArray.parseArray(str);
		List<List<Integer>> weight = new ArrayList<>();
		for (int i = 0; i < arr.size(); i++) {
			JSONArray a = arr.getJSONArray(i);
			List<Integer> wArr = new ArrayList<>();
			wArr.add(a.getInteger(0));
			wArr.add(a.getInteger(1));
			weight.add(wArr);
		}
		HERO_REBORN_WEIGHT = weight;
	}

	private static List<List<Float>> loadLevelExpBuff(LoadService loadService) {
		String levelExpBuff = loadService.getStringSystemValue(SystemId.LEVEL_EXP_BUFF, "[[0,100,0]]");
		JSONArray arr = JSONArray.parseArray(levelExpBuff);
		List<List<Float>> buff = new ArrayList<>();
		for (int i = 0; i < arr.size(); i++) {
			JSONArray a = arr.getJSONArray(i);
			List<Float> list = new ArrayList<Float>();
			list.add(a.getFloat(0));
			list.add(a.getFloat(1));
			list.add(a.getFloat(2));
			buff.add(list);
		}
		return buff;
	}

}
