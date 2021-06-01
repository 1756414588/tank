package com.game.dataMgr;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticMedal;
import com.game.domain.s.StaticMedalBouns;
import com.game.domain.s.StaticMedalRefit;
import com.game.domain.s.StaticMedalUp;
/**
* @ClassName: StaticMedalDataMgr 
* @Description: 勋章相关配置
* @author
 */
@Component
public class StaticMedalDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;
	
	private Map<Integer, StaticMedal> medalMap;
	
	private Map<Integer, Map<Integer, StaticMedalUp>> upMap;
	
	private Map<Integer, Map<Integer, StaticMedalRefit>> refitMap;

	private List<StaticMedalBouns> medalBounsList;
	
	@Override
	public void init() {
		Map<Integer, StaticMedal> medalMap = staticDataDao.selectMedalMap();
		this.medalMap = medalMap;
		this.medalBounsList = staticDataDao.selectMedalBounsList();

		initUp();
		initRefit();
	}

	/**
	* @Title: initUp 
	* @Description:   初始化勋章升级配置
	* void   

	 */
	private void initUp() {
		List<StaticMedalUp> list = staticDataDao.selectMedalUp();
		Map<Integer, Map<Integer, StaticMedalUp>> upMap = new HashMap<Integer, Map<Integer, StaticMedalUp>>();
		for (StaticMedalUp staticMedalUp : list) {
			Map<Integer, StaticMedalUp> map = upMap.get(staticMedalUp.getQuality());
			if (map == null) {
				map = new HashMap<>();
				upMap.put(staticMedalUp.getQuality(), map);
			}

			map.put(staticMedalUp.getLv(), staticMedalUp);
		}
		this.upMap = upMap;
	}
	
	/**
	* @Title: initRefit 
	* @Description:   初始化勋章分解配置
	* void   

	 */
	private void initRefit() {
		List<StaticMedalRefit> list = staticDataDao.selectMedalRefit();
		Map<Integer, Map<Integer, StaticMedalRefit>> refitMap = new HashMap<Integer, Map<Integer, StaticMedalRefit>>();
		for (StaticMedalRefit staticMedalRefit : list) {
			Map<Integer, StaticMedalRefit> map = refitMap.get(staticMedalRefit.getQuality());
			if (map == null) {
				map = new HashMap<>();
				refitMap.put(staticMedalRefit.getQuality(), map);
			}

			map.put(staticMedalRefit.getLv(), staticMedalRefit);
		}
		this.refitMap = refitMap;
	}
	
	public StaticMedal getStaticMedal(int medalId) {
		return medalMap.get(medalId);
	}

	public StaticMedalUp getStaticMedalUp(int quality, int upLv) {
		Map<Integer, StaticMedalUp> map = upMap.get(quality);
		if (map != null) {
			return map.get(upLv);
		}
		return null;
	}
	
	public StaticMedalRefit getStaticMedalRefit(int quality, int refitLv) {
		Map<Integer, StaticMedalRefit> map = refitMap.get(quality);
		if (map != null) {
			return map.get(refitLv);
		}
		return null;
	}

	public List<StaticMedalBouns> getMedalBounsList() {
		return medalBounsList;
	}
}
