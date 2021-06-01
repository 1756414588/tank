package com.game.manager;

import java.util.ArrayList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.p.CrossFameDao;
import com.game.domain.p.corss.CrossFameInfo;
import com.game.domain.p.corss.DbCrossFameInfo;
import com.game.domain.p.corssParty.CPFameInfo;
import com.game.domain.p.corssParty.DbCPFame;
import com.google.protobuf.InvalidProtocolBufferException;
/**
* @ClassName: CrossDataManager 
* @Description: 跨服战数据处理
* @author
 */
@Component
public class CrossDataManager {

	@Autowired
	private CrossFameDao crossFameDao;

	private List<CrossFameInfo> crossFameInfos;

	private List<CPFameInfo> cpFameInfos;
	/**跨服军团战名人堂数据*/
	public List<CPFameInfo> getCpFameInfos() {
		return cpFameInfos;
	}
	
	public void setCpFameInfos(List<CPFameInfo> cpFameInfos) {
		this.cpFameInfos = cpFameInfos;
	}
    /**跨服战名人堂数据*/
	public List<CrossFameInfo> getCrossFameInfos() {
		return crossFameInfos;
	}
	
	public void setCrossFameInfos(List<CrossFameInfo> crossFameInfos) {
		this.crossFameInfos = crossFameInfos;
	}

//	@PostConstruct
	public void init() throws InvalidProtocolBufferException {
		initCrossFameInfos();
	}

	/**
	* 初始化跨服战名人堂数据
	* @Title: initCrossFameInfos 
	* @Description: 初始化跨服战名人堂数据
	* @throws InvalidProtocolBufferException  
	 */
	private void initCrossFameInfos() throws InvalidProtocolBufferException {
		crossFameInfos = new ArrayList<CrossFameInfo>();

		List<DbCrossFameInfo> list = crossFameDao.selectCrossFameInfo();
		for (DbCrossFameInfo info : list) {
			CrossFameInfo ci = new CrossFameInfo();
			ci.dser(info);
			crossFameInfos.add(ci);
		}

		cpFameInfos = new ArrayList<CPFameInfo>();
		List<DbCPFame> cpList = crossFameDao.selectCPFameInfo();
		for (DbCPFame info : cpList) {
			CPFameInfo ci = new CPFameInfo();
			ci.dser(info);
			cpFameInfos.add(ci);
		}
	}

	/**
	 * 跨服战
	 * 
	 * @param beginTime
	 * @param endTime
	 * @param fameInfos
	 * @throws InvalidProtocolBufferException
	 */
	public void addCrossFrame(String beginTime, String endTime, byte[] fameInfos)
			throws InvalidProtocolBufferException {
		DbCrossFameInfo dbInfo = new DbCrossFameInfo();
		dbInfo.setBeginTime(beginTime);
		dbInfo.setEndTime(endTime);
		dbInfo.setCrossFames(fameInfos);
		crossFameDao.insertCrossFameInfo(dbInfo);

		CrossFameInfo crossFameInfo = new CrossFameInfo();
		crossFameInfo.setBeginTime(beginTime);
		crossFameInfo.setEndTime(endTime);
		crossFameInfo.dser(dbInfo);
		crossFameInfos.add(crossFameInfo);
	}

	/**
	 * 跨服军团战
	 * 
	 * @param beginTime
	 * @param endTime
	 * @param fameInfos
	 * @throws InvalidProtocolBufferException
	 */
	public void addCpFrame(String beginTime, String endTime, byte[] fameInfos) throws InvalidProtocolBufferException {
		DbCPFame dbInfo = new DbCPFame();
		dbInfo.setBeginTime(beginTime);
		dbInfo.setEndTime(endTime);
		dbInfo.setCrossFames(fameInfos);
		crossFameDao.insertCPFameInfo(dbInfo);

		CPFameInfo cpFameInfo = new CPFameInfo();
		cpFameInfo.setBeginTime(beginTime);
		cpFameInfo.setEndTime(endTime);
		cpFameInfo.dser(dbInfo);
		cpFameInfos.add(cpFameInfo);
	}
}
