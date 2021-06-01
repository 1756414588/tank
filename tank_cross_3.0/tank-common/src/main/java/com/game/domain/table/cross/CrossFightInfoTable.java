package com.game.domain.table.cross;

import com.game.cross.domain.CompetGroup;
import com.game.cross.domain.ComptePojo;
import com.game.cross.domain.KnockoutBattleGroup;
import com.game.pb.CommonPb;
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
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 15:38
 * @description：战斗信息
 */
@Table(value = "cross_fight_info_table", fetch = Table.FeatchType.START)
public class CrossFightInfoTable implements KeyDataEntity<Integer> {

  @Primary
  @Foreign
  @Column(value = "cross_id", comment = "跨服id")
  private int crossId;

  @Column(value = "df_KnockoutBattle_Groups", length = 65535, comment = "巅峰组信息 淘汰战")
  private byte[] dfKnockoutBattleGroups;

  @Column(value = "jy_KnockoutBattle_Groups", length = 65535, comment = "精英组信息 淘汰战")
  private byte[] jyKnockoutBattleGroups;

  @Column(value = "df_FinalBattle_Groups", length = 65535, comment = "巅峰组信息 决战")
  private byte[] dfFinalBattleGroups;

  @Column(value = "jy_FinalBattle_Groups", length = 65535, comment = "精英组信息 决战")
  private byte[] jyFinalBattleGroups;

  public int getCrossId() {
    return crossId;
  }

  public void setCrossId(int crossId) {
    this.crossId = crossId;
  }

  public byte[] getDfKnockoutBattleGroups() {
    return dfKnockoutBattleGroups;
  }

  public void setDfKnockoutBattleGroups(byte[] dfKnockoutBattleGroups) {
    this.dfKnockoutBattleGroups = dfKnockoutBattleGroups;
  }

  public byte[] getJyKnockoutBattleGroups() {
    return jyKnockoutBattleGroups;
  }

  public void setJyKnockoutBattleGroups(byte[] jyKnockoutBattleGroups) {
    this.jyKnockoutBattleGroups = jyKnockoutBattleGroups;
  }

  public byte[] getDfFinalBattleGroups() {
    return dfFinalBattleGroups;
  }

  public void setDfFinalBattleGroups(byte[] dfFinalBattleGroups) {
    this.dfFinalBattleGroups = dfFinalBattleGroups;
  }

  public byte[] getJyFinalBattleGroups() {
    return jyFinalBattleGroups;
  }

  public void setJyFinalBattleGroups(byte[] jyFinalBattleGroups) {
    this.jyFinalBattleGroups = jyFinalBattleGroups;
  }

