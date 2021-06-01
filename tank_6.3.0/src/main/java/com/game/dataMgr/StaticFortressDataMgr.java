package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticFortressAttr;
import com.game.domain.s.StaticFortressJob;
import com.game.domain.s.StaticFortressSufferJifen;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * 要塞战
 * 
 * @author wanyi
 *
 */
@Component
public class StaticFortressDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticFortressSufferJifen> sufferJifenMap;

	private List<StaticFortressAttr> attrList;
	// id ： level : attr
	private Map<Integer,Map<Integer,StaticFortressAttr>> fortressAttrMap = new HashMap<Integer, Map<Integer,StaticFortressAttr>>();
	
	private Map<Integer,StaticFortressJob> fortressJobMap = new HashMap<Integer,StaticFortressJob>();
	
	private List<Integer> attrIdList;

	@Override
	public void init() {
		Map<Integer, StaticFortressSufferJifen> sufferJifenMap = staticDataDao.selectFortressSufferJifenMap();
		this.sufferJifenMap = sufferJifenMap;

		List<StaticFortressAttr> attrList = staticDataDao.selectFortressAttr();
		this.attrList = attrList;

		Map<Integer, Map<Integer, StaticFortressAttr>> fortressAttrMap = new HashMap<Integer, Map<Integer, StaticFortressAttr>>();
		for (StaticFortressAttr s : attrList) {
			Map<Integer, StaticFortressAttr> map = fortressAttrMap.get(s.getId());
			if (map == null) {
				map = new HashMap<Integer, StaticFortressAttr>();
				fortressAttrMap.put(s.getId(), map);
			}
			map.put(s.getLevel(), s);
		}
		this.fortressAttrMap = fortressAttrMap;

		this.attrIdList = new ArrayList<Integer>(fortressAttrMap.keySet());

		Map<Integer, StaticFortressJob> fortressJobMap = staticDataDao.selectFortressJob();
		this.fortressJobMap = fortressJobMap;
	}

	public Map<Integer, StaticFortressSufferJifen> getSufferJifenMap() {
		return sufferJifenMap;
	}

	public List<StaticFortressAttr> getAttrList() {
		return attrList;
	}
	
	public int getFortressSufferJifen(int tankId){
		return sufferJifenMap.get(tankId).getJifen();
	}
	
	public StaticFortressAttr getStaticFortressAttr(int id,int level){
		return fortressAttrMap.get(id).get(level);
	}

	public List<Integer> getAttrIdList() {
		return attrIdList;
	}

	public StaticFortressJob getFortressJob(int jobId){
		return fortressJobMap.get(jobId);
	}
	
}
