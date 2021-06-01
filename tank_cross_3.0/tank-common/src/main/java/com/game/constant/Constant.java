package com.game.constant;

import com.alibaba.fastjson.JSONArray;
import com.game.service.LoadService;

import java.util.ArrayList;
import java.util.List;

/**
 * @ClassName Constant.java @Description TODO
 *
 * @author TanDonghai
 * @date 创建时间：2016年9月12日 下午7:28:53
 */
public class Constant {
  private Constant() {}

  /** 服务器当前玩家等级上限 */
  public static int MAX_ROLE_LEVEL;
  //	/** 配件淬炼提升上升概率次数 */
  //	public static int SMELT_MAX_TIMES;
  //	/** 配件淬炼提升上升概率系数 */
  //	public static float SMELT_UP_RADIO;
  /** 配件淬炼要求角色等级 */
  public static int SMELT_PLAYER_LV = 75;

  public static int MEDAL_RATE = 0;

  /** 奥古斯特复活部队数量权重 */
  public static List<List<Integer>> HERO_REBORN_WEIGHT;

  /**
   * 废墟影响载重减少率 万分率
   */
  public static int RUINS_LOAD_REDUCE;

  public static void loadSystem(LoadService loadService) {
    MAX_ROLE_LEVEL = loadService.getIntegerSystemValue(SystemId.MAX_ROLE_LEVEL, 80);
    //		SMELT_MAX_TIMES = loadService.getIntegerSystemValue(SystemId.SMELT_MAX_TIMES, 0);
    //		int radio = loadService.getIntegerSystemValue(SystemId.SMELT_UP_RADIO, 0);
    //		SMELT_UP_RADIO = 1f -  radio / 100f;
    MEDAL_RATE = loadService.getIntegerSystemValue(SystemId.MEDAL_RATE, 0);

    RUINS_LOAD_REDUCE = loadService.getIntegerSystemValue(SystemId.RUINS_LOAD_REDUCE, 5000);

    loadHeroSystem(loadService);
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
}
