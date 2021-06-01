package com.game.domain.p;

/**
 * @author zhangdh
 * @ClassName: RedefinedLordId
 * @Description:数据修复时 旧玩家id和新id对应关系
 * @date 2017-08-13 0:05
 */
public class RedefinedLordId {
    private int uid;
    private int ptNo;
    private int serverId;
    private long oldId;
    private long newId;

    public int getUid() {
        return uid;
    }

    public void setUid(int uid) {
        this.uid = uid;
    }

    public int getPtNo() {
        return ptNo;
    }

    public void setPtNo(int ptNo) {
        this.ptNo = ptNo;
    }

    public long getOldId() {
        return oldId;
    }

    public void setOldId(long oldId) {
        this.oldId = oldId;
    }

    public long getNewId() {
        return newId;
    }

    public void setNewId(long newId) {
        this.newId = newId;
    }
}
