/**
 * @Title: LogHelper.java
 * @Package com.game.util
 * @Description:
 * @author ZhangJun
 * @date 2015年8月21日 下午2:08:13
 * @version V1.0
 */
package com.game.util;

import com.game.constant.AwardFrom;
import com.game.domain.Player;
import com.game.domain.p.Account;
import com.game.domain.p.Lord;
import com.game.domain.p.Task;
import com.game.server.GameServer;
import org.apache.log4j.LogManager;
import org.apache.log4j.Logger;

import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: LogHelper
 * @Description:
 * @date 2015年8月21日 下午2:08:13
 */
public class LogHelper {
    public static Logger GAME_LOGGER = Logger.getLogger("GAME");
    public static Logger ACTIVITY_LOGGER = LogManager.getLogger("ACTIVITY");
    public static Logger CROSS_LOGGER = LogManager.getLogger("CROSS");

    /**
     * 增加角色的道具
     *
     * @param lord
     * @param itemFrom
     * @param serverId
     * @param type
     * @param id
     * @param count
     * @param param    void
     */
    static public void logItem(Lord lord, AwardFrom itemFrom, int serverId, int type, int id, int count, String param) {
        GAME_LOGGER.error("itemAdd|" + lord.getLordId() + "|" + serverId + "|" + itemFrom.getMsg() + "|" + type + "|" + id + "|" + count + "|" + param);
    }

    /**
     * 发送奖励邮件给角色
     *
     * @param lord
     * @param mailId
     * @param keyId  void
     */
    static public void logGetAttachMail(Lord lord, int mailId, int keyId) {
        GAME_LOGGER.error("awardMail|" + lord.getLordId() + "|" + lord.getNick() + "|" + mailId + "|" + keyId);
    }

    /**
     * 军工科技改装坦克
     *
     * @param lord
     * @param tankId
     * @param count  void
     */
    static public void logMilitaryRefitTank(Lord lord, int tankId, int count) {
        GAME_LOGGER.error("militaryRefitTank|" + lord.getLordId() + "|" + lord.getNick() + "|" + tankId + "|" + count);
    }

    /**
     * 军工科技升级
     *
     * @param lord
     * @param scienceId
     * @param level     void
     */
    static public void logUpMilitaryScience(Lord lord, int scienceId, int level) {
        GAME_LOGGER.error("UpMilitaryScience|" + lord.getLordId() + "|" + lord.getNick() + "|" + scienceId + "|" + level);
    }

    /**
     * 军工科技解锁
     *
     * @param lord
     * @param tankId
     * @param pos    void
     */
    static public void logUnLockMilitaryGrid(Lord lord, int tankId, int pos) {
        GAME_LOGGER.error("logUnLockMilitaryGrid|" + lord.getLordId() + "|" + lord.getNick() + "|" + tankId + "|" + pos);
    }

    /**
     * 登陆
     *
     * @param player void
     */
    static public void logLogin(Player player) {
        Lord lord = player.lord;
        int accountKey = 0;
        int serverId = 0;
        String deviceNo = "";
        int platNo = 0;
        int childNo = 0;
        String platId = "";
        String createDate = "";
        String ip = "";
        if (player.account != null) {
            Account account = player.account;
            accountKey = account.getAccountKey();
            serverId = account.getServerId();
            deviceNo = account.getDeviceNo();
            platNo = account.getPlatNo();
            childNo = account.getChildNo();
            platId = account.getPlatId();
            if (account.getCreateDate() != null) {
                createDate = DateHelper.formatDateTime(account.getCreateDate(), DateHelper.format1);
            }
            ip = account.getIp();
        }
        GAME_LOGGER.error("login|" + lord.getLordId() + "|\"" + lord.getNick() + "\"|" + lord.getVip() + "|" + lord.getTopup() + "|" + lord.getProsMax() + "|" + lord.getGold() + "|" + lord.getGoldCost() + "|" + lord.getGoldGive() + "|" + accountKey + "|" + serverId + "|" + lord.getLevel() + "|" + platNo + "|" + platId + "|" + deviceNo + "|" + createDate + "|" + childNo + "|" + ip);
        //		recordRoleLogin(accountKey, platNo, lord.getLordId(), lord.getNick(), lord.getLevel(), player.account);
    }

