package com.game.dao.table.mine;

import com.game.domain.table.crossmine.CrossMineAmryTable;
import com.gamemysql.cache.DataCacheManager;
import com.gamemysql.dao.CacheKeyDao;
import org.springframework.stereotype.Service;

import javax.inject.Inject;

/**
 * @author yeding
 * @create 2019/6/18 10:56
 * @decs
 */
@Service
public class CrossMineArmyTableDao extends CacheKeyDao<Integer, CrossMineAmryTable> {

    @Inject
    public CrossMineArmyTableDao(DataCacheManager manager) {
        super(manager, CrossMineAmryTable.class);
    }

}
