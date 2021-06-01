package com.game.service;

import com.game.service.teaminstance.TeamService;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

/**
 * @author GuiJie
 * @description 玩家掉线下线
 * @created 2018/04/21 15:02
 */
@Component
public class PlayerLogOutService {


    @Autowired
    private TeamService teamService;

    /**
     * 玩家主动下线 被顶号
     * @param roleId
     */
    public void logOut(long roleId) {

        try {
            teamService.logOut(roleId);
        } catch (Exception e) {
            LogUtil.error("",e);
        }

    }
}
