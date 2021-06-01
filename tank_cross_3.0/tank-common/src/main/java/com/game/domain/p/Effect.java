/**
 * @Title: Effect.java @Package com.game.domain.p @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月6日 下午2:54:08
 * @version V1.0
 */
package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;

/**
 * @ClassName: Effect @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月6日 下午2:54:08
 */
public class Effect {
  private int effectId;
  private int endTime;

  public int getEffectId() {
    return effectId;
  }

  public void setEffectId(int effectId) {
    this.effectId = effectId;
  }

  public int getEndTime() {
    return endTime;
  }

  public void setEndTime(int endTime) {
    this.endTime = endTime;
  }

  /**
   * @param effectId
   * @param endTime
   */
  public Effect(int effectId, int endTime) {
    super();
    this.effectId = effectId;
    this.endTime = endTime;
  }

  public Effect(){

  }

  public Effect(CrossTeamProto.Effect effect){
    this.effectId = effect.getId();
    this.endTime = effect.getEndTime();
  }
}
