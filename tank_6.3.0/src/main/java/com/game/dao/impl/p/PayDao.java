package com.game.dao.impl.p;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Pay;
/**
* @ClassName: PayDao 
* @Description: 充值相关
* @author
 */
public class PayDao extends BaseDao {
	public Pay selectPay(int platNo, String orderId) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("platNo", platNo);
		map.put("orderId", orderId);
		return this.getSqlSession().selectOne("PayDao.selectPay", map);
	}

	public List<Pay> selectRolePay(int serverId, long roleId) {
		Map<String, Object> map = new HashMap<String, Object>();
		map.put("serverId", serverId);
		map.put("roleId", roleId);
		return this.getSqlSession().selectList("PayDao.selectRolePay", map);
	}

//	public void updateState(Pay pay) {
//		this.getSqlSession().update("PayDao.updateState", pay);
//	}

	public void createPay(Pay pay) {
		this.getSqlSession().insert("PayDao.createPay", pay);
	}

}
