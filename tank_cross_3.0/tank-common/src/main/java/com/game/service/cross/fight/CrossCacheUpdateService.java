package com.game.service.cross.fight;

import com.game.cross.domain.Athlete;
import com.game.cross.domain.JiFenPlayer;
import com.game.dao.table.fight.CrossFightAthleteTableDao;
import com.game.dao.table.fight.CrossFightPlayerJifenTableDao;
import com.game.domain.table.cross.CrossFightAthleteTable;
import com.game.domain.table.cross.CrossFightPlayerJifenTable;
import com.game.manager.cross.fight.CrossFightCache;
import com.game.pb.CommonPb;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/13 15:56
 * @description：该类定时 入库已经修改的玩家数据
 */
@Component
public class CrossCacheUpdateService {
    @Autowired
    private CrossFightAthleteTableDao crossFightAthleteTableDao;
    @Autowired
    private CrossFightPlayerJifenTableDao crossFightPlayerJifenTableDao;

    public void updateAthlete(Athlete athlete) {
        CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(athlete.getRoleId());
        athleteTable.setAthlete(athlete);
        crossFightAthleteTableDao.update(athleteTable);
    }

    /**
     * 修改玩家数据
     */
    public void updateAthlete() {

        LogUtil.error("开始循环遍历玩家数据 把修改过数据的玩家入库");

        int size = 0;

        Map<Long, Athlete> athleteMap = CrossFightCache.getAthleteMap();
        for (Athlete athlete : athleteMap.values()) {
            try {
                CrossFightAthleteTable athleteTable = crossFightAthleteTableDao.get(athlete.getRoleId());
                if (athleteTable != null && athlete.isUpdate()) {
                    athlete.setUpdate(false);
                    updateAthlete(athlete);
                    size++;
                }
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }
        LogUtil.error("把玩家数据入库  size=" + size);
    }

    /**
     * 修改玩家积分数据
     */
    public void updateJiFenPlayer(JiFenPlayer jiFenPlayer) {
        CrossFightPlayerJifenTable crossFightPlayerJifenTable = crossFightPlayerJifenTableDao.get(jiFenPlayer.getRoleId());
        CommonPb.JiFenPlayer jifenPlayerPb = PbHelper.createJifenPlayerPb(jiFenPlayer, CrossFightCache.getDfKnockoutBattleGroups(), CrossFightCache.getJyKnockoutBattleGroups(), CrossFightCache.getJyFinalBattleGroups(), CrossFightCache.getDfFinalBattleGroups());
        crossFightPlayerJifenTable.setJifenInfo(jifenPlayerPb.toByteArray());
        crossFightPlayerJifenTableDao.update(crossFightPlayerJifenTable);
    }

    /**
     * 修改玩家积分数据
     */
    public void updateJiFenPlayer() {

        LogUtil.error("开始循环遍历玩家积分数据 把修改过数据的玩家入库");

        int size = 0;

        LinkedHashMap<Long, JiFenPlayer> jifenPlayerMap = CrossFightCache.getJifenPlayerMap();
        for (JiFenPlayer jiFenPlayer : jifenPlayerMap.values()) {
            try {
                updateJiFenPlayer(jiFenPlayer);
                size++;
            } catch (Exception e) {
                LogUtil.error(e);
            }
        }

        LogUtil.error("把积分数据入库 size=" + size);
    }
}
