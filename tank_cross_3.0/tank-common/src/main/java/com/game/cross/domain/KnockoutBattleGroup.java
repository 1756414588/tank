package com.game.cross.domain;

import java.util.HashMap;
import java.util.Map;

/**
 * 淘汰赛对战组
 *
 * @author wanyi
 */
public class KnockoutBattleGroup {

  private int groupType; // 1A 2B 3C 3D

  // 淘汰赛1-8组 9-12组 13-14组 15组
  public Map<Integer, CompetGroup> groupMaps = new HashMap<Integer, CompetGroup>();

  public int getGroupType() {
    return groupType;
  }

  public Map<Integer, CompetGroup> getGroupMaps() {
    return groupMaps;
  }

  public void setGroupMaps(Map<Integer, CompetGroup> groupMaps) {
    this.groupMaps = groupMaps;
  }

  public void setGroupType(int groupType) {
    this.groupType = groupType;
  }

  @Override
  public String toString() {
    return "KnockoutBattleGroup [groupType=" + groupType + ", groupMaps=" + groupMaps + "]";
  }
}
