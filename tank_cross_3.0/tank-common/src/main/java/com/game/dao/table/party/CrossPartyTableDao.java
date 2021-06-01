package com.game.dao.table.party;

import com.game.domain.table.party.CrossPartyTable;
import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.dao.CacheKeyDao;
import org.springframework.stereotype.Service;

import javax.inject.Inject;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/14 13:38
 * @description：
 */
@Service
public class CrossPartyTableDao extends CacheKeyDao<Integer, CrossPartyTable> {
  @Inject
  protected CrossPartyTableDao(DataCacheManager manager) {
    super(manager, CrossPartyTable.class);
  }
}
