package com.game.dao.table.fight;

import com.game.domain.table.cross.CrossFightPlayerJifenTable;
import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.dao.CacheKeyDao;
import org.springframework.stereotype.Service;

import javax.inject.Inject;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 14:57
 * @description：CrossFightTable dao
 */
@Service
public class CrossFightPlayerJifenTableDao extends CacheKeyDao<Long, CrossFightPlayerJifenTable> {
  @Inject
  public CrossFightPlayerJifenTableDao(DataCacheManager manager) {
    super(manager, CrossFightPlayerJifenTable.class);
  }
}
