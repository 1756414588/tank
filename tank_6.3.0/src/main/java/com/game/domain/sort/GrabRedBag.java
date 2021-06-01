package com.game.domain.sort;

import com.game.pb.SerializePb;
import com.game.util.UnsafeSortInfo;

/**
 * @author zhangdh
 * @ClassName: GrabRedBag
 * @Description: 抢红包信息
 * @date 2018-01-31 11:05
 */
public class GrabRedBag implements UnsafeSortInfo.ISortVO<GrabRedBag> {
    private long lordId;
    //抢到的金额
    private int grabMoney;
    //抢红包时间
    private long grabTime;

    public SerializePb.SerGrabRedBag paserPb(){
        SerializePb.SerGrabRedBag.Builder builder = SerializePb.SerGrabRedBag.newBuilder();
        builder.setLordId(lordId);
        builder.setGrabMoney(grabMoney);
        builder.setGrabTime(grabTime);
        return builder.build();
    }

    public GrabRedBag(long lordId) {
        this.lordId = lordId;
    }

    public GrabRedBag(long lordId, int grabMoney) {
        this.lordId = lordId;
        this.grabMoney = grabMoney;
        this.grabTime = System.currentTimeMillis();
    }

    public GrabRedBag(SerializePb.SerGrabRedBag pb){
        this.lordId = pb.getLordId();
        this.grabMoney = pb.getGrabMoney();
        this.grabTime = pb.getGrabTime();
    }

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getGrabMoney() {
        return grabMoney;
    }

    public void setGrabMoney(int grabMoney) {
        this.grabMoney = grabMoney;
    }

    public long getGrabTime() {
        return grabTime;
    }

    public void setGrabTime(long grabTime) {
        this.grabTime = grabTime;
    }

    @Override
    public String getKey() {
        return String.valueOf(lordId);
    }

    @Override
    public long getValue() {
        return grabMoney;
    }

    @Override
    public int compareTo(GrabRedBag o) {
        if (grabMoney > o.grabMoney) {
            return -1;
        } else if (grabMoney < o.grabMoney) {
            return 1;
        } else {
            if (grabTime < o.grabTime) {
                return -1;
            } else if (grabTime > o.grabTime) {
                return 1;
            } else {
                return lordId < o.lordId ? -1 : lordId > o.lordId ? 1 : 0;
            }
        }
    }
}
