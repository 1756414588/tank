package com.game.server;

import com.game.common.FilterCmd;
import com.game.pb.BasePb.Base;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.util.ChannelUtil;
import com.game.server.work.IRWork;
import com.game.service.crossmin.CrossMinService;
import com.game.util.LogUtil;
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.LengthFieldPrepender;
import io.netty.handler.codec.protobuf.ProtobufDecoder;
import io.netty.handler.codec.protobuf.ProtobufEncoder;
import io.netty.handler.timeout.IdleStateHandler;

import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;


public class CrossMinInnerServer extends Server {
    public ChannelHandlerContext innerCtx;

    AtomicInteger maxMessage = new AtomicInteger(0);
    AtomicInteger maxConnect = new AtomicInteger(0);

    public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    public OrderedQueuePoolExecutor recvExcutor = new OrderedQueuePoolExecutor("消息接收队列", 100, -1);

    private String crossIp;
    private int port;

    public CrossMinInnerServer(String crossIp, int port) {
        super("CrossMinInnerServer");
        this.crossIp = crossIp;
        this.port = port;
    }

    volatile boolean flag = true;

    EventLoopGroup group = null;

    @Override
    public void run() {
        super.addHook();
        group = new NioEventLoopGroup();
        try {
            Bootstrap b = new Bootstrap();
            b.group(group).channel(NioSocketChannel.class);
            b.option(ChannelOption.TCP_NODELAY, true);
            b.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
            b.option(ChannelOption.SO_KEEPALIVE, true);
            b.option(ChannelOption.SO_BACKLOG, 1024);
            b.handler(new CrossMinClientChannelHandler());


            ChannelFuture connect = null;
            // 尝试连接的次数
            int tryConnectNum = 0;

            while (flag && tryConnectNum < 3) {
                try {
                    connect = b.connect(crossIp, port).sync();
                } catch (Exception e) {
                    tryConnectNum++;
                    LogUtil.info("CrossMinInnerServer 跨服服务器没有连接上，等待5s,次数: " + tryConnectNum);
                    Thread.sleep(5000L);
                    continue;
                }
                flag = false;
                LogUtil.info("CrossMinInnerServer 跨服服务已连接上");
                connect.awaitUninterruptibly();
                connect.channel().closeFuture().sync();

            }

        } catch (InterruptedException e) {
            LogUtil.error(e);
        } finally {
            group.shutdownGracefully();
        }
    }

    /**
     * @author
     * @ClassName: ConnectChannelHandler
     * @Description: 初始化连接处理器
     */
    private class CrossMinClientChannelHandler extends ChannelInitializer<SocketChannel> {


        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            ChannelPipeline pipeLine = ch.pipeline();
            pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
            pipeLine.addLast(new HeartbeatHandler());
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(2));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());
            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 2, 0, 2));
            pipeLine.addLast("protobufDecoder", new ProtobufDecoder(Base.getDefaultInstance(), GameServer.registry));
            pipeLine.addLast("protobufHandler", new CrsssMinInnerMessageHandler(CrossMinInnerServer.this));
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
            ctx.close();
        }

    }

    /**
     * @param ctx
     * @param msg void
     * @Title: doCommand
     * @Description: 获得跨服服消息后加入消息处理队列
     */
    public void doCommand(ChannelHandlerContext ctx, Base msg) {
        maxMessage.incrementAndGet();
        int cmd = msg.getCmd();
        if (!FilterCmd.inOutFilterPrint(cmd)) {
            LogUtil.s2sMessage(msg);
        }
        Long id = ChannelUtil.getChannelId(ctx);
        recvExcutor.addTask(id, new IRWork(ctx, msg));
    }


    class CrsssMinInnerMessageHandler extends SimpleChannelInboundHandler<Base> {
        private CrossMinInnerServer server;

        public CrsssMinInnerMessageHandler(CrossMinInnerServer server) {
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
            // 关联上下文
            innerCtx = ctx;
            LogUtil.crossInfo("MessageHandler channelActive");
            int total = server.maxConnect.get();
            LogUtil.error(ctx + " open, total " + total);
            Long index = ChannelUtil.createChannelId(ctx);
            ChannelUtil.setChannelId(ctx, index);
            CrossMinService.sendGameServerRegMsgToCrossServer("socket");
        }

        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            int total = server.maxConnect.decrementAndGet();
            LogUtil.error(ctx + " close, total " + total);


            CrossMinContext.setCrossMinSocket(false);
            CrossMinContext.setCrossMinRpc(false);
        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            ctx.close();
        }
    }


    @Override
    String getGameType() {
        return "CrossMinInnerServer";
    }

    @Override
    public void stop() {
        if (group != null) {
            if (!group.isShutdown()) {
                group.shutdownGracefully();
            }
        }
        if (!sendExcutor.isShutdown()) {
            sendExcutor.shutdown();
        }
        if (!recvExcutor.isShutdown()) {
            recvExcutor.shutdown();
        }
    }
}
