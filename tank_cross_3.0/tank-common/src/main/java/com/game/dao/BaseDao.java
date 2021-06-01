package com.game.dao;

import org.mybatis.spring.support.SqlSessionDaoSupport;

import java.util.HashMap;

public class BaseDao extends SqlSessionDaoSupport {
  protected HashMap<String, Object> paramsMap() {
    HashMap<String, Object> paramsMap = new HashMap<String, Object>();
    return paramsMap;
  }
}
