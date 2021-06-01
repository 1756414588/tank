package com.game.service.cross.fight;

import com.game.constant.CrossConst;
import com.game.constant.MailType;
import com.game.constant.SysChatId;
import com.game.service.cross.ChatInfo;
import com.game.service.cross.MailInfo;

import java.util.HashMap;
import java.util.LinkedHashMap;
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/13 11:36
 * @description：cross service 缓存
 */
public class CrossServiceCache {
    /**
     * 广播消息 day,time,sysChatId
     */
    private static final Map<Integer, Map<String, ChatInfo>> sysChatConst = new HashMap<Integer, Map<String, ChatInfo>>();
    /**
     * 大状态(按天划分): 开始时间,结束时间
     */
    private static final LinkedHashMap<Integer, LinkedHashMap<String, String>> flowMap = new LinkedHashMap<Integer, LinkedHashMap<String, String>>();
    /**
     * 邮件
     */
    private static final Map<Integer, Map<String, MailInfo>> sysMailConst = new HashMap<Integer, Map<String, MailInfo>>();

    static {
        putSysChatConst();
        initFlowMap();
        putSysMailConst();
    }

    public static Map<Integer, Map<String, ChatInfo>> getSysChatConst() {
        return sysChatConst;
    }

    public static Map<String, ChatInfo> getChat(int dayNum) {
        return sysChatConst.get(dayNum);
    }

    public static Map<String, MailInfo> getMail(int dayNum) {
        return sysMailConst.get(dayNum);
    }

    public static LinkedHashMap<String, String> getFlow(int dayNum) {
        return flowMap.get(dayNum);
    }

    public static Map<Integer, Map<String, MailInfo>> getSysMailConst() {
        return sysMailConst;
    }

