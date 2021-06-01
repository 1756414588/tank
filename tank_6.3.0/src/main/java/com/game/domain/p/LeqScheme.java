package com.game.domain.p;

import java.util.HashMap;
import java.util.Map;

import com.game.pb.CommonPb;
import com.game.pb.CommonPb.TwoInt;
import com.game.util.PbHelper;

/**
 * @author: LiFeng
 * @date: 2018年9月21日 上午3:47:00
 * @description: 军备方案
 */
public class LeqScheme {
	private Map<Integer, Integer> leq = new HashMap<>();
	private String schemeName;
	private int type;

	public Map<Integer, Integer> getLeq() {
		return leq;
	}

	public void setLeq(Map<Integer, Integer> leq) {
		this.leq = leq;
	}

	public String getSchemeName() {
		return schemeName;
	}

	public void setSchemeName(String schemeName) {
		this.schemeName = schemeName;
	}

	public int getType() {
		return type;
	}

	public void setType(int type) {
		this.type = type;
	}

	public CommonPb.LeqScheme toPb() {
		CommonPb.LeqScheme.Builder builder = CommonPb.LeqScheme.newBuilder();
		// 避免一些意外情况导致的空指针异常
		builder.setName(schemeName == null ? "" : schemeName);
		builder.setType(type);
		for (Map.Entry<Integer, Integer> entry : leq.entrySet()) {
			builder.addLeq(PbHelper.createTwoIntPb(entry.getKey(), entry.getValue()));
		}
		return builder.build();
	}

	public LeqScheme() {
		super();
	}

	public LeqScheme(CommonPb.LeqScheme scheme) {
		for (TwoInt twoInt : scheme.getLeqList()) {
			this.leq.put(twoInt.getV1(), twoInt.getV2());
		}
		this.schemeName = scheme.getName();
		this.type = scheme.getType();
	}

	@Override
	public String toString() {
		return "LeqScheme [leq=" + leq + ", schemeName=" + schemeName + ", type=" + type + "]";
	}

}
