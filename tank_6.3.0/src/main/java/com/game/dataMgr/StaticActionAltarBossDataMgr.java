package com.game.dataMgr;


import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticAltarBossAward;
import com.game.domain.s.StaticAltarBossContribute;
import com.game.domain.s.StaticAltarBossStar;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StaticActionAltarBossDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, Map<Integer, StaticAltarBossAward>> altarAwardMaps = new HashMap<>();

    private Map<Integer, Map<Integer, StaticAltarBossContribute>> altarContriButeMaps = new HashMap<>();

    private List<StaticAltarBossStar> altarStarList = new ArrayList<>();

    private int maxExp; //获取最大经验


    @Override
    public void init() {

        try {
            awardinit();
        } catch (Exception e) {
            LogUtil.error("祭坛Boss奖励解析配置出错", e);
        }


        try {
            contributeInit();
        } catch (Exception e) {
            LogUtil.error("祭坛Boss解析配置出错", e);
        }

        try {
            startInit();
        } catch (Exception e) {
            LogUtil.error("祭坛Boss星级解析配置出错", e);
        }
    }

    /*
     * 祭坛Boss奖励.
     */
    private void awardinit() {
        Map<Integer, Map<Integer, StaticAltarBossAward>> tempAltarAwards = new HashMap<>();
        List<StaticAltarBossAward> awardList = staticDataDao.staticAltarBossAwardList();

        if (awardList != null && !awardList.isEmpty()) {
            for (StaticAltarBossAward c : awardList) {
                if (!tempAltarAwards.containsKey(c.getStar())) {
                    Map<Integer, StaticAltarBossAward> m = new HashMap<>();
                    tempAltarAwards.put(c.getStar(), m);
                }

                if (!tempAltarAwards.get(c.getStar()).containsKey(c.getLv())) {


                    tempAltarAwards.get(c.getStar()).put(c.getLv(), c);
                }
            }

        }
        altarAwardMaps.clear();
        altarAwardMaps = tempAltarAwards;

    }

	 /*
      * 祭坛Boss捐献
	  */

    private void contributeInit() {
        Map<Integer, Map<Integer, StaticAltarBossContribute>> tempcontriButes = new HashMap<>();
        List<StaticAltarBossContribute> contriubteList = staticDataDao.staticAltarBossContributeList();

        if (contriubteList != null && !contriubteList.isEmpty()) {
            for (StaticAltarBossContribute c : contriubteList) {
                if (!tempcontriButes.containsKey(c.getType())) {
                    Map<Integer, StaticAltarBossContribute> m = new HashMap<>();
                    tempcontriButes.put(c.getType(), m);
                }

                if (!tempcontriButes.get(c.getType()).containsKey(c.getCount())) {
                    tempcontriButes.get(c.getType()).put(c.getCount(), c);
                }
            }
        }
        altarContriButeMaps.clear();
        altarContriButeMaps = tempcontriButes;
    }

    /*
     * 祭坛Boss星级
     */
    private void startInit() {
        altarStarList = staticDataDao.staticAltarBossStarList();

        for (StaticAltarBossStar staticAltarBossStar : altarStarList) {
            if (staticAltarBossStar.getExp() > maxExp) {
                maxExp = staticAltarBossStar.getExp();
            }
        }
    }

    /**
     * 获取奖励列表对象
     *
     * @param bosslv
     * @param starlv
     * @return
     */
    public StaticAltarBossAward getAltarAwardMaps(int bosslv, int starlv) {
        if (!altarAwardMaps.containsKey(starlv)) {
            return null;
        }
        return altarAwardMaps.get(starlv).get(bosslv);
    }

    /**
     * 获取捐献列表对象
     *
     * @param type
     * @param count
     * @return
     */
    public StaticAltarBossContribute getStaticAltarBossContribute(int type, int count) {

        if (!altarContriButeMaps.containsKey(type)) {
            return null;
        }

        return altarContriButeMaps.get(type).get(count);
    }


    /**
     * 获取星级列表对象
     *
     * @param exp
     * @return
     */
    public StaticAltarBossStar getAltarStarMaps(int exp) {

        for (int i = altarStarList.size() - 1; i >= 0; i--) {
            if (exp >= altarStarList.get(i).getExp()) {
                return altarStarList.get(i);
            }
        }
        return null;
    }

    public int getMaxExp() {
        return maxExp;
    }

}