  /** 巅峰组信息 淘汰战 反序列化 */
  public Map<Integer, KnockoutBattleGroup> dserDfKnockoutBattleGroups()
      throws InvalidProtocolBufferException {

    Map<Integer, KnockoutBattleGroup> dfKnockoutBattleGroupsMap = new HashMap<>();

    if (dfKnockoutBattleGroups == null) {
      return dfKnockoutBattleGroupsMap;
    }

    SerializePb.SerDFKnockoutBattleGroups ser =
        SerializePb.SerDFKnockoutBattleGroups.parseFrom(dfKnockoutBattleGroups);

    for (CommonPb.KnockoutBattleGroup k : ser.getKnockoutBattleGroupList()) {
      int groupType = k.getGroupType();

      KnockoutBattleGroup kbg = dfKnockoutBattleGroupsMap.get(groupType);
      if (kbg == null) {
        kbg = new KnockoutBattleGroup();
        kbg.setGroupType(groupType);
        dfKnockoutBattleGroupsMap.put(groupType, kbg);
      }

      for (CommonPb.KnockoutCompetGroup g : k.getCompetGroupList()) {
        int cgId = g.getCompetGroupId();

        CompetGroup cg = kbg.groupMaps.get(cgId);
        if (cg == null) {
          cg = new CompetGroup();
          cg.setCompetGroupId(cgId);
          kbg.groupMaps.put(cgId, cg);
        }
        if (g.hasWin()) {
          cg.setWin(g.getWin());
        }

        if (g.hasC1()) {
          cg.setC1(
              new ComptePojo(
                  g.getC1().getPos(),
                  g.getC1().getServerId(),
                  g.getC1().getRoleId(),
                  g.getC1().getNick(),
                  g.getC1().getBet(),
                  0,
                  g.getC1().getServerName(),
                  g.getC1().getFight(),
                  g.getC1().getPortrait(),
                  g.getC1().getPartyName(),
                  g.getC1().getLevel()));
        }
        if (g.hasC2()) {
          cg.setC2(
              new ComptePojo(
                  g.getC2().getPos(),
                  g.getC2().getServerId(),
                  g.getC2().getRoleId(),
                  g.getC2().getNick(),
                  g.getC2().getBet(),
                  0,
                  g.getC2().getServerName(),
                  g.getC2().getFight(),
                  g.getC2().getPortrait(),
                  g.getC2().getPartyName(),
                  g.getC2().getLevel()));
        }

        for (CommonPb.CompteRound cr : g.getCompteRoundList()) {
          cg.getMap()
              .put(
                  cr.getRoundNum(),
                  new com.game.cross.domain.CompteRound(
                      cr.getRoundNum(), cr.getWin(), cr.getReportKey(), cr.getDetail()));
        }
      }
    }
    return dfKnockoutBattleGroupsMap;
  }

  /**
   * 巅峰组信息 淘汰战 序列化
   *
   * @param dfKnockoutBattleGroupsMap
   * @return
   */
  public byte[] serDfKnockoutBattleGroups(
      Map<Integer, KnockoutBattleGroup> dfKnockoutBattleGroupsMap) {
    SerializePb.SerDFKnockoutBattleGroups.Builder ser =
        SerializePb.SerDFKnockoutBattleGroups.newBuilder();
    Iterator<KnockoutBattleGroup> its = dfKnockoutBattleGroupsMap.values().iterator();
    while (its.hasNext()) {
      ser.addKnockoutBattleGroup(PbHelper.createKnockoutBattleGroupPb(its.next()));
    }
    return ser.build().toByteArray();
  }

  /**
   * 精英组信息 淘汰战 反序列化
   *
   * @throws InvalidProtocolBufferException
   */
  public Map<Integer, KnockoutBattleGroup> dserJyKnockoutBattleGroups()
      throws InvalidProtocolBufferException {

    Map<Integer, KnockoutBattleGroup> jyKnockoutBattleGroupsMap = new HashMap<>();

    if (jyKnockoutBattleGroups == null) {
      return jyKnockoutBattleGroupsMap;
    }
    SerializePb.SerJYKnockoutBattleGroups ser =
        SerializePb.SerJYKnockoutBattleGroups.parseFrom(jyKnockoutBattleGroups);
    for (CommonPb.KnockoutBattleGroup k : ser.getKnockoutBattleGroupList()) {
      int groupType = k.getGroupType();

      KnockoutBattleGroup kbg = jyKnockoutBattleGroupsMap.get(groupType);
      if (kbg == null) {
        kbg = new KnockoutBattleGroup();
        kbg.setGroupType(groupType);
        jyKnockoutBattleGroupsMap.put(groupType, kbg);
      }

      for (CommonPb.KnockoutCompetGroup g : k.getCompetGroupList()) {
        int cgId = g.getCompetGroupId();

        CompetGroup cg = kbg.groupMaps.get(cgId);
        if (cg == null) {
          cg = new CompetGroup();
          cg.setCompetGroupId(cgId);
          kbg.groupMaps.put(cgId, cg);
        }
        if (g.hasWin()) {
          cg.setWin(g.getWin());
        }

        if (g.hasC1()) {
          cg.setC1(
              new ComptePojo(
                  g.getC1().getPos(),
                  g.getC1().getServerId(),
                  g.getC1().getRoleId(),
                  g.getC1().getNick(),
                  g.getC1().getBet(),
                  0,
                  g.getC1().getServerName(),
                  g.getC1().getFight(),
                  g.getC1().getPortrait(),
                  g.getC1().getPartyName(),
                  g.getC1().getLevel()));
        }
        if (g.hasC2()) {
          cg.setC2(
              new ComptePojo(
                  g.getC2().getPos(),
                  g.getC2().getServerId(),
                  g.getC2().getRoleId(),
                  g.getC2().getNick(),
                  g.getC2().getBet(),
                  0,
                  g.getC2().getServerName(),
                  g.getC2().getFight(),
                  g.getC2().getPortrait(),
                  g.getC2().getPartyName(),
                  g.getC2().getLevel()));
        }

        for (CommonPb.CompteRound cr : g.getCompteRoundList()) {
          cg.getMap()
              .put(
                  cr.getRoundNum(),
                  new com.game.cross.domain.CompteRound(
                      cr.getRoundNum(), cr.getWin(), cr.getReportKey(), cr.getDetail()));
        }
      }
    }

    return jyKnockoutBattleGroupsMap;
  }

