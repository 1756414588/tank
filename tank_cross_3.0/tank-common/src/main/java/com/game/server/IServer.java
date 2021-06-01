package com.game.server;

import com.game.pb.BasePb.Base;
import io.netty.channel.ChannelHandlerContext;

/**
 * @author ZhangJun
 * @date 2015年7月29日 下午3:07:08
 */
public interface IServer {
    /**
     * Method: doCommand @Description: 处理消息
     *
     * @param
     * @param msg
     * @return void
     * @throws
     */
    public abstract void doCommand(ChannelHandlerContext ctx, Base msg);

    /**
     * Method: channelActive @Description: channel 打开
     *
     * @param ctx
     * @return void
     * @throws
     */
    public void channelActive(ChannelHandlerContext ctx);

    /**
     * Method: channelInactive @Description: channel 关闭
     *
     * @param ctx
     * @return void
     * @throws
     */
    public void channelInactive(ChannelHandlerContext ctx);
}
