package com.game.server.timer;

import com.game.server.GameContext;
import com.game.service.teaminstance.CrossTeamService;
import com.game.util.TimeHelper;

public class TeamDismissTimer extends TimerEvent {


    public TeamDismissTimer() {
        super(-1, TimeHelper.SECOND_MS);
    }

    @Override
    public void action() {
        //每天凌晨对赏金副本的队伍进行检查，解散无效队伍
        if (TimeHelper.getCurrentSecond() == TimeHelper.getTodayZone()){
            GameContext.getAc().getBean(CrossTeamService.class).disInvalidTeamLogic();
        }
    }

}
