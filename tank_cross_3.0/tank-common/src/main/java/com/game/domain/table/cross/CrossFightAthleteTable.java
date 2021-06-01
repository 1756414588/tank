package com.game.domain.table.cross;

import com.game.cross.domain.Athlete;
import com.game.pb.CommonPb;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 15:00
 * @description：跨服战玩家信息
 */
@Table(value = "cross_fight_athlete_table", fetch = Table.FeatchType.START)
public class CrossFightAthleteTable implements KeyDataEntity<Long> {

  @Primary
  @Foreign
  @Column(value = "role_id", comment = "玩家id")
  private long roleId;

  @Column(value = "server_id", comment = "玩家的serverId")
  private int serverId;

  @Column(value = "athlete_info", length = 65535, comment = "玩家信息")
  private byte[] athleteInfo;

  @Column(value = "receive_cross_rank_reward", comment = "是否领取领取排行奖励")
  private int receiveCrossRankReward;

  public long getRoleId() {
    return roleId;
  }

  public void setRoleId(long roleId) {
    this.roleId = roleId;
  }

  public int getServerId() {
    return serverId;
  }

  public void setServerId(int serverId) {
    this.serverId = serverId;
  }

  public byte[] getAthleteInfo() {
    return athleteInfo;
  }

  public void setAthleteInfo(byte[] athleteInfo) {
    this.athleteInfo = athleteInfo;
  }

  public int getReceiveCrossRankReward() {
    return receiveCrossRankReward;
  }

  public void setReceiveCrossRankReward(int receiveCrossRankReward) {
    this.receiveCrossRankReward = receiveCrossRankReward;
  }

  public Athlete getAthlete() {
    try {
      if (athleteInfo == null || athleteInfo.length == 0) {
        return null;
      }
      CommonPb.Athlete athletePb = CommonPb.Athlete.parseFrom(athleteInfo);
      Athlete athlete = PbHelper.dserAthlete(athletePb);
      return athlete;
    } catch (InvalidProtocolBufferException e) {
      LogUtil.error(e);
    }
    return null;
  }

  public void setAthlete(Athlete athlete) {
    CommonPb.Athlete athletePb = PbHelper.crateAthletePb(athlete);
    this.athleteInfo = athletePb.toByteArray();
  }
}
