package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-17 下午2:21:59
 * @declare
 */
public class StaticMail {

  private int moldId;
  private int type;
  private String sname;
  private String mtitle;
  private String mcontent;
  private String param;

  public int getMoldId() {
    return moldId;
  }

  public void setMoldId(int moldId) {
    this.moldId = moldId;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public String getSname() {
    return sname;
  }

  public void setSname(String sname) {
    this.sname = sname;
  }

  public String getMtitle() {
    return mtitle;
  }

  public void setMtitle(String mtitle) {
    this.mtitle = mtitle;
  }

  public String getMcontent() {
    return mcontent;
  }

  public void setMcontent(String mcontent) {
    this.mcontent = mcontent;
  }

  public String getParam() {
    return param;
  }

  public void setParam(String param) {
    this.param = param;
  }
}
