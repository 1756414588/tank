/**
 * @Title: ArenaTimer.java @Package com.game.server.timer @Description: TODO
 * @author ZhangJun
 * @date 2015年9月9日 下午3:32:03
 * @version V1.0
 */
package com.game.server.timer;

import com.game.server.GameContext;
import com.game.server.ICommand;
import com.game.service.cross.CrossRegisterService;

/** @author wanyi */
public class WatchGameServerTimer extends TimerEvent {

    public WatchGameServerTimer() {
        super(-1, 20000);
    }

    /**
     * Overriding: action
     *
     * @see ICommand#action()
     */
    @Override
    public void action() {
        GameContext.getAc().getBean(CrossRegisterService.class).watchGameServerTimerLogic();
    }
}
