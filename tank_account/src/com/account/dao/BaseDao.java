package com.account.dao;

import java.util.HashMap;

import org.mybatis.spring.support.SqlSessionDaoSupport;

public class BaseDao extends SqlSessionDaoSupport {
    protected HashMap<String, Object> paramsMap() {
        HashMap<String, Object> paramsMap = new HashMap<String, Object>();
        return paramsMap;
    }
}
