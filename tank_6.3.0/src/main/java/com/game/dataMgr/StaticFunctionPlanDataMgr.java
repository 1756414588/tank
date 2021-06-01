package com.game.dataMgr;

import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.common.ServerSetting;
import com.game.constant.FuncType;
import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticFunctionPlan;
import com.game.util.DateHelper;
import com.game.util.LogUtil;

/**
 * @author ChenKui
 * @version 创建时间：2016-3-23 下午2:58:57
 * @Description 能晶配置数据管理类
 */
@Component
public class StaticFunctionPlanDataMgr extends BaseDataMgr {

    @Autowired
    private ServerSetting serverSetting;

    @Autowired
    private StaticDataDao staticDataDao;

    // 功能开关
    private Map<Integer, Boolean> funcMap = new HashMap<>();

    @Override
    public void init() {
        Date openTime = DateHelper.parseDate(serverSetting.getOpenTime());
        int serverId = serverSetting.getServerID();// 本服ID
        List<StaticFunctionPlan> list = staticDataDao.selectFunctionPlan();
        for (StaticFunctionPlan plan : list) {
            int funId = plan.getFunId();
            String rules = plan.getRules().trim();
            if (rules.equals("")) {
                funcMap.put(funId, false);
                continue;
            }
            if (rules.equals("*") || rules.equals("1")) {
                funcMap.put(funId, true);
            } else if (rules.equals("0")) {
                funcMap.put(funId, false);
            } else {
                String[] rule = rules.split(",");
                for (int i = 0; i < rule.length; i++) {
                    if (!rule[i].contains("-")) {
                        continue;
                    }
                    String sids[] = rule[i].split("-");
                    if (sids.length < 2) {
                        continue;
                    }
                    int sidB = Integer.parseInt(sids[0].trim());
                    int sidE = Integer.parseInt(sids[1].trim());
                    if (serverId >= sidB && serverId <= sidE) {
                        funcMap.put(funId, true);
                    }
                }
            }
        }
        LogUtil.info("function plan : {}", funcMap);
    }

    /**
     * 过滤是否开启
     *
     * @param functionName
     * @return
     */
    private boolean filter(int funId) {
        Boolean bOpen = funcMap.get(funId);
        return bOpen != null && bOpen;
    }

    public boolean isMilitaryRankOpen() {
        return filter(FuncType.MILITARY_RANK);
    }

    public boolean isLiveTaskOpen() {
        // return false;
        return filter(FuncType.LIVE_TASK);
    }

    public boolean isPlayerBackOpen() {
        // return false;
        return filter(FuncType.PLAYER_BACK);
    }

    public boolean isAirshipOpen() {
        return filter(FuncType.AIRSHIP);
    }

    /**
     * 是否开启军备功能
     */
    public boolean isLordEquipOpen() {
        return filter(FuncType.LORD_EQUIP);
    }

    /**
     * 是否开启军备洗练功能
     *
     * @return
     */
    public boolean isLordEquipChangeOpen() {
        return filter(FuncType.LORD_EQUIP_CHANGE);
    }

    /**
     * 是否开启文官入驻
     *
     * @return
     */
    public boolean isHeroPutOpen() {
        return filter(FuncType.HERO_PUT);
    }

    /**
     * 是否开启邮件优化
     *
     * @return
     */
    public boolean isOptimizeMailOpen() {
        return filter(FuncType.MAIL_OPTIMIZE);
    }

    /**
     * 最强实力排行榜功能开关
     *
     * @return
     */
    public boolean isRankStrongestOpen() {
        return filter(FuncType.RANK_STRONGEST);
    }

    /**
     * 皮肤管理功能开关
     */
    public boolean isSkinOpen() {
        return filter(FuncType.SKIN);
    }

    /**
     * 风行者觉醒开关
     */
    public boolean isAwakenHeroOpen() {
        return filter(FuncType.AWAKENHERO);
    }

    /**
     * 震慑效果开关
     *
     * @return
     */
    public boolean isFrightenOpen() {
        return filter(FuncType.FRIGHTEN);
    }

    /**
     * 勋章精炼开关
     *
     * @return
     */
    public boolean isTransMedalOpen() {
        return filter(FuncType.TRANS_MEDAL);
    }

    /**
     * Sentry日志功能是否开启
     *
     * @return
     */
    public boolean isSentryOpen() {
        return filter(FuncType.SENTRY_LOG);
    }

    /**
     * 秘密武器是否开启
     *
     * @return
     */
    public boolean isSecretWeaponOpen() {
        return filter(FuncType.SECRET_WEAPON);
    }

    /**
     * 攻击特效是否开启
     *
     * @return
     */
    public boolean isAttackEffectOpen() {
        return filter(FuncType.ATTACK_EFFECT);
    }


    /**
     * 作战实验室否开启
     *
     * @return
     */
    public boolean isFightLabOpen() {
        return filter(FuncType.FIGHT_LAB);
    }

    /**
     * 作战实验室否开启
     *
     * @return
     */
    public boolean isVcodeScoutOpen() {
        return filter(FuncType.VCODE_SCOUT);
    }
}
