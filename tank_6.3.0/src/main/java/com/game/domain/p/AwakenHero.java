package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

import com.game.constant.HeroConst;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.TwoInt;
import com.game.util.LogUtil;
/**
* @ClassName: AwakenHero 
* @Description: 觉醒将领
* @author
 */
public class AwakenHero implements Cloneable {
	private int keyId;
	private int heroId;
	private int state;
	private int failTimes;
	private Map<Integer, Integer> skillLv = new HashMap<Integer, Integer>();

	public AwakenHero(int keyId, int heroId) {
		this.keyId = keyId;
		this.heroId = heroId;
	}
	
	public AwakenHero(CommonPb.AwakenHero a) {
		this.keyId = a.getKeyId();
		this.heroId = a.getHeroId();
		this.state = a.getState();
		for (TwoInt twoInt : a.getSkillLvList()) {
			skillLv.put(twoInt.getV1(), twoInt.getV2());
		}
		this.failTimes = a.getFailTimes();
	}
	
	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getHeroId() {
		return heroId;
	}

	public void setHeroId(int heroId) {
		this.heroId = heroId;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public int getFailTimes() {
		return failTimes;
	}

	public void setFailTimes(int failTimes) {
		this.failTimes = failTimes;
	}

	public Map<Integer, Integer> getSkillLv() {
		return skillLv;
	}

	public void setSkillLv(Map<Integer, Integer> skillLv) {
		this.skillLv = skillLv;
	}

	@Override
	public AwakenHero clone() {
		try {
			return (AwakenHero) super.clone();
		} catch (CloneNotSupportedException e) {
			LogUtil.error(e);
		}
		return null;
	}
	
	public boolean isUsed(){
		return state == HeroConst.HERO_AWAKEN_STATE_USED;
	}
	
	public void setUsed(boolean used){
		if(used){
			state = HeroConst.HERO_AWAKEN_STATE_USED;
		}else{
			state = 0;
		}
	}
}
