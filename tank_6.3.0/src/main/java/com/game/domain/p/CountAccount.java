package com.game.domain.p;

/**
 * @author zhangdh
 * @ClassName: CountAccount
 * @Description:用来查询服务器账号数量pojo
 * @date 2017-08-04 11:01
 */
public class CountAccount {

    private int platNo;
    private int serverId;
    private int maxLordId;

    public int getPlatNo() {
        return platNo;
    }

    public void setPlatNo(int platNo) {
        this.platNo = platNo;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public int getMaxLordId() {
        return maxLordId;
    }

    public void setMaxLordId(int maxLordId) {
        this.maxLordId = maxLordId;
    }
}
