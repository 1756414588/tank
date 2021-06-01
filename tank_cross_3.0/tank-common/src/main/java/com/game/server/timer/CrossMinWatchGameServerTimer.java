package com.game.server.timer;

import com.game.server.GameContext;
import com.game.service.crossmin.CrossMinService;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/4/18 15:15
 * @Description :java类作用描述
 */
public class CrossMinWatchGameServerTimer extends TimerEvent {

    public CrossMinWatchGameServerTimer() {
        super(-1, 10000);
    }

    @Override
    public void action() {
        GameContext.getAc().getBean(CrossMinService.class).watchGameServerTimerLogic();
    }
}
