package com.test.simula.handler.activity.simple;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;
import java.util.List;

/**
 * @author zhangdh
 * @ClassName: GetActLotteryExploreRsHandler
 * @Description:
 * @date 2018-01-31 10:37
 */
public class GetActLotteryExploreRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.GetActLotteryExploreRs res = msg.getExtension(GamePb5.GetActLotteryExploreRs.ext);
        int score = res.getScore();
        LogUtil.info("当前积分 ：" + score);
        List<CommonPb.ActivityCond> list = res.getCondList();
        if (list != null && !list.isEmpty()) {
            for (CommonPb.ActivityCond cond : list) {
                LogUtil.info(String.format("keyId :%d, 活动进度 %d/%d, 奖励 :%s", cond.getKeyId(), score, cond.getCond(), Arrays.toString(cond.getAwardList().toArray())));
            }
        }
    }
}
