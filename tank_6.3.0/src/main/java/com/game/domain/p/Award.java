package com.game.domain.p;

import java.util.List;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-6 下午8:22:15
 * @Description: 奖励物资
 */

public class Award {

	private int type;
	private int id;
	private int count;
	private int keyId;
	private List<Integer> param; 
	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getCount() {
		return count;
	}

	public void setCount(int count) {
		this.count = count;
	}

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public List<Integer> getParam() {
        return param;
    }

    public void setParam(List<Integer> param) {
        this.param = param;
    }

    public Award() {
	}

    public Award(int type, int id, int count, int keyId) {
		this.type = type;
		this.id = id;
		this.count = count;
		this.keyId = keyId;
	}
}
