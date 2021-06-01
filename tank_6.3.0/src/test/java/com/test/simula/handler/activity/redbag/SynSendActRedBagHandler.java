package com.test.simula.handler.activity.redbag;

import com.game.pb.BasePb;
import com.game.pb.GamePb6;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

/**
 * @author zhangdh
 * @ClassName: SynSendActRedBagHandler
 * @Description:
 * @date 2018-02-05 19:51
 */
public class SynSendActRedBagHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb6.SynSendActRedBagRq stc = msg.getExtension(GamePb6.SynSendActRedBagRq.ext);
        LogUtil.info("有人发红包啦!!! " + stc.getChat());
    }
}
