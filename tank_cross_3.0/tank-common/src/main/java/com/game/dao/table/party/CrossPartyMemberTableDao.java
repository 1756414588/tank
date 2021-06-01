package com.game.dao.table.party;

import com.game.domain.table.party.CrossPartyMemberTable;
import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.dao.CacheKeyDao;
import org.springframework.stereotype.Service;

import javax.inject.Inject;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/14 13:40
 * @description：
 */
@Service
public class CrossPartyMemberTableDao extends CacheKeyDao<Long, CrossPartyMemberTable> {
  @Inject
  protected CrossPartyMemberTableDao(DataCacheManager manager) {
    super(manager, CrossPartyMemberTable.class);
  }
}
