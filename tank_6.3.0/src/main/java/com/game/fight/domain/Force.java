/**
 * @Title: Force.java
 * @Package com.game.fight.domain
 * @Description:
 * @author ZhangJun
 * @date 2015年8月28日 下午4:35:48
 * @version V1.0
 */
package com.game.fight.domain;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.constant.HeroConst;
import com.game.domain.s.StaticTank;
import com.game.domain.s.tactics.StaticTacticsTankSuit;
import com.game.fight.FightCalc;

/**
 * @ClassName: 战斗单位 的坦克栏位 (一个阵型有6个栏位 可以放6种坦克)
 * @Description:
 * @author ZhangJun
 * @date 2015年8月28日 下午4:35:48
 *
 */
public class Force {
	public int pos;
	public long hp;
	public long maxHp;
	public long initCount;// 战斗刚开始时坦克数量
	public AttrData attrData;
	public StaticTank staticTank;
	public int count;
	public int killed;
	public boolean dizzy;
	public Fighter fighter;
	public int key;
	public int type; // 5 蓄力 6自爆 7分裂
	public boolean god;
	public int frightenNum;// 震慑造成的眩晕数
	public boolean frightenDizzy;// 震慑造成的眩晕
	public int eid;// 攻击特效

	public int forceCount;// 蓄力回合数量
	public boolean isforce = false;// 玩家是否蓄力完成
	public int force = 0;// 蓄力完成攻击次数
	public boolean isDivisive = false;// 是否是分裂出来的坦克

	public boolean isExplosion = false;// 是否是自爆坦克

	public Map<Integer, Object> skillEffect = new HashMap<>();
	public int zbCount = 0;// 自爆卡车攻击人数
	public long lcbHurt = 0;// 列车炮伤害

	public StaticTacticsTankSuit tacticsTankSuitConfig;

	/**
	 * 觉醒技能属性
	 */
	public Map<Integer, Integer> heroAttr = new HashMap<>();

	/**
	 * 减伤护罩（全体，持续回合）
	 */
	public float subHurtB = 0;
	/**
	 * 被动加减伤百分比
	 */
	public float subHurtB2 = 0;

	/**
	 * 是否免疫震慑穿刺
	 */
	public boolean isImmune = false;

	/**
	 * 复活增加的属性百分比
	 */
	public Map<Integer, Float> fhAttr = new HashMap<>();

	public Force(StaticTank staticTank, AttrData attrData, int pos, int count, int eid) {
		this(staticTank, attrData, pos, count);
		this.eid = eid;
	}

	public Force(StaticTank staticTank, AttrData attrData, int pos, int count) {
		this.pos = pos;
		this.staticTank = staticTank;
		this.attrData = attrData;
		this.count = count;
		this.initCount = count;
		type = staticTank.getType();
		dizzy = false;
		god = false;
		killed = 0;
		hp = 0;
		frightenNum = 0;
		frightenDizzy = false;
	}

	public Force copyForce() {
		Force force = new Force(staticTank, attrData.copy(), pos, count);
		force.pos = pos;
		force.hp = hp;
		force.maxHp = maxHp;
		force.staticTank = staticTank;
		force.count = count;
		force.killed = killed;
		force.dizzy = dizzy;
		force.fighter = fighter;
		force.key = key;
		force.type = type;
		force.god = god;
		force.skillEffect = new HashMap<>();
		force.skillEffect.putAll(skillEffect);
		force.initCount = initCount;
		force.frightenNum = frightenNum;
		force.frightenDizzy = frightenDizzy;
		force.eid = eid;
		force.fhAttr.putAll(fhAttr);

		return force;


	}

	public void initHp() {
		maxHp = calcHp();
		hp = maxHp * count;
	}

	public boolean alive() {
		return count > 0;
	}

	public long hurt(long hurt) {
		if (god) {
			return 0;
		}

		hp -= hurt;
		if (hp < 0) {
			hp = 0;
		}

		int alive = FightCalc.calcAlive(this);
		int killed = count - alive;

		if (count != alive) {
			count = alive;
			this.killed += killed;
		}

		if (hp <= 0) {
			fighter.fightLogic.onForceDie(this);
		}

		// GameServer.GAME_LOGGER.error("force " + key + " count:" + count +
		// " bekilled:" + this.killed + " alive:" + alive);

		return count;
	}

