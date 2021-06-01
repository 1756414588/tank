/**   
 * @Title: WarParty.java    
 * @Package com.game.warFight.domain    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月17日 下午2:56:47    
 * @version V1.0   
 */
package com.game.warFight.domain;

import com.game.domain.PartyData;

import java.util.*;

/**
 * @ClassName: WarParty
 * @Description: 军团战军团信息
 * @author ZhangJun
 * @date 2015年12月17日 下午2:56:47
 * 
 */
public class WarParty {
	private Map<Long, WarMember> members = new HashMap<Long, WarMember>();
	private List<WarMember> fighters = new ArrayList<>();
	private int order = 0;
	private int outCount = 0;

	private PartyData partyData;

	public WarParty(PartyData partyData) {
		this.partyData = partyData;
		partyData.setRegLv(partyData.getPartyLv());
	}

	public void prepair() {
		fighters.clear();
		fighters.addAll(members.values());
		Collections.shuffle(fighters);
	}

	public boolean allOut() {
		return outCount == members.size();
	}

	public WarMember aquireFighter() {
		while (true) {
			WarMember warMember = fighters.get(order % fighters.size());
			order++;
			if (warMember.getState() == 1) {
				continue;
			}

			return warMember;
		}
	}

	public void fighterOut(WarMember warMember) {
		warMember.setState(1);
		outCount++;
	}

	public void add(WarMember warMember) {
		members.put(warMember.getPlayer().roleId, warMember);
		warMember.setWarParty(this);
//		partyData.fight += warMember.getMember().getRegFight();
		partyData.setRegFight(partyData.getRegFight() + warMember.getMember().getRegFight());
	}
	
	public void load(WarMember warMember) {
		members.put(warMember.getPlayer().roleId, warMember);
		warMember.setWarParty(this);
	}

	public WarMember getMember(long roleId) {
		return members.get(roleId);
	}

	public void remove(WarMember warMember) {
		members.remove(warMember.getPlayer().roleId);
//		fight -= warMember.getMember().getRegFight();
		partyData.setRegFight(partyData.getRegFight() - warMember.getMember().getRegFight());
		warMember.getMember().setRegParty(0);
		warMember.getMember().setRegLv(0);
		warMember.getMember().setRegTime(0);
		warMember.getMember().setRegFight(0);
	}

	public Map<Long, WarMember> getMembers() {
		return members;
	}

//	public int getRank() {
//		return rank;
//	}
//
//	public void setRank(int rank) {
//		this.rank = rank;
//	}



//	public long getFight() {
//		return fight;
//	}
//
//	public void setFight(long fight) {
//		this.fight = fight;
//	}

	public PartyData getPartyData() {
		return partyData;
	}

	public void setPartyData(PartyData partyData) {
		this.partyData = partyData;
	}
}
