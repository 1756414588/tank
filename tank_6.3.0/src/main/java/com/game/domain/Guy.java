package com.game.domain;

import java.util.ArrayList;
import java.util.Iterator;
import java.util.List;

import com.game.domain.p.TipGuy;
import com.game.pb.SerializePb.SerOneLong;
import com.google.protobuf.InvalidProtocolBufferException;

/**
 * @author ChenKui
 * @version 创建时间：2016-4-23 下午3:37:20
 * @declare 举报玩家
 */

public class Guy {

	private long lordId;
	private int vip;
	private int level;
	private int count;
	private List<Long> tips = new ArrayList<Long>();
	private String content;
	private boolean isFlag = false;
	private int lastSaveTime;// 最终更新的时间

	public long getLordId() {
		return lordId;
	}

	public void setLordId(long lordId) {
		this.lordId = lordId;
	}

	public int getVip() {
		return vip;
	}

	public void setVip(int vip) {
		this.vip = vip;
	}

	public int getLevel() {
		return level;
	}

	public void setLevel(int level) {
		this.level = level;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public List<Long> getTips() {
		return tips;
	}

	public void setTips(List<Long> tips) {
		this.tips = tips;
	}

	public String getContent() {
		return content;
	}

	public void setContent(String content) {
		this.content = content;
	}

	public boolean isFlag() {
		return isFlag;
	}

	public void setFlag(boolean isFlag) {
		this.isFlag = isFlag;
	}

	public int getLastSaveTime() {
		return lastSaveTime;
	}

	public void setLastSaveTime(int lastSaveTime) {
		this.lastSaveTime = lastSaveTime;
	}

	public byte[] serTips() {
		SerOneLong.Builder ser = SerOneLong.newBuilder();
		Iterator<Long> it = tips.iterator();
		while (it.hasNext()) {
			ser.addV(it.next());
		}
		return ser.build().toByteArray();
	}

	public void dserTips(byte[] data) throws InvalidProtocolBufferException {
		if (data == null) {
			return;
		}
		SerOneLong ser = SerOneLong.parseFrom(data);
		List<Long> vList = ser.getVList();
		for (Long e : vList) {
			tips.add(e);
		}
	}

	public Guy() {
	}

	public Guy(long lordId) {
		this.lordId = lordId;
	}

	public TipGuy copyData() {
		TipGuy tipGuy = new TipGuy();
		tipGuy.setLordId(this.lordId);
		tipGuy.setCount(this.getCount());
		tipGuy.setVip(this.vip);
		tipGuy.setLevel(this.level);
		tipGuy.setContent(this.content);
		
		tipGuy.setTips(serTips());
		return tipGuy;
	}

	public Guy(TipGuy tipGuy) {
		this.lordId = tipGuy.getLordId();
		this.level = tipGuy.getLevel();
		this.vip = tipGuy.getVip();
		this.count = tipGuy.getCount();
		this.content = tipGuy.getContent();

		try {
			dserTips(tipGuy.getTips());
		} catch (InvalidProtocolBufferException e) {
			e.printStackTrace();
		}
	}
}
