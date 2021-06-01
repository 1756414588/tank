package com.game.dataMgr;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticActiveBoxConfig;

/**
 * @author: LiFeng
 * @date:
 * @description:
 */
@Component
public class StaticActiveBoxDataMgr extends BaseDataMgr {
	
	@Autowired
	private StaticDataDao staticDataDao;

	private StaticActiveBoxConfig activeBoxCfg;

	@Override
	public void init() {
		this.activeBoxCfg = staticDataDao.selectActiveBoxConfig();
	}

	public StaticActiveBoxConfig getActiveBoxCfg() {
		return activeBoxCfg;
	}

}