	// 闪避
	public int calcDodge() {
		return (int) (attrData.dodge + fighter.auraData[type - 1].dodge);
	}

	// 命中
	public int calcHit() {
		return (int) (attrData.hit + fighter.auraData[type - 1].hit);
	}

	// 暴击
	public int calcCrit() {
		return (int) (attrData.crit + fighter.auraData[type - 1].crit);
	}

	// 抗暴
	public int calcCritDef() {
		return (int) (attrData.critDef + fighter.auraData[type - 1].critDef);
	}

	// 穿刺
	public int calcImpale() {
		return (int) (attrData.impale + fighter.auraData[type - 1].impale);
	}
	
	// 防护
	public int calcDefend() {
		return (int) (attrData.defend + fighter.auraData[type - 1].defend);
	}

	// HP，基础值 * 加成比例
	public long calcHp() {
		return (long) (attrData.hp * (FightCalc.BASE + attrData.hpF) / FightCalc.BASE);
	}

	// 震慑
	public int calcFrighten() {
		return (int) (attrData.frighten + fighter.auraData[type - 1].frighten);
	}
	
	// 刚毅
	public int calcFortitude() {
		return (int) (attrData.fortitude + fighter.auraData[type - 1].fortitude);
	}

	public boolean removeSkillEffect(Integer id) {
		return skillEffect.remove(id) != null;
	}

	public int getSkillEffectBarrier() {
		Integer reduceHurt = (Integer) skillEffect.get(HeroConst.ID_SKILL_BARRIER);
		if (reduceHurt == null) {
			reduceHurt = 0;
		}
		return reduceHurt;
	}

	@Override
	public String toString() {
		return "Force{" + "pos=" + pos + ", hp=" + hp + ", count=" + count + ", killed=" + killed + ", key=" + key + ", tankId="
				+ (staticTank != null ? staticTank.getTankId() : 0) + '}';
	}

	/**
	 * 风行者增伤技能增加伤害值
	 * 
	 * @return
	 */
	public int getDemageF() {
		List<Integer> twoInt = (List<Integer>) skillEffect.get(HeroConst.ID_SKILL_11);
		if (twoInt == null || twoInt.size() != 2) {
			return 0;
		}
		return twoInt.get(0);
	}

	/**
	 * 震慑造成的眩晕数清0
	 */
	public void cleanDizzyNum() {
		frightenNum = 0;
	}

	public Map<Integer, Integer> getHeroAttr() {
		return heroAttr;
	}

	/**
	 * 添加觉醒技能属性
	 * 
	 * @param attrId
	 * @param val
	 */
	public void addHeroAttr(Integer attrId, int val) {
		if (!this.heroAttr.containsKey(attrId)) {
			this.heroAttr.put(attrId, 0);
		}
		this.heroAttr.put(attrId, this.heroAttr.get(attrId) + val);
		attrData.addValue(attrId, val);
	}

	/**
	 * 清楚觉醒技能属性
	 */
	public void clearHeroAttr() {

		if (!this.heroAttr.isEmpty()) {
			for (Map.Entry<Integer, Integer> e : this.heroAttr.entrySet()) {

				long value = attrData.getValue(e.getKey());
				if (value > e.getValue()) {
					attrData.addValue(e.getKey(), -e.getValue());
				}
			}
		}

	}

	public void addFhAttr(int attrId, float bl) {
		if (!this.fhAttr.containsKey(attrId)) {
			this.fhAttr.put(attrId, 0f);
		}
		this.fhAttr.put(attrId, this.fhAttr.get(attrId) + bl);
	}

	public void calFhAttr() {
		if (!this.fhAttr.isEmpty()) {
			for (Map.Entry<Integer, Float> e : this.fhAttr.entrySet()) {
				attrData.addValue(e.getKey(), e.getValue().intValue());
			}
		}

	}
}
