package com.game.cross.domain;

public class CrossTrend {
  private int trendId; // 详情id
  private String[] trendParam; // 军情参数
  private int trendTime; // 军情发生时间

  public int getTrendId() {
    return trendId;
  }

  public void setTrendId(int trendId) {
    this.trendId = trendId;
  }

  public int getTrendTime() {
    return trendTime;
  }

  public void setTrendTime(int trendTime) {
    this.trendTime = trendTime;
  }

  public String[] getTrendParam() {
    return trendParam;
  }

  public void setTrendParam(String[] trendParam) {
    this.trendParam = trendParam;
  }

  public CrossTrend(int trendId, int trendTime, String... trendParam) {
    super();
    this.trendId = trendId;
    this.trendTime = trendTime;
    this.trendParam = trendParam;
  }

  public CrossTrend() {
    super();
  }
}
