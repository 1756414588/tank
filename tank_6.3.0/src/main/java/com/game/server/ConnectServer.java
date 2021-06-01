/**
 * @Title: ConnectServer.java
 * @Package com.game.server
 * @Description:
 * @author ZhangJun
 * @date 2015年7月29日 下午5:03:17
 * @version V1.0
 */
package com.game.server;

import com.alibaba.fastjson.JSON;
import com.game.common.FilterCmd;
import com.game.common.ServerSetting;
import com.game.constant.Constant;
import com.game.constant.GameError;
import com.game.pb.BasePb;
import com.game.pb.BasePb.Base;
import com.game.pb.GamePb1.BeginGameRq;
import com.game.server.executor.NonOrderedQueuePoolExecutor;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.util.ChannelUtil;
import com.game.server.work.RWork;
import com.game.server.work.WWork;
import com.game.util.DateHelper;
import com.game.util.LogUtil;
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

import java.net.InetSocketAddress;
import java.util.Date;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

/**
 * @author ZhangJun
 * @ClassName: ConnectServer
 * @Description: 连接服务器
 * @date 2015年7月29日 下午5:03:17
 */
public class ConnectServer extends Server {
    private EventLoopGroup bossGroup;
    private EventLoopGroup workerGroup;

    public GlobalTrafficShapingHandler trafficShapingHandler;

    ServerBootstrap bootstrap;
    public AtomicInteger maxMessage = new AtomicInteger(0);
    public AtomicInteger maxConnect = new AtomicInteger(0);
    public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    public OrderedQueuePoolExecutor recvExcutor = new OrderedQueuePoolExecutor("消息接收队列", 100, -1);
    public NonOrderedQueuePoolExecutor actionExcutor = new NonOrderedQueuePoolExecutor(500);

    /**
     * 最大连接数
     */
    public static int MAX_CONNECT = 20000;

    public ConnectServer() {
        super("ConnectServer");
    }

    /**
     * <p>
     * Title: stop
     * </p>
     * <p>
     * Description: 停止此服务器
     * </p>
     *
     * @see com.game.server.Server#stop()
     */
    @Override
    protected void stop() {
        // Auto-generated method stub
        bossGroup.shutdownGracefully();
        workerGroup.shutdownGracefully();
        recvExcutor.shutdown();
    }

    /**
     * <p>
     * Title: run
     * </p>
     * <p>
     * Description: 此线程run方法 此方法会启动netty服务端监听
     * </p>
     *
     * @see com.game.server.Server#run()
     */
    @Override
    public void run() {
        super.addHook();
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
        // bootstrap.childOption(ChannelOption.ALLOCATOR, new
        // PooledByteBufAllocator(false));
        // bootstrap.childOption(ChannelOption.SO_RCVBUF, 1048576);
        // bootstrap.childOption(ChannelOption.SO_SNDBUF, 1048576);

        ChannelFuture f;
        try {
            // 绑定端口，同步等待成功
            f = bootstrap.bind(Integer.parseInt(GameServer.ac.getBean(ServerSetting.class).getClientPort())).sync();
            // 等待服务端监听端口关闭
            f.channel().closeFuture().sync();

        } catch (InterruptedException e) {
            LogUtil.error("服务器启动绑定端口异常", e);
        }
    }

    /**
     * @author
     * @ClassName: ConnectChannelHandler
     * @Description: 连接处理器
     * @date
     */
    private class ConnectChannelHandler extends ChannelInitializer<SocketChannel> {

        /**
         * <p>
         * Title: initChannel
         * </p>
         * <p>
         * Description: 初始化连接的方法实现 初始化连接时会加入
         * 1. trafficShapingHandler流量控制线程
         * 2. IdleStateHandler心跳检测线程
         * 3. LengthFieldPrepender编码器
         * 4. ProtobufEncoder编码器
         * 5.LengthFieldBasedFrameDecoder解码器
         * 6.ProtobufDecoder解码器
         * 7. MessageHandler消息处理器
         * </p>
         *
         * @param ch
         * @throws Exception
         * @see io.netty.channel.ChannelInitializer#initChannel(io.netty.channel.Channel)
         */
        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            LogUtil.channel("ConnectChannelHandler initChannel:" + Thread.currentThread().getId());

