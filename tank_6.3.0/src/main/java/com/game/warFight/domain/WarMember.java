/**   
 * @Title: WarMember.java    
 * @Package com.game.domain.p    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年12月14日 下午1:50:23    
 * @version V1.0   
 */
package com.game.warFight.domain;

import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.p.Form;

/**
 * @ClassName: WarMember
 * @Description:  参加军团战的剧团成员信息
 * @author ZhangJun
 * @date 2015年12月14日 下午1:50:23
 * 
 */
public class WarMember {
	private Player player;
	private Member member;
	private WarParty warParty;
	private Form form;

	/**
	 * @Fields state : 参战状态，0.未出局 1.已出局
	 */
	private int state;
//	private int winCount;
	private Form instForm;
    //战斗中获得的战损
    private long mplt;

    public void addMplt(long v) {
        mplt += v;
    }

    public long getMplt() {
        return mplt;
    }

    public Player getPlayer() {
		return player;
	}

	public void setPlayer(Player player) {
		this.player = player;
	}

	public Form getForm() {
		return form;
	}

	public void setForm(Form form) {
		this.form = form;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public Form getInstForm() {
		return instForm;
	}

	public void setInstForm(Form instForm) {
		this.instForm = instForm;
	}

	public int calcHp() {
		Form baseForm = getForm();
		Form curForm = getInstForm();
		int base = baseForm.c[0] + baseForm.c[1] + baseForm.c[2] + baseForm.c[3] + baseForm.c[4] + baseForm.c[5];
		int cur = curForm.c[0] + curForm.c[1] + curForm.c[2] + curForm.c[3] + curForm.c[4] + curForm.c[5];
		return cur * 100 / base;
	}

	public WarParty getWarParty() {
		return warParty;
	}

	public void setWarParty(WarParty warParty) {
		this.warParty = warParty;
	}

	public Member getMember() {
		return member;
	}

	public void setMember(Member member) {
		this.member = member;
	}
	
	public String toSimpleString() {
		return "roleId:" + player.roleId + ", nick:" + player.lord.getNick() + ", partyId:" + member.getPartyId()
				+ ", state:" + state + ", form:" + form;
	}
}
