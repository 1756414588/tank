/**
 * @Title: PublicService.java
 * @Package com.account.service
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年8月3日 上午10:10:56
 * @version V1.0
 */
package com.account.service;

import java.util.concurrent.ConcurrentHashMap;

import javax.annotation.PostConstruct;
import javax.annotation.PreDestroy;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import com.account.common.ServerSetting;
import com.account.dao.impl.AccountDao;
import com.account.dao.impl.GiftDao;
import com.account.domain.Gift;
import com.account.domain.GiftCode;
import com.account.executor.AbstractWork;
import com.account.executor.OrderedQueuePoolExecutor;
import com.account.handle.MessageHandle;
import com.account.util.ChannelUtil;
import com.game.pb.BasePb;
import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb.RegisterRq;
import com.game.pb.InnerPb.RegisterRs;
import com.game.pb.InnerPb.UseGiftCodeRq;
import com.game.pb.InnerPb.UseGiftCodeRs;

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

/**
 * @ClassName: PublicService
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年8月3日 上午10:10:56
 *
 */

@Deprecated
public class PublicService {
    public static Logger LOG = LoggerFactory.getLogger(PublicService.class);


    @Autowired
    private ServerSetting serverSetting;

    @Autowired
    private AccountDao accountDao;

    @Autowired
    private GiftDao giftDao;


    private static Logger logger = LoggerFactory.getLogger(PublicService.class);
    private EventLoopGroup bossGroup;
    private EventLoopGroup workerGroup;
    private ServerBootstrap bootstrap;

    private ConcurrentHashMap<Integer, ChannelHandlerContext> channelHandlerMap = new ConcurrentHashMap<>();
    private OrderedQueuePoolExecutor sendExcutor = new OrderedQueuePoolExecutor("消息发送队列", 100, -1);
    private OrderedQueuePoolExecutor recvExcutor = new OrderedQueuePoolExecutor("消息接收队列", 100, -1);
    // private NonOrderedQueuePoolExecutor publicActionExcutor = new
    // NonOrderedQueuePoolExecutor(500);

    private ConcurrentHashMap<Long, ChannelHandlerContext> serverChannels = new ConcurrentHashMap<>();