            ChannelPipeline pipeLine = ch.pipeline();
            pipeLine.addLast(trafficShapingHandler);
            pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
            pipeLine.addLast(new HeartbeatHandler());
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(4));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());

            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 4, 0, 4));
            pipeLine.addLast("protobufDecoder", new ProtobufDecoder(BasePb.Base.getDefaultInstance(),
                    GameServer.registry));
            pipeLine.addLast("protobufHandler", new MessageHandler(ConnectServer.this));
        }

        /**
         * <p>Title: channelUnregistered</p>
         * <p>Description: 未注册的连接处理  加入日志记录线程号</p>
         *
         * @param ctx
         * @throws Exception
         * @see io.netty.channel.ChannelInboundHandlerAdapter#channelUnregistered(io.netty.channel.ChannelHandlerContext)
         */
        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            LogUtil.channel("ConnectChannelHandler channelUnregistered:" + Thread.currentThread().getId());
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
            LogUtil.channel("ConnectChannelHandler channelInactive:" + Thread.currentThread().getId());
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
            LogUtil.channel("ConnectChannelHandler exceptionCaught:" + Thread.currentThread().getId());
            ctx.close();
        }
    }

    /**
     * <p>Title: getGameType</p>
     * <p>Description:服务器类型 </p>
     *
     * @return
     * @see com.game.server.Server#getGameType()
     */
    @Override
    String getGameType() {
        return "connect";
    }

    /**
     * @param ctx 连接上下文
     * @param msg 消息
     *            void
     * @Title: doCommand
     * @Description: 获得客户端消息后加入消息处理队列
     */
    public void doCommand(ChannelHandlerContext ctx, Base msg) {
        maxMessage.incrementAndGet();
        Long roleId = ChannelUtil.getRoleId(ctx);
        int cmd = msg.getCmd();
        if (!FilterCmd.inOutFilterPrint(cmd) && roleId != null) {
            LogUtil.c2sReqMessage(msg, roleId);
        }
        if (cmd != BeginGameRq.EXT_FIELD_NUMBER && roleId == 0L) {
            ChannelUtil.closeChannel(ctx, "没有发送beginGame消息");
            return;
        }
        Long id = ChannelUtil.getChannelId(ctx);
        recvExcutor.addTask(id, new RWork(ctx, msg));
    }
}

/**
 * @author
 * @ClassName: HeartbeatHandler
 * @Description: 服务端如果长时间没有接受到客户端的信息，即IdleState.READER_IDLE被触发，则关闭当前的channel。
 * @date 2017年11月14日 上午11:43:41
 */
class HeartbeatHandler extends ChannelDuplexHandler {
    /**
     * <p>Title: userEventTriggered</p>
     * <p>Description: 心跳触发事件</p>
     *
     * @param ctx
     * @param evt
     * @throws Exception
     * @see io.netty.channel.ChannelInboundHandlerAdapter#userEventTriggered(io.netty.channel.ChannelHandlerContext, java.lang.Object)
     */
    @Override
    public void userEventTriggered(ChannelHandlerContext ctx, Object evt) throws Exception {
        super.userEventTriggered(ctx, evt);
        if (evt instanceof IdleStateEvent) {
            IdleStateEvent e = (IdleStateEvent) evt;
            if (e.state() == IdleState.READER_IDLE) {
                LogUtil.channel("HeartbeatHandler trigger READER_IDLE");
                ctx.close();
            }
        }
    }
}

/**
 * @author
 * @ClassName: MessageHandler
 * @Description: 处理连接服务器消息的消息处理器
 * @date 2017年11月14日 下午5:25:53
 */
class MessageHandler extends SimpleChannelInboundHandler<Base> {
    private ConnectServer server;

    public MessageHandler(ConnectServer server) {
        this.server = server;
    }

    /**
     * <p>Title: channelRead0</p>
     * <p>Description: 收到客户端消息时的读取方法  </p>
     *
     * @param ctx
     * @param msg
     * @throws Exception
     * @see io.netty.channel.SimpleChannelInboundHandler#channelRead0(io.netty.channel.ChannelHandlerContext, java.lang.Object)
     */
    @Override
    protected void channelRead0(ChannelHandlerContext ctx, Base msg) throws Exception {
        if (!checkAndSendServerMainteError(ctx)) {
            ChannelUtil.closeChannel(ctx, String.format("server is open :%b, mainte finish", GameServer.MAINTE_SERVER_OPEN));
            return;
        }
        server.doCommand(ctx, msg);
    }

