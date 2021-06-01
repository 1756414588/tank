package com.test.simula.handler;

import com.game.pb.BasePb;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author zhangdh
 * @ClassName: ISimulaHandler
 * @Description: 模拟器客户端处理消息接口
 * @date 2017/5/12 19:03
 */
public interface ISimulaHandler {

    public void doCommand(ChannelHandlerContext ctx, BasePb.Base msg);
}
