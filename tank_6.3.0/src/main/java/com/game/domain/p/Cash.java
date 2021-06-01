package com.game.domain.p;

import java.util.ArrayList;
import java.util.List;

import com.game.pb.CommonPb;

/**
 * @author ChenKui
 * @version 创建时间：2016-3-14 下午3:00:58
 * @Description: 装备兑换记录
 */

public class Cash {

	private int cashId;// 兑换ID
	private int formulaId;// 配方ID
	private int state;// 剩余可兑换次数
	private int free;// 剩余免费刷新次数
	private int refreshDate;// 刷新日期
	private int price;
	private List<List<Integer>> list;
	private List<Integer> awardList;

	public int getCashId() {
		return cashId;
	}

	public void setCashId(int cashId) {
		this.cashId = cashId;
	}

	public int getFormulaId() {
		return formulaId;
	}

	public void setFormulaId(int formulaId) {
		this.formulaId = formulaId;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getFree() {
		return free;
	}

	public void setFree(int free) {
		this.free = free;
	}

	public int getRefreshDate() {
		return refreshDate;
	}

	public void setRefreshDate(int refreshDate) {
		this.refreshDate = refreshDate;
	}

	public int getPrice() {
		return price;
	}

	public void setPrice(int price) {
		this.price = price;
	}

	public List<List<Integer>> getList() {
		return list;
	}

	public void setList(List<List<Integer>> list) {
		this.list = list;
	}

	public List<Integer> getAwardList() {
		return awardList;
	}

	public void setAwardList(List<Integer> awardList) {
		this.awardList = awardList;
	}

	public Cash() {
	}

	public Cash(CommonPb.Cash e) {
		this.cashId = e.getCashId();
		this.formulaId = e.getFormulaId();
		this.state = e.getState();
		this.free = e.getFree();
		this.refreshDate = e.getRefreshDate();
		this.price = e.getPrice();
		this.list = new ArrayList<List<Integer>>();
		this.awardList = new ArrayList<Integer>();
		List<CommonPb.Atom> atomList = e.getAtomList();
		for (CommonPb.Atom e1 : atomList) {
			int type = e1.getType();
			int id = e1.getId();
			int count = e1.getCount();
			List<Integer> e2 = new ArrayList<Integer>();
			e2.add(type);
			e2.add(id);
			e2.add(count);
			this.list.add(e2);
		}
		this.awardList.add(e.getAward().getType());
		this.awardList.add(e.getAward().getId());
		this.awardList.add((int)e.getAward().getCount());
	}
}