    /**
     * <p>Title: channelRegistered</p>
     * <p>Description: 注册连接</p>
     *
     * @param ctx
     * @throws Exception
     * @see io.netty.channel.ChannelInboundHandlerAdapter#channelRegistered(io.netty.channel.ChannelHandlerContext)
     */
    @Override
    public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
        super.channelRegistered(ctx);
        LogUtil.channel("MessageHandler channelRegistered");
    }

    /**
     * <p>Title: channelUnregistered</p>
     * <p>Description: 未注册连接的处理</p>
     *
     * @param ctx
     * @throws Exception
     * @see io.netty.channel.ChannelInboundHandlerAdapter#channelUnregistered(io.netty.channel.ChannelHandlerContext)
     */
    @Override
    public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
        super.channelUnregistered(ctx);
        LogUtil.channel("MessageHandler channelUnregistered");
    }

    /**
     * <p>Title: channelActive</p>
     * <p>Description: 连接激活时触发，会判断连接数，超过最大连接数时无法连入</p>
     *
     * @param ctx
     * @throws Exception
     * @see io.netty.channel.ChannelInboundHandlerAdapter#channelActive(io.netty.channel.ChannelHandlerContext)
     */
    @Override
    public void channelActive(ChannelHandlerContext ctx) throws Exception {
        super.channelActive(ctx);
        LogUtil.channel("MessageHandler channelActive");
        int total = server.maxConnect.get();
        LogUtil.channel(ctx + " open, total " + total);

        if (total > ConnectServer.MAX_CONNECT) {
            ChannelUtil.closeChannel(ctx, "连接数过多(" + total + ")");
            return;
        } else {
            if (!checkAndSendServerMainteError(ctx)) {
                ChannelUtil.closeChannel(ctx, String.format("server is open :%b, mainte finish ", GameServer.MAINTE_SERVER_OPEN));
                return;
            }
            server.maxConnect.incrementAndGet();
            ChannelUtil.setHeartTime(ctx, System.currentTimeMillis());
        }

        Long index = ChannelUtil.createChannelId(ctx);
        ChannelUtil.setChannelId(ctx, index);
        ChannelUtil.setRoleId(ctx, 0L);

        GameServer.getInstance().userChannels.put(index, ctx);
        LogUtil.channel("session max create:" + server.maxConnect.get());
    }

    /**
     * <p>Title: channelInactive</p>
     * <p>Description: 连接失效时触发，日志会打印当前客户端连接数,并且注销该玩家在线状态</p>
     *
     * @param ctx
     * @throws Exception
     * @see io.netty.channel.ChannelInboundHandlerAdapter#channelInactive(io.netty.channel.ChannelHandlerContext)
     */
    @Override
    public void channelInactive(ChannelHandlerContext ctx) throws Exception {
        super.channelInactive(ctx);
        LogUtil.channel("MessageHandler channelInactive");
        int total = server.maxConnect.decrementAndGet();
        LogUtil.channel(ctx + " close, total " + total);
        Long roleId = ChannelUtil.getRoleId(ctx);
        GameServer.getInstance().userChannels.remove(ChannelUtil.createChannelId(ctx));
        GameServer.getInstance().playerExit(ctx, roleId != null ? roleId : 0);
    }


    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
        LogUtil.channel("MessageHandler exceptionCaught!", cause);
        ctx.close();
    }

    private boolean checkAndSendServerMainteError(ChannelHandlerContext ctx) {
        if (!GameServer.MAINTE_SERVER_OPEN) {
            InetSocketAddress address = (InetSocketAddress) ctx.channel().remoteAddress();
            String ip = address.getAddress().getHostAddress();
            if (Constant.WHITE_IPS.size() > 0 && !Constant.WHITE_IPS.contains(ip)) {
                LogUtil.error("服务器未对外开放 ip={},white_ips={}", ip, JSON.toJSONString(Constant.WHITE_IPS));
                ctx.close();
                return false;
            }
        }
        return true;
    }

}
