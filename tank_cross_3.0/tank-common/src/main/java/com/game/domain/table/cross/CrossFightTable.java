package com.game.domain.table.cross;

import com.game.cross.domain.CrossShopBuy;
import com.game.pb.SerializePb;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.*;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 14:41
 * @description：跨服战数据
 */
@Table(value = "cross_fight_table", fetch = Table.FeatchType.START)
public class CrossFightTable implements KeyDataEntity<Integer> {

  @Primary
  @Foreign
  @Column(value = "cross_id", comment = "跨服id")
  private int crossId;

  @Column(value = "cross_time", comment = "资格争夺战时间 也就是跨服开启时间")
  private int crossTime;

  @Column(value = "chat_day_num", comment = "公告跨服进度天数和时间 天数")
  private int chatDayNum;

  @Column(value = "chat_day_time", defaultValue = "", length = 64, comment = "公告跨服进度天数和时间 时间")
  private String chatDayTime;

  @Column(value = "mail_day_num", comment = "发送邮件的进度 天数和时间 天数")
  private int mailDayNum;

  @Column(value = "mail_day_time", defaultValue = "", length = 64, comment = "发送邮件的进度 天数和时间 时间")
  private String mailDayTime;

  @Column(value = "report_key", defaultValue = "0", comment = "每次 +1的key")
  private int reportKey;

  @Column(value = "cross_shop_refresh_date", defaultValue = "0", comment = "跨服商店最后一次刷新的日期")
  private int crossShopRefreshDate;

  @Column(value = "cross_shop", length = 65535, comment = "跨服商店的珍品购买情况")
  private byte[] crossShop;

  @Column(value = "cross_state", defaultValue = "", length = 1024, comment = "每场战斗状态时间信息")
  private String crossState;

  @Column(value = "dfrank", length = 65535, comment = "巅峰排行")
  private byte[] dfRank;

  @Column(value = "jyrank", length = 65535, comment = "精英排行")
  private byte[] jyrank;

  public int getCrossId() {
    return crossId;
  }

  public void setCrossId(int crossId) {
    this.crossId = crossId;
  }

  public int getCrossTime() {
    return crossTime;
  }

  public void setCrossTime(int crossTime) {
    this.crossTime = crossTime;
  }

  public int getChatDayNum() {
    return chatDayNum;
  }

  public void setChatDayNum(int chatDayNum) {
    this.chatDayNum = chatDayNum;
  }

  public String getChatDayTime() {
    if (chatDayTime == null) {
      return "";
    }
    return chatDayTime;
  }

  public void setChatDayTime(String chatDayTime) {
    this.chatDayTime = chatDayTime;
  }

  public int getMailDayNum() {
    return mailDayNum;
  }

  public void setMailDayNum(int mailDayNum) {
    this.mailDayNum = mailDayNum;
  }

  public String getMailDayTime() {
    if (mailDayTime == null) {
      return "";
    }
    return mailDayTime;
  }

  public void setMailDayTime(String mailDayTime) {
    this.mailDayTime = mailDayTime;
  }

  public int getReportKey() {
    return reportKey;
  }

  public void setReportKey(int reportKey) {
    this.reportKey = reportKey;
  }

  public int getCrossShopRefreshDate() {
    return crossShopRefreshDate;
  }

  public void setCrossShopRefreshDate(int crossShopRefreshDate) {
    this.crossShopRefreshDate = crossShopRefreshDate;
  }

  public String getCrossState() {
    return crossState;
  }

  public void setCrossState(String crossState) {
    this.crossState = crossState;
  }

  public byte[] getCrossShop() {
    return crossShop;
  }

  public void setCrossShop(byte[] crossShop) {
    this.crossShop = crossShop;
  }

  public byte[] getDfRank() {
    return dfRank;
  }

  public void setDfRank(byte[] dfRank) {
    this.dfRank = dfRank;
  }

  public byte[] getJyrank() {
    return jyrank;
  }

  public void setJyrank(byte[] jyrank) {
    this.jyrank = jyrank;
  }

  public byte[] serCrossShopMap(Collection<CrossShopBuy> crossShopBuys) {
    SerializePb.SerCrossShop.Builder ser = SerializePb.SerCrossShop.newBuilder();
    for (CrossShopBuy buy : crossShopBuys) {
      ser.addCrossShop(PbHelper.createCrossShopBuyPb(buy));
    }
    return ser.build().toByteArray();
  }

  public Map<Integer, CrossShopBuy> dserCrossShop() throws InvalidProtocolBufferException {
    Map<Integer, CrossShopBuy> crossShopMap = new HashMap<Integer, CrossShopBuy>();

    if (crossShop == null) {
      return crossShopMap;
    }

    SerializePb.SerCrossShop ser = SerializePb.SerCrossShop.parseFrom(crossShop);
    for (com.game.pb.CommonPb.CrossShopBuy buy : ser.getCrossShopList()) {
      crossShopMap.put(buy.getShopId(), new CrossShopBuy(buy));
    }

    return crossShopMap;
  }

  public byte[] serJyRankMap(LinkedHashMap<Long, Long> jyRankMap) {

    SerializePb.SerJYRankMap.Builder ser = SerializePb.SerJYRankMap.newBuilder();
    Iterator<Long> its = jyRankMap.values().iterator();
    while (its.hasNext()) {
      ser.addAthleteKey(its.next() + "");
    }
    return ser.build().toByteArray();
  }

  public byte[] serdfRankMap(LinkedHashMap<Long, Long> dfRankMap) {
    SerializePb.SerDFRankMap.Builder ser = SerializePb.SerDFRankMap.newBuilder();
    Iterator<Long> its = dfRankMap.values().iterator();
    while (its.hasNext()) {
      ser.addAthleteKey(its.next() + "");
    }
    return ser.build().toByteArray();
  }

  public LinkedHashMap<Long, Long> dserDfRankMap() throws InvalidProtocolBufferException {

    LinkedHashMap<Long, Long> dfRankMap = new LinkedHashMap<>();
    if (dfRank == null) {
      return dfRankMap;
    }

    SerializePb.SerDFRankMap ser = SerializePb.SerDFRankMap.parseFrom(dfRank);
    for (String key : ser.getAthleteKeyList()) {
      dfRankMap.put(Long.valueOf(key), Long.valueOf(key));
    }
    return dfRankMap;
  }

  public LinkedHashMap<Long, Long> dserJyRankMap() throws InvalidProtocolBufferException {

    LinkedHashMap<Long, Long> jyRankMap = new LinkedHashMap<>();

    if (jyrank == null) {
      return jyRankMap;
    }
    SerializePb.SerJYRankMap ser = SerializePb.SerJYRankMap.parseFrom(jyrank);
    for (String key : ser.getAthleteKeyList()) {
      jyRankMap.put(Long.valueOf(key), Long.valueOf(key));
    }
    return jyRankMap;
  }
}
