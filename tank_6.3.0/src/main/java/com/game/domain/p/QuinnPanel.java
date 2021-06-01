package com.game.domain.p;

import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.Quinn;

import java.util.List;

/**
 * 超时空财团商品
 * @author 丁文渊
 * 上午11:04:07
 */
public class QuinnPanel {
    /**  面板类型  1贸易  2兑换 */
    private int type;
    /**  商品对象*/
    private List<Quinn> quinns;
    /**  当前刷新类型 1免费 2刷新券 3金币*/
    private int getType;
    /**  当前金币刷新次数(刷新类型为免费时此字段为剩余免费次数，)*/
    private int getNumber;
    /** 累计刷新金钱*/
    private  int getSum;
    /** 累计刷新金钱*/
    private  long freshedDate = 0;

    public long getFreshedDate() {
		return freshedDate;
	}
	public void setFreshedDate(long freshedDate) {
		this.freshedDate = freshedDate;
	}
	/** 当前刷新奖励(可以没有)*/
    private List<Award> awards = null;
    
    /** 当前刷新奖励id*/
    private int eggId;
    public int getType() {
        return type;
    }
    public void setType(int type) {
        this.type = type;
    }
    public List<Quinn> getQuinns() {
        return quinns;
    }
    public void setQuinns(List<Quinn> quinns) {
        this.quinns = quinns;
    }
    public int getGetType() {
        return getType;
    }
    public void setGetType(int getType) {
        this.getType = getType;
    }
    public int getGetNumber() {
        return getNumber;
    }
    public void setGetNumber(int getNumber) {
        this.getNumber = getNumber;
    }
    public List<Award> getAwards() {
        return awards;
    }
    public void setAwards(List<Award> awards) {
        this.awards = awards;
    }
    
    public int getGetSum() {
        return getSum;
    }
    public void setGetSum(int getSum) {
        this.getSum = getSum;
    }


 
    /**
     * @return the eggId
     */
    public int getEggId() {
        return eggId;
    }
    /**
     * @param eggId the eggId to set
     */
    public void setEggId(int eggId) {
        this.eggId = eggId;
    }

}
