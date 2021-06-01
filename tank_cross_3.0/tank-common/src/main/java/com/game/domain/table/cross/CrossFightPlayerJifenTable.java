package com.game.domain.table.cross;

import com.game.cross.domain.JiFenPlayer;
import com.game.pb.CommonPb;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;
import com.google.protobuf.InvalidProtocolBufferException;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/12 15:00
 * @description：跨服战玩家积分信息
 */
@Table(value = "cross_fight_player_jifen_table", fetch = Table.FeatchType.START)
public class CrossFightPlayerJifenTable implements KeyDataEntity<Long> {

    @Primary
    @Foreign
    @Column(value = "role_id", comment = "玩家id")
    private long roleId;

    @Column(value = "server_id", comment = "玩家的serverId")
    private int serverId;

    @Column(value = "jifen_info", length = 65535, comment = "玩家积分信息")
    private byte[] jifenInfo;

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public byte[] getJifenInfo() {
        return jifenInfo;
    }

    public void setJifenInfo(byte[] jifenInfo) {
        this.jifenInfo = jifenInfo;
    }

    public JiFenPlayer getJiFenPlayer() {
        try {

            if (jifenInfo == null || jifenInfo.length == 0) {
                return null;
            }

            CommonPb.JiFenPlayer jiFenPlayer = CommonPb.JiFenPlayer.parseFrom(jifenInfo);
            JiFenPlayer jp = PbHelper.createJifenPlayer(jiFenPlayer);
            return jp;
        } catch (InvalidProtocolBufferException e) {
            LogUtil.error(e);
        }
        return null;
    }
}
