package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticActKingRank;
import com.game.domain.s.StaticKingActAward;
import com.game.domain.s.StaticKingActRatio;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StaticActivateKingMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticKingActRatio> kingActRatioConfig = new HashMap<>();


    private Map<Integer, StaticKingActAward> kingActAwardConfig = new HashMap<>();
    private Map<Integer, Map<Integer, List<StaticActKingRank>>> kingRankRewardConfig = new HashMap<>();

    public StaticKingActRatio getKingActRatioConfig(int type) {
        return kingActRatioConfig.get(type);
    }

    public StaticKingActAward getKingActAwardConfig(int id) {
        return kingActAwardConfig.get(id);
    }

    public StaticActKingRank getKingRankRewardConfig(int awardId, int type, int rank) {

        if (!kingRankRewardConfig.containsKey(awardId)) {
            return null;
        }

        Map<Integer, List<StaticActKingRank>> listMap = kingRankRewardConfig.get(awardId);

        if (!listMap.containsKey(type)) {
            return null;
        }

        List<StaticActKingRank> staticActKingRanks = listMap.get(type);

        for (StaticActKingRank config : staticActKingRanks) {
            if (rank >= config.getRankBegin() && rank <= config.getRankEnd()) {
                return config;
            }
        }
        return null;
    }


    @Override
    public void init() {

        {
            Map<Integer, StaticKingActRatio> tempKingActRatioConfig = new HashMap<>();

            List<StaticKingActRatio> staticKingActRatios = staticDataDao.selectKingActRatio();
            for (StaticKingActRatio config : staticKingActRatios) {
                tempKingActRatioConfig.put(config.getType(), config);
            }

            kingActRatioConfig.clear();
            kingActRatioConfig = tempKingActRatioConfig;

        }

        {
            Map<Integer, StaticKingActAward> tempKingActAwardConfig = new HashMap<>();

            List<StaticKingActAward> staticKingActAward = staticDataDao.selectKingActAward();
            for (StaticKingActAward config : staticKingActAward) {
                tempKingActAwardConfig.put(config.getId(), config);
            }

            kingActAwardConfig.clear();
            kingActAwardConfig = tempKingActAwardConfig;

        }


        {
            Map<Integer, Map<Integer, List<StaticActKingRank>>> tempKingRankRewardConfig = new HashMap<>();
            List<StaticActKingRank> staticActKingRanks = staticDataDao.selectStaticActKingRank();
            for (StaticActKingRank config : staticActKingRanks) {

                if (!tempKingRankRewardConfig.containsKey(config.getAwardId())) {
                    tempKingRankRewardConfig.put(config.getAwardId(), new HashMap<Integer, List<StaticActKingRank>>());

                }

                if (!tempKingRankRewardConfig.get(config.getAwardId()).containsKey(config.getType())) {
                    tempKingRankRewardConfig.get(config.getAwardId()).put(config.getType(), new ArrayList<StaticActKingRank>());
                }

                tempKingRankRewardConfig.get(config.getAwardId()).get(config.getType()).add(config);
            }

            kingRankRewardConfig.clear();
            kingRankRewardConfig = tempKingRankRewardConfig;

        }
    }
}
