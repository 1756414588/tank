package com.game.server.timer;

import com.game.service.crossmin.ServerListManager;
import com.game.util.LogUtil;

/**
 * @Author :GuiJie Liu
 * @date :Create in 2019/4/18 15:15
 * @Description :java类作用描述
 */
public class CrossMinRefreshServerTimer extends TimerEvent {

    public long time = 0;

    public CrossMinRefreshServerTimer() {
        super(-1, 20);
    }

    @Override
    public void action() {
        try {
            if (time == 0 || Math.abs(System.currentTimeMillis() - time) > 30000) {
                ServerListManager.refreshServerIds();
                ServerListManager.refreshServerListConfig();
                time = System.currentTimeMillis();
            }
        } catch (Exception e) {
            LogUtil.error(e);
        }

    }
}
