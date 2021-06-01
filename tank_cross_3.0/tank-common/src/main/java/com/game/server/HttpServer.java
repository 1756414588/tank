package com.game.server;

import com.game.common.ServerSetting;
import com.game.message.handler.ServerHandler;
import com.game.message.pool.MessagePool;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.RegisterRq;
import com.game.server.executor.NonOrderedQueuePoolExecutor;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.work.HttpWork;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.google.common.util.concurrent.AbstractIdleService;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.*;

public class HttpServer extends AbstractIdleService {
    private EventLoopGroup bossGroup;
    private EventLoopGroup workerGroup;
    public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    private NonOrderedQueuePoolExecutor publicActionExcutor = new NonOrderedQueuePoolExecutor(500);

    private MessagePool messagePool;

    public String accountServerUrl = GameContext.getAc().getBean(ServerSetting.class).getAccountServerUrl();
    public String fixAccountServerUrl = null;

    public HttpServer(MessagePool messagePool) {
        this.messagePool = messagePool;
    }


    @Override
    public void shutDown() throws Exception {
        bossGroup.shutdownGracefully();
        workerGroup.shutdownGracefully();
    }

    @Override
    public void startUp() throws Exception {
        bossGroup = new NioEventLoopGroup();
        workerGroup = new NioEventLoopGroup();
        try {
            ServerBootstrap b = new ServerBootstrap();
            b.group(bossGroup, workerGroup).channel(NioServerSocketChannel.class).childHandler(new ChannelInitializer<SocketChannel>() {
                @Override
                public void initChannel(SocketChannel ch) throws Exception {
                    ch.pipeline().addLast(new HttpResponseEncoder());
                    ch.pipeline().addLast(new HttpRequestDecoder());
                    ch.pipeline().addLast(new HttpServerInboundHandler(HttpServer.this));
                }
            })
                    .option(ChannelOption.SO_BACKLOG, 128)
                    .childOption(ChannelOption.SO_KEEPALIVE, true);

            ChannelFuture f = b.bind(Integer.parseInt(GameContext.getAc().getBean(ServerSetting.class).getHttpPort())).sync();
            LogUtil.info("Http服务 Port {}", GameContext.getAc().getBean(ServerSetting.class).getHttpPort());
//            f.channel().closeFuture().sync();
        } catch (InterruptedException e) {
            LogUtil.error(e, e);
        }
    }

    public void sendPublicMsg(Base msg) {
        sendExcutor.execute(new HttpWork(this, msg));
    }

    public void sendPublicMsg(Base msg, int serverId) {
        if (fixAccountServerUrl == null) {
            fixAccountServerUrl = this.accountServerUrl + "?serverId=" + serverId;
        }
        sendExcutor.execute(new HttpWork(this, fixAccountServerUrl, msg));
    }

    /**
     * 发送消息到制定的http服务器
     *
     * @param url
     * @param msg
     */
    public void sendHttpMsg(String url, Base msg) {
        sendExcutor.execute(new HttpWork(this, url, msg));
    }

    public void registerGameToPublic() {
        RegisterRq.Builder builder = RegisterRq.newBuilder();
        builder.setServerId(GameContext.getAc().getBean(ServerSetting.class).getServerID());
        builder.setServerName(GameContext.getAc().getBean(ServerSetting.class).getServerName());
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(RegisterRq.EXT_FIELD_NUMBER);
        baseBuilder.setExtension(RegisterRq.ext, builder.build());

        Base msg = baseBuilder.build();
        sendPublicMsg(msg);
    }

    /**
     * Method: doPublicCommand @Description: 与帐号服之间的消息逻辑放入线程池中执行
     *
     * @param msg
     * @return void
     * @throws
     */
    public void doPublicCommand(Base msg) {

        int cmd = msg.getCmd();
        ServerHandler handler;
        try {

            handler = messagePool.getServerHandler(cmd);
            if (handler != null) {
                handler.setMsg(msg);
                publicActionExcutor.execute(handler);
            }

        } catch (Exception e) {
            LogUtil.error(e, e);
        }
    }
}

class HttpServerInboundHandler extends ChannelInboundHandlerAdapter {
    private HttpServer httpServer;

    /**
     *
     */
    public HttpServerInboundHandler(HttpServer httpServer) {
        super();
        this.httpServer = httpServer;
    }

    @Override
    public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {

        if (msg instanceof HttpContent) {
            HttpContent content = (HttpContent) msg;

            ByteBuf buf = content.content();
            byte[] packet = new byte[buf.readableBytes()];
            buf.readBytes(packet);

            Base base = PbHelper.parseFromByte(packet);
            Base rsBase = PbHelper.createRsBase(base.getCmd() + 1, 200);
            byte[] rsData = rsBase.toByteArray();
            byte[] rsLen = PbHelper.putShort((short) rsData.length);
            FullHttpResponse response = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, HttpResponseStatus.OK, Unpooled.wrappedBuffer(rsLen, rsData));
            response.headers().set(HttpHeaders.Names.CONTENT_TYPE, "application/octet-stream");
            response.headers().set(HttpHeaders.Names.CONTENT_LENGTH, response.content().readableBytes());
            ctx.write(response);
            ctx.flush();
            ctx.writeAndFlush(Unpooled.EMPTY_BUFFER).addListener(ChannelFutureListener.CLOSE);

            httpServer.doPublicCommand(base);
        }
    }

    @Override
    public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
        ctx.flush();
    }

    @Override
    public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
        LogUtil.error(cause.getMessage(), cause);
        ctx.close();
    }
}
