/**
 * @Title: PbHelper.java
 * @Package com.account.util
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年11月6日 下午6:43:38
 * @version V1.0
 */
package com.account.util;

import com.game.pb.BasePb.Base;
import com.game.pb.InnerPb;
import com.game.pb.InnerPb.*;
import com.google.protobuf.GeneratedMessage.GeneratedExtension;

import java.util.List;

/**
 * @author ZhangJun
 * @ClassName: PbHelper
 * @Description: TODOR
 * @date 2015年11月6日 下午6:43:38
 */
public class PbHelper {
    public static byte[] putShort(short s) {
        byte[] b = new byte[2];
        b[0] = (byte) (s >> 8);
        b[1] = (byte) (s >> 0);
        return b;
    }

    static public short getShort(byte[] b, int index) {
        return (short) (((b[index + 1] & 0xff) | b[index + 0] << 8));
    }

    static public <T> Base createRqBase(int cmd, Long param, GeneratedExtension<Base, T> ext, T msg) {
        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(cmd);
        if (param != null) {
            baseBuilder.setParam(param);
        }
        baseBuilder.setExtension(ext, msg);
        return baseBuilder.build();
    }

    static public Base createSendToMailRq(String marking, int type, String channleNo, int online, String to, String moldId, String sendName, String title,
                                          String content, String award, int alv, int blv, int avip, int bvip, String partys) {
        SendToMailRq.Builder builder = SendToMailRq.newBuilder();
        builder.setMarking(marking);
        builder.setType(type);
        builder.setChannelNo(channleNo);
        builder.setOnline(online);
        builder.setTo(to);
        builder.setMoldId(moldId);
        builder.setSendName(sendName);
        builder.setTitle(title);
        builder.setContont(content);
        builder.setAward(award);
        builder.setAlv(alv);
        builder.setBlv(blv);
        builder.setAvip(avip);
        builder.setBvip(bvip);
        if (partys != null) {
            builder.setPartys(partys);
        }
        Base msg = PbHelper.createRqBase(SendToMailRq.EXT_FIELD_NUMBER, null, SendToMailRq.ext, builder.build());
        return msg;
    }

    static public Base createForbiddenRq(String nick, int forbiddenId, long time) {
        ForbiddenRq.Builder builder = ForbiddenRq.newBuilder();
        builder.setNick(nick);
        builder.setForbiddenId(forbiddenId);
        builder.setMarking("1");
        builder.setTime(time);
        Base msg = PbHelper.createRqBase(ForbiddenRq.EXT_FIELD_NUMBER, null, ForbiddenRq.ext, builder.build());
        return msg;
    }

    static public Base createForbiddenRq(long lordId, int forbiddenId, long time) {
        ForbiddenRq.Builder builder = ForbiddenRq.newBuilder();
        builder.setLordId(lordId);
        builder.setForbiddenId(forbiddenId);
        builder.setMarking("1");
        builder.setTime(time);
        Base msg = PbHelper.createRqBase(ForbiddenRq.EXT_FIELD_NUMBER, null, ForbiddenRq.ext, builder.build());
        return msg;
    }

    static public Base createNoticeRq(String marking, String notice) {
        NoticeRq.Builder builder = NoticeRq.newBuilder();
        builder.setMarking(marking);
        builder.setContent(notice);
        Base msg = PbHelper.createRqBase(NoticeRq.EXT_FIELD_NUMBER, null, NoticeRq.ext, builder.build());
        return msg;
    }

    static public Base createLordBaseRq(String marking, long lordId, int type) {
        GetLordBaseRq.Builder builder = GetLordBaseRq.newBuilder();
        builder.setMarking(marking);
        builder.setLordId(lordId);
        builder.setType(type);
        Base msg = PbHelper.createRqBase(GetLordBaseRq.EXT_FIELD_NUMBER, null, GetLordBaseRq.ext, builder.build());
        return msg;
    }

    static public Base createRankBaseRq(String marking, int type, int num) {
        GetRankBaseRq.Builder builder = GetRankBaseRq.newBuilder();
        builder.setMarking(marking);
        builder.setType(type);
        builder.setNum(num);
        Base msg = PbHelper.createRqBase(GetRankBaseRq.EXT_FIELD_NUMBER, null, GetRankBaseRq.ext, builder.build());
        return msg;
    }

    static public Base createPartyMembersRq(String marking, String partyName) {
        GetPartyMembersRq.Builder builder = GetPartyMembersRq.newBuilder();
        builder.setMarking(marking);
        builder.setPartyName(partyName);
        Base msg = PbHelper.createRqBase(GetPartyMembersRq.EXT_FIELD_NUMBER, null, GetPartyMembersRq.ext, builder.build());
        return msg;
    }

    static public Base createVipBaseRq(String marking, long lordId, int type, int value) {
        ModVipRq.Builder builder = ModVipRq.newBuilder();
        builder.setMarking(marking);
        builder.setLordId(lordId);
        builder.setType(type);
        builder.setValue(value);
        Base msg = PbHelper.createRqBase(ModVipRq.EXT_FIELD_NUMBER, null, ModVipRq.ext, builder.build());
        return msg;
    }

