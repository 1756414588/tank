package com.game.domain.s;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-16 下午2:25:38
 * @declare
 */
public class StaticPartyTrend {

  private int trendId;
  private int type;
  private String name;
  private String content;
  private String param;

  public int getTrendId() {
    return trendId;
  }

  public void setTrendId(int trendId) {
    this.trendId = trendId;
  }

  public int getType() {
    return type;
  }

  public void setType(int type) {
    this.type = type;
  }

  public String getName() {
    return name;
  }

  public void setName(String name) {
    this.name = name;
  }

  public String getContent() {
    return content;
  }

  public void setContent(String content) {
    this.content = content;
  }

  public String getParam() {
    return param;
  }

  public void setParam(String param) {
    this.param = param;
  }
}
