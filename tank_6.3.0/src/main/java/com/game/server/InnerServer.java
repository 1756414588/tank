/**
 * @Title: ConnectServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午5:03:17
 * @version V1.0
 */
package com.game.server;

import com.game.common.FilterCmd;
import com.game.common.ServerSetting;
import com.game.pb.BasePb;
import com.game.pb.BasePb.Base;
import com.game.pb.CrossGamePb.CCGameServerRegRq;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.util.ChannelUtil;
import com.game.server.work.IRWork;
import com.game.util.LogHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
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


/**
 * @author
 * @ClassName: InnerServer
 * @Description: InnerServer服务器 用来跟跨服服务器通信
 * @date 2017年11月18日 上午11:02:37
 */
public class InnerServer extends Server {
    public ChannelHandlerContext innerCtx;

    AtomicInteger maxMessage = new AtomicInteger(0);
    AtomicInteger maxConnect = new AtomicInteger(0);

    public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    public OrderedQueuePoolExecutor recvExcutor = new OrderedQueuePoolExecutor("消息接收队列", 100, -1);

    private String crossIp;
    private int port;

    public InnerServer(String crossIp, int port) {
        super("InnerServer");
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
            // 通过NoDelay禁用Nagle,使消息立即发出去，不用等待到一定的数据量才发出去
            b.option(ChannelOption.TCP_NODELAY, true);
            b.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
            b.option(ChannelOption.SO_KEEPALIVE, true);
            b.option(ChannelOption.SO_BACKLOG, 1024);
            b.handler(new ClientChannelHandler());


            ChannelFuture connect = null;
            // 尝试连接的次数
            int tryConnectNum = 0;

            while (flag && tryConnectNum < 3) {
                try {
                    connect = b.connect(crossIp, port).sync();
                } catch (Exception e) {
                    tryConnectNum++;
                    LogUtil.crossInfo("跨服服务器没有连接上，等待5s,次数: " + tryConnectNum);
                    Thread.sleep(5000L);
                    continue;
                }
                flag = false;
                LogUtil.crossInfo("跨服服务已连接上");
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
    private class ClientChannelHandler extends ChannelInitializer<SocketChannel> {

        /**
         * <p>Title: initChannel</p>
         * <p>Description:         * Description: 初始化连接的方法实现 初始化连接时会加入
         * 1. trafficShapingHandler流量控制线程
         * 2. IdleStateHandler心跳检测线程
         * 3. LengthFieldPrepender编码器
         * 4. ProtobufEncoder编码器
         * 5.LengthFieldBasedFrameDecoder解码器
         * 6.ProtobufDecoder解码器
         * 7. InnerMessageHandler消息处理器 </p>
         *
         * @param ch
         * @throws Exception
         * @see io.netty.channel.ChannelInitializer#initChannel(io.netty.channel.Channel)
         */
        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            LogUtil.crossInfo("ClientChannelHandler initChannel:" + Thread.currentThread().getId());

            ChannelPipeline pipeLine = ch.pipeline();
            pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
            pipeLine.addLast(new HeartbeatHandler());
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(2));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());

            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 2, 0, 2));
            pipeLine.addLast("protobufDecoder", new ProtobufDecoder(BasePb.Base.getDefaultInstance(), GameServer.registry));
            pipeLine.addLast("protobufHandler", new InnerMessageHandler(InnerServer.this));
        }

        /**
         * <p>Title: channelUnregistered</p>
         * <p>Description:  未注册的连接处理  加入日志记录线程号</p>
         *
         * @param ctx
         * @throws Exception
         * @see io.netty.channel.ChannelInboundHandlerAdapter#channelUnregistered(io.netty.channel.ChannelHandlerContext)
         */
        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            LogUtil.crossInfo("InnnerChannelHandler channelUnregistered:" + Thread.currentThread().getId());
        }

        /**
         * <p>Title: channelInactive</p>
         * <p>Description: 当连接失效时触发，加入日志记录线程号</p>
         *
         * @param ctx
         * @throws Exception
         * @see io.netty.channel.ChannelInboundHandlerAdapter#channelInactive(io.netty.channel.ChannelHandlerContext)
         */
        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            LogUtil.crossInfo("InnnerChannelHandler channelInactive:" + Thread.currentThread().getId());
        }

        /**
         * <p>Title: exceptionCaught</p>
         * <p>Description:  处理器遇到异常时记录日志并关闭连接</p>
         *
         * @param ctx
         * @param cause
         * @throws Exception
         * @see io.netty.channel.ChannelInitializer#exceptionCaught(io.netty.channel.ChannelHandlerContext, java.lang.Throwable)
         */
        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            super.exceptionCaught(ctx, cause);
            LogUtil.crossInfo("InnnerChannelHandler exceptionCaught:" + Thread.currentThread().getId());
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

    /**
     * @author
     * @ClassName: InnerMessageHandler
     * @Description: 处理跨服服务器消息的消息处理器  类同于MessageHandler
     */
    class InnerMessageHandler extends SimpleChannelInboundHandler<Base> {
        private InnerServer server;

        public InnerMessageHandler(InnerServer server) {
            this.server = server;
        }

        @Override
        protected void channelRead0(ChannelHandlerContext ctx, Base msg) throws Exception {
            server.doCommand(ctx, msg);
        }

        @Override
        public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
            super.channelRegistered(ctx);
            LogUtil.crossInfo("MessageHandler channelRegistered");
        }

        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            LogUtil.crossInfo("MessageHandler channelUnregistered");
        }

        @Override
        public void channelActive(ChannelHandlerContext ctx) throws Exception {
            super.channelActive(ctx);

            // 关联上下文
            innerCtx = ctx;

            LogUtil.crossInfo("MessageHandler channelActive");
            int total = server.maxConnect.get();
            LogUtil.crossInfo(ctx + " open, total " + total);

            Long index = ChannelUtil.createChannelId(ctx);
            ChannelUtil.setChannelId(ctx, index);

            // 发送注册消息到cross服务器
            sendGameServerRegMsgToCrossServer();
        }

        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            LogUtil.crossInfo("MessageHandler channelInactive");
            int total = server.maxConnect.decrementAndGet();
            LogUtil.crossInfo(ctx + " close, total " + total);

        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            LogUtil.crossInfo("MessageHandler exceptionCaught!" + cause);
            ctx.close();
        }
    }

    /**
     * 发送注册消息到cross服务器
     */
    public void sendGameServerRegMsgToCrossServer() {
        CCGameServerRegRq.Builder builder = CCGameServerRegRq.newBuilder();
        builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
        builder.setServerName(GameServer.ac.getBean(ServerSetting.class).getServerName());

        Base.Builder baseBuilder = PbHelper.createRqBase(CCGameServerRegRq.EXT_FIELD_NUMBER, null,
                CCGameServerRegRq.ext, builder.build());
        GameServer.getInstance().sendMsgToCross(baseBuilder);
    }

    @Override
    String getGameType() {
        return "inner";
    }

    @Override
    protected void stop() {
        if (group != null) {
            if (!group.isShutdown()) {
                group.shutdownGracefully();
            }
        }
        if(!sendExcutor.isShutdown()){
            sendExcutor.shutdown();
        }
        if (!recvExcutor.isShutdown()) {
            recvExcutor.shutdown();
        }
    }
}
