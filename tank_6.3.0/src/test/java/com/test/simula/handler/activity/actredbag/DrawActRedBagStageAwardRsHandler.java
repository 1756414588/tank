package com.test.simula.handler.activity.actredbag;

import com.game.pb.BasePb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;

/**
 * @author zhangdh
 * @ClassName: DrawActRedBagStageAwardRsHandler
 * @Description:
 * @date 2018-02-01 18:53
 */
public class DrawActRedBagStageAwardRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.DrawActRedBagStageAwardRs res = msg.getExtension(GamePb5.DrawActRedBagStageAwardRs.ext);
        LogUtil.info("领取充值红包阶段奖励成功 : " + Arrays.toString(res.getAwardList().toArray()));
    }
}
