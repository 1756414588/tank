package com.test.simula.handler.activity.actredbag;

import com.game.pb.BasePb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;

/**
 * @author zhangdh
 * @ClassName: GetActRedBagInfoRsHandler
 * @Description:
 * @date 2018-02-01 17:31
 */
public class GetActRedBagInfoRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.GetActRedBagInfoRs res = msg.getExtension(GamePb5.GetActRedBagInfoRs.ext);
        LogUtil.info("当前活动ID ： " + res.getActivityId());
        LogUtil.info("当前充值金额 ：" + res.getMoney());
        LogUtil.info("已经领取过的阶段 : " + Arrays.toString(res.getStageList().toArray()));
        LogUtil.info("当前拥有的红包道具 ：" + Arrays.toString(res.getPropList().toArray()));
    }
}