    /**
     * 广播消息
     */
    public static void putSysChatConst() {
        putSysChatConst(new ChatInfo(1, "00:00:01", "00:01:01", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "03:00:00", "03:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "06:00:00", "06:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "09:00:00", "09:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "12:00:00", "12:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "15:00:00", "15:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "18:00:00", "18:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "21:00:00", "21:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "22:00:00", "22:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(1, "23:00:00", "23:01:00", SysChatId.Cross_Begin));
        putSysChatConst(new ChatInfo(2, "00:00:01", "00:01:01", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "03:00:00", "03:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "06:00:00", "06:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "09:00:00", "09:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "12:00:00", "12:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "15:00:00", "15:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "18:00:00", "18:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "21:00:00", "21:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "22:00:00", "22:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(2, "23:00:00", "23:01:00", SysChatId.Cross_Reg));
        putSysChatConst(new ChatInfo(3, "09:00:00", "09:01:00", SysChatId.Cross_JiFen_Brocast));
        putSysChatConst(new ChatInfo(3, "11:00:00", "11:01:00", SysChatId.Cross_JiFen_Brocast));
        putSysChatConst(new ChatInfo(3, "13:00:00", "13:01:00", SysChatId.Cross_JiFen_Brocast));
        putSysChatConst(new ChatInfo(3, "15:00:00", "15:01:00", SysChatId.Cross_JiFen_Brocast));
        putSysChatConst(new ChatInfo(3, "17:00:00", "17:01:00", SysChatId.Cross_JiFen_Brocast));
        putSysChatConst(new ChatInfo(3, "19:00:00", "19:01:00", SysChatId.Cross_JiFen_Brocast));
        putSysChatConst(new ChatInfo(4, "09:00:00", "09:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "11:00:00", "11:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "13:00:00", "13:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "14:00:00", "14:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "17:00:00", "17:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "18:00:00", "18:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "20:00:00", "20:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(4, "22:00:00", "22:01:00", SysChatId.Cross_TaoTai_Brocast));
        putSysChatConst(new ChatInfo(5, "09:00:00", "09:01:00", SysChatId.Cross_Jue_Sai_Brocast));
        putSysChatConst(new ChatInfo(5, "12:00:00", "12:01:00", SysChatId.Cross_Jue_Sai_Brocast));
        putSysChatConst(new ChatInfo(5, "18:00:00", "18:01:00", SysChatId.Cross_Jue_Sai_Brocast));
        putSysChatConst(new ChatInfo(5, "20:00:00", "20:01:00", SysChatId.Cross_Jue_Sai_Brocast));
        putSysChatConst(new ChatInfo(5, "20:15:00", "20:16:00", SysChatId.Cross_Champion_Brocast));
        putSysChatConst(new ChatInfo(5, "21:00:00", "21:01:00", SysChatId.Cross_Champion_Brocast));
        putSysChatConst(new ChatInfo(5, "22:00:00", "22:01:00", SysChatId.Cross_Champion_Brocast));
        putSysChatConst(new ChatInfo(5, "23:59:00", "23:59:59", SysChatId.Cross_Champion_Brocast));
        putSysChatConst(new ChatInfo(5, "20:30:00", "20:31:00", SysChatId.Cross_Award_Brocast));
        putSysChatConst(new ChatInfo(6, "09:00:00", "09:01:00", SysChatId.Cross_Award_Brocast));
        putSysChatConst(new ChatInfo(6, "12:00:00", "12:01:00", SysChatId.Cross_Award_Brocast));
        putSysChatConst(new ChatInfo(6, "15:00:00", "15:01:00", SysChatId.Cross_Award_Brocast));
        putSysChatConst(new ChatInfo(6, "18:00:00", "18:01:00", SysChatId.Cross_Award_Brocast));
        putSysChatConst(new ChatInfo(6, "21:00:00", "21:01:00", SysChatId.Cross_Award_Brocast));
        putSysChatConst(new ChatInfo(7, "00:00:01", "00:01:00", SysChatId.Cross_End));
    }

    /**
     * @param info
     */
    private static void putSysChatConst(ChatInfo info) {
        Map<String, ChatInfo> map = sysChatConst.get(info.getDay());
        if (map == null) {
            map = new HashMap<String, ChatInfo>();
            sysChatConst.put(info.getDay(), map);
        }
        map.put(info.getBeginTime(), info);
    }

    private static void putSysMailConst() {
        putSysMailConst(new MailInfo(1, "00:00:01", "00:01:01", MailType.MOLD_CROSS_PLAN));
        putSysMailConst(new MailInfo(2, "00:00:01", "00:01:01", MailType.MOLD_CROSS_REG));
        putSysMailConst(new MailInfo(3, "00:00:01", "00:01:01", MailType.MOLD_JIFEN_PLAN));
        putSysMailConst(new MailInfo(3, "21:00:01", "21:01:01", MailType.MOLD_KNOCK_PLAN));
        putSysMailConst(new MailInfo(4, "12:30:01", "12:31:01", MailType.MOLD_KNOCK_PLAN));
        putSysMailConst(new MailInfo(4, "16:00:01", "16:01:01", MailType.MOLD_KNOCK_PLAN));
        putSysMailConst(new MailInfo(4, "19:30:01", "19:31:01", MailType.MOLD_KNOCK_PLAN));
        putSysMailConst(new MailInfo(4, "23:00:01", "23:01:01", MailType.MOLD_FINAL_PLAN));
        putSysMailConst(new MailInfo(CrossConst.STAGE.STATE_FINAL, "20:15:00", "20:16:00", MailType.MOLD_JIFEN_GET));
    }

    private static void putSysMailConst(MailInfo info) {
        Map<String, MailInfo> map = sysMailConst.get(info.getDay());
        if (map == null) {
            map = new HashMap<String, MailInfo>();
            sysMailConst.put(info.getDay(), map);
        }
        map.put(info.getBeginTime(), info);
    }

    private static void initFlowMap() {
        putFlow(CrossConst.STAGE.STAGE_ZIGEZHENDUO, "00:00:01", "23:59:59");
        putFlow(CrossConst.STAGE.STAGE_REG, "00:00:01", "23:59:59");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "12:30:00", "12:35:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "12:35:00", "12:40:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "12:40:00", "12:45:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "12:45:00", "12:50:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "12:50:00", "12:55:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "12:55:00", "13:00:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "16:30:00", "16:35:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "16:35:00", "16:40:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "16:40:00", "16:45:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "16:45:00", "16:50:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "16:50:00", "16:55:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "16:55:00", "17:00:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "20:30:00", "20:35:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "20:35:00", "20:40:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "20:40:00", "20:45:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "20:45:00", "20:50:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "20:50:00", "20:55:00");
        putFlow(CrossConst.STAGE.STAGE_JIFEN1, "20:55:00", "21:00:00");
        putFlow(CrossConst.STAGE.STAGE_KNOCK1, "12:00:00", "12:30:00");
        putFlow(CrossConst.STAGE.STAGE_KNOCK1, "15:30:00", "16:00:00");
        putFlow(CrossConst.STAGE.STAGE_KNOCK1, "19:00:00", "19:30:00");
        putFlow(CrossConst.STAGE.STAGE_KNOCK1, "22:30:00", "23:00:00");
        putFlow(CrossConst.STAGE.STATE_FINAL, "12:00:00", "12:15:00");
        putFlow(CrossConst.STAGE.STATE_FINAL, "20:00:00", "20:15:00");
    }

    private static void putFlow(int day, String beginTime, String endTime) {
        LinkedHashMap<String, String> map = flowMap.get(day);
        if (map == null) {
            map = new LinkedHashMap<String, String>();
            flowMap.put(day, map);
        }
        map.put(beginTime, endTime);
    }
}