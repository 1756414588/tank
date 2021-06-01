package com;

import com.gamemysql.core.entity.DataRepository;
import com.google.common.util.concurrent.AbstractIdleService;
import org.apache.log4j.Logger;

/**
 * @author GuiJie
 * @description 描述
 * @created 2018/01/22 14:23
 */
public class GameMysqlServer extends AbstractIdleService {

  public static Logger logger = Logger.getLogger("ERROR");

  private static DataRepository gameRepository;

  @Override
  public void shutDown() throws Exception {
    logger.error("game-mysql 停服开始存储数据");
    getGameRepository().getDataCacheManager().shutdown();
    logger.error("game-mysql 数据存储完成");
  }

  @Override
  public void startUp() {
    logger.error("开始加载game-mysql");
    logger.error("game-mysql加载完成");
  }

  public static DataRepository getGameRepository() {
    return gameRepository;
  }
}
