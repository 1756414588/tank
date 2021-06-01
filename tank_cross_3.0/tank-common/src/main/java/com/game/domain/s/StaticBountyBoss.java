package com.game.domain.s;

/**
 * @author: LiFeng
 * @date: 4.19
 * @description: 赏金活动，关卡BOSS信息
 */
public class StaticBountyBoss {
	// CREATE TABLE `s_bounty_boss` (
	// `id` int(11) NOT NULL,
	// `name` varchar(255) NOT NULL,
	// `desc` varchar(255) NOT NULL,
	// `skill` int(11) NOT NULL,
	// `skillDesc` varchar(255) NOT NULL,
	// `frighten` int(11) NOT NULL COMMENT 'frighten：Boss的震慑属性，补充s_tank表对应BOSS',
	// `fortitude` int(11) NOT NULL COMMENT 'fortitude：BOSS刚毅',
	// `canImpale` int(11) NOT NULL COMMENT 'canImpale:是否可以被穿刺 0：否 1：可',
	// `canFrighten` int(11) NOT NULL COMMENT 'canFrighten：是否可以被震慑 0：否 1：可',
	// PRIMARY KEY (`id`)
	// ) ENGINE=InnoDB DEFAULT CHARSET=utf8;

	private int id;
	private String name;
	private int skill;
	private int frighten;
	private int fortitude;
	private int canFrighten;
	private int canImpale;

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}

	public int getSkill() {
		return skill;
	}

	public void setSkill(int skill) {
		this.skill = skill;
	}

	public int getFrighten() {
		return frighten;
	}

	public void setFrighten(int frighten) {
		this.frighten = frighten;
	}

	public int getFortitude() {
		return fortitude;
	}

	public void setFortitude(int fortitude) {
		this.fortitude = fortitude;
	}

	public int getCanFrighten() {
		return canFrighten;
	}

	public void setCanFrighten(int canFrighten) {
		this.canFrighten = canFrighten;
	}

	public int getCanImpale() {
		return canImpale;
	}

	public void setCanImpale(int canImpale) {
		this.canImpale = canImpale;
	}

}
