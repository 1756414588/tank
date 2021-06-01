package com.game.dao;

import java.util.HashMap;

import org.mybatis.spring.support.SqlSessionDaoSupport;

/**
 * 
* @ClassName: BaseDao 
* @Description: 数据库访问基类
* @author
 */public class BaseDao extends SqlSessionDaoSupport {
	protected HashMap<String, Object> paramsMap() {
		HashMap<String, Object> paramsMap = new HashMap<String, Object>();
		return paramsMap;
	}
}
