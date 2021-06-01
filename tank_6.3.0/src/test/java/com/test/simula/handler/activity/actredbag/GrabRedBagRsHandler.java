package com.test.simula.handler.activity.actredbag;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;

/**
 * @author zhangdh
 * @ClassName: GrabRedBagRsHandler
 * @Description:
 * @date 2018-02-01 19:03
 */
public class GrabRedBagRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.GrabRedBagRs res = msg.getExtension(GamePb5.GrabRedBagRs.ext);
        int grabMoney = res.getGrabMoney();
        if (grabMoney > 0) {
            LogUtil.info("抢到红包金额 :" + grabMoney);
        } else {
            CommonPb.ActRedBag pb = res.getRedBag();
            LogUtil.info(String.format("uid :%d, 红包所属玩家 :%s, 剩余金额/总金额 (%d/%d), 剩余个数/总个数(%d,%d)",
                    pb.getUid(), pb.getLordName(), pb.getRemainMoney(), pb.getTotalMoney(), pb.getGrabCnt() - pb.getGrabList().size(), pb.getGrabCnt()));
            if (pb.getGrabList().isEmpty()) {
                LogUtil.info("当前红包没人抢啊!!!!!!!!!!");
            } else {
                LogUtil.info("抢红包列表 :" + Arrays.toString(pb.getGrabList().toArray()));
            }
            LogUtil.info("----------------------------------");
        }
    }
}
