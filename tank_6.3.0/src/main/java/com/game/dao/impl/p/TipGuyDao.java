package com.game.dao.impl.p;

import java.util.List;

import com.game.dao.BaseDao;
import com.game.domain.p.TipGuy;
/**
* @ClassName: TipGuyDao 
* @Description: 玩家举报记录
* @author
 */
public class TipGuyDao extends BaseDao {
	
	public TipGuy selectTipGuyByLordId(long lordId) {
		return getSqlSession().selectOne("TipGuyDao.selectTipGuyByLordId", lordId);
	}

	public List<TipGuy> loadTipGuy() {
		return this.getSqlSession().selectList("TipGuyDao.loadTipGuy");
	}

	public int updateTipGuy(TipGuy tipGuy) {
		return this.getSqlSession().update("TipGuyDao.updateTipGuy", tipGuy);
	}

	public int insertTipGuy(TipGuy tipGuy) {
		return this.getSqlSession().insert("TipGuyDao.insertTipGuy", tipGuy);
	}

}
