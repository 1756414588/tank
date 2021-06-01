package com.game.crossParty.domain;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

public class GroupParty {
  private int group; // 1A 2B 3C 4D 5E
  public Map<String, Party> groupPartyMap = new HashMap<String, Party>();

  // 组战况
  private List<Integer> groupKeyList = new ArrayList<Integer>();

  // 组排名
  private Map<Integer, Party> rankMap = new HashMap<Integer, Party>();

  public int getGroup() {
    return group;
  }

  public void setGroup(int group) {
    this.group = group;
  }

  public Map<String, Party> getGroupPartyMap() {
    return groupPartyMap;
  }

  public void setGroupPartyMap(Map<String, Party> groupPartyMap) {
    this.groupPartyMap = groupPartyMap;
  }

  public List<Integer> getGroupKeyList() {
    return groupKeyList;
  }

  public void setGroupKeyList(List<Integer> groupKeyList) {
    this.groupKeyList = groupKeyList;
  }

  public Map<Integer, Party> getRankMap() {
    return rankMap;
  }

  public void setRankMap(Map<Integer, Party> rankMap) {
    this.rankMap = rankMap;
  }

  public void addKey(int key) {
    groupKeyList.add(key);
  }
}
