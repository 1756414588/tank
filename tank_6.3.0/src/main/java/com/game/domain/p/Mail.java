package com.game.domain.p;

import java.util.List;

import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Report;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-4 下午3:18:11
* @Description:邮件对象
 */

public class Mail implements Cloneable {
	private int keyId;
	private int type;
	private int moldId;
	private String[] param;
	private String title;
	private String sendName;
	private List<String> toName;
	private int state;
	private String contont;
	private List<CommonPb.Award> award;
	private Report report;
	private int time;
	private int lv;
	private int vipLv;
	private int collections;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getMoldId() {
		return moldId;
	}

	public void setMoldId(int moldId) {
		this.moldId = moldId;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getSendName() {
		return sendName;
	}

	public void setSendName(String sendName) {
		this.sendName = sendName;
	}

	public List<String> getToName() {
		return toName;
	}

	public void setToName(List<String> toName) {
		this.toName = toName;
	}

	public int getState() {
		return state;
	}

	public void setState(int state) {
		this.state = state;
	}

	public String getContont() {
		return contont;
	}

	public void setContont(String contont) {
		this.contont = contont;
	}

	public int getTime() {
		return time;
	}

	public void setTime(int time) {
		this.time = time;
	}

	public String[] getParam() {
		return param;
	}

	public void setParam(String[] param) {
		this.param = param;
	}

	public Report getReport() {
		return report;
	}

	public void setReport(Report report) {
		this.report = report;
	}

	public int getLv() {
		return lv;
	}

	public void setLv(int lv) {
		this.lv = lv;
	}

	public int getVipLv() {
		return vipLv;
	}

	public void setVipLv(int vipLv) {
		this.vipLv = vipLv;
	}

	public Mail() {

	}

	public Mail(int keyId, int type, int moldId, int state, int time) {
		this.keyId = keyId;
		this.type = type;
		this.state = state;
		this.moldId = moldId;
		this.time = time;
	}

	public Mail(int keyId, int type, int state, int time, String title, String content, String sendName) {
		this.keyId = keyId;
		this.type = type;
		this.state = state;
		this.time = time;
		this.title = title;
		this.contont = content;
		this.sendName = sendName;
	}

	public List<CommonPb.Award> getAward() {
		return award;
	}

	public void setAward(List<CommonPb.Award> award) {
		this.award = award;
	}
	
	public Object clone() {
	    try {
            return super.clone();
        } catch (CloneNotSupportedException e) {
            e.printStackTrace();
        }
	    return null;
	}

	public int getCollections() {
		return collections;
	}

	public void setCollections(int collections) {
		this.collections = collections;
	}
}
