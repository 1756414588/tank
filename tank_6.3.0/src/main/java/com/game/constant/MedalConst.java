package com.game.constant;

import com.alibaba.fastjson.JSONArray;
import com.game.service.LoadService;

import java.util.HashMap;
import java.util.Map;

/**
 * 
* @ClassName: MedalConst 
* @Description: 勋章相关
* @author
 */
public class MedalConst {
	
	public static int UNIVERSAL_MEDAL_CHIP_ID = 1101; //万能碎片id
	
	/** 勋章最高强化等级 */
	public static int MAX_MEDAL_UP_LV;
	
	/** 勋章最高改造等级 */
	public static int MAX_MEDAL_REFIT_LV;

	/** 勋章仓库最大上限容量 */
	public static final int MEDAL_STORE_LIMIT = 300;
	
	/** 勋章温养总冷却时间,单位：s */
	public static int MEDAL_UP_TIME_MAX;

	/** 勋章温养单次花费时间，单位：s */
	public static int MEDAL_UP_TIME;
	
	/** 勋章温养每次的基础经验 */
	public static int MEDAL_UP_ADD_EXP;
	
	/** 勋章位置开放等级 */
	public static Map<Integer, Integer> MEDAL_POS_OPEN_LV;
	
	public static void loadSystem(LoadService loadService) {
		MEDAL_UP_TIME_MAX = loadService.getIntegerSystemValue(SystemId.MEDAL_UP_TIME_MAX, 3600);
		MEDAL_UP_TIME = loadService.getIntegerSystemValue(SystemId.MEDAL_UP_TIME, 180);
		MEDAL_UP_ADD_EXP = loadService.getIntegerSystemValue(SystemId.MEDAL_UP_ADD_EXP, 10);
		loadMedalPosOpenLv(loadService);
		
		MAX_MEDAL_UP_LV = loadService.getIntegerSystemValue(SystemId.MEDAL_UP_OPEN_LV, 80);
		MAX_MEDAL_REFIT_LV = loadService.getIntegerSystemValue(SystemId.MEDAL_REFIT_OPEN_LV, 4);
	}
	
	public static void loadMedalPosOpenLv(LoadService loadService) {
		String str = loadService.getStringSystemValue(SystemId.MEDAL_POS_OPEN_LV, "");
		JSONArray arr = JSONArray.parseArray(str);
		Map<Integer, Integer> map = new HashMap<Integer, Integer>();
		for (int i = 0; i < arr.size(); i++) {
			JSONArray a = arr.getJSONArray(i);
			map.put(a.getInteger(0),a.getInteger(1));
		}
		MEDAL_POS_OPEN_LV = map;
	}

}
