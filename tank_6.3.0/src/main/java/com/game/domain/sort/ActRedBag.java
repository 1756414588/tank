package com.game.domain.sort;

import com.game.pb.SerializePb;
import com.game.util.UnsafeSortInfo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: ActRedBag
 * @Description: 活动红包
 * @date 2018-01-31 11:02
 */
public class ActRedBag implements UnsafeSortInfo.ISortVO<ActRedBag> {
    //红包ID
    private int id;
    //红包发放人
    private long lordId;
    //红包所属军团
    private int partyId;
    //红包总金额
    private int totalMoney;
    //剩余金额
    private int remainMoney;
    //可抢人数
    private int grabCnt;
    //红包发放时间
    private long sendTime;
    //抢红包信息
    private Map<Long, GrabRedBag> grabs = new HashMap<>();

    public Map<String, Long> playerIps = new HashMap<>();
    

    public ActRedBag(int uid, long lordId, int partyId) {
        this.id = uid;
        this.lordId = lordId;
        this.partyId = partyId;
        this.sendTime = System.currentTimeMillis();
    }

    public ActRedBag(SerializePb.SerActRedBag pb) {
        this.id = pb.getUid();
        this.lordId = pb.getLordId();
        this.partyId = pb.getPartyId();
        this.totalMoney = pb.getTotalMoney();
        this.remainMoney = pb.getRemainMoney();
        this.grabCnt = pb.getGrabCnt();
        this.sendTime = pb.getSendTime();
        if (pb.getGrabList() != null) {
            for (SerializePb.SerGrabRedBag pbGrab : pb.getGrabList()) {
                GrabRedBag grb = new GrabRedBag(pbGrab);
                grabs.put(grb.getLordId(), grb);
            }
        }
    }
    
    public ActRedBag() {
	}

	public SerializePb.SerActRedBag paserPb() {
        SerializePb.SerActRedBag.Builder builder = SerializePb.SerActRedBag.newBuilder();
        builder.setUid(id);
        builder.setLordId(lordId);
        builder.setPartyId(partyId);
        builder.setTotalMoney(totalMoney);
        builder.setRemainMoney(remainMoney);
        builder.setGrabCnt(grabCnt);
        builder.setSendTime(sendTime);
        for (Map.Entry<Long, GrabRedBag> entry : grabs.entrySet()) {
            builder.addGrab(entry.getValue().paserPb());
        }
        return builder.build();
    }

    @Override
    public String getKey() {
        return String.valueOf(id);
    }

    @Override
    public long getValue() {
        return grabCnt;
    }

    @Override
    public int compareTo(ActRedBag o) {
        return 0;
    }

    public int getTotalMoney() {
        return totalMoney;
    }

    public void setTotalMoney(int totalMoney) {
        this.totalMoney = totalMoney;
    }

    public int getRemainMoney() {
        return remainMoney;
    }

    public void setRemainMoney(int remainMoney) {
        this.remainMoney = remainMoney;
    }

    public int getGrabCnt() {
        return grabCnt;
    }

    public void setGrabCnt(int grabCnt) {
        this.grabCnt = grabCnt;
    }

    public Map<Long, GrabRedBag> getGrabs() {
        return grabs;
    }

    public void setGrabs(Map<Long, GrabRedBag> grabs) {
        this.grabs = grabs;
    }

    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public long getSendTime() {
        return sendTime;
    }

    public void setSendTime(long sendTime) {
        this.sendTime = sendTime;
    }
}
