package com.test.simula.handler;

import com.game.pb.BasePb;
import com.game.pb.GamePb1;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;


/**
 * @author zhangdh
 * @ClassName: SimulaGetLordRsHandler
 * @Description:
 * @date 2017/5/12 19:26
 */
public class SimulaGetLordRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb1.GetLordRs rs = msg.getExtension(GamePb1.GetLordRs.ext);
        LogUtil.info("玩家昵称 : " + rs.getNick());
        LogUtil.info("玩家等级 : " + rs.getLevel());
        LogUtil.info("玩家金币 : " + rs.getGold());
        LogUtil.info("当前体力 : " + rs.getPower());
    }
}
