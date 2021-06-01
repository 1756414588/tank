
package com.game.server.work;

import com.game.pb.BasePb.Base;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author ZhangJun
 * @ClassName: WWork
 * @date 2015年8月3日 下午6:14:52
 */
public class WWork extends AbstractWork {
    private ChannelHandlerContext ctx;
    private Base msg;

    public WWork(ChannelHandlerContext ctx, Base msg) {
        this.ctx = ctx;
        this.msg = msg;
    }

    /**
     * Overriding: run
     */
    @Override
    public void run() {
        try {
            ctx.writeAndFlush(msg);
        } catch (Exception e) {
            LogUtil.error(e, e);
        }

    }
}
