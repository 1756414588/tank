/**   
 * @Title: StaticSkill.java    
 * @Package com.game.domain.s    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月4日 下午2:14:21    
 * @version V1.0   
 */
package com.game.domain.s;

/**
 * @ClassName: StaticSkill
 * @Description: 技能表
 * @author ZhangJun
 * @date 2015年9月4日 下午2:14:21
 */
public class StaticSkill {
	private int skillId;
	private int target;
	private int attr;
	private int attrValue;

	public int getSkillId() {
		return skillId;
	}

	public void setSkillId(int skillId) {
		this.skillId = skillId;
	}

	public int getTarget() {
		return target;
	}

	public void setTarget(int target) {
		this.target = target;
	}

	public int getAttr() {
		return attr;
	}

	public void setAttr(int attr) {
		this.attr = attr;
	}

	public int getAttrValue() {
		return attrValue;
	}

	public void setAttrValue(int attrValue) {
		this.attrValue = attrValue;
	}

}
