package com.test.simula.handler.activity.monopoly;

import com.game.pb.BasePb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;

/**
 * @author zhangdh
 * @ClassName: GetMonopolyRsHandler
 * @Description:
 * @date 2017-12-02 15:47
 */
public class GetMonopolyRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.GetMonopolyInfoRs res = msg.getExtension(GamePb5.GetMonopolyInfoRs.ext);
        LogUtil.info("当前事件列表信息 ：" + Arrays.toString(res.getEventList().toArray()));
        LogUtil.info("玩家当前位置     : " + res.getPos());
        LogUtil.info("玩家当前剩余精力  ：" + res.getEnergy());
        LogUtil.info("已经领取过的完成奖励 : " + Arrays.toString(res.getDrawRoundList().toArray()));

    }
}
