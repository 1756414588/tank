package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;

/** 勋章 */
public class Medal {
  private int keyId;
  private int medalId;
  /** 0是仓库 1将领身上 20展示 */
  private int pos;

  private int upLv;
  private int upExp;
  private int refitLv;
  private boolean locked;

  public int getKeyId() {
    return keyId;
  }

  public void setKeyId(int keyId) {
    this.keyId = keyId;
  }

  public int getMedalId() {
    return medalId;
  }

  public void setMedalId(int medalId) {
    this.medalId = medalId;
  }

  public int getPos() {
    return pos;
  }

  public void setPos(int pos) {
    this.pos = pos;
  }

  public int getUpLv() {
    return upLv;
  }

  public void setUpLv(int upLv) {
    this.upLv = upLv;
  }

  public int getUpExp() {
    return upExp;
  }

  public void setUpExp(int upExp) {
    this.upExp = upExp;
  }

  public int getRefitLv() {
    return refitLv;
  }

  public void setRefitLv(int refitLv) {
    this.refitLv = refitLv;
  }

  public boolean isLocked() {
    return locked;
  }

  public void setLocked(boolean locked) {
    this.locked = locked;
  }

  public Medal(){

  }
  public Medal(int keyId, int medalId, int upLv, int refitLv, int pos, int exp, boolean locked) {
    this.keyId = keyId;
    this.medalId = medalId;
    this.upLv = upLv;
    this.upExp = exp;
    this.refitLv = refitLv;
    this.pos = pos;
    this.locked = locked;
  }

  public Medal(CrossTeamProto.Medal medal){
    this.keyId = medal.getKeyId();
    this.medalId = medal.getMedalId();
    this.upLv = medal.getUpLv();
    this.upExp = medal.getUpExp();
    this.refitLv = medal.getRefitLv();
    this.pos = medal.getPos();
    this.locked = medal.getLocked();
  }


}