    static public void logActivity(Lord lord, int activityId, int costGold, int type, int id, int count, int serverId) {
        ACTIVITY_LOGGER.error(lord.getLordId() + "|" + activityId + "|" + costGold + "|" + type + "|" + id + "|" + count + "|" + serverId + "|" + DateHelper.displayDateTime());
    }

    static public void logPay(Lord lord, Account account, int serverId, String orderId, String serialId, int amount, String payTime) {
        GAME_LOGGER.error("pay|" + serverId + "|" + lord.getLordId() + "|" + account.getPlatNo() + "|" + account.getPlatId() + "|" + orderId + "|" + serialId + "|" + amount + "|" + payTime + "|" + account.getAccountKey() + "|" + account.getChildNo() + "|" + lord.getVip() + "|" + lord.getLevel());
    }

    static public void logPaySelf(Lord lord, Account account, int serverId, String orderId, String serialId, int amount, String payTime) {
        GAME_LOGGER.error("paySelf|" + serverId + "|" + lord.getLordId() + "|" + account.getPlatNo() + "|" + account.getPlatId() + "|" + orderId + "|" + serialId + "|" + amount + "|" + payTime + "|" + account.getAccountKey() + "|" + account.getChildNo() + "|" + lord.getVip() + "|" + lord.getLevel());
    }

    static public void logRegister(Account account) {
        if (account == null) {
            return;
        }
        String createDate = "";
        if (account.getCreateDate() != null) {
            createDate = DateHelper.formatDateTime(account.getCreateDate(), DateHelper.format1);
        }
        GAME_LOGGER.error("register|" + account.getLordId() + "|" + account.getServerId() + "|" + account.getPlatNo() + "|" + account.getPlatId() + "|" + account.getDeviceNo() + "|" + account.getCreated() + "|" + createDate + "|" + account.getAccountKey() + "|" + account.getChildNo() + "|" + account.getIp());
    }

    /**
     * 游戏服务器保存数据到数据库失败时，发送错误日志到账号服保存
     *
     * @param dataType
     * @param errorCount
     * @param errorDesc
     */
    public static void sendGameSaveErrorLog(int dataType, int errorCount, String errorDesc) {
        try {
            GameServer.getInstance().sendMsgToPublic(PbHelper.createGameSaveErrorLogBase(dataType, errorCount, errorDesc));
        } catch (Exception e) {
            LogUtil.error("发送game服务器保存数据失败的消息出错, dataType:" + dataType + ", errorCount:" + errorCount + ", errorDesc:" + errorDesc, e);
        }
    }

    /**
     * 记录玩家的副本进度
     *
     * @param player
     */
    public static void logCombat(Player player) {
        GAME_LOGGER.error("combatId|" + player.lord.getLordId() + "|" + player.lord.getFight() + "|" + player.combatId);
    }

    /**
     * 记录玩家的主线任务
     *
     * @param player
     */
    public static void logMainTask(Player player, int taskId) {
        GAME_LOGGER.error("mainTaskId|" + player.lord.getLordId() + "|" + player.lord.getFight() + "|" + taskId);
    }


    /**
     * 数据需求 起服时打到game.log
     *
     * @param player
     */
    public static void logMTask(Player player) {
        Map<Integer, Task> majorTasks = player.majorTasks;
        if (majorTasks != null) {
            for (Integer tk : majorTasks.keySet()) {
                GAME_LOGGER.error("mainTask|" + player.lord.getLordId() + "|" + player.account.getServerId() + "|"
                        + player.account.getPlatNo() + "|" + player.account.getChildNo()
                        + "|" + player.lord.getNick() + "|" + player.lord.getLevel()
                        + "|" + player.lord.getVip() + "|" + player.lord.getTopup()
                        + "|" + player.combatId + "|" + DateHelper.displayNowDateTime(player.account.getLoginDate())
                        + "|" + player.lord.getFight() + "|" + tk);
            }
        }
    }

    /**
     * 玩家当日在线时长统计
     * @param lord
     */
    public static void logOltime(Lord lord) {
        GAME_LOGGER.error("olTime|" + lord.getLordId() + "|" + lord.getOlTime());
    }


}