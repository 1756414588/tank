package com.test.simula.handler.activity.monopoly;

import com.game.pb.BasePb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

/**
 * @author zhangdh
 * @ClassName: ThrowDiceRsHandler
 * @Description:
 * @date 2017-12-02 17:18
 */
public class ThrowDiceRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.ThrowDiceRs res = msg.getExtension(GamePb5.ThrowDiceRs.ext);
        LogUtil.info("玩家当前位置 :" + res.getPos());
        LogUtil.info("当前剩余精力 ：" + res.getEnergy());
        LogUtil.info("当前已完成的游戏次数 ： " + res.getFinishRound());
        if (res.getAwardList() != null) {
            LogUtil.info("当前获得到的奖励 ：" + res.getAwardList().toString());
        }
    }
}
