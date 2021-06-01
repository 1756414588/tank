package com.game.domain.p;

import com.game.manager.DataRepairDM;
import com.game.pb.CommonPb;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-3 下午6:02:17
* @Description: 用于显示的玩家信息（军情民情会用到）
 */

public class Man {

	private long lordId;
	private int icon;
	private int sex;
	private String nick;
	private int level;
	private long fight;
	private int ranks;
	private int exp;
	private int pos;
	private int vip = -1;
	private int honour = -1;
	private int pros = -1;
	private int prosMax;
	private String partyName;
	private int jobId;

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getIcon() {
		return icon;
	}

	public void setIcon(int icon) {
		this.icon = icon;
	}

	public int getSex() {
		return sex;
	}

	public void setSex(int sex) {
		this.sex = sex;
	}

	public String getNick() {
		return nick;
	}

	public void setNick(String nick) {
		this.nick = nick;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public long getFight() {
		return fight;
	}

	public void setFight(long fight) {
		this.fight = fight;
	}

	public int getRanks() {
		return ranks;
	}

	public void setRanks(int ranks) {
		this.ranks = ranks;
	}

	public int getExp() {
		return exp;
	}

	public void setExp(int exp) {
		this.exp = exp;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}

	public int getVip() {
		return vip;
	}

	public void setVip(int vip) {
		this.vip = vip;
	}

	public int getHonour() {
		return honour;
	}

	public void setHonour(int honour) {
		this.honour = honour;
	}

	public int getPros() {
		return pros;
	}

	public void setPros(int pros) {
		this.pros = pros;
	}

	public int getProsMax() {
		return prosMax;
	}

	public void setProsMax(int prosMax) {
		this.prosMax = prosMax;
	}

	public String getPartyName() {
		return partyName;
	}

	public void setPartyName(String partyName) {
		this.partyName = partyName;
	}

	public Man() {
	}

	public Man(long lordId) {
		this.lordId = lordId;
	}
	
	public int getJobId() {
		return jobId;
	}

	public void setJobId(int jobId) {
		this.jobId = jobId;
	}

	public Man(long lordId, int sex, String nick, int icon, int level) {
		this.lordId = lordId;
		this.sex = sex;
		this.nick = nick;
		this.icon = icon;
		this.level = level;
	}

    public Man(CommonPb.Man pbm, DataRepairDM dataRepairDM) {
        this.lordId = dataRepairDM.getNewLordId(pbm.getLordId());
        this.icon = pbm.getIcon();
        this.sex = pbm.getSex();
        this.nick = pbm.getNick();
        this.level = pbm.getLevel();
        this.fight = pbm.getFight();
        this.ranks = pbm.getRanks();
        this.exp = pbm.getExp();
        this.pos = pbm.getPos();
        if (pbm.getVip() > 0) {
            this.vip = pbm.getVip();
        }
        if (pbm.getHonour() > 0) {
            this.honour = pbm.getHonour();
        }
        if (pbm.getPros() > 0) {
            this.pros = pbm.getPros();
        }
        this.prosMax = pbm.getProsMax();
        this.partyName = pbm.getPartyName();
        this.jobId = pbm.getJobId();
    }

}
