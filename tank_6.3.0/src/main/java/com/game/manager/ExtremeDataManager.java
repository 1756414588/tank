/**   
 * @Title: ExtremeDataManager.java    
 * @Package com.game.manager    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月26日 上午11:37:35    
 * @version V1.0   
 */
package com.game.manager;

import java.util.HashMap;
import java.util.HashSet;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Set;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.p.ExtremeDao;
import com.game.dataMgr.StaticCombatDataMgr;
import com.game.domain.p.DbExtreme;
import com.game.domain.p.Extreme;
import com.game.domain.s.StaticExplore;
import com.game.pb.CommonPb.AtkExtreme;
import com.game.pb.SerializePb.SerAtkExtreme;
import com.google.protobuf.InvalidProtocolBufferException;

/**
 * @ClassName: ExtremeDataManager
 * @Description: 极限探险活动相关
 * @author ZhangJun
 * @date 2015年9月26日 上午11:37:35
 * 
 */
@Component
public class ExtremeDataManager {
	@Autowired
	private ExtremeDao extremeDao;

	@Autowired
	private StaticCombatDataMgr staticCombatDataMgr;

	public Map<Integer, Extreme> recordMap = new HashMap<Integer, Extreme>();

	public Set<Integer> saveSet = new HashSet<>();

//	@PostConstruct
	public void init() throws InvalidProtocolBufferException {
		List<DbExtreme> list = extremeDao.selectExtreme();
		for (int i = 0; i < list.size(); i++) {
			DbExtreme dbExtreme = list.get(i);
			Extreme extreme = dserExtreme(dbExtreme);
			recordMap.put(extreme.getExtremeId(), extreme);
		}

		Iterator<StaticExplore> it = staticCombatDataMgr.getAllExplore().values().iterator();
		while (it.hasNext()) {
			StaticExplore staticExplore = (StaticExplore) it.next();
			if (staticExplore.getType() == 3) {
				Extreme extreme = recordMap.get(staticExplore.getExploreId());
				if (extreme == null) {
					extreme = new Extreme();
					extreme.setExtremeId(staticExplore.getExploreId());
					recordMap.put(staticExplore.getExploreId(), extreme);
					extremeDao.insertExtreme(serExtreme(extreme));
				}
			}
		}
	}

	public void update(DbExtreme dbExtreme) {
		extremeDao.updateExtreme(dbExtreme);
	}

	/**
	* @Description: 序列化
	* @param extreme
	* @return  
	* DbExtreme
	 */
	public DbExtreme serExtreme(Extreme extreme) {
		DbExtreme dbExtreme = new DbExtreme();
		dbExtreme.setExtremeId(extreme.getExtremeId());
		if (extreme.getFirst1() != null) {
			dbExtreme.setFirst1(extreme.getFirst1().toByteArray());
		} else {
			dbExtreme.setFirst1(AtkExtreme.newBuilder().build().toByteArray());
		}

		SerAtkExtreme.Builder builder = SerAtkExtreme.newBuilder();
		builder.addAllAtkExtreme(extreme.getLast3());
		dbExtreme.setLast3(builder.build().toByteArray());

		return dbExtreme;
	}

    /**
    * @Description: 
    * @param dbExtreme
    * @return
    * @throws InvalidProtocolBufferException  
    * Extreme
     */
	public Extreme dserExtreme(DbExtreme dbExtreme) throws InvalidProtocolBufferException {
		Extreme extreme = new Extreme();
		extreme.setExtremeId(dbExtreme.getExtremeId());
		if (dbExtreme.getFirst1() != null) {
			extreme.setFirst1(AtkExtreme.parseFrom(dbExtreme.getFirst1()));
		}

		if (dbExtreme.getLast3() != null) {
			List<AtkExtreme> list = SerAtkExtreme.parseFrom(dbExtreme.getLast3()).getAtkExtremeList();
			if (list != null) {
				for (AtkExtreme atkExtreme : list) {
					extreme.getLast3().add(atkExtreme);
				}
			}
		}
		return extreme;
	}

	/**
	* @Description: 增加一条极限探险记录
	* @param extremeId
	* @param atkExtreme  
	* void
	 */
	public void record(int extremeId, AtkExtreme atkExtreme) {
		Extreme extreme = recordMap.get(extremeId);
		if (extreme.getFirst1() == null || !extreme.getFirst1().hasAttacker()) {
			extreme.setFirst1(atkExtreme);
		}

		if (extreme.getLast3().size() >= 3) {
			extreme.getLast3().removeFirst();
		}

		extreme.getLast3().add(atkExtreme);

		saveSet.add(extremeId);
	}

	public Extreme getExtreme(int extremeId) {
		return recordMap.get(extremeId);
	}
}
