package com.game.domain.s;

/**
 * @ClassName StaticRebelAttr.java
 * @Description 叛军部队属性配置
 * @author TanDonghai
 * @date 创建时间：2016年9月6日 下午4:52:14
 *
 */
public class StaticRebelAttr {
	private int keyId;
	private int teamType;// 部队类型。1、小队。2、分队。3、领袖
	private int enemyLevel;// 敌军等级
	private int tankId;// tankId
	private int attack;// 攻击力
	private int hp;// 生命
	private int hit;// 命中万分比
	private int dodge;// 闪避万分比
	private int crit;// 暴击万分比
	private int critDef;// 抗暴万分比
	private int impale;// 穿刺万分比
	private int defend;// 防护万分比
	private int damege;// 增伤百分比
	private int injured;// 减伤百分比

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getTeamType() {
		return teamType;
	}

	public void setTeamType(int teamType) {
		this.teamType = teamType;
	}

	public int getEnemyLevel() {
		return enemyLevel;
	}

	public void setEnemyLevel(int enemyLevel) {
		this.enemyLevel = enemyLevel;
	}

	public int getTankId() {
		return tankId;
	}

	public void setTankId(int tankId) {
		this.tankId = tankId;
	}

	public int getAttack() {
		return attack;
	}

	public void setAttack(int attack) {
		this.attack = attack;
	}

	public int getHp() {
		return hp;
	}

	public void setHp(int hp) {
		this.hp = hp;
	}

	public int getHit() {
		return hit;
	}

	public void setHit(int hit) {
		this.hit = hit;
	}

	public int getDodge() {
		return dodge;
	}

	public void setDodge(int dodge) {
		this.dodge = dodge;
	}

	public int getCrit() {
		return crit;
	}

	public void setCrit(int crit) {
		this.crit = crit;
	}

	public int getCritDef() {
		return critDef;
	}

	public void setCritDef(int critDef) {
		this.critDef = critDef;
	}

	public int getImpale() {
		return impale;
	}

	public void setImpale(int impale) {
		this.impale = impale;
	}

	public int getDefend() {
		return defend;
	}

	public void setDefend(int defend) {
		this.defend = defend;
	}

	public int getDamege() {
		return damege;
	}

	public void setDamege(int damege) {
		this.damege = damege;
	}

	public int getInjured() {
		return injured;
	}

	public void setInjured(int injured) {
		this.injured = injured;
	}

	@Override
	public String toString() {
		return "StaticRebelAttr [keyId=" + keyId + ", teamType=" + teamType + ", enemyLevel=" + enemyLevel + ", tankId="
				+ tankId + ", attack=" + attack + ", hp=" + hp + ", hit=" + hit + ", dodge=" + dodge + ", crit=" + crit
				+ ", critDef=" + critDef + ", impale=" + impale + ", defend=" + defend + ", damege=" + damege
				+ ", injured=" + injured + "]";
	}
}
