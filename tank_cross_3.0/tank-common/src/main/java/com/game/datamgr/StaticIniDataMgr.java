package com.game.datamgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticIniLord;
import com.game.domain.s.StaticIniName;
import com.game.domain.s.StaticSystem;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

@Component
public class StaticIniDataMgr extends BaseDataMgr {
  @Autowired private StaticDataDao staticDataDao;

  private List<String> markList = new ArrayList<String>();
  private List<String> familyList = new ArrayList<String>();
  private List<String> manList = new ArrayList<String>();
  private List<String> womanList = new ArrayList<String>();

  // 全局常量配置信息
  private Map<Integer, StaticSystem> systemMap;

  @Override
  public void init() {
    this.initName();
  }

  public void initSystem() {
    Map<Integer, StaticSystem> systemMap = staticDataDao.selectSystemMap();
    this.systemMap = systemMap;
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

  public Map<Integer, StaticSystem> getSystemMap() {
    return systemMap;
  }
}
