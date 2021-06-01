package com.game.domain.p.repair;

import java.util.Date;

/**
 * @author zhangdh
 * @ClassName: MailDelt
 * @Description:已删除的邮件记录
 * @date 2017-10-20 12:00
 */
public class MailDelt {
    private int serverId;
    private long lordId;
    private int getKeyId;
    private Date createDate;

    public long getLordId() {
        return lordId;
    }

    public void setLordId(long lordId) {
        this.lordId = lordId;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public int getGetKeyId() {
        return getKeyId;
    }

    public void setGetKeyId(int getKeyId) {
        this.getKeyId = getKeyId;
    }

    public Date getCreateDate() {
        return createDate;
    }

    public void setCreateDate(Date createDate) {
        this.createDate = createDate;
    }
}
