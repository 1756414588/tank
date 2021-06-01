package com.game.server;

import com.game.common.ServerSetting;
import com.game.pb.BasePb.Base;
import com.game.server.executor.NonOrderedQueuePoolExecutor;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.util.ChannelUtil;
import com.game.server.work.RWork;
import com.game.service.crossmin.SessionManager;
import com.game.service.teaminstance.CrossTeamService;
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

public class CrossMinConnectServer extends AbstractIdleService {
    private EventLoopGroup bossGroup;
    private EventLoopGroup workerGroup;
    public GlobalTrafficShapingHandler trafficShapingHandler;
    ServerBootstrap bootstrap;

    public AtomicInteger maxMessage = new AtomicInteger(0);
    public AtomicInteger maxConnect = new AtomicInteger(0);
    public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    public OrderedQueuePoolExecutor recvExcutor = new OrderedQueuePoolExecutor("消息接收队列", 100, -1);
    public NonOrderedQueuePoolExecutor actionExcutor = new NonOrderedQueuePoolExecutor(500);

    public static int MAX_CONNECT = 1000;


    @Override
    protected void shutDown() throws Exception {
        bossGroup.shutdownGracefully();
        workerGroup.shutdownGracefully();
        recvExcutor.shutdown();
    }

    @Override
    protected void startUp() throws Exception {
        bossGroup = new NioEventLoopGroup();
        workerGroup = new NioEventLoopGroup();
        bootstrap = new ServerBootstrap();
        trafficShapingHandler = new GlobalTrafficShapingHandler(workerGroup, 5000L);
        bootstrap.group(bossGroup, workerGroup);
        bootstrap.channel(NioServerSocketChannel.class);
        bootstrap.option(ChannelOption.SO_BACKLOG, 1024);
        bootstrap.option(ChannelOption.TCP_NODELAY, true);
        bootstrap.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
        bootstrap.childHandler(new ConnectChannelHandler());
        bootstrap.childOption(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
        bootstrap.childOption(ChannelOption.SO_KEEPALIVE, true);
        bootstrap.childOption(ChannelOption.SO_REUSEADDR, true);
        bootstrap.bind(Integer.parseInt(GameContext.getAc().getBean(ServerSetting.class).getClientPort())).sync();
        LogUtil.info("TCP服务 socket Port {}", GameContext.getAc().getBean(ServerSetting.class).getClientPort());
    }

    private class ConnectChannelHandler extends ChannelInitializer<SocketChannel> {


        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            ChannelPipeline pipeLine = ch.pipeline();
            pipeLine.addLast(trafficShapingHandler);
            pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
            pipeLine.addLast(new CrossMinHeartbeatHandler());
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(2));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());
            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 2, 0, 2));
            pipeLine.addLast("protobufDecoder", new ProtobufDecoder(Base.getDefaultInstance(), GameContext.registry));
            pipeLine.addLast("protobufHandler", new CrossMinMessageHandler(CrossMinConnectServer.this));
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

class CrossMinHeartbeatHandler extends ChannelDuplexHandler {
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

class CrossMinMessageHandler extends SimpleChannelInboundHandler<Base> {
    private CrossMinConnectServer server;

    public CrossMinMessageHandler(CrossMinConnectServer server) {
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

        if (total > CrossMinConnectServer.MAX_CONNECT) {
            ChannelUtil.closeChannel(ctx, "连接数过多(" + total + ")");
            return;
        } else {
            server.maxConnect.incrementAndGet();
            ChannelUtil.setHeartTime(ctx, System.currentTimeMillis());
        }
        Long index = ChannelUtil.createChannelId(ctx);
        ChannelUtil.setChannelId(ctx, index);
        //LogUtil.error("session max create:" + server.maxConnect.get());
    }

    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        super.channelInactive(ctx);
        int serverId = ChannelUtil.getServerId(ctx);
        GameContext.getAc().getBean(CrossTeamService.class).removeServerCrossPlayer(serverId);
        SessionManager.removeSession(serverId);
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        ctx.close();
    }
}
