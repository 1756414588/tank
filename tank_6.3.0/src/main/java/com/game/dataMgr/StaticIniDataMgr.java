package com.game.dataMgr;

import java.util.*;

import com.alibaba.fastjson.JSONArray;
import com.game.domain.s.friend.FriendlinessResourceRate;
import com.game.domain.s.friend.GiveProp;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticIniLord;
import com.game.domain.s.StaticIniName;
import com.game.domain.s.StaticSystem;
import com.game.util.RandomHelper;

/**
 * @author
 * @ClassName: StaticIniDataMgr
 * @Description: 全局常量配置信息
 */
@Component
public class StaticIniDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private List<String> markList = new ArrayList<String>();
    private List<String> familyList = new ArrayList<String>();
    private List<String> manList = new ArrayList<String>();
    private List<String> womanList = new ArrayList<String>();

    /**
     * 全局常量配置信息
     */
    private Map<Integer, StaticSystem> systemMap;
    /**
     * 荣耀生存玩法全局常量配置信息
     */
    private Map<Integer, StaticSystem> honourMap;

    @Override
    public void init() {
        this.initName();
    }

    public void initSystem() {
        this.systemMap = staticDataDao.selectSystemMap();
        this.honourMap = staticDataDao.selectHonourSystemMap();
    }

    public void initName() {
        List<StaticIniName> staticNameList = staticDataDao.selectName();
        List<String> familyList = new ArrayList<String>();
        List<String> womanList = new ArrayList<String>();
        List<String> markList = new ArrayList<String>();
        List<String> manList = new ArrayList<String>();
        for (StaticIniName staticName : staticNameList) {
            String familyName = staticName.getFamilyname();
            String womanName = staticName.getWomanname();
            String manName = staticName.getManname();
            String mark = staticName.getMark();
            if (familyName != null && !familyName.equals("")) {
                familyList.add(familyName);
            }

            if (womanName != null && !womanName.equals("")) {
                womanList.add(womanName);
            }

            if (manName != null && !manName.equals("")) {
                manList.add(manName);
            }

            if (mark != null && !mark.equals("")) {
                markList.add(mark);
            }
        }
        this.familyList = familyList;
        this.womanList = womanList;
        this.markList = markList;
        this.manList = manList;
    }

    // public String getNick() {
    // StringBuffer sb = new StringBuffer();
    //
    // int familyIndex = RandomHelper.randomInSize(familyList.size());
    // sb.append(familyList.get(familyIndex));
    // int nameIndex = RandomHelper.randomInSize(nameList.size());
    // sb.append(nameList.get(nameIndex));
    // return sb.toString();
    // }

    public String getManNick() {
        StringBuffer sb = new StringBuffer();

        int familyIndex = RandomHelper.randomInSize(familyList.size());
        sb.append(familyList.get(familyIndex));

        int nameIndex = RandomHelper.randomInSize(manList.size());
        sb.append(manList.get(nameIndex));
        return sb.toString();
    }

    public String getWomanNick() {
        StringBuffer sb = new StringBuffer();

        int familyIndex = RandomHelper.randomInSize(familyList.size());
        sb.append(familyList.get(familyIndex));

        int nameIndex = RandomHelper.randomInSize(womanList.size());
        sb.append(womanList.get(nameIndex));
        return sb.toString();
    }

    public StaticIniLord getLordIniData() {
        return staticDataDao.selectLord();
    }

    public StaticSystem getSystemConstantById(int id) {
        return systemMap.get(id);
    }

    public StaticSystem getHonourConstantById(int id) {
        return honourMap.get(id);
    }

    public Map<Integer, StaticSystem> getSystemMap() {
        return systemMap;
    }

    public Map<Integer, StaticSystem> getHonourMap() {
        return honourMap;
    }

    /**
     * 获取9-10号配件合成本体碎片数量限制配置信息
     * key: 配件品质 ；value：本体碎片数量
     *
     * @param id
     * @return
     */
    public Map<Integer, Integer> getNineOrTenPartCombineChipCountMap(int id) {
        StaticSystem staticSystem = systemMap.get(id);
        if (staticSystem == null) {
            return null;
        }
        String value = staticSystem.getValue();
        JSONArray arr = JSONArray.parseArray(value);
        Map<Integer, Integer> combinePartChipCountMap = new HashMap<>();
        for (int i = 0; i < arr.size(); i++) {
            JSONArray a = arr.getJSONArray(i);
            Integer quality = a.getInteger(0);
            Integer chipCount = a.getInteger(1);
            combinePartChipCountMap.put(quality, chipCount);
        }

        return combinePartChipCountMap;
    }

    /**
     * 获取好友度掠夺资源量比例配置信息
     *
     * @param id
     * @return
     */
    public List<FriendlinessResourceRate> getFriendlinessResourceRates(int id) {
        StaticSystem staticSystem = systemMap.get(id);
        if (staticSystem == null) {
            return new ArrayList<>();
        }
        String value = staticSystem.getValue();
        JSONArray arr = JSONArray.parseArray(value);
        List<FriendlinessResourceRate> list = new ArrayList<FriendlinessResourceRate>();
        for (int i = 0; i < arr.size(); i++) {
            JSONArray a = arr.getJSONArray(i);
            Integer min = a.getInteger(0);
            Integer max = a.getInteger(1);
            Integer rate = a.getInteger(2);
            FriendlinessResourceRate friendlinessResourceRate = new FriendlinessResourceRate(min, max, rate);
            list.add(friendlinessResourceRate);
        }
        return list;
    }
}
