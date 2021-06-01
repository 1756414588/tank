package com.game.dao.table.party;

import com.game.domain.table.party.CrossPartyRecordsTable;
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
public class CrossPartyRecordsTableDao extends CacheKeyDao<Integer, CrossPartyRecordsTable> {
  @Inject
  protected CrossPartyRecordsTableDao(DataCacheManager manager) {
    super(manager, CrossPartyRecordsTable.class);
  }
}
