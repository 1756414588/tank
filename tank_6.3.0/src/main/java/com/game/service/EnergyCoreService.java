
package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.dataMgr.StaticCoreDataMgr;
import com.game.dataMgr.StaticEquipDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Equip;
import com.game.domain.p.PEnergyCore;
import com.game.domain.s.*;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.LogLordHelper;
import com.game.util.MapUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.HashMap;
import java.util.List;
import java.util.Map;


/**
 * @author yeding
 * @create 2019/3/26 18:45
 */
@Service
public class EnergyCoreService {


    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticCoreDataMgr staticCoreDataMgr;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;


    /**
     * 获取能源核心信息
     *
     * @param handler
     */
    public void checkEnergyCore(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        GamePb6.EnergyCoreRs.Builder msg = GamePb6.EnergyCoreRs.newBuilder();
        PEnergyCore energy = player.energyCore;
        if (energy != null) {
            if (energy.getState() == 1) {
                StaticCoreExp exp = staticCoreDataMgr.getCoreExp(energy.getLevel() + 1, 1);
                if (exp != null) {
                    energy.resetCore();
                }
            }
            CommonPb.ThreeInt.Builder builder = CommonPb.ThreeInt.newBuilder();
            builder.setV1(energy.getLevel());
            builder.setV2(energy.getSection());
            builder.setV3(energy.getExp());
            msg.setCoreInfo(builder);
            msg.setState(energy.getState());
            msg.setRedExp(energy.getRedExp());
        }
        handler.sendMsgToPlayer(GamePb6.EnergyCoreRs.ext, msg.build());
    }


    /**
     * 熔炼装备
     *
     * @param handler
     * @param req
     */
    public void smeltEquip(ClientHandler handler, GamePb6.SmeltCoreEquipRq req) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        PEnergyCore energy = player.energyCore;
        if (energy == null) {
            return;
        }
        StaticCoreAward coreAward = staticCoreDataMgr.getCoreAward(energy.getLevel());
        if (coreAward != null) {
            if (!playerDataManager.checkEnergyCodeCond(player, coreAward.getType(), coreAward.getCond())) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
        }
        List<CommonPb.ThreeInt> list = req.getEquipList();
        if (list == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
            return;
        }
        StaticCoreExp exp = staticCoreDataMgr.getCoreExp(energy.getLevel(), energy.getSection());
        GamePb6.SmeltCoreEquipRs.Builder msg = GamePb6.SmeltCoreEquipRs.newBuilder();
        if (exp == null) {
            //处理等级最后阶段逻辑
            if (energy.getState() == 1) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
            Map<Integer, StaticCoreMaterial> m_map = staticCoreDataMgr.getCoreMater(energy.getLevel());
            if (m_map == null || m_map.isEmpty() || list.size() != m_map.size()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
            //处理装备经验逻辑
            Map<Integer, Map<Integer, Integer>> map = new HashMap<>();
            for (Map.Entry<Integer, StaticCoreMaterial> it : m_map.entrySet()) {
                int pos = it.getKey();
                StaticCoreMaterial model = it.getValue();
                CommonPb.ThreeInt info = list.get(pos - 1);
                List<Integer> need = null;
                if (info != null) {
                    for (List<Integer> integers : model.getMaterial()) {
                        if (integers.get(0) == info.getV1() && integers.get(1) == info.getV2() && integers.get(2) == info.getV3()) {
                            need = integers;
                            break;
                        }
                    }
                    if (need == null) {
                        handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                        return;
                    }
                    MapUtil.assembleMap(map, need);
                }
            }
            for (Map.Entry<Integer, Map<Integer, Integer>> integerMapEntry : map.entrySet()) {
                int type = integerMapEntry.getKey();
                Map<Integer, Integer> maps = integerMapEntry.getValue();
                for (Map.Entry<Integer, Integer> pro : maps.entrySet()) {
                    if (!playerDataManager.checkPropIsEnougth(player, type, pro.getKey(), pro.getValue())) {
                        handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                        return;
                    }
                }
            }
            exp = staticCoreDataMgr.getCoreExp(energy.getLevel() + 1, 1);
            energy.setState(1);
            if (exp != null) {
                energy.resetCore();
            }
            msg.setRedExp(energy.getRedExp());
            for (CommonPb.ThreeInt threeInt : list) {
                msg.addAtom(playerDataManager.subProp(player, threeInt.getV1(), threeInt.getV2(), threeInt.getV3(), AwardFrom.ENERGYCORE_EQUIP));
            }
        } else {
            int totalExp = 0;
            if (list == null || list.isEmpty()) {
                if (energy.getRedExp() > 0) {
                    totalExp = energy.getRedExp();
                    energy.setRedExp(0);
                }
            } else {
                Map<Integer, Equip> map = player.equips.get(0);
                for (CommonPb.ThreeInt threeInt : list) {
                    Equip e = map.get(threeInt.getV2());
                    if (e == null) {
                        handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                        return;
                    }
                    StaticEquip equip = staticEquipDataMgr.getStaticEquip(e.getEquipId());
                    if (equip == null) {
                        handler.sendErrorMsgToPlayer(GameError.NO_EQUIP);
                        return;
                    }
                    if (equip.getEquipId() / 100 > 6) {
                        totalExp += activityDataManager.upEquipExp(equip.getA());
                    } else {
                        totalExp += e.getExp();
                        StaticEquipLv staticEquipLv = staticEquipDataMgr.getStaticEquipLv(equip.getQuality(), e.getLv());
                        if (staticEquipLv != null) {
                            totalExp += staticEquipLv.getGiveExp();
                        }
                    }
                    map.remove(threeInt.getV2());
                    //消耗装备,装备卡日志
                    LogLordHelper.equip(AwardFrom.ENERGYCORE_EQUIP, player.account, player.lord, threeInt.getV2(), e.getEquipId(), e.getLv(), -1);
                }
            }
            if (totalExp > 0) {
                addExp(energy, totalExp,exp);//, exp
            }
        }
        CommonPb.ThreeInt.Builder builder = CommonPb.ThreeInt.newBuilder();
        builder.setV1(energy.getLevel());
        builder.setV2(energy.getSection());
        builder.setV3(energy.getExp());
        msg.setCoreInfo(builder);
        msg.setState(energy.getState());
        msg.setRedExp(energy.getRedExp());
        handler.sendMsgToPlayer(GamePb6.SmeltCoreEquipRs.ext, msg.build());
    }

