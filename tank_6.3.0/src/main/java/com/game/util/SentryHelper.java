package com.game.util;

import com.game.common.ServerSetting;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.server.GameServer;
import com.game.server.executor.NonOrderedQueuePoolExecutor;
import com.game.server.work.SentryWork;
import io.sentry.Sentry;
import io.sentry.SentryClient;
import io.sentry.SentryClientFactory;

/**
 * @author TanDonghai
 * @Description Sentry（远程日志监控系统）帮助类
 * @date 创建时间：2017年11月8日 下午3:26:53
 */
public class SentryHelper {
    private SentryHelper() {
    }

    private static boolean initialized = false;

    /**
     * 非有序线程池
     */
    private static NonOrderedQueuePoolExecutor sendExcutor = new NonOrderedQueuePoolExecutor(3);

    /**
     * 初始化Sentry相关信息
     *
     * @param dsn
     */
    public static void initSentry(String dsn) {
        try {
            ServerSetting server = GameServer.ac.getBean(ServerSetting.class);
            if (server.isOpenSentry()) {
                LogUtil.start("开始初始化Sentry, dsn:" + dsn);
                SentryClient sentryClient = SentryClientFactory.sentryClient(dsn, null);
                if (null != sentryClient) {
                    Sentry.setStoredClient(sentryClient);
                    sentryClient.setServerName(server.getServerName());
                    sentryClient.addTag("game", "tank");
                    sentryClient.addTag("serverId", server.getServerID() + "");
                    String ip = IPUtil.getIP();
                    sentryClient.addTag("ip", ip);
                    sentryClient.addTag("port", server.getClientPort());
                    initialized = true;
                }
            } else {
                LogUtil.start("sentry not open !!!");
            }
        } catch (Exception e) {
            LogUtil.error("Sentry初始化失败, dsn:" + dsn, e);
        } finally {
            if (initialized) {
                LogUtil.start("Sentry已启动成功, dsn:" + dsn);
            }
        }
    }

    /**
     * 向Sentry服务器发送消息
     *
     * @param throwable void
     */
    public static void sendToSentry(Throwable throwable) {
        if (isOpen()) {
            sendExcutor.execute(new SentryWork(throwable));
        }
    }

    /**
     * 向Sentry服务器发送消息
     *
     * @param message void
     */
    public static void sendToSentry(String message) {
        if (isOpen()) {
            sendExcutor.execute(new SentryWork(message));
        }
    }

    /**
     * 功能是否开启
     *
     * @return boolean
     */
    private static boolean isOpen() {
        return initialized && GameServer.ac.getBean(StaticFunctionPlanDataMgr.class).isSentryOpen();
    }

}
