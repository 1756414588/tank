/**
 * @Title: StaticPartDataMgr.java @Package com.game.dataMgr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月19日 下午5:45:44
 * @version V1.0
 */
package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticPart;
import com.game.domain.s.StaticPartRefit;
import com.game.domain.s.StaticPartUp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @ClassName: StaticPartDataMgr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月19日 下午5:45:44
 */
@Component
public class StaticPartDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  private Map<Integer, StaticPart> partMap;

  /** @Fields upMap : Map<partId, Map<lv, StaticPartUp>> */
  private Map<Integer, Map<Integer, StaticPartUp>> upMap;

  /** @Fields refitMap : Map<quality, Map<lv, StaticPartUp>> */
  private Map<Integer, Map<Integer, StaticPartRefit>> refitMap;

  /**
   * Overriding: init
   *
   */
  @Override
  public void init() {
    // TODO Auto-generated method stub
    partMap = staticDataDao.selectPart();
    initUp();
    initRefit();
  }

  private void initUp() {
    upMap = new HashMap<Integer, Map<Integer, StaticPartUp>>();
    List<StaticPartUp> list = staticDataDao.selectPartUp();
    for (StaticPartUp staticPartUp : list) {
      Map<Integer, StaticPartUp> map = upMap.get(staticPartUp.getPartId());
      if (map == null) {
        map = new HashMap<>();
        upMap.put(staticPartUp.getPartId(), map);
      }

      map.put(staticPartUp.getLv(), staticPartUp);
    }
  }

  private void initRefit() {
    refitMap = new HashMap<Integer, Map<Integer, StaticPartRefit>>();
    List<StaticPartRefit> list = staticDataDao.selectPartRefit();
    for (StaticPartRefit staticPartRefit : list) {
      Map<Integer, StaticPartRefit> map = refitMap.get(staticPartRefit.getQuality());
      if (map == null) {
        map = new HashMap<>();
        refitMap.put(staticPartRefit.getQuality(), map);
      }

      map.put(staticPartRefit.getLv(), staticPartRefit);
    }
  }

  public StaticPart getStaticPart(int partId) {
    return partMap.get(partId);
  }

  public StaticPartUp getStaticPartUp(int partId, int upLv) {
    Map<Integer, StaticPartUp> map = upMap.get(partId);
    if (map != null) {
      return map.get(upLv);
    }
    return null;
  }

  public StaticPartRefit getStaticPartRefit(int quality, int refitLv) {
    Map<Integer, StaticPartRefit> map = refitMap.get(quality);
    if (map != null) {
      return map.get(refitLv);
    }
    return null;
  }
}
