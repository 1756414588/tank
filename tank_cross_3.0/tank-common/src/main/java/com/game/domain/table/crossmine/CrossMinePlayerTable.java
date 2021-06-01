package com.game.domain.table.crossmine;

import com.game.domain.CrossPlayer;
import com.game.domain.p.Effect;
import com.game.pb.CommonPb;
import com.game.pb.SerializePb;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.gamemysql.annotation.Column;
import com.gamemysql.annotation.Foreign;
import com.gamemysql.annotation.Primary;
import com.gamemysql.annotation.Table;
import com.gamemysql.core.entity.KeyDataEntity;

import java.util.HashMap;
import java.util.List;

/**
 * @author yeding
 * @create 2019/6/18 9:38
 * @decs
 */
@Table(value = "cross_mine_player", fetch = Table.FeatchType.START)
public class CrossMinePlayerTable implements KeyDataEntity<Long> {

    @Primary
    @Foreign
    @Column(value = "role_id", comment = "玩家role_id")
    private long roleId;

    @Column(value = "server_id", comment = "玩家服务器id")
    private int serverId;

    @Column(value = "nick_name", comment = "玩家昵称")
    private String nickName;

    @Column(value = "vip", comment = "vip")
    private int vip;

    @Column(value = "honor", comment = "玩家honor积分")
    private int honor;

    @Column(value = "pros", comment = "玩家pros")
    private int pros;

    @Column(value = "maxPros", comment = "maxPros")
    private int maxPros;

    @Column(value = "partyId", comment = "partyId")
    private int partyId;

    @Column(value = "partyName", comment = "partyName")
    private String partyName;

    @Column(value = "effect", length = 65535, comment = "effect")
    private byte[] effect;

    @Column(value = "score", comment = "score")
    private int score;

    @Column(value = "fight", comment = "fight")
    private long fight;


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

    public String getNickName() {
        return nickName;
    }

    public void setNickName(String nickName) {
        this.nickName = nickName;
    }

    public int getVip() {
        return vip;
    }

    public void setVip(int vip) {
        this.vip = vip;
    }

    public int getHonor() {
        return honor;
    }

    public void setHonor(int honor) {
        this.honor = honor;
    }

    public int getPros() {
        return pros;
    }

    public void setPros(int pros) {
        this.pros = pros;
    }

    public int getMaxPros() {
        return maxPros;
    }

    public void setMaxPros(int maxPros) {
        this.maxPros = maxPros;
    }

    public int getPartyId() {
        return partyId;
    }

    public void setPartyId(int partyId) {
        this.partyId = partyId;
    }

    public String getPartyName() {
        return partyName;
    }

    public void setPartyName(String partyName) {
        this.partyName = partyName;
    }

    public byte[] getEffect() {
        return effect;
    }

    public void setEffect(byte[] effect) {
        this.effect = effect;
    }

    public int getScore() {
        return score;
    }

    public void setScore(int score) {
        this.score = score;
    }

    public long getFight() {
        return fight;
    }

    public void setFight(long fight) {
        this.fight = fight;
    }

    public CrossPlayer desPlayer() {
        CrossPlayer player = new CrossPlayer(this.roleId);
        player.setServerId(this.serverId);
        player.setNick(this.nickName);
        player.setVip(this.vip);
        player.setHonor(this.honor);
        player.setPros(this.pros);
        player.setMaxPros(this.maxPros);
        player.setPartyId(this.partyId);
        player.setPartyName(this.partyName);
        player.setSenScore(this.score);
        player.setFight(this.fight);
        try {
            SerializePb.SerEffect effect = SerializePb.SerEffect.parseFrom(this.effect);
            if (effect != null) {
                List<CommonPb.Effect> effectList = effect.getEffectList();
                for (CommonPb.Effect effect1 : effectList) {
                    player.getEffects().put(effect1.getId(), PbHelper.createEffect(effect1));
                }
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }
        return player;
    }

    public CrossMinePlayerTable() {

    }

    public CrossMinePlayerTable(CrossPlayer player) {
        this.roleId = player.getRoleId();
        this.serverId = player.getServerId();
        this.nickName = player.getNick();
        this.vip = player.getVip();
        this.honor = player.getHonor();
        this.pros = player.getPros();
        this.maxPros = player.getMaxPros();
        this.partyId = player.getPartyId();
        this.partyName = player.getPartyName();
        SerializePb.SerEffect.Builder msg = SerializePb.SerEffect.newBuilder();
        HashMap<Integer, Effect> effects = player.getEffects();
        for (Effect effect1 : effects.values()) {
            msg.addEffect(PbHelper.createEffectPb(effect1));
        }
        this.effect = msg.build().toByteArray();
        this.score = player.getSenScore();
        this.fight = player.getFight();
    }
}
