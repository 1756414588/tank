/**   
 * @Title: HttpServer.java    
 * @Package com.game.server    
 * @Description:   
 * @author ZhangJun   
 * @date 2015年11月3日 上午10:36:08    
 * @version V1.0   
 */
package com.game.server;

import com.game.common.FilterCmd;
import com.game.common.ServerSetting;
import com.game.constant.GameError;
import com.game.message.handler.ServerHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.RegisterRq;
import com.game.server.executor.NonOrderedQueuePoolExecutor;
import com.game.server.executor.OrderedQueuePoolExecutor;
import com.game.server.work.HttpWork;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.*;

import java.io.ByteArrayOutputStream;

/**
 * @ClassName: HttpServer
 * @Description: http服务器  用来和账号服通信
 * @author ZhangJun
 * @date 2015年11月3日 上午10:36:08
 * 
 */
public class HttpServer extends Server {
	private EventLoopGroup bossGroup;
	private EventLoopGroup workerGroup;
	public OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
	private NonOrderedQueuePoolExecutor publicActionExcutor = new NonOrderedQueuePoolExecutor(500);

	private GameServer gameServer;

	public String accountServerUrl = GameServer.ac.getBean(ServerSetting.class).getAccountServerUrl();
	public String fixAccountServerUrl = null;

	/**
	 * 
	* <p>Title: </p> 
	* <p>Description: </p> 
	* @param gameServer 服务器名HttpServer
	 */
	public HttpServer(GameServer gameServer) {
		super("HttpServer");
		this.gameServer = gameServer;
	}

	/**
	 * 
	* <p>Title: getGameType</p> 
	* <p>Description:服务器类型 </p> 
	* @return 
	* @see com.game.server.Server#getGameType()
	 */
	@Override
	String getGameType() {
		//Auto-generated method stub
		return "http";
	}

	/**
	 * 
	* <p>Title: stop</p> 
	* <p>Description: 停止服务器</p>  
	* @see com.game.server.Server#stop()
	 */
	@Override
	protected void stop() {
		//Auto-generated method stub
		bossGroup.shutdownGracefully();
		workerGroup.shutdownGracefully();
	}
	/**
	 * 
	* <p>Title: run</p> 
	* <p>Description: 启动netty服务</p>  
	* @see com.game.server.Server#run()
	 */
	@Override
	public void run() {
		super.addHook();
		bossGroup = new NioEventLoopGroup();
		workerGroup = new NioEventLoopGroup();
		try {
			ServerBootstrap b = new ServerBootstrap();
			b.group(bossGroup, workerGroup).channel(NioServerSocketChannel.class).childHandler(new ChannelInitializer<SocketChannel>() {
				@Override
				public void initChannel(SocketChannel ch) throws Exception {
					// server端发送的是httpResponse，所以要使用HttpResponseEncoder进行编码
					ch.pipeline().addLast(new HttpResponseEncoder());
					// server端接收到的是httpRequest，所以要使用HttpRequestDecoder进行解码
					ch.pipeline().addLast(new HttpRequestDecoder());
					ch.pipeline().addLast(new HttpServerInboundHandler(HttpServer.this));
				}
			}).option(ChannelOption.SO_BACKLOG, 128).childOption(ChannelOption.SO_KEEPALIVE, true)/*.childOption(ChannelOption.RCVBUF_ALLOCATOR, new AdaptiveRecvByteBufAllocator(64, 1024 * 2, 65536))*/;

			ChannelFuture f = b.bind(Integer.parseInt(GameServer.ac.getBean(ServerSetting.class).getHttpPort())).sync();

			f.channel().closeFuture().sync();
		} catch (InterruptedException e) {
			//Auto-generated catch block
			// e.printStackTrace();
//			LogHelper.ERROR_LOGGER.error(e, e);
			LogUtil.error("Http Server start Exception", e);
		}
	}
	
	/**
	 * 
	* @Title: sendPublicMsg 
	* @Description: 发送消息到账号服
	* @param msg  
	* void   

	 */
	public void sendPublicMsg(Base msg) {

		int cmd = msg.getCmd();
		if (!FilterCmd.inOutFilterPrint(cmd)) {
			LogUtil.s2sMessage(msg);
		}


		sendExcutor.execute(new HttpWork(this, msg));
	}

	/**
	 * 
	* @Title: sendPublicMsg 
	* @Description: 发送消息到账号服  这个方法没用到
	* @param msg
	* @param serverId  
	* void   

	 */
	public void sendPublicMsg(Base msg, int serverId) {
		int cmd = msg.getCmd();
		if (!FilterCmd.inOutFilterPrint(cmd)) {
			LogUtil.s2sMessage(msg);
		}


		if (fixAccountServerUrl == null) {
			fixAccountServerUrl = this.accountServerUrl + "?serverId=" + serverId;
		}
		sendExcutor.execute(new HttpWork(this, fixAccountServerUrl, msg));
	}

