package com.game.server.timer;

import com.game.server.ICommand;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author zc
 * @ClassName:CloseConnectTimer
 * @Description: 关闭连接
 * @date 2017年10月11日
 */
public class CloseConnectTimer implements ICommand {
    private ChannelHandlerContext ctx;

    public CloseConnectTimer(ChannelHandlerContext ctx) {
        //super(1, TimeHelper.SECOND_MS);
        this.ctx = ctx;
    }

    @Override
    public void action() {
        if (ctx != null) {
            ctx.close();
        }
    }
}
