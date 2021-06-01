package com.game.domain.p;

import com.game.domain.s.StaticPartyProp;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-9 下午7:05:33
 * @Description: 军团道具
 */

public class PartyProp {

	private int keyId;
	private int count;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public PartyProp() {
	}

	public PartyProp(StaticPartyProp staticProp) {
		this.keyId = staticProp.getKeyId();
	}
}
