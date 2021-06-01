/**   
 * @Title: Role.java    
 * @Package com.game.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月26日 下午6:01:52    
 * @version V1.0   
 */
package com.game.domain;

import com.game.domain.p.*;

import java.util.List;

/**
 * @ClassName: Role
 * @Description: 
 * @author ZhangJun
 * @date 2015年8月26日 下午6:01:52
 * 
 */
public class Role {
	private long roleId;
	private DataNew data;
	private Lord lord;
	private Building building;
	private Resource resource;
	private Arena arena;
	private PartyMember partyMember;
	private BossFight bossFight;// 世界BOSS战斗信息
	private BossFight altarBossFight;// 祭坛BOSS战斗信息
	private List<Mail>  saveMails;//新邮件
	private List<List<Integer>> updateMails;//状态更新了的邮件
	private List<Integer> delMails;//删除的邮件
	
	public long getRoleId() {
		return roleId;
	}

	public void setRoleId(long roleId) {
		this.roleId = roleId;
	}

	public DataNew getData() {
		return data;
	}

	public void setData(DataNew data) {
		this.data = data;
	}

	public Lord getLord() {
		return lord;
	}

	public void setLord(Lord lord) {
		this.lord = lord;
	}

	public Building getBuilding() {
		return building;
	}

	public void setBuilding(Building building) {
		this.building = building;
	}

	public Resource getResource() {
		return resource;
	}

	public void setResource(Resource resource) {
		this.resource = resource;
	}

	public PartyMember getPartyMember() {
		return partyMember;
	}

	public void setPartyMember(PartyMember partyMember) {
		this.partyMember = partyMember;
	}

	public Role(Player player, Arena arena, Member member, BossFight bossFight, BossFight altarBossFight) {
		roleId = player.roleId;
		data = player.serNewData();
		lord = (Lord) player.lord.clone();
		building = (Building) player.building.clone();
		resource = (Resource) player.resource.clone();
		if (arena != null) {
			this.setArena((Arena) arena.clone());
		}

		if (member != null) {
			this.setPartyMember(member.copyData());
		}
		
		if (bossFight != null) {
			this.setBossFight((BossFight)bossFight.clone());
		}
		
		if(altarBossFight != null) {
			this.setAltarBossFight((BossFight) altarBossFight.clone());
		}
		
		if(player.getNewMailsSize() > 0) {
		    saveMails = player.copyNewMails();
		}
		
		if(player.getUpdMailsSize() > 0) {
		    updateMails = player.copyUpdMails();
        }
		
		if(player.getDelMailsSize() > 0) {
		    delMails = player.copyDelMails();
        }
	}

	public Arena getArena() {
		return arena;
	}

	public void setArena(Arena arena) {
		this.arena = arena;
	}

	public BossFight getBossFight() {
		return bossFight;
	}

	public void setBossFight(BossFight bossFight) {
		this.bossFight = bossFight;
	}

	public BossFight getAltarBossFight() {
		return altarBossFight;
	}

	public void setAltarBossFight(BossFight altarBossFight) {
		this.altarBossFight = altarBossFight;
	}

    public List<Mail> getSaveMails() {
        return saveMails;
    }

    public void setSaveMails(List<Mail> saveMails) {
        this.saveMails = saveMails;
    }

    public List<List<Integer>> getUpdateMails() {
        return updateMails;
    }

    public void setUpdateMails(List<List<Integer>> updateMails) {
        this.updateMails = updateMails;
    }

    public List<Integer> getDelMails() {
        return delMails;
    }

    public void setDelMails(List<Integer> delMails) {
        this.delMails = delMails;
    }
}
