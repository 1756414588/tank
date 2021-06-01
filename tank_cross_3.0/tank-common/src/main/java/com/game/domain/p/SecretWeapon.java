package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;
import com.game.pb.CommonPb;

import java.util.ArrayList;
import java.util.List;

/**
 * @author zhangdh @ClassName: SecretWeapon @Description: 秘密武器定义
 * @date 2017-11-14 10:56
 */
public class SecretWeapon {
    // 武器ID
    private int id;
    // 武器技能列表, 数组信息: 0-技能ID,1-是否锁定
    private List<SecretWeaponBar> bars = new ArrayList<>(6);

    public SecretWeapon(int id) {
        this.id = id;
    }

    public SecretWeapon(CommonPb.SecretWeapon pbData) {
        this.id = pbData.getId();
        for (CommonPb.SecretWeaponBar pbBar : pbData.getBarList()) {
            SecretWeaponBar bar = new SecretWeaponBar(pbBar.getSid());
            bar.setLock(pbBar.getLocked());
            bars.add(bar);
        }
    }

    public SecretWeapon(CrossTeamProto.SecretWeapon pbData) {
        this.id = pbData.getId();
        for (CrossTeamProto.SecretWeaponBar pbBar : pbData.getBarList()) {
            SecretWeaponBar bar = new SecretWeaponBar(pbBar.getSid());
            bar.setLock(pbBar.getLocked());
            bars.add(bar);
        }
    }


    public int getId() {
        return id;
    }

    public void setId(int id) {
        this.id = id;
    }

    public List<SecretWeaponBar> getBars() {
        return bars;
    }

    public void setBars(List<SecretWeaponBar> bars) {
        this.bars = bars;
    }
}
