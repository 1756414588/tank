/**
 * @Title: Equip.java @Package com.game.domain.p @Description:
 *
 * @author ZhangJun
 * @date 2015年8月18日 下午12:05:37
 * @version V1.0
 */
package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;

/**
 * @ClassName: Equip @Description:
 *
 * @author ZhangJun
 * @date 2015年8月18日 下午12:05:37
 */
public class Equip {
  protected int keyId;
  protected int equipId;
  protected int lv;
  protected int exp;
  protected int pos; // 穿戴部位,0-未穿戴
  protected int starlv; // 星级

  public int getKeyId() {
    return keyId;
  }

  public void setKeyId(int keyId) {
    this.keyId = keyId;
  }

  public int getEquipId() {
    return equipId;
  }

  public void setEquipId(int equipId) {
    this.equipId = equipId;
  }

  public int getLv() {
    return lv;
  }

  public void setLv(int lv) {
    this.lv = lv;
  }

  public int getPos() {
    return pos;
  }

  public void setPos(int pos) {
    this.pos = pos;
  }

  public int getExp() {
    return exp;
  }

  public void setExp(int exp) {
    this.exp = exp;
  }

  /**
   * @param keyId
   * @param equipId
   * @param lv
   * @param exp
   * @param pos
   */
  public Equip(int keyId, int equipId, int lv, int exp, int pos) {
    super();
    this.keyId = keyId;
    this.equipId = equipId;
    this.lv = lv;
    this.exp = exp;
    this.pos = pos;
  }
  public Equip(){
  }

  public Equip(CrossTeamProto.Equip equip){
    this.keyId = equip.getKeyId();
    this.equipId = equip.getEquipId();
    this.lv = equip.getLv();
    this.exp = equip.getExp();
    this.pos = equip.getPos();
  }

  public int getStarlv() {
    return starlv;
  }

  public void setStarlv(int starlv) {
    this.starlv = starlv;
  }
}