  /**
   * 精英组信息 淘汰战 序列化
   *
   * @param jyKnockoutBattleGroupsMap
   * @return
   */
  public byte[] serJyKnockoutBattleGroups(
      Map<Integer, KnockoutBattleGroup> jyKnockoutBattleGroupsMap) {
    SerializePb.SerJYKnockoutBattleGroups.Builder ser =
        SerializePb.SerJYKnockoutBattleGroups.newBuilder();
    Iterator<KnockoutBattleGroup> its = jyKnockoutBattleGroupsMap.values().iterator();
    while (its.hasNext()) {
      ser.addKnockoutBattleGroup(PbHelper.createKnockoutBattleGroupPb(its.next()));
    }
    return ser.build().toByteArray();
  }

  /**
   * 精英组信息 决战 反序列化
   *
   * @return
   * @throws InvalidProtocolBufferException
   */
  public Map<Integer, CompetGroup> dserJYFinalBattleGroups() throws InvalidProtocolBufferException {

    Map<Integer, CompetGroup> jyFinalBattleGroupsMap = new HashMap<>();

    if (jyFinalBattleGroups == null) {
      return jyFinalBattleGroupsMap;
    }

    SerializePb.SerJYFinalBattleGroups ser =
        SerializePb.SerJYFinalBattleGroups.parseFrom(jyFinalBattleGroups);
    for (CommonPb.FinalCompetGroup g : ser.getFinalCompetGroupList()) {

      CompetGroup cg = jyFinalBattleGroupsMap.get(g.getCompetGroupId());
      if (cg == null) {
        cg = new CompetGroup();
        cg.setCompetGroupId(g.getCompetGroupId());

        jyFinalBattleGroupsMap.put(cg.getCompetGroupId(), cg);
      }

      if (g.hasWin()) {
        cg.setWin(g.getWin());
      }

      if (g.hasC1()) {
        cg.setC1(
            new ComptePojo(
                g.getC1().getPos(),
                g.getC1().getServerId(),
                g.getC1().getRoleId(),
                g.getC1().getNick(),
                g.getC1().getBet(),
                0,
                g.getC1().getServerName(),
                g.getC1().getFight(),
                g.getC1().getPortrait(),
                g.getC1().getPartyName(),
                g.getC1().getLevel()));
      }
      if (g.hasC2()) {
        cg.setC2(
            new ComptePojo(
                g.getC2().getPos(),
                g.getC2().getServerId(),
                g.getC2().getRoleId(),
                g.getC2().getNick(),
                g.getC2().getBet(),
                0,
                g.getC2().getServerName(),
                g.getC2().getFight(),
                g.getC2().getPortrait(),
                g.getC2().getPartyName(),
                g.getC2().getLevel()));
      }

      for (CommonPb.CompteRound cr : g.getCompteRoundList()) {
        cg.getMap()
            .put(
                cr.getRoundNum(),
                new com.game.cross.domain.CompteRound(
                    cr.getRoundNum(), cr.getWin(), cr.getReportKey(), cr.getDetail()));
      }
    }
    return jyFinalBattleGroupsMap;
  }

