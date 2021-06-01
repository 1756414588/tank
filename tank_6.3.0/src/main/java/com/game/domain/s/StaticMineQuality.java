package com.game.domain.s;

/**
 * @ClassName: StaticMineDefine
 * @Description: 资源点成长配置
 * @author zhangdh
 * @date 2017年3月22日
 * 
 */
public class StaticMineQuality {
	private int id;
	private int mineLv;
	private int quality;
	private int upTime;// 经验增长速度
	private int downTime;// 经验减少速度
	private int ptTime;// 经验保护时间事件
    private int scoutTime;//侦查后矿点品质显示时间
	private int yield;// 品质加成

	public int getId() {
		return id;
	}

	public void setId(int id) {
		this.id = id;
	}

	public int getQuality() {
		return quality;
	}

	public void setQuality(int quality) {
		this.quality = quality;
	}

	public int getUpTime() {
		return upTime;
	}

	public void setUpTime(int upTime) {
		this.upTime = upTime;
	}

	public int getDownTime() {
		return downTime;
	}

	public void setDownTime(int downTime) {
		this.downTime = downTime;
	}

	public int getPtTime() {
		return ptTime;
	}

	public void setPtTime(int ptTime) {
		this.ptTime = ptTime;
	}

	public int getYield() {
		return yield;
	}

	public void setYield(int yield) {
		this.yield = yield;
	}

	public int getMineLv() {
		return mineLv;
	}

	public void setMineLv(int mineLv) {
		this.mineLv = mineLv;
	}

    public int getScoutTime() {
        return scoutTime;
    }

    public void setScoutTime(int scoutTime) {
        this.scoutTime = scoutTime;
    }
}
