package com.game.util;

import com.game.cross.domain.CrossTrend;
import com.game.cross.domain.JiFenPlayer;
import com.game.crossParty.domain.PartyMember;

import java.util.List;

/**
 * @ClassName CrossTrendHelper.java @Description 跨服战积分详情工具类
 *
 * @author TanDonghai
 * @date 创建时间：2016年10月12日 下午6:56:41
 */
public class CrossTrendHelper {
  /**
   * 增加玩家在跨服战中的积分详情记录
   *
   * @param player
   * @param trendId
   * @param params
   */
  public static void addCrossTrend(JiFenPlayer player, int trendId, String... params) {
    CrossTrend trend = new CrossTrend(trendId, TimeHelper.getCurrentSecond(), params);
    List<CrossTrend> crossTrends = player.crossTrends;
    crossTrends.add(trend);

    while (crossTrends.size() > 30) {
      crossTrends.remove(0);
    }
  }

  public static void addCrossTrend(PartyMember player, int trendId, String... params) {
    CrossTrend trend = new CrossTrend(trendId, TimeHelper.getCurrentSecond(), params);
    List<CrossTrend> crossTrends = player.crossTrends;
    crossTrends.add(trend);

    while (crossTrends.size() > 30) {
      crossTrends.remove(0);
    }
  }
}
