package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;

public class MedalBouns {

  private int medalId;
  /** 0获得过且未展示 1获得过且已展示 */
  private int state;

  public int getMedalId() {
    return medalId;
  }

  public void setMedalId(int medalId) {
    this.medalId = medalId;
  }

  public int getState() {
    return state;
  }

  public void setState(int state) {
    this.state = state;
  }

  public MedalBouns(int medalId, int state) {
    this.medalId = medalId;
    this.state = state;
  }

  public MedalBouns(){

  }

  public MedalBouns(CrossTeamProto.MedalBouns mpb){
    this.medalId = mpb.getMedalId();
    this.state = mpb.getState();
  }
}
