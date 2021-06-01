package com.game.domain.s;

import java.util.ArrayList;
import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2016-3-23 下午2:56:02
 * @declare 功能开关
 */

public class StaticFunctionPlan {

	private int keyId;
	private int funId;
	private String funname;
	private int dayiy;
	private String rules;
	private int whole;
	private List<Integer> serverList = new ArrayList<Integer>();

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getFunId() {
		return funId;
	}

	public void setFunId(int funId) {
		this.funId = funId;
	}

	public String getFunname() {
		return funname;
	}

	public void setFunname(String funname) {
		this.funname = funname;
	}

	public int getDayiy() {
		return dayiy;
	}

	public void setDayiy(int dayiy) {
		this.dayiy = dayiy;
	}

	public String getRules() {
		return rules;
	}

	public void setRules(String rules) {
		this.rules = rules;
	}

	public int getWhole() {
		return whole;
	}

	public void setWhole(int whole) {
		this.whole = whole;
	}

	public List<Integer> getServerList() {
		return serverList;
	}

	public void setServerList(List<Integer> serverList) {
		this.serverList = serverList;
	}

}
