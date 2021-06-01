/**
 * @Title: StaticPartDataMgr.java
 * @Package com.game.dataMgr
 * @Description:
 * @author ZhangJun
 * @date 2015年8月19日 下午5:45:44
 * @version V1.0
 */
package com.game.dataMgr;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.util.CheckNull;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticPart;
import com.game.domain.s.StaticPartQualityUp;
import com.game.domain.s.StaticPartRefit;
import com.game.domain.s.StaticPartSmelting;
import com.game.domain.s.StaticPartUp;

/**
 * @ClassName: StaticPartDataMgr
 * @Description: 配件相关配置
 * @author ZhangJun
 * @date 2015年8月19日 下午5:45:44
 *
 */
@Component
public class StaticPartDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticPart> partMap;

    /**
     * @Fields upMap : Map<partId, Map<lv, StaticPartUp>>
     */
    private Map<Integer, Map<Integer, StaticPartUp>> upMap;

    /**
     * @Fields refitMap : Map<quality, Map<lv, StaticPartUp>>
     */
    private Map<Integer, Map<Integer, StaticPartRefit>> refitMap;

    private Map<Integer, StaticPartSmelting> smeltingMap;

    /**
     * @Fields qualityUpMap : Map<partId, StaticPartQualityUp>
     */
    private Map<Integer, StaticPartQualityUp> qualityUpMap;

    private Map<Integer, Map<Integer, StaticPartRefit>> nineOrTenRefitMap;

    /**
     * Overriding: init
     *
     * @see com.game.dataMgr.BaseDataMgr#init()
     */
    @Override
    public void init() {
        this.partMap = staticDataDao.selectPart();

        initUp();
        initRefit();
        this.qualityUpMap = staticDataDao.selectPartQualityUpMap();

        this.smeltingMap = staticDataDao.selectPartSmelting();
    }

    private void initUp() {
        List<StaticPartUp> list = staticDataDao.selectPartUp();
        Map<Integer, Map<Integer, StaticPartUp>> upMap = new HashMap<>();
        for (StaticPartUp staticPartUp : list) {
            Map<Integer, StaticPartUp> map = upMap.get(staticPartUp.getPartId());
            if (map == null) {
                map = new HashMap<>();
                upMap.put(staticPartUp.getPartId(), map);
            }

            map.put(staticPartUp.getLv(), staticPartUp);
        }
        this.upMap = upMap;
    }

    private void initRefit() {
        List<StaticPartRefit> list = staticDataDao.selectPartRefit();
        Map<Integer, Map<Integer, StaticPartRefit>> refitMap = new HashMap<>();
        Map<Integer, Map<Integer, StaticPartRefit>> nineOrTenRefitMap = new HashMap<>();
        for (StaticPartRefit staticPartRefit : list) {
            if (staticPartRefit.getNineOrTen() == 1) {
                Map<Integer, StaticPartRefit> map = nineOrTenRefitMap.get(staticPartRefit.getQuality());
                if (CheckNull.isEmpty(map)) {
                    map = new HashMap<>();
                    nineOrTenRefitMap.put(staticPartRefit.getQuality(), map);
                }
                map.put(staticPartRefit.getLv(), staticPartRefit);
            } else {
                Map<Integer, StaticPartRefit> map = refitMap.get(staticPartRefit.getQuality());
                if (map == null) {
                    map = new HashMap<>();
                    refitMap.put(staticPartRefit.getQuality(), map);
                }

                map.put(staticPartRefit.getLv(), staticPartRefit);
            }

        }
        this.refitMap = refitMap;
        this.nineOrTenRefitMap = nineOrTenRefitMap;
    }

    public StaticPart getStaticPart(int partId) {
        return partMap.get(partId);
    }

    public StaticPartUp getStaticPartUp(int partId, int upLv) {
        Map<Integer, StaticPartUp> map = upMap.get(partId);
        if (map != null) {
            return map.get(upLv);
        }
        return null;
    }

    public StaticPartRefit getStaticPartRefit(int quality, int refitLv, boolean nineOrTen) {
        if (nineOrTen) {
            Map<Integer, StaticPartRefit> map = nineOrTenRefitMap.get(quality);
            if (CheckNull.isEmpty(map)) {
                return null;
            }
            return map.get(refitLv);
        } else {
            Map<Integer, StaticPartRefit> map = refitMap.get(quality);
            if (map != null) {
                return map.get(refitLv);
            }
            return null;
        }
    }

    public StaticPartSmelting getStaticPartSmelting(int kind) {
        return smeltingMap.get(kind);
    }

    public StaticPartQualityUp getStaticPartQualityUp(int partId) {
        return qualityUpMap.get(partId);
    }

    /**
     * 计算强化该物品总计花费
     *
     * @param partId
     * @param lv
     * @return
     */
    public long getUpCost(int partId, int lv) {
        long cost = 0;
        for (int i = 1; i <= lv; i++) {
            cost += getStaticPartUp(partId, i).getStone();
        }
        return cost;
    }
}
