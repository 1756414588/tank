package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.Constant;
import com.game.constant.GameError;
import com.game.dataMgr.StaticPeakMgr;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.s.StaticPeakCost;
import com.game.domain.s.StaticPeakSkill;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.MapUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author yeding
 * @create 2019/7/17 11:12
 * @decs
 */
@Component
public class PeakService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticPeakMgr staticPeakMgr;

    public void queryPeakInfo(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        Lord lord = player.lord;
        if (lord != null) {
            if (lord.getLevel() < Constant.PLAYER_OPEN_LV) {
                handler.sendErrorMsgToPlayer(GameError.LEVEL_NOT_ENOUGH);
                return;
            }
        }
        Map<Integer, Integer> peakMap = player.getPeakMap();
        if (peakMap.isEmpty()) {
            StaticPeakSkill initPeakSkill = staticPeakMgr.initPeakSkill;
            if (initPeakSkill != null) {
                peakMap.put(initPeakSkill.getId(), 1);
            }
        }

        GamePb6.QueryPeakInfoRs.Builder msg = GamePb6.QueryPeakInfoRs.newBuilder();
        for (Map.Entry<Integer, Integer> peakInfo : peakMap.entrySet()) {
            CommonPb.TwoInt.Builder info = CommonPb.TwoInt.newBuilder();
            info.setV1(peakInfo.getKey());
            info.setV2(peakInfo.getValue());
            msg.addPeak(info);
        }

        handler.sendMsgToPlayer(GamePb6.QueryPeakInfoRs.ext, msg.build());
    }


    /**
     * 激活 巅峰等级属性
     *
     * @param handler
     * @param request
     */
    public void actPeak(ClientHandler handler, GamePb6.ActPeakRq request) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        Lord lord = player.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        int id = request.getId();
        StaticPeakSkill peakSkill = staticPeakMgr.getPeakSkill(id);
        int costSkill = peakSkill.getCostSkill();
        if (costSkill > 0) {
            if (lord.getPeaks() < costSkill) {
                return;
            }
        }
        Map<Integer, Integer> peakMap = player.getPeakMap();

        Integer integer = peakMap.get(id);
        if (integer == null || integer == 2) {
            return;
        }


        if (peakSkill == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }
        List<List<Integer>> cost = peakSkill.getCost();//必须花费
        Map<Integer, Map<Integer, Integer>> map = new HashMap<>();
        if (cost != null) {
            for (List<Integer> integers : cost) {
                MapUtil.assembleMap(map, integers);
            }
        }
        List<CommonPb.ThreeInt> costList = request.getCostList();
        if (costList != null) {
            Map<Integer, StaticPeakCost> peakCost = staticPeakMgr.getPeakCost(id);
            int count = 0;
            for (int i = 0; i < costList.size(); i++) {
                CommonPb.ThreeInt threeInt = costList.get(i);
                StaticPeakCost staticPeakCost = peakCost.get(i + 1);
                if (staticPeakCost != null) {
                    List<List<Integer>> costSelect = staticPeakCost.getCostSelect();
                    for (List<Integer> integers : costSelect) {
                        if (threeInt.getV1() == integers.get(0) && threeInt.getV2() == integers.get(1) && threeInt.getV3() == integers.get(2)) {
                            MapUtil.assembleMap(map, integers);
                            count++;
                            break;
                        }
                    }
                }
            }
            if (count != costList.size()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
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
        for (Map.Entry<Integer, Map<Integer, Integer>> integerMapEntry : map.entrySet()) {
            int type = integerMapEntry.getKey();
            Map<Integer, Integer> maps = integerMapEntry.getValue();
            for (Map.Entry<Integer, Integer> pro : maps.entrySet()) {
                playerDataManager.subProp(player, type, pro.getKey(), pro.getValue(), AwardFrom.PEAK_ACT);
            }
        }
        lord.setPeaks(lord.getPeaks() - 1);
        peakMap.put(id, 2);
        List<Integer> after = peakSkill.getAfter();
        if (after != null) {
            for (Integer af : after) {
                if (!peakMap.containsKey(af)) {
                    peakMap.put(af, 1);
                }
            }
        }
        //todo 发奖励


    }

}
