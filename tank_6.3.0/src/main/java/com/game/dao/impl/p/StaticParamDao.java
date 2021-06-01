package com.game.dao.impl.p;

import java.util.List;

import com.game.dao.BaseDao;
import com.game.domain.p.StaticParam;
/**
* @ClassName: StaticParamDao 
* @Description: 服务器系统配置数据
* @author
 */
public class StaticParamDao extends BaseDao {
	public List<StaticParam> selectStaticParams() {
		return this.getSqlSession().selectList("StaticParamDao.selectStaticParams");
	}
}
