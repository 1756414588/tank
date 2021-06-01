package com.game.dataMgr;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.*;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.*;

/**
 * @author GuiJie
 * @description 假日碎片 幸运奖池
 * @created 2018/03/20 11:32
 */
@Component
public class StaticActivateNewMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, List<StaticActFestivalPiece>> festivalrRewardConfig = new HashMap<>();
    private Map<Integer, StaticActFestivalPiece> festivalLoginConfig = new HashMap<>();

    private Map<Integer, List<StaticActLukyDraw>> luckyConfig = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActConfig>> actConfig = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActPay>> payConfig = new HashMap<>();

    private Map<Integer, StaticActTechsell> techsellConfig = new HashMap<>();
    
    private Map<Integer, StaticActBuildsell> buildsellConfig = new HashMap<>();

    private Map<Integer, StaticSeverBoss> severBoss = new HashMap<>();

    private Map<Integer, Map<Integer, StaticActPayNew>> payNew2Config = new HashMap<>();

    public StaticActPayNew payNew2Config(int awardId, int payId) {
        return payNew2Config.get(awardId).get(payId);
    }

    private Map<Integer, StaticBouns> bouns = new HashMap<>();


    private Map<Integer, Map<Integer, List<StaticActivityPartyWar>>> activityPartyWar = new HashMap<>();
    private Map<Integer, StaticActivityPartyWar> activityPartyWarMap = new HashMap<>();




    public StaticBouns getBouns(Integer id) {
        return bouns.get(id);
    }
    public List<StaticBouns> getBounsList() {
        return new ArrayList<>(bouns.values());
    }

    public StaticSeverBoss getSeverBoss(int dayCount) {
        Collection<StaticSeverBoss> values = severBoss.values();
        for (StaticSeverBoss c : values) {
            if (dayCount >= c.getServerDay1() && dayCount <= c.getServerDay2()) {
                return c;
            }
        }
        return null;
    }

    public StaticActTechsell getTechsellConfig(int awardId) {
        return techsellConfig.get(awardId);
    }
    
    public StaticActBuildsell getBuildsellConfig(int awardId) {
    	return buildsellConfig.get(awardId);
    }

    public StaticActPay getPayConfig(int awardId, int payId) {
        return payConfig.get(awardId).get(payId);
    }

    public StaticActConfig getActConfig(int activityId, int awardId) {

        if (actConfig.containsKey(activityId)) {
            return actConfig.get(activityId).get(awardId);
        }

        return null;
    }


    /**
     * 幸运
     *
     * @param awardId
     * @return
     */
    public List<StaticActLukyDraw> getLuckyConfig(int awardId) {
        return luckyConfig.get(awardId);
    }

    /**
     * @param awardId
     * @param id
     * @return
     */
    public StaticActFestivalPiece getRewardConfig(int awardId, int id) {
        List<StaticActFestivalPiece> cs = festivalrRewardConfig.get(awardId);
        for (StaticActFestivalPiece c : cs) {
            if (c.getId() == id) {
                return c;
            }
        }
        return null;
    }

    public List<StaticActFestivalPiece> getRewardConfig(int awardId) {
        return festivalrRewardConfig.get(awardId);
    }

    /**
     * 假日碎片登录奖励
     *
     * @param awardId
     * @return
     */
    public List<List<Integer>> getLoginReward(int awardId) {
        return festivalLoginConfig.get(awardId).getReward();
    }

    @Override
    public void init() {


        try {
            festivaInit();
        } catch (Exception e) {
            LogUtil.error("节日碎片解析配置出错", e);
        }


        try {
            luckyInit();
        } catch (Exception e) {
            LogUtil.error("幸运奖池解析配置出错", e);
        }

        try {
            configInit();
        } catch (Exception e) {
            LogUtil.error("活动配置出错", e);
        }
        try {
            payInit();
        } catch (Exception e) {
            LogUtil.error("新首冲", e);
        }
        try {
            techsellInit();
        } catch (Exception e) {
            LogUtil.error("科技优惠", e);
        }
        
        try {
        	buildsellInit();
        } catch (Exception e) {
        	LogUtil.error("建筑优惠", e);
        }
        
        try {
            serverBossInit();
        } catch (Exception e) {
            LogUtil.error("世界boss等级", e);
        }


        try {
            bounsInit();
        } catch (Exception e) {
            LogUtil.error("每日每周礼包", e);
        }

        try {
            warInit();
        } catch (Exception e) {
            LogUtil.error("工会活动", e);
        }

    }

    private void warInit() {
        Map<Integer, Map<Integer, List<StaticActivityPartyWar>>> tempActivityPartyWar = new HashMap<>();
        Map<Integer, StaticActivityPartyWar>  tempActivityPartyWarMap = new HashMap<>();

        List<StaticActivityPartyWar> partyWar = staticDataDao.selectActivityPartyWar();

        if (partyWar != null && !partyWar.isEmpty()) {

            for (StaticActivityPartyWar c : partyWar) {
                if (!tempActivityPartyWar.containsKey(c.getAwardId())) {


                    Map<Integer, List<StaticActivityPartyWar>> m = new HashMap<>();
                    tempActivityPartyWar.put(c.getAwardId(), m);
                }

                if( !tempActivityPartyWar.get(c.getAwardId()).containsKey(c.getEventType())){

                    List<StaticActivityPartyWar> t= new ArrayList<>();
                    tempActivityPartyWar.get(c.getAwardId()).put(c.getEventType(),t);
                }
                tempActivityPartyWar.get(c.getAwardId()).get(c.getEventType()).add(c);


                tempActivityPartyWarMap.put(c.getId(),c);
            }
        }

        this.activityPartyWar.clear();
        this.activityPartyWar = tempActivityPartyWar;
        this.activityPartyWarMap.clear();
        this.activityPartyWarMap = tempActivityPartyWarMap;
    }

    private void bounsInit() {

         Map<Integer, StaticBouns> tempBouns = new HashMap<>();

        List<StaticBouns> tempStaticBouns = staticDataDao.selectStaticBouns();
        if (tempStaticBouns != null && !tempStaticBouns.isEmpty()) {
            for (StaticBouns c : tempStaticBouns) {
                tempBouns.put(c.getId(),c);
            }
        }

        this.bouns.clear();
        this.bouns = tempBouns;
    }
    private void serverBossInit() {
        Map<Integer, StaticSeverBoss> tempSeverBoss = new HashMap<>();

        List<StaticSeverBoss> staticSeverBosses = staticDataDao.selectStaticSeverBoss();
        if (staticSeverBosses != null && !staticSeverBosses.isEmpty()) {

            for (StaticSeverBoss c : staticSeverBosses) {
                if (c.getServerDay2() == 0) {
                    c.setServerDay2(9999999);
                }
                tempSeverBoss.put(c.getKeyId(), c);
            }
        }
        this.severBoss.clear();
        this.severBoss = tempSeverBoss;

    }

    private void techsellInit() {

        Map<Integer, StaticActTechsell> tempTechsellConfig = new HashMap<>();

        List<StaticActTechsell> configs = staticDataDao.selectStaticActTechsell();
        if (configs != null && !configs.isEmpty()) {

            for (StaticActTechsell c : configs) {
                tempTechsellConfig.put(c.getAwardId(), c);
            }
        }

        this.techsellConfig.clear();
        this.techsellConfig = tempTechsellConfig;
    }
    
    private void buildsellInit() {

        Map<Integer, StaticActBuildsell> tempBuildsellConfig = new HashMap<>();

        List<StaticActBuildsell> configs = staticDataDao.selectStaticActBuildsell();
        if (configs != null && !configs.isEmpty()) {

            for (StaticActBuildsell c : configs) {
            	tempBuildsellConfig.put(c.getAwardId(), c);
            }
        }

        this.buildsellConfig.clear();
        this.buildsellConfig = tempBuildsellConfig;
    }
    

    private void payInit() {

        Map<Integer, Map<Integer, StaticActPay>> tempPayConfig = new HashMap<>();

        List<StaticActPay> configs = staticDataDao.selectStaticActPay();


        if (configs != null && !configs.isEmpty()) {

            for (StaticActPay c : configs) {
                if (!tempPayConfig.containsKey(c.getAwardId())) {
                    tempPayConfig.put(c.getAwardId(), new HashMap<Integer, StaticActPay>());
                }
                tempPayConfig.get(c.getAwardId()).put(c.getPayId(), c);
            }

        }

        this.payConfig.clear();
        this.payConfig = tempPayConfig;



        Map<Integer, Map<Integer, StaticActPayNew>> tempPayNew2Config = new HashMap<>();

        List<StaticActPayNew> configsNew2 = staticDataDao.selectStaticActPayNew2();

        if (configsNew2 != null && !configsNew2.isEmpty()) {

            for (StaticActPayNew c : configsNew2) {
                if (!tempPayNew2Config.containsKey(c.getAwardId())) {
                    tempPayNew2Config.put(c.getAwardId(), new HashMap<Integer, StaticActPayNew>());
                }
                tempPayNew2Config.get(c.getAwardId()).put(c.getPayId(), c);
            }
        }

        this.payNew2Config.clear();
        this.payNew2Config = tempPayNew2Config;

    }

    private void configInit() {
        Map<Integer, Map<Integer, StaticActConfig>> tempActConfig = new HashMap<>();


        List<StaticActConfig> configs = staticDataDao.selectStaticActConfig();
        if (configs != null && !configs.isEmpty()) {

            for (StaticActConfig c : configs) {
                if (!tempActConfig.containsKey(c.getActivityId())) {
                    tempActConfig.put(c.getActivityId(), new HashMap<Integer, StaticActConfig>());
                }
                tempActConfig.get(c.getActivityId()).put(c.getAwardId(), c);
            }

        }

        this.actConfig.clear();
        this.actConfig = tempActConfig;

    }

    private void luckyInit() {

        Map<Integer, List<StaticActLukyDraw>> luckyConfig = new HashMap<>();

        List<StaticActLukyDraw> luckyConfigs = staticDataDao.selectStaticActLukyDraw();

        if (luckyConfigs != null && !luckyConfigs.isEmpty()) {
            for (StaticActLukyDraw c : luckyConfigs) {

                if (!luckyConfig.containsKey(c.getAwardId())) {
                    luckyConfig.put(c.getAwardId(), new ArrayList<StaticActLukyDraw>());
                }

                luckyConfig.get(c.getAwardId()).add(c);
            }
        }


        this.luckyConfig.clear();
        this.luckyConfig = luckyConfig;
    }

    private void festivaInit() {
        Map<Integer, List<StaticActFestivalPiece>> tempRewardConfig = new HashMap<>();
        Map<Integer, StaticActFestivalPiece> tempLoginConfig = new HashMap<>();


        List<StaticActFestivalPiece> configs = staticDataDao.selectStaticActFestivalPiece();

        if (configs != null && !configs.isEmpty()) {

            for (StaticActFestivalPiece c : configs) {

                if (c.getIdentfy() != 1) {

                    if (!tempRewardConfig.containsKey(c.getAwardId())) {
                        tempRewardConfig.put(c.getAwardId(), new ArrayList<StaticActFestivalPiece>());
                    }
                    tempRewardConfig.get(c.getAwardId()).add(c);

                } else {
                    tempLoginConfig.put(c.getAwardId(), c);
                }
            }
        }


        festivalrRewardConfig.clear();
        festivalLoginConfig.clear();

        this.festivalrRewardConfig = tempRewardConfig;
        this.festivalLoginConfig = tempLoginConfig;

    }

    public StaticActivityPartyWar getActivityPartyWarConfig(int id) {
        return this.activityPartyWarMap.get(id);
    }
    public List<StaticActivityPartyWar> getActivityPartyWarConfig(int awardId,int eventType) {

        if( !activityPartyWar.containsKey(awardId)){
            return null;
        }

        return activityPartyWar.get(awardId).get(eventType);
    }
    public List<StaticActivityPartyWar> getActivityPartyWarConfig() {
        return new ArrayList<>(this.activityPartyWarMap.values());
    }

}
