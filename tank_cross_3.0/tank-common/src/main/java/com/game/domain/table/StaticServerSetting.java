package com.game.domain.table;

import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/11 18:00
 * @description：s_server_setting 数据库表
 */
@Table(value = "s_server_setting")
public class StaticServerSetting implements KeyDataEntity<Integer> {

  @Primary
  @Foreign
  @Column(value = "paramId")
  private int paramId;

  @Column(value = "title")
  private String title;

  @Column(value = "paramName")
  private String paramName;

  @Column(value = "paramValue")
  private String paramValue;

  @Column(value = "descs")
  private String descs;

  public int getParamId() {
    return paramId;
  }

  public void setParamId(int paramId) {
    this.paramId = paramId;
  }

  public String getTitle() {
    return title;
  }

  public void setTitle(String title) {
    this.title = title;
  }

  public String getParamName() {
    return paramName;
  }

  public void setParamName(String paramName) {
    this.paramName = paramName;
  }

  public String getParamValue() {
    return paramValue;
  }

  public void setParamValue(String paramValue) {
    this.paramValue = paramValue;
  }

  public String getDescs() {
    return descs;
  }

  public void setDescs(String descs) {
    this.descs = descs;
  }
}
