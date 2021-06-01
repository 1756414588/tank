package com.test.simula.handler.activity.medalofhonor;

import com.game.pb.BasePb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

import java.util.Arrays;
import java.util.List;

/**
 * @author zhangdh
 * @ClassName: GetActMedalofhonorInfoRsHandler
 * @Description:
 * @date 2017-11-03 13:49
 */
public class GetActMedalofhonorInfoRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.GetActMedalofhonorInfoRs res = msg.getExtension(GamePb5.GetActMedalofhonorInfoRs.ext);
        int medalHonor = res.getMedalHonor();//荣誉勋章数量
        int searchCount = res.getCount();//搜索次数
        List<Integer> tarList = res.getTargetIdList();
        LogUtil.info(String.format("荣誉勋章数量：%d, 今日搜索次数：%d, 宝箱列表：%s", medalHonor, searchCount, Arrays.toString(tarList.toArray())));
    }
}
