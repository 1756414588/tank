package com.game.dao.impl.p;

import com.game.dao.BaseDao;
import com.game.domain.p.UClientMessage;

/**
* @ClassName: UClientMessageDao 
* @Description: 记录玩家客户端信息
* @author
 */
public class UClientMessageDao extends BaseDao {

	public int ceate(UClientMessage clientMessage) {
		return this.getSqlSession().insert("UClientMessageDao.ceate", clientMessage);
	}

}
