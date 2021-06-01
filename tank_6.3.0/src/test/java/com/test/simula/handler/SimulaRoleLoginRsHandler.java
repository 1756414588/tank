package com.test.simula.handler;

import com.game.pb.BasePb;
import com.game.pb.GamePb1;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import com.test.simula.SimulaRequestFactory;

/**
 * @author zhangdh
 * @ClassName: SimulaRoleLoginRs
 * @Description: 登录角色
 * @date 2017/5/12 19:22
 */
public class SimulaRoleLoginRsHandler implements ISimulaHandler {
    @Override
    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg) {
        GamePb1.RoleLoginRs rs = msg.getExtension(GamePb1.RoleLoginRs.ext);
        LogUtil.info("rs.getState():"+rs.getState());
        LogUtil.info("红蓝大战是否已报名 : "+rs.getDrill());
        LogUtil.info("要塞战是否已开启 : "+rs.getFortress());
        ctx.writeAndFlush(SimulaRequestFactory.createGetLordRq());
    }
}
