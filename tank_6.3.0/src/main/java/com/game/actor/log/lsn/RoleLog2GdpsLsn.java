package com.game.actor.log.lsn;

import com.game.actor.log.LogEvent;
import com.game.common.ServerSetting;
import com.game.domain.Player;
import com.game.domain.p.Account;
import com.game.domain.p.Lord;
import com.game.server.Actor.IMessage;
import com.game.server.Actor.IMessageListener;
import com.game.util.HttpUtils;
import com.game.util.LogUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

/**
 * @author zhangdh
 * @ClassName: RoleLoginLog2GdpsLsn
 * @Description: 角色记录日志到账号服
 * @date 2017-07-05 14:30
 */
@Service
public class RoleLog2GdpsLsn implements IMessageListener {
    private static final String recordRoleURL = "http://web.pay.hundredcent.com:8090/tank_account_role/account/recordRoleLogin.do";

    private static String accountRoleInfoUrl = "";


    @Autowired
    private ServerSetting serverSetting;

    @Override
    public void onMessage(IMessage msg) {
        if (msg instanceof LogEvent) {
            LogEvent evt = (LogEvent) msg;
            recordRole(evt.getPlayer(), evt);
        }
    }

    protected String makeData(Player player, LogEvent evt) {
        Account account = player.account;
        Lord lord = player.lord;
        String nick = lord != null ? lord.getNick() : "";
        int level = lord != null ? lord.getLevel() : 0;
        int vip = lord != null ? lord.getVip() : 0;
        int topup = lord != null ? lord.getTopup() : 0;

        StringBuilder sb = new StringBuilder().append("platNo=")
                .append(account.getPlatNo())
                .append("&accountKey=")
                .append(account.getAccountKey())
                .append("&roleId=")
                .append(account.getLordId())
                .append("&roleName=")
                .append(nick)
                .append("&level=")
                .append(level)
                .append("&serverId=")
                .append(account.getServerId())
                .append("&serverName=")
                .append(serverSetting.getServerName())
                .append("&createTime=")
                .append(player.account.getCreateDate().getTime())
                .append("&subject=")
                .append(evt.getSubject())
                .append("&platId=")
                .append(account.getPlatId())
                .append("&platNo=")
                .append(account.getPlatNo())
                .append("&childNo=")
                .append(account.getChildNo())
                .append("&vip=")
                .append(vip)
                .append("&topup=")
                .append(topup)
                .append("&loginDate=")
                .append(account.getLoginDate().getTime());

        return sb.toString();
    }

    /**
     * 将玩家信息发送到account服务器，如果是需要记录玩家角色信息的渠道，会被记录下来
     *
     * @param player
     * @param evt
     */
    public void recordRole(Player player, LogEvent evt) {
        try {
            String url = serverSetting.getRecordRoleURL();
            if (url == null || url.equalsIgnoreCase("")) {
                url = recordRoleURL;
            }
            String data = makeData(player, evt);


            long time1 = System.currentTimeMillis();

            try {
                HttpUtils.sentPost(url, data);
            } catch (Exception e) {
                LogUtil.error("", e);
            }

            LogUtil.info("发送到tank_account_role roleId={},耗时 {} ms", player.roleId, System.currentTimeMillis() - time1);

            try {
                if (accountRoleInfoUrl.equals("")) {
                    int lastIndexOf = serverSetting.getAccountServerUrl().lastIndexOf("/");
                    String accountUrl = serverSetting.getAccountServerUrl().substring(0, lastIndexOf);
                    accountRoleInfoUrl = accountUrl + "/gameRoleInfo.do";
                }
                long time2 = System.currentTimeMillis();

                HttpUtils.sentPost(accountRoleInfoUrl, data);

                LogUtil.info("发送到tank_account roleId={},耗时 {} ms", player.roleId, System.currentTimeMillis() - time2);

            } catch (Exception e) {
                LogUtil.error("", e);
            }
        } catch (Exception e) {
            LogUtil.error("", e);
        }
    }
}
