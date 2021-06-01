package merge;

import com.alibaba.fastjson.JSONObject;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import io.netty.bootstrap.ServerBootstrap;
import io.netty.buffer.ByteBuf;
import io.netty.buffer.Unpooled;
import io.netty.channel.*;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.SocketChannel;
import io.netty.channel.socket.nio.NioServerSocketChannel;
import io.netty.handler.codec.http.*;

import java.io.ByteArrayOutputStream;

public class MHttpServer {
	private String name = "MHttpServer";
	
	private class CloseByExit implements Runnable {
		private String serverName;

		public CloseByExit(String serverName) {
			this.serverName = serverName;
		}

		@Override
		public void run() {
			MHttpServer.this.stop();
			LogUtil.stop(this.serverName + " Stop!!");
		}
	}
	
	public void stop() {
		bossGroup.shutdownGracefully();
		workerGroup.shutdownGracefully();
	}
	
	private EventLoopGroup bossGroup;
	private EventLoopGroup workerGroup;
	
	public void run() {
		Runtime.getRuntime().addShutdownHook(new Thread(new CloseByExit(name)));
		
		LogUtil.error("MHttpServer Server start");
		
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
					ch.pipeline().addLast(new HttpServerInboundHandler(MHttpServer.this));
				}
			}).option(ChannelOption.SO_BACKLOG, 128).childOption(ChannelOption.SO_KEEPALIVE, true);

			ChannelFuture f = b.bind(9100).sync();

			f.channel().closeFuture().sync();
		} catch (InterruptedException e) {
			LogUtil.error("Http Server start Exception", e);
		}
	}

	class HttpServerInboundHandler extends ChannelInboundHandlerAdapter {
		private MHttpServer httpServer;
		private ByteArrayOutputStream body;
		private HttpMethod method;
		private String url;

		public HttpServerInboundHandler(MHttpServer httpServer) {
			super();
			this.httpServer = httpServer;
		}

		@Override
		public void channelRead(ChannelHandlerContext ctx, Object msg) throws Exception {
			if (msg instanceof HttpContent) {
				ByteBuf in = ((HttpContent) msg).content();
	        	byte[] data = new byte[in.readableBytes()];
	        	in.readBytes(data);
	        	body.write(data);
	        	if(msg instanceof LastHttpContent){
	        		if(method == HttpMethod.GET){
	        			httpServer.doGet(ctx,url);
	        		}else if(method == HttpMethod.POST){
	        			httpServer.doPost(ctx,url,body.toByteArray());
	        		}else{
	        			LogUtil.error("not do handler");
	        			httpServer.respData(ctx, new byte[0]);
	        			return;
	        		}
	        	}
			} else if(msg instanceof HttpRequest){
				body = new ByteArrayOutputStream();
				method = ((HttpRequest) msg).getMethod();
				url = ((HttpRequest) msg).getUri();
			}
		}

		@Override
		public void channelReadComplete(ChannelHandlerContext ctx) throws Exception {
			ctx.flush();
		}

		@Override
		public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) {
			LogUtil.error("HttpServerInboundHandler exceptionCaught", cause);
			ctx.close();
		}

	}
	
	private void respData(ChannelHandlerContext ctx,byte[] data){
		FullHttpResponse response = new DefaultFullHttpResponse(HttpVersion.HTTP_1_1, HttpResponseStatus.OK, Unpooled.wrappedBuffer(data.length, data));
		response.headers().set(HttpHeaders.Names.CONTENT_TYPE, "application/json;charset=utf-8");
		response.headers().set(HttpHeaders.Names.CONTENT_LENGTH,data.length);
		ctx.writeAndFlush(response).addListener(ChannelFutureListener.CLOSE);
	}
	
	private void doPost(ChannelHandlerContext ctx,String uri, byte[] byteArray) {
		LogUtil.error("post:"+uri + "-->");
		
		if(uri.startsWith("/selectScoreActRank")){
			String b = new String(byteArray);
			LogUtil.info(b);
			JSONObject body = JSONObject.parseObject(b);
			
			String data = SelectActRank.selectScoreActRank(body.getString("location"),"root","",body.getIntValue("activity_id"));
			
			if(data != null){
				respData(ctx, data.getBytes());
			}else{
				respData(ctx, "fail".getBytes());
			}
		}else{
			respData(ctx, "error".getBytes());
		}
	}

	private void doGet(ChannelHandlerContext ctx,String uri) {
		LogUtil.error("get:"+uri + "-->");
		
		String ret = HttpUtils.sentPost("http://127.0.0.1:9100/selectScoreActRank", "{\"location\":\"jdbc:mysql://localhost:3306/tank_2\",\"activity_id\":104}");
		LogUtil.info(ret);
		
		respData(ctx, "ok".getBytes());
	}
	
	
	public static void main(String[] args) {
		MHttpServer httpServer = new MHttpServer();
		httpServer.run();
	}
	
	
	
}