    static public Base createRecalcBaseRq() {
        RecalcResourceRq.Builder builder = RecalcResourceRq.newBuilder();
        Base msg = PbHelper.createRqBase(RecalcResourceRq.EXT_FIELD_NUMBER, null, RecalcResourceRq.ext, builder.build());
        return msg;
    }

    static public Base createCensusBaseRq(String marking, int alv, int blv, int vip, int type, int id, int count) {
        CensusBaseRq.Builder builder = CensusBaseRq.newBuilder();
        builder.setMarking(marking);
        builder.setAlv(alv);
        builder.setBlv(blv);
        builder.setVip(vip);
        builder.setType(type);
        builder.setId(id);
        builder.setCount(count);
        Base msg = PbHelper.createRqBase(CensusBaseRq.EXT_FIELD_NUMBER, null, CensusBaseRq.ext, builder.build());
        return msg;
    }

    static public Base createModLordBaseRq(String marking, long lordId, int type, int keyId, int value) {
        ModLordRq.Builder builder = ModLordRq.newBuilder();
        builder.setMarking(marking);
        builder.setLordId(lordId);
        builder.setType(type);
        builder.setKeyId(keyId);
        builder.setValue(value);
        Base msg = PbHelper.createRqBase(ModLordRq.EXT_FIELD_NUMBER, null, ModLordRq.ext, builder.build());
        return msg;
    }

    static public Base createModPartyMemberJob(String marking, long lordId, int job) {
        ModPartyMemberJobRq.Builder builder = ModPartyMemberJobRq.newBuilder();
        builder.setLordId(lordId);
        builder.setJob(job);
        Base msg = PbHelper.createRqBase(ModPartyMemberJobRq.EXT_FIELD_NUMBER, null, ModPartyMemberJobRq.ext, builder.build());
        return msg;
    }

    static public Base createReloadParamBaseRq(String marking, int type) {
        ReloadParamRq.Builder builder = ReloadParamRq.newBuilder();
        builder.setMarking(marking);
        builder.setType(type);
        Base msg = PbHelper.createRqBase(ReloadParamRq.EXT_FIELD_NUMBER, null, ReloadParamRq.ext, builder.build());
        return msg;
    }

    static public Base createModPropRq(String marking, long lordId, int type, String props) {
        ModPropRq.Builder builder = ModPropRq.newBuilder();
        builder.setMarking(marking);
        builder.setLordId(lordId);
        builder.setType(type);
        builder.setProps(props);
        Base msg = PbHelper.createRqBase(ModPropRq.EXT_FIELD_NUMBER, null, ModPropRq.ext, builder.build());
        return msg;
    }

    static public Base createModNameRq(String marking, long lordId, String name) {
        ModNameRq.Builder builder = ModNameRq.newBuilder();
        builder.setMarking(marking);
        builder.setLordId(lordId);
        builder.setName(name);
        Base msg = PbHelper.createRqBase(ModNameRq.EXT_FIELD_NUMBER, null, ModNameRq.ext, builder.build());
        return msg;
    }

    static public Base createModPlatNoRq(long oldLordId, long newLordId) {
        ChangePlatNoRq.Builder builder = ChangePlatNoRq.newBuilder();
        builder.setDestLordId(oldLordId);
        builder.setSrcLordId(newLordId);
        Base msg = PbHelper.createRqBase(ChangePlatNoRq.EXT_FIELD_NUMBER, null, ChangePlatNoRq.ext, builder.build());
        return msg;
    }

    static public Base createHotfixRq(String hotfixId) {
        InnerPb.HotfixClassRq.Builder builder = InnerPb.HotfixClassRq.newBuilder();
        builder.setHotfixId(hotfixId);
        return PbHelper.createRqBase(InnerPb.HotfixClassRq.EXT_FIELD_NUMBER, null, InnerPb.HotfixClassRq.ext, builder.build());
    }

    static public Base createExecuteHotfixRq() {
        InnerPb.ExecutHotfixRq.Builder builder = InnerPb.ExecutHotfixRq.newBuilder();
        return PbHelper.createRqBase(InnerPb.ExecutHotfixRq.EXT_FIELD_NUMBER, null, InnerPb.ExecutHotfixRq.ext, builder.build());
    }

    static public Base createAddAttackFreeBuffRq(List<Long> ids, int second, boolean sendMail) {
        InnerPb.AddAttackFreeBuffRq.Builder builder = InnerPb.AddAttackFreeBuffRq.newBuilder();
        builder.setSecond(second);
        builder.setSendMail(sendMail);
        if (ids != null && !ids.isEmpty()) {
            builder.addAllLordId(ids);
        }
        return PbHelper.createRqBase(InnerPb.AddAttackFreeBuffRq.EXT_FIELD_NUMBER, null, InnerPb.AddAttackFreeBuffRq.ext, builder.build());
    }


    static public Base createEnergyRq(String mak,long lordId) {
        InnerPb.GetEnergyBaseRq.Builder msg = InnerPb.GetEnergyBaseRq.newBuilder();
        msg.setMarking(mak);
        msg.setLordId(lordId);
        Base rqBase = PbHelper.createRqBase(GetEnergyBaseRq.EXT_FIELD_NUMBER, null, GetEnergyBaseRq.ext, msg.build());
        return rqBase;
    }
}
