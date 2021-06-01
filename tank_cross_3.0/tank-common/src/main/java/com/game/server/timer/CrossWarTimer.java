package com.game.server.timer;

import com.game.common.ServerSetting;
import com.game.constant.CrossConst;
import com.game.server.GameContext;
import com.game.service.GmToolService;
import com.game.service.cross.fight.CrossService;
import com.game.service.cross.party.CrossPartyService;
import com.game.util.LogUtil;
import org.springframework.beans.BeansException;

import java.util.Calendar;

public class CrossWarTimer extends TimerEvent {

    private boolean loadConfig = false;

    public CrossWarTimer() {
        super(-1, 1000);
    }

    @Override
    public void action() {

        try {
            // 每天上午十点加载一次配置
            Calendar calendar = Calendar.getInstance();
            if (calendar.get(Calendar.HOUR_OF_DAY) == 10) {
                if (!loadConfig) {
                    loadConfig = true;
                    LogUtil.error("开始加载init配置");
                    GameContext.getAc().getBean(GmToolService.class).reloadParamLogic(1);
                    GameContext.getAc().getBean(GmToolService.class).reloadParamLogic(2);
                    LogUtil.error("加载init配置完成");
                }
            } else {
                loadConfig = false;
            }
        } catch (BeansException e) {
            LogUtil.error(e);
        }

        if (Integer.parseInt(GameContext.getAc().getBean(ServerSetting.class).getCrossType()) == CrossConst.CrossType) {
            GameContext.getAc().getBean(CrossService.class).crossWarTimerLogic();
        } else if (Integer.parseInt(GameContext.getAc().getBean(ServerSetting.class).getCrossType()) == CrossConst.CrossPartyType) {
            GameContext.getAc().getBean(CrossPartyService.class).crossPartyWarTimerLogic();
        }

        // 跨服商店刷新逻辑(珍宝商店不限购，去掉)
        // GameServer.ac.getBean(CrossDataManager.class).refreshCrossShopLogic();
    }
}
