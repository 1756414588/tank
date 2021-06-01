package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticMail;
import com.game.domain.s.StaticMailPlat;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StaticMailDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  private Map<Integer, StaticMail> mailMap = new HashMap<Integer, StaticMail>();

  private Map<Integer, List<StaticMailPlat>> mailPlatMap =
      new HashMap<Integer, List<StaticMailPlat>>();

  /**
   * Overriding: init
   *
   */
  @Override
  public void init() {
    mailMap = staticDataDao.selectMail();

    List<StaticMailPlat> mailPlatList = staticDataDao.selectStaticMailPlat();
    for (StaticMailPlat e : mailPlatList) {
      List<StaticMailPlat> elist = mailPlatMap.get(e.getPlatNo());
      if (elist == null) {
        elist = new ArrayList<StaticMailPlat>();
        mailPlatMap.put(e.getPlatNo(), elist);
      }
      elist.add(e);
    }
  }

  public StaticMail getStaticMail(int moldId) {
    return mailMap.get(moldId);
  }

  public List<StaticMailPlat> getPlatMail(int platNo) {
    return mailPlatMap.get(platNo);
  }
}
