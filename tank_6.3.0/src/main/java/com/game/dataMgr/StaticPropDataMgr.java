/**   
 * @Title: StaticPropDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年8月13日 下午5:09:13    
 * @version V1.0   
 */
package com.game.dataMgr;

import java.util.HashMap;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticProp;
import com.game.domain.s.StaticSkin;

/**
 * @ClassName: StaticPropDataMgr
 * @Description: 初始化道具配置
 * @author ZhangJun
 * @date 2015年8月13日 下午5:09:13
 * 
 */
@Component
public class StaticPropDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private Map<Integer, StaticProp> propMap;

	//基地皮肤
	private Map<Integer, StaticSkin> skinMap;
	
	//基地皮肤map，键为类型（1 皮肤 2 铭牌 3 聊天气泡）
	private Map<Integer, Map<Integer, StaticSkin>> skinMapByType;
	
	@Override
	public void init() {
		Map<Integer, StaticProp> propMap = staticDataDao.selectProp();
		this.propMap = propMap;
		Map<Integer, StaticSkin> skinMap = staticDataDao.selectSkin();
		this.skinMap = skinMap;
		
		initSkinMapByType(skinMap);
	}

	private void initSkinMapByType(Map<Integer, StaticSkin> skinMap) {
	    Map<Integer, Map<Integer, StaticSkin>> skinMapByType = new HashMap<>();
	    
	    Integer type;
	    Map<Integer, StaticSkin> mapByType;
	    for(StaticSkin skin : skinMap.values()) {
	        type = skin.getType();
	        mapByType = skinMapByType.get(type);
	        if(mapByType == null) {
	            mapByType = new HashMap<>();
	            skinMapByType.put(type, mapByType);
	        }
	        mapByType.put(skin.getId(), skin);
	    }
	    
	    this.skinMapByType = skinMapByType;
	}
	
	public StaticProp getStaticProp(int propId) {
		return propMap.get(propId);
	}
	
	public Map<Integer, StaticSkin> getSkinMap() {
		return skinMap;
	}
	/**
	 * 返回皮肤对应的道具
	 * @param skinId
	 * @return
	 */
	public StaticProp getStaticSkinProp(int skinId) {
		StaticSkin skin = skinMap.get(skinId);
		if(skin.getItem() != 0)
			return getStaticProp(skin.getItem());
		return null;
	}
	
	public StaticSkin getStaticSkin(int skinId) {
		return skinMap.get(skinId);
	}
	
	//按类型查询
	public StaticSkin getStaticSkinByType(int type, int skinId) {
	    return skinMapByType.get(type).get(skinId);
	}
	
	public Map<Integer, StaticSkin> getStaticSkinByType(int type) {
        return skinMapByType.get(type);
    }
}
