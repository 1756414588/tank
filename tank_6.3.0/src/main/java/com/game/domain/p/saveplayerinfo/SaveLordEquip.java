package com.game.domain.p.saveplayerinfo;

import java.util.ArrayList;
import java.util.List;

/**
 * @ClassName:SaveEquipt
 * @author zc
 * @Description:军备
 * @date 2017年9月19日
 */
public class SaveLordEquip {
	private int equipId;// 军备id
	private int equipLv;// 军备等级
	private List<Integer> lordEquipSkillList;// 军备技能

	public long getMem() {
		return 32 * 2 + lordEquipSkillList.size() * 32;
	}
	
	public SaveLordEquip(int equipId, int equipLv, List<List<Integer>> lordEquipSkillList) {
		this.equipId = equipId;
		this.equipLv = equipLv;
		this.lordEquipSkillList = new ArrayList<>(lordEquipSkillList.size());
		for (List<Integer> skill : lordEquipSkillList) {
			this.lordEquipSkillList.add(skill.get(0));
		}
	}

	public int getEquipId() {
		return equipId;
	}

	public int getEquipLv() {
		return equipLv;
	}

	public List<Integer> getLordEquipSkillList() {
		return lordEquipSkillList;
	}
	
	public String getSkill() {
		StringBuilder sb = new StringBuilder();
		for(Integer skill : lordEquipSkillList){
			sb.append(skill+",");
		}
		if(sb.length() > 0){
			sb.setLength(sb.length() - 1);
		}
		return sb.toString();
	}
}
