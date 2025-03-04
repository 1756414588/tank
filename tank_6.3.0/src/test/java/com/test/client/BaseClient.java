package com.test.client;

import java.util.concurrent.ConcurrentLinkedQueue;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.atomic.AtomicInteger;

import com.game.pb.BasePb;
import com.game.pb.BasePb.Base;
import com.game.server.util.ChannelUtil;

import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelHandlerContext;
import io.netty.channel.ChannelInitializer;
import io.netty.channel.ChannelOption;
import io.netty.channel.ChannelPipeline;
import io.netty.channel.EventLoopGroup;
import io.netty.channel.SimpleChannelInboundHandler;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioSocketChannel;
import io.netty.handler.codec.LengthFieldBasedFrameDecoder;
import io.netty.handler.codec.LengthFieldPrepender;
import io.netty.handler.codec.protobuf.ProtobufDecoder;
import io.netty.handler.codec.protobuf.ProtobufEncoder;
import io.netty.handler.timeout.IdleStateHandler;

/**
 * @ClassName BaseClient.java
 * @Description 模拟游戏客户端
 * @author TanDonghai
 * @date 创建时间：2016年10月31日 下午1:32:21
 *
 */
public class BaseClient implements Runnable {
    public ChannelHandlerContext ctx;

    AtomicInteger maxMessage = new AtomicInteger(0);
    AtomicInteger maxConnect = new AtomicInteger(0);

    private String serverIp;
    private int port;

    public BaseClient(String serverIp, int port) {
        this.serverIp = serverIp;
        this.port = port;
    }

    // 记录当前是否正在连接服务器
    protected boolean connecting = true;

    // 服务器是否已连接成功
    protected boolean connected = false;

    @Override
    public void run() {

        EventLoopGroup group = new NioEventLoopGroup();
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

            while (connecting && tryConnectNum < 3) {
                try {
                    connect = b.connect(serverIp, port).sync();
                } catch (Exception e) {
                    tryConnectNum++;
                    ClientLogger.print("服务器没有连接上，等待5s后重连,次数: " + tryConnectNum);
                    Thread.sleep(5000L);
                    continue;
                }

                connecting = false;
                connected = true;
                ClientLogger.print("服务器已连接上");
                connect.awaitUninterruptibly();
                connect.channel().closeFuture().sync();
            }
            connecting = false;
        } catch (InterruptedException e) {
            e.printStackTrace();
        } finally {
            group.shutdownGracefully();
        }
    }

    /**
     * 向服务器发送消息
     * 
     * @param baseBuilder
     */
    public void sendMsgToServer(Base.Builder baseBuilder) {
        if (ctx != null && ctx.channel().isActive()) {
            Base msg = baseBuilder.build();
            ClientLogger.print("客户端发送消息：" + msg);

            ctx.writeAndFlush(msg);
        }
    }

    private class ClientChannelHandler extends ChannelInitializer<SocketChannel> {

        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            ClientLogger.print("ClientChannelHandler initChannel:" + Thread.currentThread().getId());

            ChannelPipeline pipeLine = ch.pipeline();
            pipeLine.addLast(new IdleStateHandler(360, 0, 0, TimeUnit.SECONDS));
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(4));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());

            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 4, 0, 4));
            pipeLine.addLast("protobufDecoder",
                    new ProtobufDecoder(BasePb.Base.getDefaultInstance(), Registry.registry));
            pipeLine.addLast("protobufHandler", new ClientMessageHandler(BaseClient.this));
        }

        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            ClientLogger.print("ClientChannelHandler channelUnregistered:" + Thread.currentThread().getId());
        }

        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            ClientLogger.print("ClientChannelHandler channelInactive:" + Thread.currentThread().getId());
        }

        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            super.exceptionCaught(ctx, cause);
            ClientLogger.print("ClientChannelHandler exceptionCaught:" + Thread.currentThread().getId());
            ctx.close();
        }

    }

    // 记录服务端返回到客户端的协议
    public final ConcurrentLinkedQueue<Base> queue = new ConcurrentLinkedQueue<Base>();

    /**
     * 收到服务器返回的消息时调用
     * 
     * @param ctx
     * @param msg
     */
    private void doCommand(ChannelHandlerContext ctx, Base msg) {
        maxMessage.incrementAndGet();
        // 打印接收到的协议
        ClientLogger.print(msg);
        receivedMessage(msg);
    }

    /**
     * 记录消息
     * 
     * @param message
     */
    private synchronized void receivedMessage(Base message) {
        queue.add(message);
        this.notifyAll();
    }

    /**
     * 按协议号获取服务端返回消息，在收到该协议号的消息之前等待一段时间，如果超过时间未收到协议，将返回null，如果不是对应的协议，将被丢弃
     * 
     * @param cmd 协议号
     * @param timeout 如果一直等不到服务端返回消息的超时时间（毫秒）
     * @return
     */
    public synchronized Base getMessage(Integer cmd, int timeout) {
        Base message = queue.poll();
        long start = System.currentTimeMillis();
        while (message == null || message.getCmd() != cmd) {
            try {
                if (queue.isEmpty()) {
                    // 每次最多等待1秒
                    this.wait(1000);
                }
                message = queue.poll();
                ClientLogger.print("收到服务端返回协议, message:" + message);

                // 如果超过超时时间，跳出循环
                if (System.currentTimeMillis() - start >= timeout) {
                    break;
                }
            } catch (InterruptedException e) {
                ClientLogger.error(e, "获取返回协议时异常:");
            }
        }
        ClientLogger.print("客户端应收到的协议:" + cmd + ", 实际返回协议:" + message);
        return message;
    }

    class ClientMessageHandler extends SimpleChannelInboundHandler<Base> {
        private BaseClient client;

        public ClientMessageHandler(BaseClient client) {
            this.client = client;
        }

        @Override
        protected void channelRead0(ChannelHandlerContext ctx, Base msg) throws Exception {
            // 接收到从服务器返回的协议
            client.doCommand(ctx, msg);
        }

        @Override
        public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
            super.channelRegistered(ctx);
            ClientLogger.print("MessageHandler channelRegistered");
        }

        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            ClientLogger.print("MessageHandler channelUnregistered");
        }

        @Override
        public void channelActive(ChannelHandlerContext ctx) throws Exception {
            super.channelActive(ctx);
            // 关联上下文
            BaseClient.this.ctx = ctx;

            ClientLogger.print("MessageHandler channelActive");
            int total = client.maxConnect.get();
            ClientLogger.print(ctx + " open, total " + total);

            Long index = ChannelUtil.createChannelId(ctx);
            ChannelUtil.setChannelId(ctx, index);
        }

        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            ClientLogger.print("MessageHandler channelInactive");
            int total = client.maxConnect.decrementAndGet();
            ClientLogger.print(ctx + " close, total " + total);
        }

        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            ClientLogger.error("MessageHandler exceptionCaught!" + cause);
            ctx.close();
        }
    }
}
