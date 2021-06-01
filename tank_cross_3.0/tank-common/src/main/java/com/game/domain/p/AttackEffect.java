package com.game.domain.p;

import com.game.grpc.proto.team.CrossTeamProto;
import com.game.pb.CommonPb;

import java.util.HashSet;
import java.util.List;
import java.util.Set;

/**
 * @author zhangdh @ClassName: AttackEffect @Description:
 * @date 2017-11-28 10:18
 */
public class AttackEffect {
    // 兵种类型
    private int type;
    // 已经解锁的特效KEY:坦克类型,VALUE:解锁的特效列表
    private Set<Integer> unlock = new HashSet<>();
    // 使用的特效信息KEY:坦克类型,VALUE:使用的特效ID
    private int useId;

    public AttackEffect(int type, int eid) {
        this.unlock.add(eid);
        this.type = type;
        this.useId = eid;
    }

    public AttackEffect(CommonPb.AttackEffectPb pb) {
        List<Integer> list = pb.getUnlockList();
        if (list != null && !list.isEmpty()) {
            unlock.addAll(list);
        }
        this.useId = pb.getUseId();
        this.type = pb.getType();
    }

    public AttackEffect(CrossTeamProto.AttackEffectPb pb) {
        List<Integer> list = pb.getUnlockList();
        if (list != null && !list.isEmpty()) {
            unlock.addAll(list);
        }
        this.useId = pb.getUseId();
        this.type = pb.getType();
    }

    public int getType() {
        return type;
    }

    public void setType(int type) {
        this.type = type;
    }

    public Set<Integer> getUnlock() {
        return unlock;
    }

    public void setUnlock(Set<Integer> unlock) {
        this.unlock = unlock;
    }

    public int getUseId() {
        return useId;
    }

    public void setUseId(int useId) {
        this.useId = useId;
    }
}
