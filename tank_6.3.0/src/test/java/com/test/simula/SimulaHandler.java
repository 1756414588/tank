package com.test.simula;

import com.game.pb.BasePb;
import com.game.util.LogUtil;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.socket.SocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.LengthFieldPrepender;
import io.netty.handler.codec.protobuf.ProtobufDecoder;
import io.netty.handler.codec.protobuf.ProtobufEncoder;
import io.netty.handler.timeout.IdleStateHandler;
import com.test.simula.handler.ISimulaHandler;
import com.test.simula.handler.SimulaMessageRegist;

import java.util.concurrent.TimeUnit;

/**
 * @author zhangdh
 * @ClassName: SimulaHandler
 * @Description: 模拟测试处理
 * @date 2017/5/12 18:18
 */
public class SimulaHandler extends ChannelInitializer<SocketChannel> {
    @Override
    protected void initChannel(SocketChannel ch) throws Exception {
        LogUtil.info("SimulaHandler initChannel:" + Thread.currentThread().getId());

        ChannelPipeline pipeLine = ch.pipeline();
        // pipeLine.addLast(trafficShapingHandler);
        pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
        pipeLine.addLast("frameEncoder", new LengthFieldPrepender(4));
        pipeLine.addLast("protobufEncoder", new ProtobufEncoder());

        pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 4, 0, 4));
        pipeLine.addLast("protobufDecoder", new ProtobufDecoder(BasePb.Base.getDefaultInstance(), SimulaClient.registry));
        pipeLine.addLast("protobufHandler", new SimulaHandler.MassageHandler());
    }

    class MassageHandler extends SimpleChannelInboundHandler<BasePb.Base> {
        @Override
        protected void channelRead0(ChannelHandlerContext ctx, BasePb.Base base) throws Exception {
            int cmd = base.getCmd();
            LogUtil.info("response cmd : " + cmd + " code :" + base.getCode());
            if (base.getCode() == 200 || base.getCode() == 0) {
                ISimulaHandler handler = SimulaMessageRegist.getCommand(cmd);
                if (handler == null) {
                    LogUtil.info(String.format("cmd :%d, handler not found", cmd));
                    return;
                }
                handler.doCommand(ctx, base);
            } else {
                LogUtil.info("");
            }
        }
    }
}
