/**
 * @Title: WWork.java
 * @Package com.game.server.work
 * @Description:
 * @author ZhangJun
 * @date 2015年8月3日 下午6:14:52
 * @version V1.0
 */
package com.game.server.work;

import com.game.pb.BasePb.Base;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;

/**
 * @ClassName: WWork
 * @Description: 向跨服服务器发送消息的指令
 * @author ZhangJun
 * @date 2015年8月3日 下午6:14:52
 *
 */
public class WWork extends AbstractWork {
    private ChannelHandlerContext ctx;
    private Base msg;

    public WWork(ChannelHandlerContext ctx, Base msg) {
        this.ctx = ctx;
        this.msg = msg;
    }

    /**
     *
     * <p>Title: run</p>
     * <p>Description: 执行任务</p>
     * @see java.lang.Runnable#run()
     */
    @Override
    public void run() {
        try {
            ctx.writeAndFlush(msg);
        } catch (Exception e) {
            LogUtil.error("向客服端写入协议数据出错", e);
        }
    }
}
