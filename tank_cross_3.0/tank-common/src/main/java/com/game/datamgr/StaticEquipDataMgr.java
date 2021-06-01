package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.p.Equip;
import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author ZhangJun
 * @ClassName: StaticEquipDataMgr @Description: TODO
 * @date 2015年8月18日 上午11:32:19
 */
@Component
public class StaticEquipDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;
    private Map<Integer, StaticEquipUpStar> equipStarMap;

    public StaticEquipUpStar getEquipStar(int starLv) {
        return equipStarMap.get(starLv);
    }

    private Map<Integer, StaticEquip> equipMap;
    // 军备列表
    private Map<Integer, StaticLordEquip> lordEquips;
    /**
     * @Fields levelMap : Map<quality, Map<level, StaticEquipLv>>
     */
    private Map<Integer, Map<Integer, StaticEquipLv>> levelMap;
    private List<StaticEquipBonusAttribute> bonusAttribute;
    // 军备技能表
    private Map<Integer, StaticLordEquipSkill> lordEquipSkillMap;

    /**
     * Overriding: init
     */
    @Override
    public void init() {
        Map<Integer, StaticEquip> equipMap = staticDataDao.selectEquip();
        this.equipMap = equipMap;
        this.bonusAttribute = staticDataDao.selectEquipBonusAttribute();
        this.lordEquips = staticDataDao.selectLordEquip();
        this.lordEquipSkillMap = staticDataDao.selectLordEquipSkill();
        initLevel();
        initBonusAttribute();
        this.equipStarMap = staticDataDao.selectStaticEquipUpStar();
    }

    private void initBonusAttribute() {
        // 排序
        Collections.sort(bonusAttribute, new Comparator<StaticEquipBonusAttribute>() {
            @Override
            public int compare(StaticEquipBonusAttribute o1, StaticEquipBonusAttribute o2) {
                if (o2.getQuality() > o1.getQuality()) {
                    return 1;
                } else if (o2.getQuality() < o1.getQuality()) {
                    return -1;
                } else {
                    if (o2.getNumber() > o1.getNumber()) {
                        return 1;
                    } else if (o2.getNumber() < o1.getNumber()) {
                        return -1;
                    }
                    return 0;
                }
            }
        });
    }

    private void initLevel() {
        List<StaticEquipLv> list = staticDataDao.selectEquipLv();
        Map<Integer, Map<Integer, StaticEquipLv>> levelMap = new HashMap<Integer, Map<Integer, StaticEquipLv>>();
        for (StaticEquipLv staticEquipLv : list) {
            Map<Integer, StaticEquipLv> qualityMap = levelMap.get(staticEquipLv.getQuality());
            if (qualityMap == null) {
                qualityMap = new HashMap<>();
                levelMap.put(staticEquipLv.getQuality(), qualityMap);
            }
            qualityMap.put(staticEquipLv.getLevel(), staticEquipLv);
        }
        this.levelMap = levelMap;
    }

    public StaticEquip getStaticEquip(int equipId) {
        return equipMap.get(equipId);
    }

    public StaticEquipLv getStaticEquipLv(int quality, int lv) {
        Map<Integer, StaticEquipLv> map = levelMap.get(quality);
        if (map != null) {
            return map.get(lv);
        }
        return null;
    }

    public Map<Integer, StaticLordEquipSkill> getLordEquipSkillMap() {
        return lordEquipSkillMap;
    }

    public boolean addEquipExp(Equip equip, int add) {
        StaticEquip staticEquip = equipMap.get(equip.getEquipId());
        int quality = staticEquip.getQuality();
        int oriLv = equip.getLv();
        int lv = oriLv;
        int curExp = equip.getExp() + add;
        while (true) {
            StaticEquipLv staticEquipLv = getStaticEquipLv(quality, lv + 1);
            if (staticEquipLv == null) {
                break;
            }
            if (curExp >= staticEquipLv.getNeedExp()) {
                lv++;
                curExp -= staticEquipLv.getNeedExp();
            } else {
                break;
            }
        }
        equip.setLv(lv);
        equip.setExp(curExp);
        return oriLv != lv;
    }

    public int getEquipExpTotal(Equip equip, int quality) {
        int exp = equip.getExp();
        // 装备1级不需要经验
        for (int i = 2; i <= equip.getLv(); i++) {
            StaticEquipLv staticEquipLv = getStaticEquipLv(quality, i);
            if (staticEquipLv == null) {
                continue;
            }
            exp += staticEquipLv.getNeedExp();
        }
        return exp;
    }

    public List<StaticEquipBonusAttribute> getBonusAttribute() {
        return bonusAttribute;
    }

    public StaticLordEquip getStaticLordEquip(int eid) {
        return lordEquips.get(eid);
    }
}