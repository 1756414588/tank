package com.game.domain.s.tactics;

public class StaticTacticsUplv {

  //    CREATE TABLE `s_tactics_uplv` (
  //            `keyId` int(11) NOT NULL COMMENT 'id',
  //            `quality` int(11) NOT NULL COMMENT '战术品质',
  //            `lv` int(11) NOT NULL COMMENT '升级的目标等级',
  //            `expNeed` int(11) NOT NULL COMMENT '升级到目标等级需要的经验值',
  //            `expOffer` int(11) NOT NULL COMMENT '吞掉该战术可提供的基础经验值（实际提供经验=该值+当前等级溢出的经验值）',
  //    PRIMARY KEY (`keyId`)
  // ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

  private int keyId;
  private int quality;
  private int lv;
  private int expNeed;
  private int expOffer;
  private int breakOn;

  public int getKeyId() {
    return keyId;
  }

  public void setKeyId(int keyId) {
    this.keyId = keyId;
  }

  public int getQuality() {
    return quality;
  }

  public void setQuality(int quality) {
    this.quality = quality;
  }

  public int getLv() {
    return lv;
  }

  public void setLv(int lv) {
    this.lv = lv;
  }

  public int getExpNeed() {
    return expNeed;
  }

  public void setExpNeed(int expNeed) {
    this.expNeed = expNeed;
  }

  public int getExpOffer() {
    return expOffer;
  }

  public void setExpOffer(int expOffer) {
    this.expOffer = expOffer;
  }

  public int getBreakOn() {
    return breakOn;
  }

  public void setBreakOn(int breakOn) {
    this.breakOn = breakOn;
  }
}