    @PostConstruct
    public void init() {
        bossGroup = new NioEventLoopGroup();
        workerGroup = new NioEventLoopGroup();
        bootstrap = new ServerBootstrap();
        bootstrap.group(bossGroup, workerGroup);
        bootstrap.channel(NioServerSocketChannel.class);
        bootstrap.option(ChannelOption.SO_BACKLOG, 1024);
        // 通过NoDelay禁用Nagle,使消息立即发出去，不用等待到一定的数据量才发出去
        bootstrap.option(ChannelOption.TCP_NODELAY, true);
        bootstrap.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
        bootstrap.childHandler(new PublicChannelHandler());
        bootstrap.childOption(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
        bootstrap.childOption(ChannelOption.SO_KEEPALIVE, true);
        bootstrap.childOption(ChannelOption.SO_REUSEADDR, true);
        // 绑定端口
        bootstrap.bind(Integer.valueOf(serverSetting.getPublicPort()));
    }

    @PreDestroy
    public void destory() {
        if (bossGroup != null) {
            bossGroup.shutdownGracefully();
        }

        if (workerGroup != null) {
            workerGroup.shutdownGracefully();
        }
    }

    public void registerServer(RegisterRq req, ChannelHandlerContext ctx) {
        int serverId = req.getServerId();
        String serverName = req.getServerName();
        channelHandlerMap.put(serverId, ctx);
        RegisterRs.Builder builder = RegisterRs.newBuilder();
        builder.setState(1);
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(RegisterRs.EXT_FIELD_NUMBER);
        baseBuilder.setCode(200);
        baseBuilder.setExtension(RegisterRs.ext, builder.build());
        System.out.printf("服务器 [%d区]" + "[%s]" + "注册到account!", serverId, serverName);
        sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
    }

//	public void verifyPlayer(VerifyRq req, ChannelHandlerContext ctx, Long param) {
//		int keyId = req.getKeyId();
//		int serverId = req.getServerId();
//		String token = req.getToken();
//		String curVersion = req.getCurVersion();
//		String deviceNo = req.getDeviceNo();
//
//		Base.Builder baseBuilder = Base.newBuilder();
//		baseBuilder.setCmd(VerifyRs.EXT_FIELD_NUMBER);
//		baseBuilder.setParam(param);
//		Account account = accountDao.selectByKey(keyId);
//		if (account == null) {
//			baseBuilder.setCode(GameError.INVALID_TOKEN.getCode());
//			sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
//			return;
//		}
//
//		String tokenExist = account.getToken();
//		if (tokenExist == null || !tokenExist.equals(token)) {
//			baseBuilder.setCode(GameError.INVALID_TOKEN.getCode());
//			sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
//			return;
//		}
//
//		this.recordRecentServer(account, serverId);
//
//		VerifyRs.Builder builder = VerifyRs.newBuilder();
//		builder.setKeyId(keyId);
//		builder.setPlatId(account.getPlatId());
//		builder.setPlatNo(account.getPlatNo());
//		builder.setChildNo(account.getChildNo());
//		builder.setCurVersion(curVersion);
//		builder.setDeviceNo(deviceNo);
//		builder.setServerId(serverId);
//
//		baseBuilder.setCode(GameError.OK.getCode());
//
//		baseBuilder.setExtension(VerifyRs.ext, builder.build());
//		sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
//	}

    public void useGiftCode(UseGiftCodeRq req, ChannelHandlerContext ctx) {
        long lordId = req.getLordId();
        int serverId = req.getServerId();
        String code = req.getCode();

        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(UseGiftCodeRs.EXT_FIELD_NUMBER);

        UseGiftCodeRs.Builder builder = UseGiftCodeRs.newBuilder();
        builder.setServerId(serverId);
        builder.setLordId(lordId);

        String giftId = code.substring(0, 4);
        GiftCode used = giftDao.selectGiftCodeByLord(giftId, serverId, lordId);
        if (used != null) {
            builder.setState(1);
            baseBuilder.setExtension(UseGiftCodeRs.ext, builder.build());
            sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
            return;
        }

        GiftCode giftCode = giftDao.selectGiftCode(code);
        if (giftCode == null) {
            builder.setState(2);
            baseBuilder.setExtension(UseGiftCodeRs.ext, builder.build());
            sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
            return;
        } else {
            if (giftCode.getServerId() != 0) {// 该码被使用过
                builder.setState(3);
                baseBuilder.setExtension(UseGiftCodeRs.ext, builder.build());
                sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
                return;
            }
        }

        Gift gift = giftDao.selectGift(Integer.valueOf(giftId));
        if (gift == null) {
            builder.setState(4);
            baseBuilder.setExtension(UseGiftCodeRs.ext, builder.build());
            sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
            return;
        }

        long now = System.currentTimeMillis();
        long begin = gift.getBeginTime().getTime();
        long end = gift.getEndTime().getTime();
        if (gift == null || gift.getValid() != 1 || now < begin || now > end) {// 兑换码无效
            builder.setState(4);
            baseBuilder.setExtension(UseGiftCodeRs.ext, builder.build());
            sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
            return;
        }

        builder.setState(0);
        giftCode.setServerId(serverId);
        giftCode.setLordId(lordId);
        giftDao.updateGiftCode(giftCode);

        builder.setAward(gift.getGift());
        baseBuilder.setExtension(UseGiftCodeRs.ext, builder.build());
        sendExcutor.addTask(ChannelUtil.getChannelId(ctx), new WWork(ctx, baseBuilder.build()));
    }

//	private void recordRecentServer(Account account, int serverId) {
//		int[] record = { account.getFirstSvr(), account.getSecondSvr(), account.getThirdSvr() };
//		int temp = 0;
//		if (record[0] != 0) {
//			if (record[0] != serverId) {
//				temp = record[2];
//				record[2] = record[1];
//				record[1] = record[0];
//			}
//		}
//
//		record[0] = serverId;
//		if (record[2] == serverId) {
//			record[2] = temp;
//		}
//		account.setFirstSvr(record[0]);
//		account.setSecondSvr(record[1]);
//		account.setThirdSvr(record[2]);
//		accountDao.updateRecentServer(account);
//	}

    private class PublicChannelHandler extends ChannelInitializer<SocketChannel> {

        /**
         * Overriding: initChannel
         *
         * @param ch
         * @throws Exception
         * @see io.netty.channel.ChannelInitializer#initChannel(io.netty.channel.Channel)
         */
        @Override
        protected void initChannel(SocketChannel ch) throws Exception {
            // TODO Auto-generated method stub
            logger.trace("ConnectChannelHandler initChannel:" + Thread.currentThread().getId());

            // LOG.error(Thread.currentThread().getId());
            // InetSocketAddress address = (InetSocketAddress)
            // ch.remoteAddress();
            // LOG.error("ip:" +
            // address.getAddress().getHostAddress());
            // LOG.error("port:" + address.getPort());

            ChannelPipeline pipeLine = ch.pipeline();
            // pipeLine.addLast(new IdleStateHandler(10, 0, 0,
            // TimeUnit.SECONDS));
            // pipeLine.addLast(new HeartbeatHandler());
            pipeLine.addLast("frameEncoder", new LengthFieldPrepender(2));
            pipeLine.addLast("protobufEncoder", new ProtobufEncoder());

            pipeLine.addLast("frameDecoder", new LengthFieldBasedFrameDecoder(1048576, 0, 2, 0, 2));
            pipeLine.addLast("protobufDecoder", new ProtobufDecoder(BasePb.Base.getDefaultInstance(), MessageHandle.PB_EXTENDSION_REGISTRY));
            pipeLine.addLast("protobufHandler", new MessageHandler());
        }

        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            logger.trace("ConnectChannelHandler channelUnregistered:" + Thread.currentThread().getId());
        }

        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            logger.trace("ConnectChannelHandler channelInactive:" + Thread.currentThread().getId());
        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            super.exceptionCaught(ctx, cause);
            logger.trace("ConnectChannelHandler exceptionCaught:" + Thread.currentThread().getId());
            ctx.close();
        }
    }

    // private class HeartbeatHandler extends ChannelDuplexHandler {
    // @Override
    // public void userEventTriggered(ChannelHandlerContext ctx, Object evt)
    // throws Exception {
    // super.userEventTriggered(ctx, evt);
    // LOG.error("HeartbeatHandler trigger");
    // if (evt instanceof IdleStateEvent) {
    // IdleStateEvent e = (IdleStateEvent) evt;
    // if (e.state() == IdleState.READER_IDLE) {
    // LOG.error("HeartbeatHandler trigger READER_IDLE");
    // ctx.close();
    // }
    // }
    // }
    // }

    private class MessageHandler extends SimpleChannelInboundHandler<Base> {

        /**
         * Overriding: channelRead0
         *
         * @param ctx
         * @param msg
         * @throws Exception
         * @see io.netty.channel.SimpleChannelInboundHandler#channelRead0(io.netty.channel.ChannelHandlerContext,
         *      java.lang.Object)
         */
        @Override
        protected void channelRead0(ChannelHandlerContext ctx, com.game.pb.BasePb.Base msg) throws Exception {
            // TODO Auto-generated method stub
            // logger.trace("MessageHandler doCommand:" + msg.toString());
            LOG.error("MessageHandler channelRead0");
            recvExcutor.addTask(ChannelUtil.getChannelId(ctx), new RWork(ctx, msg));
            // publicActionExcutor.execute(new RWork(ctx, msg));
        }

        @Override
        public void channelRegistered(ChannelHandlerContext ctx) throws Exception {
            super.channelRegistered(ctx);
            logger.trace("MessageHandler channelRegistered");
        }

        @Override
        public void channelUnregistered(ChannelHandlerContext ctx) throws Exception {
            super.channelUnregistered(ctx);
            LOG.error("MessageHandler channelUnregistered");
            logger.trace("MessageHandler channelUnregistered");
        }

        @Override
        public void channelActive(ChannelHandlerContext ctx) throws Exception {
            super.channelActive(ctx);
            logger.trace("MessageHandler channelActive");
            Long id = ChannelUtil.createChannelId(ctx);
            ChannelUtil.setChannelId(ctx, id);
            serverChannels.put(id, ctx);
        }

        @Override
        public void channelInactive(ChannelHandlerContext ctx) throws Exception {
            super.channelInactive(ctx);
            LOG.error("MessageHandler channelInactive");
            logger.trace("MessageHandler channelInactive");
        }

        @Override
        public void exceptionCaught(ChannelHandlerContext ctx, Throwable cause) throws Exception {
            LOG.error("MessageHandler exceptionCaught");
            logger.trace("MessageHandler exceptionCaught!" + cause);
            ctx.close();
        }
    }

    class RWork extends AbstractWork {
//		private Base msg;
//		private ChannelHandlerContext ctx;

        public RWork(ChannelHandlerContext ctx, Base msg) {
//			this.msg = msg;
//			this.ctx = ctx;
        }

        /**
         * Overriding: run
         *
         * @see java.lang.Runnable#run()
         */
        @Override
        public void run() {
//			LOG.error("receive++++++");
//			LOG.error(msg);
//			LOG.error("receive------");
//			try {
//				switch (msg.getCmd()) {
//				case RegisterRq.EXT_FIELD_NUMBER:
//					registerServer(msg.getExtension(RegisterRq.ext), ctx);
//					break;
//				case VerifyRq.EXT_FIELD_NUMBER:
//					verifyPlayer(msg.getExtension(VerifyRq.ext), ctx, msg.getParam());
//					break;
//				case UseGiftCodeRq.EXT_FIELD_NUMBER:
//					useGiftCode(msg.getExtension(UseGiftCodeRq.ext), ctx);
//					break;
//				default:
//					break;
//				}
//			} catch (Exception e) {
//				e.printStackTrace();
//			}
        }
    }

    class WWork extends AbstractWork {
        private ChannelHandlerContext ctx;
        private Base msg;

        public WWork(ChannelHandlerContext ctx, Base msg) {
            this.ctx = ctx;
            this.msg = msg;
        }

        /**
         * Overriding: run
         *
         * @see java.lang.Runnable#run()
         */
        @Override
        public void run() {
            // TODO Auto-generated method stub
            LOG.error("send++++++");
            LOG.error("msg:" + msg);
            LOG.error("send------");
            ctx.writeAndFlush(msg);
        }
    }
}
