package com.game.domain.table.party;

import com.alibaba.fastjson.JSON;
import com.game.cross.domain.CrossState;
import com.game.crossParty.domain.GroupParty;
import com.game.crossParty.domain.Party;
import com.game.crossParty.domain.ServerSisuation;
import com.game.pb.SerializePb;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedHashMap;
import java.util.Map;

/** 跨服军团战信息 @Author: hezhi @Date: 2019/3/11 16:51 */
@Table(value = "cross_party_table", fetch = Table.FeatchType.START)
public class CrossPartyTable implements KeyDataEntity<Integer> {

  @Primary
  @Foreign
  @Column(value = "cross_id", comment = "主键id")
  private int crossId;

  @Column(value = "cross_time", comment = "跨服军团战资格赛争夺开始时间")
  private int crossTime;

  @Column(value = "chat_day_num", comment = "广播信息第几天")
  private int chatDayNum;

  @Column(value = "chat_day_time", comment = "广播信息几点")
  private String chatDayTime;

  @Column(value = "mail_day_num", comment = "邮件信息第几天")
  private int mailDayNum;

  @Column(value = "mail_day_time", comment = "邮件信息几点")
  private String mailDayTime;

  @Column(value = "groupMap", length = 65535, comment = "分组信息")
  private byte[] groupMap;

  @Column(value = "lianShengRank", length = 65535, comment = "决赛连胜排行")
  private byte[] lianShengRank;

  @Column(value = "serverSisuationMap", length = 65535, comment = "记录服的key")
  private byte[] serverSisuationMap;

  @Column(value = "cross_state", length = 1024, comment = "每场战斗状态时间信息")
  private String crossState;

  @Column(value = "report_key", comment = "每次 +1的key")
  private int reportKey;

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

  public String getMailDayTime() {
    if (mailDayTime == null) {
      return "";
    }
    return mailDayTime;
  }

  public void setMailDayTime(String mailDayTime) {
    this.mailDayTime = mailDayTime;
  }

  public int getMailDayNum() {
    return mailDayNum;
  }

  public void setMailDayNum(int mailDayNum) {
    this.mailDayNum = mailDayNum;
  }

  public byte[] getGroupMap() {
    return groupMap;
  }

  public void setGroupMap(byte[] groupMap) {
    this.groupMap = groupMap;
  }

  public byte[] getLianShengRank() {
    return lianShengRank;
  }

  public void setLianShengRank(byte[] lianShengRank) {
    this.lianShengRank = lianShengRank;
  }

  public byte[] getServerSisuationMap() {
    return serverSisuationMap;
  }

  public void setServerSisuationMap(byte[] serverSisuationMap) {
    this.serverSisuationMap = serverSisuationMap;
  }

  public String getCrossState() {
    return crossState;
  }

  public void setCrossState(String crossState) {
    this.crossState = crossState;
  }

  public int getReportKey() {
    return reportKey;
  }

  public void setReportKey(int reportKey) {
    this.reportKey = reportKey;
  }

  public byte[] serGroupMap(Map<Integer, GroupParty> groupMap) {
    SerializePb.SerGroupMap.Builder builder = SerializePb.SerGroupMap.newBuilder();
    Iterator<GroupParty> its = groupMap.values().iterator();
    while (its.hasNext()) {
      builder.addGroupParty(PbHelper.createGroupPartyPb(its.next()));
    }
    return builder.build().toByteArray();
  }

  public Map<Integer, GroupParty> dserGroupMap(LinkedHashMap<String, Party> partys)
      throws InvalidProtocolBufferException {

    Map<Integer, GroupParty> groupHashMap = new HashMap<Integer, GroupParty>();

    if (groupMap == null) {
      return groupHashMap;
    }

    SerializePb.SerGroupMap ser = SerializePb.SerGroupMap.parseFrom(groupMap);
    for (com.game.pb.CommonPb.GroupParty gp : ser.getGroupPartyList()) {
      int group = gp.getGroup();

      GroupParty aa = new GroupParty();
      aa.setGroup(group);

      for (String str : gp.getGroupPartyMapList()) {
        aa.groupPartyMap.put(str, partys.get(str));
      }

      if (gp.getGroupKeyListCount() > 0) {
        aa.getGroupKeyList().addAll(gp.getGroupKeyListList());
      }

      for (com.game.pb.CommonPb.RankParty rp : gp.getRankPartyList()) {
        String key = rp.getKey();
        int rank = rp.getRank();

        aa.getRankMap().put(rank, partys.get(key));
      }

      groupHashMap.put(group, aa);
    }
    return groupHashMap;
  }

  public byte[] serLianShengRank(LinkedHashMap<String, String> lianShengRank) {
    SerializePb.SerLianShengRank.Builder builder = SerializePb.SerLianShengRank.newBuilder();
    builder.addAllLianShengRank(lianShengRank.values());
    return builder.build().toByteArray();
  }

  public LinkedHashMap<String, String> dserLianShengRank() throws InvalidProtocolBufferException {

    LinkedHashMap<String, String> lianShengRankMap = new LinkedHashMap<String, String>();
    if (lianShengRank == null) {
      return lianShengRankMap;
    }

    SerializePb.SerLianShengRank ser = SerializePb.SerLianShengRank.parseFrom(lianShengRank);
    for (String str : ser.getLianShengRankList()) {
      lianShengRankMap.put(str, str);
    }
    return lianShengRankMap;
  }

  public byte[] serServerSisuationMap(Map<Integer, ServerSisuation> serverSisuationMap) {
    SerializePb.SerServerSisuation.Builder builder = SerializePb.SerServerSisuation.newBuilder();
    Iterator<ServerSisuation> its = serverSisuationMap.values().iterator();
    while (its.hasNext()) {
      builder.addServerSisuation(PbHelper.createServerSisuationPb(its.next()));
    }
    return builder.build().toByteArray();
  }

  public Map<Integer, ServerSisuation> dserServerSisuationMap()
      throws InvalidProtocolBufferException {
    Map<Integer, ServerSisuation> serverSisuation = new HashMap<Integer, ServerSisuation>();
    if (serverSisuationMap == null) {
      return serverSisuation;
    }

    SerializePb.SerServerSisuation ser =
        SerializePb.SerServerSisuation.parseFrom(serverSisuationMap);
    for (com.game.pb.CommonPb.ServerSisuation ss : ser.getServerSisuationList()) {
      ServerSisuation s = new ServerSisuation();
      s.setServerId(ss.getServerId());
      if (ss.getFinalKeyListCount() > 0) {
        s.getFinalKeyList().addAll(ss.getFinalKeyListList());
      }
      if (ss.getGroupKeyListCount() > 0) {
        s.getGroupKeyList().addAll(ss.getGroupKeyListList());
      }

      serverSisuation.put(s.getServerId(), s);
    }
    return serverSisuation;
  }

  public CrossState getCrossStateConfig() {
    if (this.crossState == null) {
      return null;
    }
    return JSON.toJavaObject(JSON.parseObject(this.crossState), CrossState.class);
  }

  public void setCrossStateConfig(CrossState state) {
    this.crossState = JSON.toJSONString(state);
  }
}
