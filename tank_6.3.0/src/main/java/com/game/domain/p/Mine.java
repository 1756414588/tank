package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-3 下午6:17:17
 * @Description: 资源点
 */

public class Mine {
	private int mineId;
	private int mineLv;
	private int pos;
	private int qua;//矿点品质
	private int quaExp;//矿点品质经验
	private int modTime;//矿点最后修改时间
    //此矿点被侦查列表KEY:玩家ID,VALUE:侦查时间
    private Map<Long, Integer> scoutMap = new HashMap<>();

	public int getMineId() {
		return mineId;
	}

	public void setMineId(int mineId) {
		this.mineId = mineId;
	}

	public int getMineLv() {
		return mineLv;
	}

	public void setMineLv(int mineLv) {
		this.mineLv = mineLv;
	}

	public int getPos() {
		return pos;
	}

	public void setPos(int pos) {
		this.pos = pos;
	}
	
	public int getQua() {
		return qua;
	}

	public void setQua(int qua) {
		this.qua = qua;
	}

	public int getQuaExp() {
		return quaExp;
	}

	public void setQuaExp(int quaExp) {
		this.quaExp = quaExp;
	}

	public int getModTime() {
		return modTime;
	}

	public void setModTime(int modTime) {
		this.modTime = modTime;
	}

	public Mine(){}
	public Mine(int pos, int qua){
		this.pos = pos;
		this.qua = qua;
	}
	public Mine(int mineId, int mineLv, int pos) {
		this.mineId = mineId;
		this.mineLv = mineLv;
		this.pos = pos;
	}

    public Map<Long, Integer> getScoutMap() {
        return scoutMap;
    }

    @Override
	public String toString() {
		return String.format("mid :%d pos :%d qua :%d qua exp :%d", mineId, pos, qua, quaExp);
	}
	
	

}
