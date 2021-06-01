package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticSecretWeapon;
import com.game.domain.s.StaticSecretWeaponSkill;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: StaticSecretWeaponDataMgr
 * @Description: 秘密武器配置管理
 * @date 2017-11-13 19:08
 */
@Component
public class StaticSecretWeaponDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    //KEY:秘密武器ID,VALUE:武器配置
    private TreeMap<Integer, StaticSecretWeapon> weapons = new TreeMap<>();
    //KEY:秘密武器ID, VALUE:0-技能ID,1-技能权重
    private Map<Integer, List<List<Integer>>> skillWeight = new HashMap<>();

    //KEY:技能ID,VALUE:技能配置
    private Map<Integer, StaticSecretWeaponSkill> weaponSkills = new HashMap<>();

    //KEY:当前武器，VALUE:可以解锁的武器列表
    private Map<StaticSecretWeapon, List<StaticSecretWeapon>> openMap = new HashMap<>();

    @Override
    public void init() {
        weapons.clear();
        weapons.putAll(staticDataDao.selectSecretWeapon());

        initSecretWeapon();
        initSecretWeaponSkill();
    }

    /**
     * 初始化秘密武器的开启信息
     */
    private void initSecretWeapon() {
        for (Map.Entry<Integer, StaticSecretWeapon> entry : weapons.entrySet()) {
            StaticSecretWeapon data = entry.getValue();
            if (data.getOpenId() > 0) {
                StaticSecretWeapon openData = weapons.get(data.getOpenId());
                List<StaticSecretWeapon> list = openMap.get(openData);
                if (list == null) openMap.put(openData, list = new ArrayList<StaticSecretWeapon>());
                list.add(data);
            }
        }
    }

    /**
     * 初始化技能配置信息
     */
    private void initSecretWeaponSkill() {
        weaponSkills = staticDataDao.selectSecretWeaponSkill();
        for (Map.Entry<Integer, StaticSecretWeaponSkill> entry : weaponSkills.entrySet()) {
            StaticSecretWeaponSkill data = entry.getValue();
            for (Map.Entry<Integer, Integer> probEntry : data.getWeight().entrySet()) {
                List<List<Integer>> list = skillWeight.get(probEntry.getKey());//KEY:武器ID
                if (list == null) skillWeight.put(probEntry.getKey(), list = new ArrayList<List<Integer>>());
                List<Integer> probList = new ArrayList<Integer>();
                probList.add(data.getSid());//技能ID
                probList.add(probEntry.getValue());//权重
                list.add(probList);
            }
        }
    }

    public StaticSecretWeapon getSecretWeapon(int weaponId) {
        StaticSecretWeapon data = weapons.get(weaponId);
        if (data == null) {
            LogUtil.error("not found secret weapon id :" + weaponId);
        }
        return data;
    }

    /**
     * 获取指定秘密武器开启的下一批武器
     *
     * @param before
     * @return
     */
    public List<StaticSecretWeapon> getOpenSecretWeapon(StaticSecretWeapon before) {
        return openMap.get(before);
    }

    /**
     * 获取秘密武器的技能权重
     *
     * @param weaponId
     * @return
     */
    public List<List<Integer>> getStudyWeight(int weaponId) {
        List<List<Integer>> skilWeight = skillWeight.get(weaponId);
        if (skilWeight == null) {
            LogUtil.error(String.format("not found weapon :%d weight", weaponId));
        }
        return skilWeight;
    }


    /**
     * 获取玩家功能开启时给予的默认武器
     *
     * @return
     */
    public StaticSecretWeapon getPlayerFunctionOpenDefault() {
        return weapons.firstEntry().getValue();
    }


    /**
     * 获得秘密武器技能信息
     * @param sid
     * @return
     */
    public StaticSecretWeaponSkill getSecretWeaponSkill(int sid) {
        StaticSecretWeaponSkill data = weaponSkills.get(sid);
        if (data == null) {
            LogUtil.error("not found secret weapon skill :" + sid);
        }
        return data;
    }

}
