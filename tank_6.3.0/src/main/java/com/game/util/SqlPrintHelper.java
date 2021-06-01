package com.game.util;

import com.game.domain.p.Party;

/**
 * @author ChenKui
 * @version 创建时间：2015-11-23 上午11:12:32
 * @declare sql工具类
 */

public class SqlPrintHelper {

    /**
     * 
    * domain对象转化成更新sql语句
    * @param party
    * @return  
    * String
     */
	public static String printUpdateParty(Party party) {
		if (party == null) {
			return "";
		}
		StringBuffer sql = new StringBuffer();
		sql.append("update p_party set legatusName=");
		sql.append(party.getLegatusName());
		sql.append(",partyLv=");
		sql.append(party.getPartyLv());
		sql.append(",scienceLv=");
		sql.append(party.getScienceLv());
		sql.append(",wealLv=");
		sql.append(party.getWealLv());
		sql.append(",lively=");
		sql.append(party.getLively());
		sql.append(",build=");
		sql.append(party.getBuild());
		sql.append(",fight=");
		sql.append(party.getFight());
		sql.append(",apply=");
		sql.append(party.getApply());
		sql.append(",applyLv=");
		sql.append(party.getApplyLv());
		sql.append(",applyFight=");
		sql.append(party.getApplyFight());
		sql.append(",slogan=");
		sql.append(party.getSlogan());
		sql.append(",innerSlogan=");
		sql.append(party.getInnerSlogan());
		sql.append(",jobName1=");
		sql.append(party.getJobName1());
		sql.append(",jobName2=");
		sql.append(party.getJobName2());
		sql.append(",jobName3=");
		sql.append(party.getJobName3());
		sql.append(",jobName4=");
		sql.append(party.getJobName4());

		// 二进制数据要特出处理
		sql.append(",mine=");
		sql.append(byteToString(party.getMine()));
		sql.append(",science=");
		sql.append(byteToString(party.getScience()));
		sql.append(",applyList=");
		sql.append(byteToString(party.getApplyList()));
		sql.append(",trend=");
		sql.append(byteToString(party.getTrend()));
		sql.append(",liveTask=");
		sql.append(byteToString(party.getLiveTask()));
		sql.append(",activity=");
		sql.append(byteToString(party.getActivity()));
		sql.append(",partyCombat=");
		sql.append(byteToString(party.getPartyCombat()));
		sql.append(",donates=");
		sql.append(byteToString(party.getDonates()));

		sql.append(",refreshTime=");
		sql.append(party.getRefreshTime());
		sql.append(" where partyId=");
		sql.append(party.getPartyId());
		LogUtil.info(sql.toString());
		return sql.toString();
	}
	
	/**
	 * 
	* domain对象转化成更新sql语句
	* @param party
	* @return  
	* String
	 */
	public static String printUpdateLord(Party party) {
		if (party == null) {
			return "";
		}
		StringBuffer sql = new StringBuffer();
		sql.append("update p_party set legatusName=");
		sql.append(party.getLegatusName());
		sql.append(",partyLv=");
		sql.append(party.getPartyLv());
		sql.append(",scienceLv=");
		sql.append(party.getScienceLv());
		sql.append(",wealLv=");
		sql.append(party.getWealLv());
		sql.append(",lively=");
		sql.append(party.getLively());
		sql.append(",build=");
		sql.append(party.getBuild());
		sql.append(",fight=");
		sql.append(party.getFight());
		sql.append(",apply=");
		sql.append(party.getApply());
		sql.append(",applyLv=");
		sql.append(party.getApplyLv());
		sql.append(",applyFight=");
		sql.append(party.getApplyFight());
		sql.append(",slogan=");
		sql.append(party.getSlogan());
		sql.append(",innerSlogan=");
		sql.append(party.getInnerSlogan());
		sql.append(",jobName1=");
		sql.append(party.getJobName1());
		sql.append(",jobName2=");
		sql.append(party.getJobName2());
		sql.append(",jobName3=");
		sql.append(party.getJobName3());
		sql.append(",jobName4=");
		sql.append(party.getJobName4());
		
		// 二进制数据要特出处理
		sql.append(",mine=");
		sql.append(byteToString(party.getMine()));
		sql.append(",science=");
		sql.append(byteToString(party.getScience()));
		sql.append(",applyList=");
		sql.append(byteToString(party.getApplyList()));
		sql.append(",trend=");
		sql.append(byteToString(party.getTrend()));
		sql.append(",liveTask=");
		sql.append(byteToString(party.getLiveTask()));
		sql.append(",activity=");
		sql.append(byteToString(party.getActivity()));
		sql.append(",partyCombat=");
		sql.append(byteToString(party.getPartyCombat()));
		sql.append(",donates=");
		sql.append(byteToString(party.getDonates()));
		
		sql.append(",refreshTime=");
		sql.append(party.getRefreshTime());
		sql.append(" where partyId=");
		sql.append(party.getPartyId());
		LogUtil.info(sql.toString());
		return sql.toString();
	}

	/**
	 * 
	* byte数组转成json数组字符串
	* @param bytes
	* @return  
	* String
	 */
	public static String byteToString(byte[] bytes) {
		if (bytes == null) {
			return "";
		}
		StringBuffer sbf = new StringBuffer();
		sbf.append('[');
		for (int i = 0; i < bytes.length; i++) {
			sbf.append(bytes[i]);
			if (i != bytes.length) {
				sbf.append(',');
			}
		}
		sbf.append(']');
		return sbf.toString();
	}
}
