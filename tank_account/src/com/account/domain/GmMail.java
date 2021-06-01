package com.account.domain;

import java.util.Date;

public class GmMail {

    private Integer keyid;
    private String ae;
    private int type;
    private String gmName;
    private String title;
    private String content;
    private String param;
    private int condition;
    private int conditionType;
    private int conditionValue;
    private String awards;
    private Date beginDate;
    private Date endDate;
    private int delModel;
    private long alive;

    public GmMail() {
    }

    public Integer getKeyid() {
        return this.keyid;
    }

    public void setKeyid(Integer keyid) {
        this.keyid = keyid;
    }

    public String getAe() {
        return ae;
    }

    public void setAe(String ae) {
        this.ae = ae;
    }

    public int getType() {
        return this.type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public String getGmName() {
        return this.gmName;
    }

    public void setGmName(String gmName) {
        this.gmName = gmName;
    }

    public String getTitle() {
        return this.title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getContent() {
        return this.content;
    }

    public void setContent(String content) {
        this.content = content;
    }

    public String getParam() {
        return this.param;
    }

    public void setParam(String param) {
        this.param = param;
    }

    public int getCondition() {
        return condition;
    }

    public void setCondition(int condition) {
        this.condition = condition;
    }

    public int getConditionType() {
        return conditionType;
    }

    public void setConditionType(int conditionType) {
        this.conditionType = conditionType;
    }

    public int getConditionValue() {
        return conditionValue;
    }

    public void setConditionValue(int conditionValue) {
        this.conditionValue = conditionValue;
    }

    public String getAwards() {
        return this.awards;
    }

    public void setAwards(String awards) {
        this.awards = awards;
    }

    public int getDelModel() {
        return this.delModel;
    }

    public void setDelModel(int delModel) {
        this.delModel = delModel;
    }

    public long getAlive() {
        return this.alive;
    }

    public void setAlive(long alive) {
        this.alive = alive;
    }

    public Date getBeginDate() {
        return this.beginDate;
    }

    public void setBeginDate(Date beginDate) {
        this.beginDate = beginDate;
    }

    public Date getEndDate() {
        return this.endDate;
    }

    public void setEndDate(Date endDate) {
        this.endDate = endDate;
    }

}
