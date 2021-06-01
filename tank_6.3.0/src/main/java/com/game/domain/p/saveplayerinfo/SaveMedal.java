package com.game.domain.p.saveplayerinfo;

/**
 * @ClassName:Medal
 * @author zc
 * @Description:勋章讯息
 * @date 2017年9月19日
 */
public class SaveMedal {
	private int medalId;// 勋章id
	private int medalUpLv;// 勋章升级等级
	private int medalRefitLv;// 勋章打磨等级

	public long getMem() {
		return 32 * 3;
	}
	
	/**
	 * @param medalId2
	 * @param medalUpLv2
	 * @param medalRefitLv2
	 */
	public SaveMedal(int medalId, int medalUpLv, int medalRefitLv) {
		this.medalId = medalId;
		this.medalUpLv = medalUpLv;
		this.medalRefitLv = medalRefitLv;
	}

	public int getMedalId() {
		return medalId;
	}

	public void setMedalId(int medalId) {
		this.medalId = medalId;
	}

	public int getMedalUpLv() {
		return medalUpLv;
	}

	public void setMedalUpLv(int medalUpLv) {
		this.medalUpLv = medalUpLv;
	}

	public int getMedalRefitLv() {
		return medalRefitLv;
	}

	public void setMedalRefitLv(int medalRefitLv) {
		this.medalRefitLv = medalRefitLv;
	}
}
