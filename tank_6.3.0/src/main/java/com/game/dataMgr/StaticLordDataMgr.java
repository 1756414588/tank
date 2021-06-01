/**
 * @Title: StaticLevelDataMgr.java
 * @Package com.game.dataMgr
 * @Description:
 * @author ZhangJun
 * @date 2015年8月13日 上午11:51:59
 * @version V1.0
 */
package com.game.dataMgr;

import java.util.Collections;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Set;
import java.util.TreeMap;

import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.Constant;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;

/**
 * @author ZhangJun
 * @ClassName: StaticLevelDataMgr
 * @Description:等级相关配置数据（指挥官，统帅等级，繁荣等级，军衔）
 * @date 2015年8月13日 上午11:51:59
 */
@Component
public class StaticLordDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    @Autowired
    private StaticPeakMgr staticPeakMgr;

    // 指挥官等级
    private Map<Integer, StaticLordLv> lordLvMap;

    // 统帅等级
    private Map<Integer, StaticLordCommand> commandLvMap;

    // 繁荣度
    private List<StaticLordPros> prosLvList;

    // 军衔
    private Map<Integer, StaticLordRank> rankMap;

    private Map<Integer, StaticPendant> pendantMap;

    private Map<Integer, StaticPortrait> portraitMap;

    private Map<Integer, StaticFameLv> fameLvMap;

    //军衔列表KEY:军衔ID,VALUE:军衔信息
    private TreeMap<Integer, StaticMilitaryRank> militaryRankTreeMap = new TreeMap<>();

    /**
     * Overriding: init
     *
     * @see com.game.dataMgr.BaseDataMgr#init()
     */
    @Override
    public void init() {
        this.lordLvMap = staticDataDao.selectLordLv();
        this.commandLvMap = staticDataDao.selectLordCommand();
        this.prosLvList = staticDataDao.selectLordPros();
        this.rankMap = staticDataDao.selectLordRank();
        this.fameLvMap = staticDataDao.selectStaticFameLvMap();

        initPendantMap();
        initPortraitMap();
        initMilitaryRankTreeMap();
    }

    /**
     * 初始化军衔信息
     */
    private void initMilitaryRankTreeMap() {
        Map<Integer, StaticMilitaryRank> dataMap = staticDataDao.selectMilitaryRank();
        if (dataMap != null && !dataMap.isEmpty()) {
            TreeMap<Integer, StaticMilitaryRank> militaryRankTreeMap0 = new TreeMap<>();
            militaryRankTreeMap0.putAll(dataMap);
            this.militaryRankTreeMap = militaryRankTreeMap0;
        }
    }

    private void initPendantMap() {
        List<StaticPendant> pendantList = staticDataDao.selectStaticPendant();
        Map<Integer, StaticPendant> pendantMap = new HashMap<>();
        for (StaticPendant staticPendant : pendantList) {
            pendantMap.put(staticPendant.getPendantId(), staticPendant);
        }
        this.pendantMap = pendantMap;
    }

    private void initPortraitMap() {
        List<StaticPortrait> list = staticDataDao.selectStaticPortrait();
        Map<Integer, StaticPortrait> map = new HashMap<>();
        for (StaticPortrait p : list) {
            map.put(p.getId(), p);
        }
        this.portraitMap = map;
    }

    /**
     * 获取指定官职
     *
     * @return
     */
    public StaticMilitaryRank getStaticMilitaryRank(int mrId) {
        StaticMilitaryRank data = militaryRankTreeMap.get(mrId);
        if (data == null && mrId <= militaryRankTreeMap.lastKey()) {
            LogUtil.error("not found military rank id :" + mrId);
        }
        return data;
    }

    /**
     * 获取比指定官职更高一级的官职
     *
     * @param opId
     * @return
     */
    public StaticMilitaryRank getHigherMilitaryRank(int opId) {
        Map.Entry<Integer, StaticMilitaryRank> entry = militaryRankTreeMap.higherEntry(opId);
        if (entry == null) {
            LogUtil.error("not found higher military rank id :%d " + opId);
        }
        return entry != null ? entry.getValue() : null;
    }

    /**
     * 判断指定官职是否是最大官职
     *
     * @param opId 官职ID
     * @return
     */
    public boolean isMaxMilitaryRank(int opId) {
        return opId >= militaryRankTreeMap.lastKey();
    }

    /**
     * 获取指定军衔所能拥有的最大军功值,0级与1级拥有最大军功值相等
     *
     * @param mlr
     * @return
     */
    public long getMilitaryRankMpltLimit(int mlr) {
        StaticMilitaryRank data = militaryRankTreeMap.get(mlr);
        if (data == null) {
            if (mlr == 0) {
                return militaryRankTreeMap.firstEntry().getValue().getMpltLimit();
            } else {
                LogUtil.error("not found data mlr : " + mlr);
            }
        } else {
            return data.getMpltLimit();
        }
        return 0;
    }

    public StaticLordLv getStaticLordLv(int lv) {
        return lordLvMap.get(lv);
    }

    public StaticLordCommand getStaticCommandLv(int lv) {
        return commandLvMap.get(lv);
    }

    /**
     * @param pros
     * @return StaticLordPros
     */
    public StaticLordPros getStaticProsLv(int pros) {
        StaticLordPros lv = null;
        for (StaticLordPros staticProsLv : prosLvList) {
            if (pros >= staticProsLv.getProsExp()) {
                lv = staticProsLv;
            } else
                break;
        }
        return lv;
    }

    public StaticLordRank getStaticLordRank(int rankId) {
        return rankMap.get(rankId);
    }

    public int getMaxLordRank() {
        Set<Integer> rankSet = rankMap.keySet();
        return Collections.max(rankSet);
    }


    public boolean addExp(Player player, long add) {
        Lord lord = player.lord;
        int lv = lord.getLevel();
        final int oldLv = lv;
        boolean up = false;
        long exp = lord.getExp() + add;
        while (true) {
            if (lv >= Constant.PLAYER_OPEN_LV) {
                StaticPeakLv peakLv = staticPeakMgr.getPeakLv(lord.getPeakLv() + 1);
                if (exp >= peakLv.getExp()) {
                    exp -= peakLv.getExp();
                    lord.setPeakLv(lord.getPeakLv() + 1);
                    lord.setPeaks(lord.getPeaks() + 1);
                } else {
                    lord.setPeakExp(exp);
                    exp = 0;
                    break;
                }
            } else {
                StaticLordLv staticLordLv = lordLvMap.get(lv + 1);
                if (exp >= staticLordLv.getNeedExp()) {
                    up = true;
                    exp -= staticLordLv.getNeedExp();
                    lv++;
                } else {
                    break;
                }
            }
        }
        //修改了exp int to long
        lord.setLevel(lv);
        lord.setExp(exp);

        //如果升级了则记录升级日志
        if (lv > oldLv) {
            LogLordHelper.logUpLevel(player, oldLv);
        }

        return up;
    }

    public StaticPendant getPendant(int pendantId) {
        return pendantMap.get(pendantId);
    }

    public Map<Integer, StaticPendant> getPendantMap() {
        return pendantMap;
    }

    public Map<Integer, StaticPortrait> getPortraitMap() {
        return portraitMap;
    }

    public boolean addFame(Lord lord, int add) {
        int lv = lord.getFameLv();

        boolean up = false;
        int exp = lord.getFame() + add;
        while (true) {
            StaticFameLv staticFameLv = fameLvMap.get(lv + 1);
            if (staticFameLv == null) {
                break;
            }
            if (exp >= staticFameLv.getFame()) {
                up = true;
                exp -= staticFameLv.getFame();
                lv++;
            } else {
                break;
            }
        }
        lord.setFameLv(lv);
        lord.setFame(exp);
        return up;
    }

}
