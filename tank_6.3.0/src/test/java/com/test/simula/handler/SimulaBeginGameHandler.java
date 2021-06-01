package com.test.simula.handler;

import com.game.pb.BasePb;
import com.game.pb.GamePb1;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.SimulaAccout;
import com.test.simula.SimulaRequestFactory;

/**
 * @author zhangdh
 * @ClassName: SimulaBeginGameHandler
 * @Description:
 * @date 2017/5/12 18:38
 */
public class SimulaBeginGameHandler implements ISimulaHandler {

    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb1.BeginGameRs rs = msg.getExtension(GamePb1.BeginGameRs.ext);
        SimulaAccout.ctx = ctx;
        LogUtil.info(rs.getState() == 1 ? "角色未创建" : "角色已创建");
        if (rs.getState() == 2) {
            ctx.writeAndFlush(SimulaRequestFactory.createRoleLoginRq());
        } else {
            System.exit(0);
        }
    }
}