  /**
   * 精英组信息 决战 序列化
   *
   * @param jyFinalBattleGroupsMap
   * @return
   */
  public byte[] serJYFinalBattleGroups(Map<Integer, CompetGroup> jyFinalBattleGroupsMap) {
    SerializePb.SerJYFinalBattleGroups.Builder ser =
        SerializePb.SerJYFinalBattleGroups.newBuilder();
    Iterator<CompetGroup> its = jyFinalBattleGroupsMap.values().iterator();
    while (its.hasNext()) {
      ser.addFinalCompetGroup(PbHelper.createFinalCompetGroupPb(its.next()));
    }

    return ser.build().toByteArray();
  }

  /**
   * 巅峰组信息 决战 反序列化
   *
   * @return
   * @throws InvalidProtocolBufferException
   */
  public Map<Integer, CompetGroup> dserDFFinalBattleGroups() throws InvalidProtocolBufferException {

    Map<Integer, CompetGroup> dfFinalBattleGroupsMap = new HashMap<>();

    if (dfFinalBattleGroups == null) {
      return dfFinalBattleGroupsMap;
    }

    SerializePb.SerDFFinalBattleGroups ser =
        SerializePb.SerDFFinalBattleGroups.parseFrom(dfFinalBattleGroups);
    for (CommonPb.FinalCompetGroup g : ser.getFinalCompetGroupList()) {

      CompetGroup cg = dfFinalBattleGroupsMap.get(g.getCompetGroupId());
      if (cg == null) {
        cg = new CompetGroup();
        cg.setCompetGroupId(g.getCompetGroupId());

        dfFinalBattleGroupsMap.put(cg.getCompetGroupId(), cg);
      }

      if (g.hasWin()) {
        cg.setWin(g.getWin());
      }

      if (g.hasC1()) {
        cg.setC1(
            new ComptePojo(
                g.getC1().getPos(),
                g.getC1().getServerId(),
                g.getC1().getRoleId(),
                g.getC1().getNick(),
                g.getC1().getBet(),
                0,
                g.getC1().getServerName(),
                g.getC1().getFight(),
                g.getC1().getPortrait(),
                g.getC1().getPartyName(),
                g.getC1().getLevel()));
      }
      if (g.hasC2()) {
        cg.setC2(
            new ComptePojo(
                g.getC2().getPos(),
                g.getC2().getServerId(),
                g.getC2().getRoleId(),
                g.getC2().getNick(),
                g.getC2().getBet(),
                0,
                g.getC2().getServerName(),
                g.getC2().getFight(),
                g.getC2().getPortrait(),
                g.getC2().getPartyName(),
                g.getC2().getLevel()));
      }

      for (CommonPb.CompteRound cr : g.getCompteRoundList()) {
        cg.getMap()
            .put(
                cr.getRoundNum(),
                new com.game.cross.domain.CompteRound(
                    cr.getRoundNum(), cr.getWin(), cr.getReportKey(), cr.getDetail()));
      }
    }
    return dfFinalBattleGroupsMap;
  }

  /**
   * 巅峰组信息 决战 序列化
   *
   * @param dfFinalBattleGroupsMap
   * @return
   */
  public byte[] serDFFinalBattleGroups(Map<Integer, CompetGroup> dfFinalBattleGroupsMap) {
    SerializePb.SerDFFinalBattleGroups.Builder ser =
        SerializePb.SerDFFinalBattleGroups.newBuilder();
    Iterator<CompetGroup> its = dfFinalBattleGroupsMap.values().iterator();
    while (its.hasNext()) {
      ser.addFinalCompetGroup(PbHelper.createFinalCompetGroupPb(its.next()));
    }
    return ser.build().toByteArray();
  }
}
