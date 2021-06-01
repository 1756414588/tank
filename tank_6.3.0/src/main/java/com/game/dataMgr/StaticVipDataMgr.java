/**   
 * @Title: StaticVipDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月24日 下午2:29:03    
 * @version V1.0   
 */
package com.game.dataMgr;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticPay;
import com.game.domain.s.StaticVip;

/**
 * @ClassName: StaticVipDataMgr
 * @Description: VIP相关
 * @author ZhangJun
 * @date 2015年9月24日 下午2:29:03
 * 
 */
@Component
public class StaticVipDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	// vip
	private Map<Integer, StaticVip> vipMap;

	private List<StaticVip> vipList;

	private List<StaticPay> payList;

	private List<StaticPay> payIosList;

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
		initVip();

		List<StaticPay> payList = staticDataDao.selectPay();
		this.payList = payList;

		List<StaticPay> payIosList = staticDataDao.selectPayIos();
		this.payIosList = payIosList;
	}

	private void initVip() {
		List<StaticVip> vipList = staticDataDao.selectVip();
		this.vipList = vipList;

		Map<Integer, StaticVip> vipMap = new HashMap<Integer, StaticVip>();
		for (StaticVip staticVip : vipList) {
			vipMap.put(staticVip.getVip(), staticVip);
		}
		this.vipMap = vipMap;
	}

	public StaticVip getStaticVip(int vip) {
		return vipMap.get(vip);
	}

	public int calcVip(int topup) {
		StaticVip vip = null;
		for (StaticVip staticVip : vipList) {
			if (topup >= staticVip.getTopup()) {
				vip = staticVip;
			} else
				break;
		}
		if (vip != null) {
			return vip.getVip();
		}

		return 0;
	}

	/**
	 * 
	 * Method: getStaticPay
	 * 
	 * @Description:  获取充值赠送
	 * @param topup 充值金币 @return @return StaticPay @throws
	 */
	public int getExtraGold(int topup, boolean ios) {
		StaticPay category = null;
		if (ios) {
			for (StaticPay staticPay : payIosList) {
				if (topup >= staticPay.getTopup()) {
					category = staticPay;
				} else
					break;
			}
		} else {
			for (StaticPay staticPay : payList) {
				if (topup >= staticPay.getTopup()) {
					category = staticPay;
				} else
					break;
			}
		}

		if (category != null) {
			return category.getExtraGold() * topup / 1000;
		}

		return 0;
	}

	public StaticPay getExtraGoldConfig(int topup, boolean ios) {
		StaticPay category = null;
		if (ios) {
			for (StaticPay staticPay : payIosList) {
				if (topup >= staticPay.getTopup()) {
					category = staticPay;
				} else
					break;
			}
		} else {
			for (StaticPay staticPay : payList) {
				if (topup >= staticPay.getTopup()) {
					category = staticPay;
				} else
					break;
			}
		}
		return category;
	}

	public List<StaticPay> getPayList() {
		return payList;
	}
}
