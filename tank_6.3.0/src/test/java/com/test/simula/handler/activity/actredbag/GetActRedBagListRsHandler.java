package com.test.simula.handler.activity.actredbag;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

/**
 * @author zhangdh
 * @ClassName: GetActRedBagListRsHandler
 * @Description:
 * @date 2018-02-01 18:59
 */
public class GetActRedBagListRsHandler implements ISimulaHandler {

    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.GetActRedBagListRs res = msg.getExtension(GamePb5.GetActRedBagListRs.ext);
        for (CommonPb.RedBagSummary summary : res.getRedBagList()) {
            LogUtil.info(String.format("红包ID :%d, 所属玩家 :%s, 剩余可领取次数 :%d", summary.getUid(), summary.getLordName(), summary.getRemainGrab()));
        }
    }
}
