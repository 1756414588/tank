/**   
 * @Title: FightSuffer.java    
 * @Package com.game.fortressFight.domain    
 * @Description:   
 * @author WanYi  
 * @date 2016年6月8日 下午2:43:04    
 * @version V1.0   
 */
package com.game.fortressFight.domain;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @Description: 个人要塞战数据
 * @author WanYi
 * @date 2016年6月8日 下午2:43:04
 * 
 */
public class MyFortressFightData {
	private long lordId;
	private Map<Integer, SufferTank> sufferTankMap = new HashMap<>();
	private Map<Integer, SufferTank> destoryTankMap = new HashMap<>();
	private MyCD myCD = new MyCD();
	private int jifen = 0;
	private int fightNum = 0;
	private int winNum = 0;
	private List<Integer> myReportKeys = new ArrayList<>(); // 我的战报key
	private Map<Integer, MyFortressAttr> myFortressAttrs = new HashMap<>();// 我的进修效果
	private int sufferTankCountForevel = 0;	//永久损失的坦克个数
    private long mplt;//活动军功

    public void addMplt(long addMplt) {
        this.mplt += addMplt;
    }

    public void setMplt(long mplt) {
        this.mplt = mplt;
    }

    public long getMplt() {
        return mplt;
    }

    public int getSufferTankCountForevel() {
		return sufferTankCountForevel;
	}

	public void setSufferTankCountForevel(int sufferTankCountForevel) {
		this.sufferTankCountForevel = sufferTankCountForevel;
	}

	public MyCD getMyCD() {
		return myCD;
	}

	public void setMyCD(MyCD myCD) {
		this.myCD = myCD;
	}

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public Map<Integer, SufferTank> getSufferTankMap() {
		return sufferTankMap;
	}

	public void setSufferTankMap(Map<Integer, SufferTank> sufferTankMap) {
		this.sufferTankMap = sufferTankMap;
	}

	public int getJifen() {
		return jifen;
	}

	public Map<Integer, SufferTank> getDestoryTankMap() {
		return destoryTankMap;
	}

	public void setDestoryTankMap(Map<Integer, SufferTank> destoryTankMap) {
		this.destoryTankMap = destoryTankMap;
	}

	public void setJifen(int jifen) {
		this.jifen = jifen;
	}

	public List<Integer> getMyReportKeys() {
		return myReportKeys;
	}

	public void setMyReportKeys(List<Integer> myReportKeys) {
		this.myReportKeys = myReportKeys;
	}

	public void addReportKey(int reportKey) {
		myReportKeys.add(reportKey);
	}

	public int getFightNum() {
		return fightNum;
	}

	public void setFightNum(int fightNum) {
		this.fightNum = fightNum;
	}

	public int getWinNum() {
		return winNum;
	}

	public void setWinNum(int winNum) {
		this.winNum = winNum;
	}

	public Map<Integer, MyFortressAttr> getMyFortressAttrs() {
		return myFortressAttrs;
	}

	public void setMyFortressAttrs(Map<Integer, MyFortressAttr> myFortressAttrs) {
		this.myFortressAttrs = myFortressAttrs;
	}

}
