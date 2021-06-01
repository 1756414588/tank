package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticAttackEffectDataMgr;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticPartDataMgr;
import com.game.domain.Player;
import com.game.domain.p.AttackEffect;
import com.game.domain.p.Part;
import com.game.domain.s.StaticAttackEffect;
import com.game.domain.s.StaticPart;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.GamePb6.GetAttackEffectRq;
import com.game.pb.GamePb6.GetAttackEffectRs;
import com.game.pb.GamePb6.UseAttackEffectRq;
import com.game.pb.GamePb6.UseAttackEffectRs;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Collection;
import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: AttackEffectService
 * @Description:攻击特效
 * @date 2017-11-28 10:24
 */
@Service
public class AttackEffectService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private StaticAttackEffectDataMgr staticAttackEffectDataMgr;
    @Autowired
    private StaticPartDataMgr staticPartDataMgr;

    /**
     * 获取攻击特效
     *
     * @param req
     * @param handler
     */
    public void getAttackEffect(GetAttackEffectRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAttackEffectOpen()) {
            handler.sendErrorMsgToPlayer(GameError.FUNCTION_NO_OPEN);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        checkAndIni(player);
        GetAttackEffectRs.Builder builder = GetAttackEffectRs.newBuilder();
        for (Map.Entry<Integer, AttackEffect> entry : player.atkEffects.entrySet()) {
            builder.addEffect(PbHelper.createAttackEffectPb(entry.getValue()));
        }
        handler.sendMsgToPlayer(GetAttackEffectRs.ext, builder.build());
    }

    /**
     * 使用攻击特效
     *
     * @param req
     * @param handler
     */
    public void useAttackEffect(UseAttackEffectRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isAttackEffectOpen()) {
            handler.sendErrorMsgToPlayer(GameError.FUNCTION_NO_OPEN);
            return;
        }
        int uid = req.getId();
        StaticAttackEffect data = uid > 0 ? staticAttackEffectDataMgr.getAttackEffect(uid) : null;
        if (data == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        AttackEffect effect = player.atkEffects.get(data.getType());
        if (effect == null || !effect.getUnlock().contains(data.getEid())) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        effect.setUseId(data.getEid());
        handler.sendMsgToPlayer(UseAttackEffectRs.ext, UseAttackEffectRs.newBuilder().build());
    }

    /**
     * 如果玩家没有设置攻击特效 就设置它
     *
     * @param player void
     */
    public void checkAndIni(Player player) {
        if (player.atkEffects.isEmpty()) {
            Map<Integer, StaticAttackEffect> effectDefault = staticAttackEffectDataMgr.getEffectDefault();
            for (Map.Entry<Integer, StaticAttackEffect> effectEntry : effectDefault.entrySet()) {
                StaticAttackEffect data = effectEntry.getValue();
                AttackEffect eft = new AttackEffect(data.getType(), data.getEid());
                player.atkEffects.put(data.getType(), eft);
                LogLordHelper.logAttackEffectChange(AwardFrom.ATTACK_EFFECT_DEFAULT, player, eft, data.getId());
            }
        }

        unLockAttackEffect(player);
    }


    /**
     * 容错机制
     *
     * @param player
     */
    public void unLockAttackEffect(Player player) {

        try {
            List<List<StaticAttackEffect>> list = staticAttackEffectDataMgr.getEffectUnlock();
            for (List<StaticAttackEffect> dataList : list) {
                for (StaticAttackEffect data : dataList) {
                    AttackEffect effect = player.atkEffects.get(data.getType());

                    if( effect == null ){
                        continue;
                    }


                    if (!effect.getUnlock().contains(data.getEid())) {
                        if (isUnLockAttackEffect(data, player)) {
                            effect.getUnlock().add(data.getEid());
                            effect.setUseId(data.getEid());
                            LogLordHelper.logAttackEffectChange(AwardFrom.UP_PART, player, effect, data.getId());
                        }
                    }else{
                        if (!isUnLockAttackEffect(data, player)) {
                            effect.getUnlock().remove(data.getEid());
                            if (effect.getUseId() == data.getEid()) {
                                effect.setUseId(1);
                            }
                        }
                    }
                }
            }
        } catch (Exception e) {
            LogUtil.error(e.getMessage());
        }

    }


    /**
     * 获取 不是默认开启的 攻击buff被激活
     *
     * @param player
     * @return
     */
    private boolean isUnLockAttackEffect(StaticAttackEffect config, Player player) {

        Collection<Map<Integer, Part>> values = player.parts.values();

        for (Map<Integer, Part> p : values) {
            for (Part part : p.values()) {
                StaticPart staticPart = staticPartDataMgr.getStaticPart(part.getPartId());

                if (config.getType() != staticPart.getType()) {
                    continue;
                }

                AttackEffect effect = player.atkEffects.get(staticPart.getType());
                if (effect == null) {
                    LogUtil.error(String.format("nick :%s, type :%d, refitLv :%d, not found", player.lord.getNick(), staticPart.getType(), part.getRefitLv()));
                }
                if (config.getIsDefault() == 0 && config.getUnLockLv() <= part.getRefitLv() && effect != null) {
                    return true;
                }
            }
        }

        return false;
    }


    /**
     * 解锁攻击特效
     *
     * @param type
     * @param lv
     */
    public void checkAndUnLockAttackEffect(Player player, int type, int refitLv) {
        List<StaticAttackEffect> list = staticAttackEffectDataMgr.getUnlockAttackEffect(type);
        if (list != null) {
            checkAndIni(player);
            AttackEffect effect = player.atkEffects.get(type);
            if (effect == null) {
                LogUtil.error(String.format("nick :%s, type :%d, refitLv :%d, not found", player.lord.getNick(), type, refitLv));
            }
            for (StaticAttackEffect data : list) {
                if (data.getUnLockLv() <= refitLv && effect != null && !effect.getUnlock().contains(data.getEid())) {
                    effect.getUnlock().add(data.getEid());
                    effect.setUseId(data.getEid());
                    LogLordHelper.logAttackEffectChange(AwardFrom.UP_PART, player, effect, data.getId());
                }
            }
        }
    }

}
