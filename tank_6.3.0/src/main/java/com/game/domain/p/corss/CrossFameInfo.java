package com.game.domain.p.corss;

import java.util.ArrayList;
import java.util.List;

import com.game.pb.SerializePb.SerCrossFame;
import com.game.util.PbHelper;
import com.google.protobuf.InvalidProtocolBufferException;

/**
* @ClassName: CrossFameInfo 
* @Description: 跨服战名人堂数据
* @author
 */
public class CrossFameInfo {
	private int keyId;
	private String beginTime;
	private String endTime;
	private List<CrossFame> crossFames;

	public String getBeginTime() {
		return beginTime;
	}

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public void setBeginTime(String beginTime) {
		this.beginTime = beginTime;
	}

	public String getEndTime() {
		return endTime;
	}

	public void setEndTime(String endTime) {
		this.endTime = endTime;
	}

	public List<CrossFame> getCrossFames() {
		return crossFames;
	}

	public void setCrossFames(List<CrossFame> crossFames) {
		this.crossFames = crossFames;
	}

	public void dser(DbCrossFameInfo info) throws InvalidProtocolBufferException {
		keyId = info.getKeyId();
		beginTime = info.getBeginTime();
		endTime = info.getEndTime();
		dserCrossFames(info.getCrossFames());
	}

	private void dserCrossFames(byte[] data) throws InvalidProtocolBufferException {
		if (null == data) {
			return;
		}
		
		crossFames = new ArrayList<CrossFame>();

		SerCrossFame ser = SerCrossFame.parseFrom(data);
		for (com.game.pb.CommonPb.CrossFame cf : ser.getCrossFameList()) {
			crossFames.add(PbHelper.createCrossFame(cf));
		}
	}

}
