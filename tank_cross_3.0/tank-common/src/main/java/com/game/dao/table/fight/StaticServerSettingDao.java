package com.game.dao.table.fight;

import com.game.domain.table.StaticServerSetting;
import com.gamemysql.dao.CrudRepository;
import org.springframework.stereotype.Service;

import javax.inject.Inject;
import javax.sql.DataSource;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/11 18:05
 * @description：StaticServerSetting dao
 */
@Service
public class StaticServerSettingDao extends CrudRepository<Integer, Integer, StaticServerSetting> {

  @Inject
  public StaticServerSettingDao(DataSource dataSource) {
    super(dataSource, StaticServerSetting.class);
  }
}
