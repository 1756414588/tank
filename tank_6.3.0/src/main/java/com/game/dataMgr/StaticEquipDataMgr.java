/**
 * @Title: StaticEquipDataMgr.java
 * @Package com.game.dataMgr
 * @Description:
 * @author ZhangJun
 * @date 2015年8月18日 上午11:32:19
 * @version V1.0
 */
package com.game.dataMgr;

import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import com.game.domain.s.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.p.Equip;
import com.game.util.LogUtil;

/**
 * @author ZhangJun
 * @ClassName: StaticEquipDataMgr
 * @Description:军备相关
 * @date 2015年8月18日 上午11:32:19
 */
@Component
public class StaticEquipDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticEquip> equipMap;

    private Map<Integer, StaticEquipUpStar> equipStarMap;

    public StaticEquipUpStar getEquipStar(int starLv) {
        return equipStarMap.get(starLv);
    }

    /**
     * @Fields levelMap : Map<quality, Map<level, StaticEquipLv>>
     */
    private Map<Integer, Map<Integer, StaticEquipLv>> levelMap;

    private List<StaticEquipBonusAttribute> bonusAttribute;

    //军备列表
    private Map<Integer, StaticLordEquip> lordEquips;

    //军备技工列表
    private TreeMap<Integer, StaticTechnical> techMap;

    //军备材料列表
    private Map<Integer, StaticLordEquipMaterial> materialMap;

    //KEY0:材料品质, KEY1:材料ID, VALUE:军备材料
    private Map<Integer, TreeMap<Integer, StaticLordEquipMaterial>> qualityMap;

    //KEY0:军备材料品质,VALUE:公式ID
    private Map<Integer, Integer> quaFla;

    //军备洗练表
    private Map<Integer, StaticLordEquipChange> lordEquipChangeMap;
    
    //军备技能表
    private Map<Integer, StaticLordEquipSkill> lordEquipSkillMap;
    
    
    /**
     * Overriding: init
     *
     * @see com.game.dataMgr.BaseDataMgr#init()
     */
    @Override
    public void init() {
        this.equipMap = staticDataDao.selectEquip();
        this.bonusAttribute = staticDataDao.selectEquipBonusAttribute();
        this.lordEquips = staticDataDao.selectLordEquip();
        this.materialMap = staticDataDao.selectLordEquipMaterial();
        this.lordEquipChangeMap = staticDataDao.selectLordEquipChange();
        this.lordEquipSkillMap = staticDataDao.selectLordEquipSkill();
        initLevel();
        initBonusAttribute();
        initTechnical();
        initQualietyMaterial();

        this.equipStarMap = staticDataDao.selectStaticEquipUpStar();
    }

    private void initQualietyMaterial() {
        Map<Integer, Integer> quaFla0 = new HashMap<>();
        for (Map.Entry<Integer, StaticLordEquipMaterial> entry : materialMap.entrySet()) {
            StaticLordEquipMaterial data = entry.getValue();
            if (data.getFormula() > 0) {
                quaFla0.put(data.getQuality(), data.getFormula());
            }
        }
        this.quaFla = quaFla0;
    }

    private void initTechnical() {
        Map<Integer, StaticTechnical> dataMap = staticDataDao.selectTechnical();
        this.techMap = new TreeMap<>();
        if (dataMap != null && !dataMap.isEmpty()) {
            for (Map.Entry<Integer, StaticTechnical> entry : dataMap.entrySet()) {
                this.techMap.put(entry.getKey(), entry.getValue());
            }
        }
    }

    private void initBonusAttribute() {
        //排序
        Collections.sort(bonusAttribute, new Comparator<StaticEquipBonusAttribute>() {

            @Override
            public int compare(StaticEquipBonusAttribute o1,
                               StaticEquipBonusAttribute o2) {
                if (o1.getQuality() != o2.getQuality()) {
                    return o2.getQuality() - o1.getQuality();
                }
                return o2.getNumber() - o1.getNumber();
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

    /**
     * 获取指定品质的所有装备
     * @param qua
     * @return
     */
    public Map<Integer, StaticEquip> getEquipsByQuality(int qua){
        Map<Integer, StaticEquip> quaMap = new HashMap<>();
        for (Map.Entry<Integer, StaticEquip> entry : equipMap.entrySet()) {
            StaticEquip data = entry.getValue();
            if (data.getQuality()==qua){
                quaMap.put(data.getEquipId(), data);
            }
        }
        return quaMap;
    }

    public StaticEquipLv getStaticEquipLv(int quality, int lv) {
        Map<Integer, StaticEquipLv> map = levelMap.get(quality);
        if (map != null) {
            return map.get(lv);
        }

        return null;
    }

    public boolean addEquipExp(int lordLv, Equip equip, int add) {
        StaticEquip staticEquip = equipMap.get(equip.getEquipId());
        int quality = staticEquip.getQuality();
        int oriLv = equip.getLv();
        int lv = oriLv;
        int curExp = equip.getExp() + add;
        while (lv < lordLv) {
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

    /**
     * 检测并处理老号玩家装备经验溢出,
     * 如果玩家装备溢出经验足够装备升级则装备自动升级
     * @param lordLv
     */
    public boolean checkEquipExpOverflow(int lordLv, Equip equip) {
        StaticEquip staticEquip = equipMap.get(equip.getEquipId());
        int quality = staticEquip.getQuality();
        StaticEquipLv staticEquipLv = getStaticEquipLv(quality, equip.getLv() + 1);
        boolean lvup = false;
        while (staticEquipLv != null && lordLv > equip.getLv()) {
            int remain = equip.getExp() - staticEquipLv.getNeedExp();
            if (remain < 0) break;
            equip.setLv(equip.getLv() + 1);
            equip.setExp(remain);
            lvup = true;
            staticEquipLv = getStaticEquipLv(quality, equip.getLv() + 1);
        }
        return lvup;
    }

    public int getEquipExpTotal(Equip equip, int quality) {
        int exp = equip.getExp();
        for (int i = 2; i <= equip.getLv(); i++) {//装备1级不需要经验
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
        StaticLordEquip data = lordEquips.get(eid);
        if (data == null) {
            LogUtil.error(String.format("not found lord equip :%d", eid));
        }
        return data;
    }

    /**
     * 获得军备技工(铁匠)
     *
     * @param id
     * @return
     */
    public StaticTechnical getTechnical(int id) {
        StaticTechnical data = techMap.get(id);
        if (data == null) {
            LogUtil.error(String.format("not found lord equip technical id :%d", id));
        }
        return data;
    }

    /**
     * 获得比指定技工更高一级的技工
     *
     * @param id
     * @return
     */
    public StaticTechnical getNextTechnical(int id) {
        if (id >= techMap.lastKey()) return null;
        Map.Entry<Integer, StaticTechnical> entry = techMap.higherEntry(id);
        return entry != null ? entry.getValue() : null;
    }

    public StaticTechnical getOpenMaxTechnical(int prosLv) {
        for (Map.Entry<Integer, StaticTechnical> entry : techMap.descendingMap().entrySet()) {
            if (entry.getValue().getProsLevel() <= prosLv) return entry.getValue();
        }
        LogUtil.error(String.format("not found pros lv :%d, technical", prosLv));
        return null;
    }

    /**
     * 获取军备材料
     *
     * @param id
     * @return
     */
    public StaticLordEquipMaterial getLordEquipMaterial(int id) {
        StaticLordEquipMaterial data = materialMap.get(id);
        if (data == null) {
            LogUtil.error(String.format("not found lord equip material id :%d", id));
        }
        return data;
    }

    /**
     * 根据品质获取军备材料生产的公式ID,
     * 目前规定：同品质所有材料的生产公式都一样
     *
     * @param quality
     * @return
     */
    public int getFormulaByQuality(int quality) {
        Integer fla = quaFla.get(quality);
        if (fla == null || fla == 0) {
            LogUtil.error(String.format("not found lord equip material quality :%d", quality));
            return 0;
        }
        return fla;
    }

	public Map<Integer, StaticLordEquipChange> getLordEquipChangeMap() {
		return lordEquipChangeMap;
	}

	public Map<Integer, StaticLordEquipSkill> getLordEquipSkillMap() {
		return lordEquipSkillMap;
	}

	public StaticLordEquipChange getLordEquipChange(int id) {
		return lordEquipChangeMap.get(id);
	}

	/**
	 * @param type
	 * @param lv
	 * @return
	 */
	public StaticLordEquipSkill getLordEquipSkillMap(int type, int lv) {
		int id = type * 100 + lv;
		return lordEquipSkillMap.get(id);
	}
}
