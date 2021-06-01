/**
 * @Title: StaticPropDataMgr.java @Package com.game.dataMgr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月13日 下午5:09:13
 * @version V1.0
 */
package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticProp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.Map;

/**
 * @ClassName: StaticPropDataMgr @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月13日 下午5:09:13
 */
@Component
public class StaticPropDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  private Map<Integer, StaticProp> propMap;

  /**
   * Overriding: init
   *
   */
  @Override
  public void init() {
    // TODO Auto-generated method stub
    propMap = staticDataDao.selectProp();
  }

  public StaticProp getStaticProp(int propId) {
    return propMap.get(propId);
  }
}
