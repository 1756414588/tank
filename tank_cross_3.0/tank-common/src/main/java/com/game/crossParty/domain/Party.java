package com.game.crossParty.domain;

import com.game.domain.p.Form;

import java.util.*;

public class Party {
  private Map<Long, PartyMember> members = new HashMap<Long, PartyMember>(); // 库里存的是key
  private List<PartyMember> fighters = new ArrayList<>();
  private int order = 0;
  private int outCount = 0;
  private int formNum = 0;

  private int serverId;
  private int partyId;
  private String partyName;
  private int partyLv;

  private int warRank; // 报名时的rank

  private int myPartySirPortrait;

  private long fight;
  private int group; // 1A 2B 3C 4D
  private boolean isFinalGroup = false;

  private List<Integer> partyReportKey = new ArrayList<Integer>(); // 军团战报key

  private int totalJifen = 0;

  public int getMyPartySirPortrait() {
    return myPartySirPortrait;
  }

  public void setMyPartySirPortrait(int myPartySirPortrait) {
    this.myPartySirPortrait = myPartySirPortrait;
  }

  public void addKey(int key) {
    partyReportKey.add(key);
  }

  public long getFight() {
    return fight;
  }

  public int getWarRank() {
    return warRank;
  }

  public boolean isFinalGroup() {
    return isFinalGroup;
  }

  public void setFinalGroup(boolean isFinalGroup) {
    this.isFinalGroup = isFinalGroup;
  }

  public void setWarRank(int warRank) {
    this.warRank = warRank;
  }

  public int getPartyLv() {
    return partyLv;
  }

  public int getTotalJifen() {
    return totalJifen;
  }

  public void setTotalJifen(int totalJifen) {
    this.totalJifen = totalJifen;
  }

  public void setPartyLv(int partyLv) {
    this.partyLv = partyLv;
  }

  public void setFight(long fight) {
    this.fight = fight;
  }

  public int getServerId() {
    return serverId;
  }

  public void setServerId(int serverId) {
    this.serverId = serverId;
  }

  public int getPartyId() {
    return partyId;
  }

  public void setPartyId(int partyId) {
    this.partyId = partyId;
  }

  public String getPartyName() {
    return partyName;
  }

  public void setPartyName(String partyName) {
    this.partyName = partyName;
  }

  public void prepair() {
    fighters.clear();
    formNum = 0;
    outCount = 0;
    order = 0;
    Iterator<PartyMember> its = members.values().iterator();
    while (its.hasNext()) {
      PartyMember p = its.next();
      p.setState(0);

      if (isFinalGroup) {
        if (p.getForm() != null) {
          p.setInstForm(new Form(p.getForm()));
        }
      }

      if (p.getForm() != null) {
        formNum++;
        fighters.add(p);
      }
    }

    Collections.shuffle(fighters);
  }

  public boolean allOut() {
    return outCount == formNum;
  }

  public PartyMember aquireFighter() {
    while (true) {
      PartyMember partyMember = fighters.get(order % fighters.size());
      order++;
      if (partyMember.getState() == 1) {
        continue;
      }

      return partyMember;
    }
  }

  public void fighterOut(PartyMember warMember) {
    warMember.setState(1);
    outCount++;
  }

  public PartyMember getMember(long roleId) {
    return members.get(roleId);
  }

  public Map<Long, PartyMember> getMembers() {
    return members;
  }

  public void setMembers(Map<Long, PartyMember> members) {
    this.members = members;
  }

  public List<PartyMember> getFighters() {
    return fighters;
  }

  public void setFighters(List<PartyMember> fighters) {
    this.fighters = fighters;
  }

  public List<Integer> getPartyReportKey() {
    return partyReportKey;
  }

  public void setPartyReportKey(List<Integer> partyReportKey) {
    this.partyReportKey = partyReportKey;
  }

  public int getGroup() {
    return group;
  }

  public void setGroup(int group) {
    this.group = group;
  }

  public int getOrder() {
    return order;
  }

  public void setOrder(int order) {
    this.order = order;
  }

  public int getOutCount() {
    return outCount;
  }

  public void setOutCount(int outCount) {
    this.outCount = outCount;
  }

  public int getFormNum() {
    return formNum;
  }

  public void setFormNum(int formNum) {
    this.formNum = formNum;
  }

  public String getKey() {

    return serverId + "_" + partyId;
  }
}
