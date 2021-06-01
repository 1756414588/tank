package com.test.simula.handler.activity.actredbag;

import com.game.pb.BasePb;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.handler.ISimulaHandler;

/**
 * @author zhangdh
 * @ClassName: SendActRedBagRsHandler
 * @Description:
 * @date 2018-02-03 11:20
 */
public class SendActRedBagRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb5.SendActRedBagRs res = msg.getExtension(GamePb5.SendActRedBagRs.ext);
        CommonPb.Atom2 atom2 = res.getAtom2();
        if (atom2 != null) {
            LogUtil.info(String.format("红包ID :%d, 剩余数量 :%d", atom2.getId(), atom2.getCount()));
        }
        LogUtil.info("发出去的红包信息 ：" + res.getSummary());
    }
}
