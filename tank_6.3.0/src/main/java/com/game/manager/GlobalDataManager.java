package com.game.manager;

import java.util.Calendar;
import java.util.LinkedList;
import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.constant.MailType;
import com.game.dao.impl.p.GlobalDao;
import com.game.dataMgr.StaticMailDataMgr;
import com.game.dataMgr.StaticPartyDataMgr;
import com.game.domain.GameGlobal;
import com.game.domain.PartyData;
import com.game.domain.p.DbGlobal;
import com.game.domain.p.Mail;
import com.game.domain.s.StaticMail;
import com.game.domain.s.StaticPartyProp;
import com.game.pb.CommonPb.Report;
import com.game.pb.CommonPb.WarRecord;
import com.game.server.GameServer;
import com.game.util.LogUtil;
import com.game.util.TimeHelper;
import com.google.protobuf.InvalidProtocolBufferException;

/**
 * @ClassName: GlobalDataManager
 * @Description: 游戏全局数据处理
 * @author ZhangJun
 * @date 2015年12月21日 下午1:49:32
 *
 */
@Component
public class GlobalDataManager {
    @Autowired
    private GlobalDao globalDao;

    @Autowired
    private StaticMailDataMgr staticMailDataMgr;

    @Autowired
    private StaticPartyDataMgr staticPartyDataMgr;

    public GameGlobal gameGlobal;


    public boolean isSaveStaffingAdd = true;

    public void init() throws InvalidProtocolBufferException {
        initGlobal();
    }

    private void initGlobal() throws InvalidProtocolBufferException {
        gameGlobal = new GameGlobal();
        DbGlobal dbGlobal = globalDao.selectGlobal();
        if (dbGlobal == null) {
            dbGlobal = gameGlobal.ser();
            globalDao.insertGlobal(dbGlobal);
            gameGlobal.setGlobalId(dbGlobal.getGlobalId());
        } else {
            gameGlobal.dser(dbGlobal);
        }
    }

    public int getMaxKey() {
        return gameGlobal.maxKey();
    }

    /**
     *
     * @Description: 全服邮件
     * @param report
     * @param moldId
     * @param now
     * @param param
     * void
     */
    public void addGlobalReportMail(Report report, int moldId, int now, String... param) {
        StaticMail staticMail = staticMailDataMgr.getStaticMail(moldId);
        if (staticMail == null) {
            return;
        }
        int type = staticMail.getType();
        Mail mail = new Mail(getMaxKey(), type, moldId, MailType.STATE_READ, now);
        if (param != null) {
            mail.setParam(param);
        }

        mail.setReport(report);

        gameGlobal.getMails().add(mail);
        if (gameGlobal.getMails().size() > 20) {
            gameGlobal.getMails().removeFirst();
        }
    }

    /**
     * @Description: 定时保存全局数据方法
     * void
     */
    public void saveGlobalTimerLogic() {
        try {
            GameServer.getInstance().saveGlobalServer.saveData(gameGlobal.ser());
        } catch (Exception e) {
            LogUtil.error("Save Global Exception", e);
        }
    }

    public void updateGlobal(DbGlobal dbGlobal) {
        globalDao.updateGlobal(dbGlobal);
    }

    /**
     * @Description: 添加战斗记录
     * @param warRecord
     * void
     */
    public void addWarRecord(WarRecord warRecord) {
        LinkedList<WarRecord> records = gameGlobal.getWarRecord();
        records.add(warRecord);
        if (records.size() > 20) {
            records.removeFirst();
        }
    }

    public void clearWarRecord() {
        gameGlobal.getWarRecord().clear();
    }

    public LinkedList<WarRecord> getWarRecord() {
        return gameGlobal.getWarRecord();
    }

    public List<Integer> getPartyShop(PartyData partyData) {
        int shopTime = gameGlobal.getShopTime();
        int today = TimeHelper.getCurrentDay();
        int shopTimeDay = shopTime / 10;// 刷新日期
        int shopTimeHour = shopTime - today * 10;// 刷新小时
        boolean flag = false;
        if (shopTimeDay != today) {
            flag = true;
        }
        Calendar calendar = Calendar.getInstance();
        int hour = calendar.get(Calendar.HOUR_OF_DAY);
        if (hour < 12) {
            hour = 0;
        } else if (hour >= 12 && hour < 18) {
            hour = 1;
        } else {
            hour = 2;
        }
        if (shopTimeHour != hour) {
            shopTimeHour = hour;
            flag = true;
        }
        if (flag) {
            gameGlobal.setShopTime(today * 10 + shopTimeHour);
            List<StaticPartyProp> rs = staticPartyDataMgr.getPartyShopProp();
            gameGlobal.getShop().clear();
            for (StaticPartyProp en : rs) {
                gameGlobal.getShop().add(en.getKeyId());
            }
        }
        if (partyData.getShopTime() != gameGlobal.getShopTime()) {
            partyData.getShopProps().clear();
            for (int i = 0; i < gameGlobal.getShop().size(); i++) {
                partyData.getShopProps().add(0);
            }
            partyData.setShopTime(gameGlobal.getShopTime());
        }
        return gameGlobal.getShop();
    }
}
