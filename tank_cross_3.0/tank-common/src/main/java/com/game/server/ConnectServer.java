/**
 * @Title: ConnectServer.java @Package com.game.server @Description: TODO
 * @author ZhangJun
 * @date 2015年7月29日 下午5:03:17
 * @version V1.0
 */
package com.game.server;

import com.game.common.ServerSetting;
import com.game.pb.BasePb.Base;
import com.game.server.executor.NonOrderedQueuePoolExecutor;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.util.ChannelUtil;
import com.game.server.work.RWork;
import com.game.util.LogUtil;
import com.google.common.util.concurrent.AbstractIdleService;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.LengthFieldPrepender;
import io.netty.handler.codec.protobuf.ProtobufDecoder;
import io.netty.handler.codec.protobuf.ProtobufEncoder;
import io.netty.handler.timeout.IdleState;
import io.netty.handler.timeout.IdleStateEvent;
import io.netty.handler.timeout.IdleStateHandler;
import io.netty.handler.traffic.GlobalTrafficShapingHandler;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

public class ConnectServer extends AbstractIdleService {
    private EventLoopGroup bossGroup;
    private EventLoopGroup workerGroup;
    public GlobalTrafficShapingHandler trafficShapingHandler;
    ServerBootstrap bootstrap;

    public AtomicInteger maxMessage = new AtomicInteger(0);
    public AtomicInteger maxConnect = new AtomicInteger(0);
    public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    public OrderedQueuePoolExecutor recvExcutor = new OrderedQueuePoolExecutor("消息接收队列", 100, -1);
    public NonOrderedQueuePoolExecutor actionExcutor = new NonOrderedQueuePoolExecutor(500);

    public static int MAX_CONNECT = 2000;


    @Override
    public void shutDown() throws Exception {
        bossGroup.shutdownGracefully();
        workerGroup.shutdownGracefully();
        recvExcutor.shutdown();
    }

    @Override
    public void startUp() throws Exception {
        // 定义两个工作线程 bossGroup workerGroup 用于管理channel连接
        bossGroup = new NioEventLoopGroup();
        workerGroup = new NioEventLoopGroup();
        bootstrap = new ServerBootstrap();
        trafficShapingHandler = new GlobalTrafficShapingHandler(workerGroup, 5000L);
        bootstrap.group(bossGroup, workerGroup);
        bootstrap.channel(NioServerSocketChannel.class);
        bootstrap.option(ChannelOption.SO_BACKLOG, 1024);
        // 通过NoDelay禁用Nagle,使消息立即发出去，不用等待到一定的数据量才发出去
        bootstrap.option(ChannelOption.TCP_NODELAY, true);
        bootstrap.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
        bootstrap.childHandler(new ConnectChannelHandler());
        bootstrap.childOption(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
        bootstrap.childOption(ChannelOption.SO_KEEPALIVE, true);
        bootstrap.childOption(ChannelOption.SO_REUSEADDR, true);
        // 绑定端口，同步等待成功
        bootstrap.bind(Integer.parseInt(GameContext.getAc().getBean(ServerSetting.class).getClientPort())).sync();
        // 等待服务端监听端口关闭
//        f.channel().closeFuture().sync();
        LogUtil.info("TCP服务 socket Port {}", GameContext.getAc().getBean(ServerSetting.class).getClientPort());
    }

    private class ConnectChannelHandler extends ChannelInitializer<SocketChannel> {


        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            ChannelPipeline pipeLine = ch.pipeline();
            pipeLine.addLast(trafficShapingHandler);
            pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
            pipeLine.addLast(new HeartbeatHandler());
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(2));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());

            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 2, 0, 2));
            pipeLine.addLast(
                    "protobufDecoder",
                    new ProtobufDecoder(Base.getDefaultInstance(), GameContext.registry));
            pipeLine.addLast("protobufHandler", new MessageHandler(ConnectServer.this));
        }

        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);

        }

        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);

        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            super.exceptionCaught(ctx, cause);

        }
    }


    public void doCommand(ChannelHandlerContext ctx, Base msg) {
        maxMessage.incrementAndGet();
        Long id = ChannelUtil.getChannelId(ctx);
        LogUtil.s2sMessage(msg);
        recvExcutor.addTask(id, new RWork(ctx, msg));
    }
}

class HeartbeatHandler extends ChannelDuplexHandler {
    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception {
        super.userEventTriggered(ctx, evt);
        if (evt instanceof IdleStateEvent) {
            IdleStateEvent e = (IdleStateEvent) evt;
            if (e.state() == IdleState.READER_IDLE) {
                ctx.close();
            }
        }
    }
}

class MessageHandler extends SimpleChannelInboundHandler<Base> {
    private ConnectServer server;

    public MessageHandler(ConnectServer server) {
        this.server = server;
    }

    @Override
    protected void channelRead0(ChannelHandlerContext ctx, Base msg) throws Exception {
        server.doCommand(ctx, msg);
    }

    @Override
    public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
        super.channelRegistered(ctx);
    }

    @Override
    public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
        super.channelUnregistered(ctx);
    }

    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        super.channelActive(ctx);
        int total = server.maxConnect.get();

        if (total > ConnectServer.MAX_CONNECT) {
            ChannelUtil.closeChannel(ctx, "连接数过多(" + total + ")");
            return;
        } else {
            server.maxConnect.incrementAndGet();
            ChannelUtil.setHeartTime(ctx, System.currentTimeMillis());
        }

        Long index = ChannelUtil.createChannelId(ctx);
        ChannelUtil.setChannelId(ctx, index);

        GameContext.userChannels.put(index, ctx);
        //LogUtil.error("session max create:" + server.maxConnect.get());
    }

    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        super.channelInactive(ctx);
        int total = server.maxConnect.decrementAndGet();

        int serverId = ChannelUtil.getServerId(ctx);
        GameContext.gameServerMaps.get(serverId).setConect(false);
        GameContext.userChannels.remove(ChannelUtil.createChannelId(ctx));
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        ctx.close();
    }
}
