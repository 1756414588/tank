package com.game.rebel.domain;

import com.game.constant.RebelConstant;

/**
 * @ClassName Rebel.java
 * @Description 记录叛军信息
 * @author TanDonghai
 * @date 创建时间：2016年9月3日 下午2:01:15
 *
 */
public class Rebel {
	private int rebelId;// 叛军id，对应s_rebel_team中的rebelId字段

	private int rebelLv;// 叛军的等级

	private int heroPick;// 对应s_rebel_hero_push表中的heroPick字段

	private int type;// 叛军类型，1 分队，2 卫队，3 领袖

	private int pos;// 坐标

	private int state;// 叛军状态，0 已击杀，1 未击杀，2 已逃跑

	/**
	 * 叛军boss 比例
	 */
	private float boss_hp;

	public Rebel() {
	}

	public Rebel(int rebelId, int rebelLv, int type, int pos, int heroPick) {
		this.heroPick = heroPick;
		this.rebelId = rebelId;
		this.rebelLv = rebelLv;
		this.type = type;
		this.pos = pos;
		this.state = RebelConstant.REBEL_STATE_ALIVE;
	}

	public Rebel(com.game.pb.CommonPb.Rebel rebel) {
		this.heroPick = rebel.getHeroPick();
		this.rebelId = rebel.getRebelId();
		this.rebelLv = rebel.getRebelLv();
		this.state = rebel.getState();
		this.type = rebel.getType();
		this.pos = rebel.getPos();
	}

	public boolean isAlive() {
		return state == RebelConstant.REBEL_STATE_ALIVE;
	}

	public int getRebelId() {
		return rebelId;
	}

	public void setRebelId(int rebelId) {
		this.rebelId = rebelId;
	}

	public int getRebelLv() {
		return rebelLv;
	}

	public void setRebelLv(int rebelLv) {
		this.rebelLv = rebelLv;
	}

	public int getHeroPick() {
		return heroPick;
	}

	public void setHeroPick(int heroPick) {
		this.heroPick = heroPick;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public float getBoss_hp() {
		return boss_hp;
	}

	public void setBoss_hp(float boss_hp) {
		this.boss_hp = boss_hp;
	}

	@Override
	public String toString() {
		return "Rebel [rebelId=" + rebelId + ", rebelLv=" + rebelLv + ", heroPick=" + heroPick + ", type=" + type
				+ ", pos=" + pos + ", state=" + state + "]";
	}
}