    private void addExp(PEnergyCore energy, int exp, StaticCoreExp coreExp) {
        int curExp = energy.getExp();
        curExp += exp;
        energy.setExp(curExp);
        if (curExp >= coreExp.getExp()) {
            energy.setSection(energy.getSection() + 1);
            StaticCoreExp coreExp1 = staticCoreDataMgr.getCoreExp(energy.getLevel(), energy.getSection());
            curExp -= coreExp.getExp();
            if (coreExp1 != null) {
                energy.setExp(0);
                if (curExp > 0) {
                    this.addExp(energy, curExp, coreExp1);
                }
            } else {
                energy.setExp(coreExp.getExp());
                if (curExp > 0) {
                    energy.setRedExp(curExp + energy.getRedExp());
                }
            }
        }
    }


    private void addExp(PEnergyCore energy, int exp) {
        //int curExp = energy.getExp() + exp;
        exp += energy.getExp();
        int lastExp = 0;
        while (true) {
            StaticCoreExp config = staticCoreDataMgr.getCoreExp(energy.getLevel(), energy.getSection());
            if (config == null) {
                energy.setRedExp(exp);
                energy.setExp(lastExp);
                break;
            }
            lastExp = config.getExp();
            if (exp >= lastExp) {
                exp -= lastExp;
                energy.setSection(energy.getSection() + 1);
            } else {
                energy.setExp(exp);
                break;
            }
        }
    }

    public void gmSetCore(long uid, int level, int sec, int exp) {
        Player player = playerDataManager.getPlayer(uid);
        if (player != null) {
            PEnergyCore energy = player.energyCore;
            energy.setLevel(level);

            energy.setState(0);
            energy.setSection(sec);
            energy.setExp(exp);
        }
    }
}

