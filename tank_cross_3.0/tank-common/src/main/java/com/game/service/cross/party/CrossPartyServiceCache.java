package com.game.service.cross.party;

import com.game.constant.MailType;
import com.game.constant.SysChatId;
import com.game.service.cross.ChatInfo;
import com.game.service.cross.MailInfo;

import java.util.HashMap;
import java.util.Map;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/14 11:03
 * @description：跨服军团战缓存
 */
public class CrossPartyServiceCache {

  /** 广播消息 day,time,sysChatId */
  private static final Map<Integer, Map<String, ChatInfo>> sysChatConst =
      new HashMap<Integer, Map<String, ChatInfo>>();

  /** 邮件 */
  private static final Map<Integer, Map<String, MailInfo>> sysMailConst =
      new HashMap<Integer, Map<String, MailInfo>>();

  public static Map<String, ChatInfo> getSysChatConst(int dayNum) {
    return sysChatConst.get(dayNum);
  }

  public static Map<String, MailInfo> getSysMailConst(int dayNum) {
    return sysMailConst.get(dayNum);
  }

  static {
    putSysChatConst();
    putSysMailConst();
  }

  private static void putSysChatConst() {
    putSysChatConst(new ChatInfo(1, "00:00:01", "00:01:01", SysChatId.CP_BEGIN));
    putSysChatConst(new ChatInfo(1, "09:00:01", "09:01:01", SysChatId.CP_BEGIN));
    putSysChatConst(new ChatInfo(1, "12:00:01", "12:01:01", SysChatId.CP_BEGIN));
    putSysChatConst(new ChatInfo(1, "18:00:01", "18:01:01", SysChatId.CP_BEGIN));

    putSysChatConst(new ChatInfo(1, "21:00:01", "21:01:01", SysChatId.CP_REG));
    putSysChatConst(new ChatInfo(2, "09:00:01", "09:01:01", SysChatId.CP_REG));
    putSysChatConst(new ChatInfo(2, "12:00:01", "12:01:01", SysChatId.CP_REG));
    putSysChatConst(new ChatInfo(2, "20:00:01", "20:01:01", SysChatId.CP_REG));
    putSysChatConst(new ChatInfo(2, "22:00:01", "22:01:01", SysChatId.CP_REG));
    putSysChatConst(new ChatInfo(2, "23:00:01", "23:01:01", SysChatId.CP_REG));

    putSysChatConst(new ChatInfo(3, "00:00:01", "00:01:01", SysChatId.CP_PRE));
    putSysChatConst(new ChatInfo(3, "09:00:01", "09:01:01", SysChatId.CP_PRE));
    putSysChatConst(new ChatInfo(3, "12:00:01", "12:01:01", SysChatId.CP_PRE));
    putSysChatConst(new ChatInfo(3, "16:00:01", "16:01:01", SysChatId.CP_PRE));

    putSysChatConst(new ChatInfo(3, "21:01:01", "21:02:01", SysChatId.cp_231));
    putSysChatConst(new ChatInfo(4, "09:00:01", "09:01:01", SysChatId.cp_231));
    putSysChatConst(new ChatInfo(4, "12:00:01", "12:01:01", SysChatId.cp_231));
    putSysChatConst(new ChatInfo(4, "13:00:01", "13:01:01", SysChatId.cp_231));

    putSysChatConst(new ChatInfo(4, "16:00:01", "16:01:01", SysChatId.cp_224));
    putSysChatConst(new ChatInfo(4, "17:00:01", "17:01:01", SysChatId.cp_224));
    putSysChatConst(new ChatInfo(4, "18:00:01", "18:01:01", SysChatId.cp_224));
    putSysChatConst(new ChatInfo(4, "19:00:01", "19:01:01", SysChatId.cp_224));

    putSysChatConst(new ChatInfo(4, "16:30:01", "16:31:01", SysChatId.cp_229));
    putSysChatConst(new ChatInfo(4, "21:00:01", "21:01:01", SysChatId.cp_229));
    putSysChatConst(new ChatInfo(5, "09:00:01", "09:01:01", SysChatId.cp_229));
    putSysChatConst(new ChatInfo(5, "12:00:01", "12:01:01", SysChatId.cp_229));
    putSysChatConst(new ChatInfo(5, "18:00:01", "18:01:01", SysChatId.cp_229));
    putSysChatConst(new ChatInfo(5, "21:00:01", "21:01:01", SysChatId.cp_229));

    putSysChatConst(new ChatInfo(6, "00:00:01", "00:01:01", SysChatId.cp_234));
  }

  private static void putSysMailConst() {
    putSysMailConst(new MailInfo(1, "00:00:01", "00:01:01", MailType.MOLD_CP_104));

    putSysMailConst(new MailInfo(1, "21:00:01", "21:01:01", MailType.MOLD_CP_105));

    putSysMailConst(new MailInfo(3, "21:00:01", "21:01:01", MailType.MOLD_CP_106)); // 107

    putSysMailConst(new MailInfo(4, "16:00:01", "16:01:01", MailType.MOLD_CP_109)); // 112,113,114
  }

  static void putSysMailConst(MailInfo info) {
    Map<String, MailInfo> map = sysMailConst.get(info.getDay());
    if (map == null) {
      map = new HashMap<String, MailInfo>();
      sysMailConst.put(info.getDay(), map);
    }
    map.put(info.getBeginTime(), info);
  }

  static void putSysChatConst(ChatInfo info) {
    Map<String, ChatInfo> map = sysChatConst.get(info.getDay());
    if (map == null) {
      map = new HashMap<String, ChatInfo>();
      sysChatConst.put(info.getDay(), map);
    }
    map.put(info.getBeginTime(), info);
  }
}
