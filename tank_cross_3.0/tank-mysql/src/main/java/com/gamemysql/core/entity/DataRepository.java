package com.gamemysql.core.entity;

import com.gamemysql.cache.DataCacheManager;
import org.apache.log4j.Logger;

import javax.sql.DataSource;

/**
 * @Author :GuiJie Liu
 *
 * @date :Create in 2019/3/11 11:21 @Description :java类作用描述
 */
public class DataRepository {
  public static Logger logger = Logger.getLogger("ERROR");
  private DataSource dataSource;
  private DataCacheManager dataCacheManager;

  public DataRepository(DataSource dataSource, DataCacheManager dataCacheManager) {
    this.dataCacheManager = dataCacheManager;
    this.dataSource = dataSource;
    logger.info("初始化DataRepository成功");
  }

  public DataSource getDataSource() {
    return dataSource;
  }

  public DataCacheManager getDataCacheManager() {
    return dataCacheManager;
  }
}
