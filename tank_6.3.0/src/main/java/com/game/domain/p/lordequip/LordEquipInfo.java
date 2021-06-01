package com.game.domain.p.lordequip;

import com.game.domain.p.Prop;
import com.game.server.GameServer;
import com.game.service.LordEquipService;
import com.game.util.TimeHelper;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: LordEquipInfo
 * @Description: 玩家的军备信息
 * @date 2017/5/13 10:30
 */
public class LordEquipInfo {
	// 指挥官身上的装备, KEY:穿戴位置, VALUE:军备
	private Map<Integer, LordEquip> putonLordEquips = new HashMap<>();

	// 指挥官仓库中的军备信息, KEY:uid, VALUE:军备
	private Map<Integer, LordEquip> storeLordEquips = new HashMap<>();

	// 军备材料图纸
	private Map<Integer, Prop> leqMat = new HashMap<>();

	// 已经解锁的最高级的铁匠
	private int unlock_tech_max;

	// 是否有一次免费雇佣机会
	private boolean free;

	// 雇佣的铁匠ID
	private int employTechId;

	// 雇佣的时间
	private int employEndTime;

	// 生产中的军备
	private List<LordEquipBuilding> leq_que = new LinkedList<>();

	// 生产中的军备材料
	private List<LordEquipMatBuilding> leq_mat_que = new ArrayList<>();

	// 已经购买的军备材料生产坑位
	private int buyMatCount;

	// 免费洗练次数
	private int freeChangeNum;

	// 计算洗练恢复时间的起点时间
	private long changeTimeSec;

	// 恢复洗练时间
	private int remainingTimeSec;

	public Map<Integer, LordEquip> getPutonLordEquips() {
		return putonLordEquips;
	}

	public Map<Integer, LordEquip> getStoreLordEquips() {
		return storeLordEquips;
	}

	public Map<Integer, Prop> getLeqMat() {
		return leqMat;
	}

	public void setLeqMat(Map<Integer, Prop> leqMat) {
		this.leqMat = leqMat;
	}

	public int getUnlock_tech_max() {
		return unlock_tech_max;
	}

	public void setUnlock_tech_max(int unlock_tech_max) {
		this.unlock_tech_max = unlock_tech_max;
	}

	public boolean isFree() {
		return free;
	}

	public void setFree(boolean free) {
		this.free = free;
	}

	public int getEmployTechId() {
		return employTechId;
	}

	public void setEmployTechId(int employTechId) {
		this.employTechId = employTechId;
	}

	public int getEmployEndTime() {
		return employEndTime;
	}

	public void setEmployEndTime(int employEndTime) {
		this.employEndTime = employEndTime;
	}

	public List<LordEquipBuilding> getLeq_que() {
		return leq_que;
	}

	public void setLeq_que(List<LordEquipBuilding> leq_que) {
		this.leq_que = leq_que;
	}

	public List<LordEquipMatBuilding> getLeq_mat_que() {
		return leq_mat_que;
	}

	public int getBuyMatCount() {
		return buyMatCount;
	}

	public void setBuyMatCount(int buyMatCount) {
		this.buyMatCount = buyMatCount;
	}

	/**
	 * 使用一次免费洗练
	 */
	public void useFreeNum() {
		freeChangeNum--;
	}

	/**
	 * 刷新免费洗练次数及倒计时时间
	 */
	public void refreshFreeChangeTime() {
		LordEquipService service = GameServer.ac.getBean(LordEquipService.class);
		int keepNum = service.getKeepNum();

		// 如果已经达到最大洗练次数，则不刷新
		if (keepNum == freeChangeNum)
			return;

		long cd = service.getCD();
		long nowSec = TimeHelper.getCurrentSecond();
		long interval = nowSec - changeTimeSec;
		// 从上次计时到现在能获得的免费次数
		int getFreeNum = (int) (interval / cd);
		// 如果总次数大于最大洗练次数，则取最大洗练次数
		// 如果总次数小于最大洗练次数，则计算恢复时间，设置计时点
		freeChangeNum += getFreeNum;
		if (freeChangeNum < keepNum) {
			changeTimeSec += getFreeNum * cd;
			remainingTimeSec = (int) (cd - (nowSec - changeTimeSec));
		} else {
			remainingTimeSec = 0;
			changeTimeSec = nowSec;
			if (freeChangeNum > keepNum) {
				freeChangeNum = keepNum;
			}
		}
	}

	public void setFreeChangeNum(int num) {
		freeChangeNum = num;
	}

	/**
	 * 获取免费洗练次数
	 * 
	 * @return
	 */
	public int getFreeChangeNum() {
		return freeChangeNum;
	}

	/**
	 * 获取恢复时间
	 * 
	 * @return
	 */
	public int getRemainingTimeSec() {
		return remainingTimeSec;
	}

	public void setChangeTimeSec(long sec) {
		changeTimeSec = sec;
	}

	/**
	 * 返回计时起始时间
	 * 
	 * @return
	 */
	public long getChangeTimeSec() {
		return changeTimeSec;
	}
	
	/**
	 * 根据军备的keyId获取LordEquip
	 * @param keyid
	 * @return
	 */
	public LordEquip getLordEquipByKeyid(int keyid) {
		for (LordEquip lordEquip : putonLordEquips.values()) {
			if (lordEquip.getKeyId() == keyid) {
				return lordEquip;
			}
		}
		return storeLordEquips.get(keyid);
	}
}
