package com.account.dao.impl;

import java.util.List;
import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.SaveBehavior;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

/**
 * Created by pengshuo on 2019/3/11 11:32
 * <br>Description:
 * <br>Modified By:
 * <br>Version:
 *
 * @author pengshuo
 */
public class SaveBehaviorDao extends BaseDao {

    private static Logger Log = LoggerFactory.getLogger(SaveBehaviorDao.class);

    /**
     * insert
     * @param sb
     */
    public void save(SaveBehavior sb) {
        this.getSqlSession().insert("SaveBehaviorDao.save", sb);
        Log.info(sb.toString());
    }
    
    public List<String> showTables() {
        return this.getSqlSession().selectList("SaveBehaviorDao.showTables");
    }

    public void createTable(String sql) {
        Map<String, Object> param = this.paramsMap();
        param.put("sql", sql);
        this.getSqlSession().update("SaveBehaviorDao.createTable", param);
    }
}
