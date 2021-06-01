package com.game.cross.domain;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 所有积分玩家
 *
 * @author wanyi
 */
public class JiFenPlayer {
  private int serverId;
  private long roleId;
  private String nick;
  private int jifen = 0;
  private int exchangeJifen = 0;

  /** 我的下注信息(myGroup_stage_groupType_competGroupId: myBet) */
  public HashMap<String, MyBet> myBets = new HashMap<String, MyBet>();

  /** 跨服战积分详情 */
  public List<CrossTrend> crossTrends = new ArrayList<CrossTrend>();

  /** 跨服商店商品购买记录 */
  public Map<Integer, CrossShopBuy> crossShopBuy = new HashMap<>();

  /** 最后一次更新跨服商店购买记录的日期 */
  private int lastUpdateCrossShopDate;

  public int getServerId() {
    return serverId;
  }

  public void setServerId(int serverId) {
    this.serverId = serverId;
  }

  public long getRoleId() {
    return roleId;
  }

  public void setRoleId(long roleId) {
    this.roleId = roleId;
  }

  public String getNick() {
    return nick;
  }

  public void setNick(String nick) {
    this.nick = nick;
  }

  public int getJifen() {
    return jifen;
  }

  public void setJifen(int jifen) {
    this.jifen = jifen;
  }

  public int getExchangeJifen() {
    return exchangeJifen;
  }

  public void setExchangeJifen(int exchangeJifen) {
    this.exchangeJifen = exchangeJifen;
  }

  public JiFenPlayer(int serverId, long roleId, String nick, int jifen, int exchangeJifen) {
    super();
    this.serverId = serverId;
    this.roleId = roleId;
    this.nick = nick;
    this.jifen = jifen;
    this.exchangeJifen = exchangeJifen;
  }

  public JiFenPlayer() {
    super();
  }

  public int getLastUpdateCrossShopDate() {
    return lastUpdateCrossShopDate;
  }

  public void setLastUpdateCrossShopDate(int lastUpdateCrossShopDate) {
    this.lastUpdateCrossShopDate = lastUpdateCrossShopDate;
  }
}
