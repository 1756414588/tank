package com.game.crossminserver.server;

import com.game.message.handler.cs.crossMin.*;
import com.game.message.pool.MessagePool;
import com.game.pb.CrossMinPb;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/4/18 14:51
 * @description：
 */
public class CrossMinMessagePool extends MessagePool {

    @Override
    protected void register() {
        // 通知游戏服注册成功
        registerC(CrossMinPb.CrossMinGameServerRegRq.EXT_FIELD_NUMBER, CrossMinPb.CrossMinGameServerRegRs.EXT_FIELD_NUMBER, CCMGameServerRegHandler.class);
        registerC(CrossMinPb.CrossMinHeartRq.EXT_FIELD_NUMBER, 0, CCMHeartHandler.class);

        //组队副本战斗
        registerC(CrossMinPb.CrossFightRq.EXT_FIELD_NUMBER, CrossMinPb.CrossFightRs.EXT_FIELD_NUMBER, CCMFightHandler.class);
        registerC(CrossMinPb.CrossTeamChatRq.EXT_FIELD_NUMBER, 0, CrossTeamChatHandler.class);


        //攻打跨服军矿
        registerC(CrossMinPb.CrossMineAttack.EXT_FIELD_NUMBER, 0, CrossMineAttackHandler.class);


    }
}
