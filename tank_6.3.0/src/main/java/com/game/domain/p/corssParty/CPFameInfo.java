package com.game.domain.p.corssParty;

import java.util.ArrayList;
import java.util.List;

import com.game.pb.SerializePb.SerCpFame;
import com.game.util.PbHelper;
import com.google.protobuf.InvalidProtocolBufferException;
/**
* @ClassName: CPFameInfo 
* @Description: 跨服军团战名人堂数据
* @author
 */
public class CPFameInfo {
	private int keyId;
	private String beginTime;
	private String endTime;
	private List<CPFame> crossFames;

	public int getKeyId() {
		return keyId;
	}

	public void setKeyId(int keyId) {
		this.keyId = keyId;
	}

	public String getBeginTime() {
		return beginTime;
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

	public List<CPFame> getCrossFames() {
		return crossFames;
	}

	public void setCrossFames(List<CPFame> crossFames) {
		this.crossFames = crossFames;
	}

	public void dser(DbCPFame info) throws InvalidProtocolBufferException {
		keyId = info.getKeyId();
		beginTime = info.getBeginTime();
		endTime = info.getEndTime();
		dserCrossFames(info.getCrossFames());
	}

	private void dserCrossFames(byte[] data) throws InvalidProtocolBufferException {
		if (null == data) {
			return;
		}
		crossFames = new ArrayList<CPFame>();

		SerCpFame ser = SerCpFame.parseFrom(data);

		for (com.game.pb.CommonPb.CPFame cf : ser.getCpFameList()) {
			crossFames.add(PbHelper.createCPFame(cf));
		}
	}

}
