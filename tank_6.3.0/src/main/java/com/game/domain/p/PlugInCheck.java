package com.game.domain.p;

import java.util.LinkedList;

/**
 * @author zhangdh
 * @ClassName: PlugInCheck
 * @Description:
 * @date 2017-12-27 15:04
 */
public class PlugInCheck {

    //记录玩家最近侦查矿点信息(不存DB)
    private LinkedList<Integer> logScoutTime = new LinkedList<>();
    //扫矿外挂验证码(不存DB)
    private String scoutMineValidCode;

    public String getScoutMineValidCode() {
        return scoutMineValidCode;
    }

    public void setScoutMineValidCode(String scoutMineValidCode) {
        this.scoutMineValidCode = scoutMineValidCode;
    }

    public LinkedList<Integer> getLogScoutTime() {
        return logScoutTime;
    }
}
