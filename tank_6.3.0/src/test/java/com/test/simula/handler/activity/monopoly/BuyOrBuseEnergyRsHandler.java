package com.test.simula.handler.activity.monopoly;

import com.game.pb.BasePb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

/**
 * @author zhangdh
 * @ClassName: BuyOrBuseEnergyRsHandler
 * @Description:
 * @date 2017-12-02 17:06
 */
public class BuyOrBuseEnergyRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.BuyOrUseEnergyRs res = msg.getExtension(GamePb5.BuyOrUseEnergyRs.ext);
        LogUtil.info("当前剩余金币 : " + res.getGold());
        LogUtil.info("大富翁剩余精力 ：" + res.getEnergy());
    }
}
