/**   
 * @Title: StaticWorldDataMgr.java    
 * @Package com.game.dataMgr    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年9月15日 下午12:06:57    
 * @version V1.0   
 */
package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.alibaba.fastjson.JSONArray;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.EndConditionItem;
import com.game.domain.s.StaticActionMsg;

/**
 * 
 * 
 * @ClassName: StaticActionMsgDataMgr
 * @Description: 行为推送消息(比如说抽了个奖抽了紫装 系统在世界频道广播下)
 * @author WanYi
 * @date 2016年4月28日 下午5:44:31
 * 
 */
@Component
public class StaticActionMsgDataMgr extends BaseDataMgr {
	@Autowired
	private StaticDataDao staticDataDao;

	private List<StaticActionMsg> sActionMsgList;

	/**
	 * actionMsg: 行为类型:前置条件id,后置条件list
	 */
	private Map<Integer, Map<Integer, List<EndConditionItem>>> actionMsgMap = new HashMap<Integer, Map<Integer, List<EndConditionItem>>>();

	/**
	 * Overriding: init
	 * 
	 * @see com.game.dataMgr.BaseDataMgr#init()
	 */
	@Override
	public void init() {
		List<StaticActionMsg> tempList = staticDataDao.selectStaticActionMsg();
		sActionMsgList = tempList;
		
		Map<Integer, Map<Integer, List<EndConditionItem>>> tempMap = new HashMap<Integer, Map<Integer, List<EndConditionItem>>>();
		for (StaticActionMsg msg : sActionMsgList) {
			Map<Integer, List<EndConditionItem>> map = tempMap.get(msg.getType());
			if (map == null) {
				map = new HashMap<Integer, List<EndConditionItem>>();
				tempMap.put(msg.getType(), map);
			}

			String[] preConditions = msg.getPreCondition().split(",");
			List<EndConditionItem> list = desrEndCondition(msg.getEndCondition(),msg.getChatId());

			for (String str : preConditions) {
				map.put(Integer.parseInt(str), list);
			}
		}
		actionMsgMap = tempMap;
	}

	/**
	 * Method: desrEndCondition
	 * 
	 * @Description: 反序列化endCondition字段（后置条件: [类型,ID,品质,星级],[[类型,ID,品质,星级]].. ）
	 * @param endCondition
	 * @return
	 * @return List<EndConditionItem>

	 */
	private List<EndConditionItem> desrEndCondition(String endCondition,int chatId) {
		List<EndConditionItem> list = new ArrayList<EndConditionItem>();
		if (endCondition == null || endCondition.isEmpty()) {
			return list;
		}
		try {
			JSONArray arrays = JSONArray.parseArray(endCondition);
			for (int i = 0; i < arrays.size(); i++) {
				EndConditionItem  item = new EndConditionItem();
				JSONArray array = arrays.getJSONArray(i);
				item.setItemType(array.getIntValue(0));
				item.setItemId(array.getIntValue(1));
				item.setQuality(array.getIntValue(2));
				item.setStar(array.getIntValue(3));
				item.setChatId(chatId);
				list.add(item);
			}
		} catch (Exception e) {
			LogUtil.info("ListEndConditionTypeHandler parse:" + endCondition);
			throw e;
		}

		return list;
	}
	

	/**
	 * 通过类型获取前置条件map
	* Method: getMsgMap    
	* @Description:     
	* @param actionType
	* @return    
	* @return Map<Integer,List<EndConditionItem>>    

	 */
	public Map<Integer, List<EndConditionItem>> getMsgMap(int actionType){
		return actionMsgMap.get(actionType);
	}

}