	/**
	 * 
	* @Title: registerGameToPublic 
	* @Description:   向账号服注册服务器开启信息
	* void   

	 */
	public void registerGameToPublic() {
		RegisterRq.Builder builder = RegisterRq.newBuilder();
		builder.setServerId(GameServer.ac.getBean(ServerSetting.class).getServerID());
		builder.setServerName(GameServer.ac.getBean(ServerSetting.class).getServerName());
		Base.Builder baseBuilder = Base.newBuilder();
		baseBuilder.setCmd(RegisterRq.EXT_FIELD_NUMBER);
		baseBuilder.setExtension(RegisterRq.ext, builder.build());

		Base msg = baseBuilder.build();
		sendPublicMsg(msg);
	}

	/**
	 * 
	* @Title: doPublicCommand 
	* @Description: 与帐号服之间的消息逻辑放入线程池中执行
	* @param msg  
	* void   

	 */
	public void doPublicCommand(Base msg) {

		int cmd = msg.getCmd();
		ServerHandler handler;
		try {

			if (!FilterCmd.inOutFilterPrint(cmd)) {
				LogUtil.s2sMessage(msg);
			}

			handler = gameServer.messagePool.getServerHandler(cmd);
			if (handler != null) {
				handler.setMsg(msg);
				publicActionExcutor.execute(handler);
			}

		} catch (Exception e) {
			LogUtil.error("与帐号服之间的消息逻辑放入线程池中执行异常", e);
		}

	}
}

/**
 * 
* @ClassName: HttpServerInboundHandler 
* @Description: http服务器的消息接收处理器
* @author 
* @date 
*
 */
class HttpServerInboundHandler extends ChannelInboundHandlerAdapter {
	private HttpServer httpServer;
	private ByteArrayOutputStream body;

	/**
	 * 
	* <p>Title: </p> 
	* <p>Description: </p> 
	* @param httpServer
	 */
	public HttpServerInboundHandler(HttpServer httpServer) {
		super();
		this.httpServer = httpServer;
	}

	/**
	 * 
	* <p>Title: channelRead</p> 
	* <p>Description: 读取消息方法 </p> 
	* @param ctx
	* @param msg
	* @throws Exception 
	* @see io.netty.channel.ChannelInboundHandlerAdapter#channelRead(io.netty.channel.ChannelHandlerContext, java.lang.Object)
	 */
	@Override
	public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
		if (msg instanceof HttpContent) {
			ByteBuf in = ((HttpContent) msg).content();
        	byte[] data = new byte[in.readableBytes()];
        	in.readBytes(data);
        	body.write(data);
        	if(msg instanceof LastHttpContent){
//                LogUtil.warn("bodyLen : " + body.toByteArray().length);
                Base base = PbHelper.parseFromByte(body.toByteArray());
    			Base rsBase = PbHelper.createRsBase(base.getCmd() + 1, GameError.OK.getCode());
    			byte[] rsData = rsBase.toByteArray();
    			byte[] rsLen = PbHelper.putShort((short) rsData.length);
    			FullHttpResponse response = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, HttpResponseStatus.OK, Unpooled.wrappedBuffer(rsLen, rsData));
    			response.headers().set(HttpHeaders.Names.CONTENT_TYPE, "application/octet-stream");
    			response.headers().set(HttpHeaders.Names.CONTENT_LENGTH, response.content().readableBytes());
    			ctx.write(response);
    			ctx.flush();
    			ctx.writeAndFlush(Unpooled.EMPTY_BUFFER).addListener(ChannelFutureListener.CLOSE);

    			httpServer.doPublicCommand(base);
    			body = null;
        	}
		} else if(msg instanceof HttpRequest) {
            body = new ByteArrayOutputStream();

            HttpRequest request = (HttpRequest) msg;
            String uri = request.getUri();
//            LogUtil.warn("Uri : " + uri);
        }
    }

	/**
	 * 
	* <p>Title: channelReadComplete</p> 
	* <p>Description: </p> 
	* @param ctx
	* @throws Exception 
	* @see io.netty.channel.ChannelInboundHandlerAdapter#channelReadComplete(io.netty.channel.ChannelHandlerContext)
	 */
	@Override
	public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
		ctx.flush();
	}

	/**
	 * 
	* <p>Title: exceptionCaught</p> 
	* <p>Description:处理器遇到异常时记录日志并关闭连接 </p> 
	* @param ctx
	* @param cause 
	* @see io.netty.channel.ChannelInboundHandlerAdapter#exceptionCaught(io.netty.channel.ChannelHandlerContext, java.lang.Throwable)
	 */
	@Override
	public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
//		LogHelper.PUBLIC_LOGGER.error(cause.getMessage(), cause);
//		cause.printStackTrace();
		LogUtil.error("HttpServerInboundHandler exceptionCaught", cause);
		ctx.close();
	}

}
