/**
 * @Title: StaticVipDataMgr.java @Package com.game.dataMgr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月24日 下午2:29:03
 * @version V1.0
 */
package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticPay;
import com.game.domain.s.StaticVip;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticVipDataMgr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年9月24日 下午2:29:03
 */
@Component
public class StaticVipDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  // vip
  private Map<Integer, StaticVip> vipMap;

  private List<StaticVip> vipList;

  private List<StaticPay> payList;

  private List<StaticPay> payIosList;

  /**
   * Overriding: init
   *
   */
  @Override
  public void init() {
    // TODO Auto-generated method stub
    initVip();
    payList = staticDataDao.selectPay();
    payIosList = staticDataDao.selectPayIos();
  }

  private void initVip() {
    vipList = staticDataDao.selectVip();
    vipMap = new HashMap<Integer, StaticVip>();

    for (StaticVip staticVip : vipList) {
      vipMap.put(staticVip.getVip(), staticVip);
    }
  }

  public StaticVip getStaticVip(int vip) {
    return vipMap.get(vip);
  }

  public int calcVip(int topup) {
    StaticVip vip = null;
    for (StaticVip staticVip : vipList) {
      if (topup >= staticVip.getTopup()) {
        vip = staticVip;
      } else break;
    }
    if (vip != null) {
      return vip.getVip();
    }

    return 0;
  }

  /**
   * Method: getStaticPay @Description: TODO
   *
   * @param topup 充值金币
   * @return
   * @return StaticPay
   * @throws
   */
  public int getExtraGold(int topup, boolean ios) {
    StaticPay category = null;
    if (ios) {
      for (StaticPay staticPay : payIosList) {
        if (topup >= staticPay.getTopup()) {
          category = staticPay;
        } else break;
      }
    } else {
      for (StaticPay staticPay : payList) {
        if (topup >= staticPay.getTopup()) {
          category = staticPay;
        } else break;
      }
    }

    if (category != null) {
      return category.getExtraGold() * topup / 1000;
    }

    return 0;
  }
}
