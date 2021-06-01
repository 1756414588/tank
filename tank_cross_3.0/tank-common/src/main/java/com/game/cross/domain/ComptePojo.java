package com.game.cross.domain;

public class ComptePojo {
  private int pos;
  private int serverId;
  private long roleId;
  private String nick;
  private int bet;
  private int myBetNum;
  private String serverName;
  private long fight;
  private int portrait;
  private String partyName;
  private int level;

  public int getLevel() {
    return level;
  }

  public void setLevel(int level) {
    this.level = level;
  }

  public ComptePojo() {
    super();
  }

  public ComptePojo(
      int pos,
      int serverId,
      long roleId,
      String nick,
      int bet,
      int myBetNum,
      String serverName,
      long fight,
      int portrait,
      String partyName,
      int level) {
    super();
    this.pos = pos;
    this.serverId = serverId;
    this.roleId = roleId;
    this.nick = nick;
    this.bet = bet;
    this.myBetNum = myBetNum;
    this.serverName = serverName;
    this.fight = fight;
    this.portrait = portrait;
    this.partyName = partyName;
    this.level = level;
  }

  public int getPortrait() {
    return portrait;
  }

  public void setPortrait(int portrait) {
    this.portrait = portrait;
  }

  public String getPartyName() {
    return partyName;
  }

  public void setPartyName(String partyName) {
    this.partyName = partyName;
  }

  public String getServerName() {
    return serverName;
  }

  public void setServerName(String serverName) {
    this.serverName = serverName;
  }

  public long getFight() {
    return fight;
  }

  public void setFight(long fight) {
    this.fight = fight;
  }

  public int getMyBetNum() {
    return myBetNum;
  }

  public void setMyBetNum(int myBetNum) {
    this.myBetNum = myBetNum;
  }

  public long getRoleId() {
    return roleId;
  }

  public void setRoleId(long roleId) {
    this.roleId = roleId;
  }

  public int getPos() {
    return pos;
  }

  public void setPos(int pos) {
    this.pos = pos;
  }

  public int getServerId() {
    return serverId;
  }

  public void setServerId(int serverId) {
    this.serverId = serverId;
  }

  public String getNick() {
    return nick;
  }

  public void setNick(String nick) {
    this.nick = nick;
  }

  public int getBet() {
    return bet;
  }

  public void setBet(int bet) {
    this.bet = bet;
  }
}
