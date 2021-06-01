package com.game.crossParty.domain;

import java.util.ArrayList;
import java.util.List;

public class ServerSisuation {
  private int serverId;
  private List<Integer> groupKeyList = new ArrayList<Integer>();
  private List<Integer> finalKeyList = new ArrayList<Integer>();

  public List<Integer> getGroupKeyList() {
    return groupKeyList;
  }

  public void setGroupKeyList(List<Integer> groupKeyList) {
    this.groupKeyList = groupKeyList;
  }

  public List<Integer> getFinalKeyList() {
    return finalKeyList;
  }

  public void setFinalKeyList(List<Integer> finalKeyList) {
    this.finalKeyList = finalKeyList;
  }

  public int getServerId() {
    return serverId;
  }

  public void setServerId(int serverId) {
    this.serverId = serverId;
  }
}
