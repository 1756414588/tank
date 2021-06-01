/**
 * @Title: GiftService.java
 * @Package com.account.service
 * @Description: TODO
 * @author ZhangJun
 * @date 2015年10月23日 上午11:04:07
 * @version V1.0
 */
package com.account.service;

import com.account.common.ServerSetting;
import com.account.constant.GameError;
import com.account.dao.impl.GiftDao;
import com.account.domain.Gift;
import com.account.domain.GiftCode;
import com.account.domain.GiftCodeExt;
import com.account.plat.impl.yyh.util.DateUtil;
import com.account.util.HttpHelper;
import com.account.util.PbHelper;
import com.account.util.VerifyCodeUtil;
import com.game.pb.BasePb;
import com.game.pb.InnerPb.UseGiftCodeRq;
import com.game.pb.InnerPb.UseGiftCodeRs;
import com.google.protobuf.InvalidProtocolBufferException;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;

import java.util.Date;

/**
 * @author ZhangJun
 * @ClassName: GiftService
 * @Description: TODO
 * @date 2015年10月23日 上午11:04:07
 */
public class GiftService {

    public Logger LOG = LoggerFactory.getLogger(GiftService.class);
    @Autowired
    private GiftDao giftDao;
    @Autowired
    protected ServerSetting serverSetting;


    public String generateGift(JSONObject req) {
        int operate = req.getInt("operate");
        if (operate == 1) {// 新增礼包类型
            int giftId = req.getInt("giftId");
            String giftName = req.getString("giftName");
            String beginTime = req.getString("beginTime");
            String endTime = req.getString("endTime");
            String giftStr = req.getString("gift");
            int reuse = 0;
            if (req.containsKey("reuse")) {
                reuse = req.getInt("reuse");
            }

            Gift gift = giftDao.selectGift(giftId);
            if (gift != null) {
                return "this gift already exist!";
            }

            try {
                JSONArray giftAward = JSONArray.fromObject(giftStr);
                if (giftAward.isEmpty() || !giftAward.isArray()) {
                    return "gift string invalid!";
                }
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                return "gift string invalid!";
            }

            try {
                gift = new Gift();
                gift.setGiftId(giftId);
                gift.setGiftName(giftName);
                gift.setBeginTime(DateUtil.stringToDate(beginTime, DateUtil.STRING_DATE_FORMAT));
                gift.setEndTime(DateUtil.stringToDate(endTime, DateUtil.STRING_DATE_FORMAT));
                gift.setValid(1);
                gift.setGift(giftStr);
                gift.setCreateTime(new Date());
                gift.setReuse(reuse);
                giftDao.insertGift(gift);

                return "create gift success!";
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                return "create gift fail!";
            }
        } else if (operate == 2) {// 新增兑换码,每次批次号需要不同
            int giftId = req.getInt("giftId");
            int count = req.getInt("count");
            String platNo = req.getString("platNo");
            String mark = req.getString("mark");//唯一标识，标记兑换码是谁添加
            Gift gift = giftDao.selectGift(giftId);
            if (gift == null) {
                return "this gift not exist!";
            }
            if (count <= 0 || count >= 100000) {
                return "count error!";
            }

            try {
                generateGiftCode(giftId, count, platNo, mark);
                return "create gift success!";
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                return "create gift fail!";
            }
        } else if (operate == 3) {// 新增礼包类型,同时新增兑换码,每次批次号需要不同
            int giftId = req.getInt("giftId");
            String giftName = req.getString("giftName");
            String beginTime = req.getString("beginTime");
            String endTime = req.getString("endTime");
            String giftStr = req.getString("gift");
            int count = req.getInt("count");
            String platNo = req.getString("platNo");
            String mark = req.getString("mark");//唯一标识，标记兑换码是谁添加
            int reuse = 0;
            if (count <= 0 || count >= 100000) {
                return "count error!";
            }
            if (req.containsKey("reuse")) {
                reuse = req.getInt("reuse");
            }
            Gift gift = giftDao.selectGift(giftId);
            if (gift != null) {
                return "this gift already exist!";
            }
            try {
                JSONArray giftAward = JSONArray.fromObject(giftStr);
                if (giftAward.isEmpty() || !giftAward.isArray()) {
                    return "gift string invalid!";
                }
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                return "gift string invalid!";
            }
            try {
                gift = new Gift();
                gift.setGiftId(giftId);
                gift.setGiftName(giftName);
                gift.setBeginTime(DateUtil.stringToDate(beginTime, DateUtil.STRING_DATE_FORMAT));
                gift.setEndTime(DateUtil.stringToDate(endTime, DateUtil.STRING_DATE_FORMAT));
                gift.setValid(1);
                gift.setGift(giftStr);
                gift.setCreateTime(new Date());
                gift.setReuse(reuse);
                giftDao.insertGift(gift);
                try {
                    generateGiftCode(giftId, count, platNo, mark);
                    return "create gift success!";
                } catch (Exception e) {
                    // TODO: handle exception
                    e.printStackTrace();
                    return "create gift fail!";
                }

                // return "create gift success!";
            } catch (Exception e) {
                // TODO: handle exception
                e.printStackTrace();
                return "create gift fail!";
            }
        }

        return "operate error!";
    }

    // public String generateGift(JSONObject req) {
    //
    //
    //
    // int giftId = req.getInt("giftId");
    // String giftName = req.getString("giftName");
    // int beginTime = req.getInt("beginTime");
    // int endTime = req.getInt("endTime");
    // String giftStr = req.getString("gift");
    // int count = req.getInt("count");
    // String batchNo = req.getString("batchNo");
    // Gift gift = giftDao.selectGift(giftId);
    // if (gift != null) {
    // return "this gift already exist!";
    // }
    //
    // try {
    // JSONArray giftAward = JSONArray.fromObject(giftStr);
    // if (giftAward.isEmpty() || !giftAward.isArray()) {
    // return "gift string invalid!";
    // }
    // } catch (Exception e) {
    // // TODO: handle exception
    // e.printStackTrace();
    // return "gift string invalid!";
    // }
    //
    // try {
    // gift = new Gift();
    // gift.setGiftId(giftId);
    // gift.setGiftName(giftName);
    // gift.setBeginTime(new Date(beginTime / 1000));
    // gift.setEndTime(new Date(endTime / 1000));
    // gift.setValid(1);
    // gift.setGift(giftStr);
    // gift.setCreateTime(new Date());
    // giftDao.insertGift(gift);
    //
    // return "create gift success!";
    // } catch (Exception e) {
    // // TODO: handle exception
    // e.printStackTrace();
    // return "create gift fail!";
    // }
    // } else if (operate == 2) {// 新增兑换码,每次批次号需要不同
    // int giftId = req.getInt("giftId");
    // int count = req.getInt("count");
    // String batchNo = req.getString("batchNo");
    //
    // Gift gift = giftDao.selectGift(giftId);
    // if (gift == null) {
    // return "this gift not exist!";
    // }
    //
    // if (count <= 0 || count >= 100000) {
    // return "count error!";
    // }
    //
    // int batchHead;
    // String batchTail;
    // try {
    // batchHead = Integer.valueOf(batchNo.substring(0, 2));
    // batchTail = batchNo.substring(2);
    // } catch (Exception e) {
    // // TODO: handle exception
    // return "batchNo error!";
    // }
    //
    // try {
    // generateGiftCode(giftId, batchHead, batchTail, count);
    // return "create gift success!";
    // } catch (Exception e) {
    // // TODO: handle exception
    // e.printStackTrace();
    // return "create gift fail!";
    // }
    // }
    //
    // return "operate error!";
    // }

    public static void main(String[] args) {
        // LOG.error(System.currentTimeMillis() / 1000);
//		Set<Integer> set = new HashSet<>(100000);
//		Date begin = new Date();
//		while (true) {
//			if (set.size() >= 100000) {
//				break;
//			}
//			int figure = RandomHelper.randomInSize(100000);
//			if (set.contains(figure)) {
//				continue;
//			}
//
//			set.add(figure);
//		}
//
//		for (Integer v : set) {
//			GiftCode giftCode = new GiftCode();
//			giftCode.setGiftId(1530);
//			giftCode.setGiftCode(153021 + convert(v));
//		}
//
//		Date end = new Date();
//		LOG.error("haust time:" + (end.getTime() - begin.getTime()));
//		LOG.error("generate size:" + set.size());

    }

    private void generateGiftCode(int giftId, int count, String platNo, String mark) {
        Date begin = new Date();

        for (int i = 0; i < count; i++) {
            GiftCode giftCode = new GiftCode();
            giftCode.setGiftId(giftId);
            giftCode.setGiftCode(VerifyCodeUtil.getVerifyCode());
            giftCode.setPlatNo(platNo);
            giftCode.setMark(mark);
            giftDao.insertGiftCode(giftCode);
        }
        Date end = new Date();
        LOG.error("haust time:" + (end.getTime() - begin.getTime()));
        LOG.error("generate size:" + count);
    }

    private static String convert(int v) {
        StringBuilder builder = new StringBuilder();
        int t = 0;
        for (int i = 0; i < 5; i++) {
            t = v % 10;
            v = v / 10;
            builder.append((char) (t + 97));
        }
        return builder.toString();
    }

    public GameError useGiftCode(UseGiftCodeRq req, UseGiftCodeRs.Builder builder) {
        long lordId = req.getLordId();
        int serverId = req.getServerId();

        int platNo = -1;// -1表示所有平台都可用
        if (req.hasPlatNo()) {
            platNo = req.getPlatNo();
        }

        String code = req.getCode();

        builder.setServerId(serverId);
        builder.setLordId(lordId);

        GiftCode giftCode = giftDao.selectGiftCode(code);
        if (giftCode == null) { // 兑换码不存在
            builder.setState(2);
            return GameError.OK;
        }

        if (giftCode.getServerId() != 0) {// 该码被使用过
            builder.setState(3);
            return GameError.OK;
        }

        // 获取礼包类型
        Gift gift = giftDao.selectGift(giftCode.getGiftId());
        if (gift == null) {
            builder.setState(4); // 兑换码无效
            return GameError.OK;
        }

        Date nowDate = new Date();
        if (!(gift.getBeginTime().getTime() <= nowDate.getTime() && gift.getEndTime().getTime() >= nowDate.getTime())) {
            builder.setState(5);// 时效性已过
            return GameError.OK;
        }

        if (gift.getReuse() == 0) {// 同一个类型不能被重复使用，同一个码只能使用一次
            // 判断玩家是否使用过同类型礼包
            GiftCode used = giftDao.selectGiftCodeByLord("" + gift.getGiftId(), serverId, lordId);
            if (used != null) {
                builder.setState(1);
                return GameError.OK;
            }
            // 判断渠道是否对
            if (!platNoIsRight(giftCode.getPlatNo(), platNo)) {
                builder.setState(6);
                return GameError.OK;
            }

//			if (!(giftCode.getPlatNo() == -1 || giftCode.getPlatNo() == platNo)) {
//				builder.setState(6);
//				return GameError.OK;
//			}
            giftCode.setServerId(serverId);
            giftCode.setLordId(lordId);
            giftCode.setUseTime(new Date());
            giftDao.updateGiftCode(giftCode);
        } else if (gift.getReuse() == 1) {// 同一个类型可以被同一个玩家多次使用

            // 判断渠道是否对
            if (!platNoIsRight(giftCode.getPlatNo(), platNo)) {
                builder.setState(6);
                return GameError.OK;
            }
            giftCode.setServerId(serverId);
            giftCode.setLordId(lordId);
            giftCode.setUseTime(new Date());
            giftDao.updateGiftCode(giftCode);
        }

        if (gift.getReuse() == 2) {// 同一个兑换码可以被不同角色使用
            // 角色是否使用过这个兑换码
            GiftCodeExt giftCodeExt = giftDao.selectGiftCodeExt(code, serverId, lordId);
            if (giftCodeExt != null) {
                builder.setState(3);
                return GameError.OK;
            }

            // 判断渠道是否对
            if (!platNoIsRight(giftCode.getPlatNo(), platNo)) {
                builder.setState(6);
                return GameError.OK;
            }

            giftCodeExt = new GiftCodeExt();
            giftCodeExt.setGiftCode(code);
            giftCodeExt.setLordId(lordId);
            giftCodeExt.setServerId(serverId);
            giftCodeExt.setPlatNo(platNo);
            giftCodeExt.setUseTime(new Date());
            giftDao.insertGiftCodeExt(giftCodeExt);
        }

        long now = System.currentTimeMillis();
        long begin = gift.getBeginTime().getTime();
        long end = gift.getEndTime().getTime();
        if (gift.getValid() != 1 || now < begin || now > end) {// 兑换码无效
            builder.setState(4);
            return GameError.OK;
        }

        builder.setState(0);
        builder.setAward(gift.getGift());
        return GameError.OK;
    }

    /**
     * 判断渠道是否包含
     *
     * @param paltNos
     * @param platNo
     * @return
     */
    private boolean platNoIsRight(String paltNos, int platNo) {
        String[] ts = paltNos.split("[|]");

        for (String s : ts) {
            if (s.equals("-1") || s.equals("" + platNo)) {
                return true;
            }
        }

        return false;
    }


    public void useGiftCode(JSONObject result, long lordId, int serverId, int platNo, String code, String actName) throws InvalidProtocolBufferException {

        GiftCode giftCode = giftDao.selectGiftCode(code);
        if (giftCode == null) {
            result.put("code", 2);
            result.put("msg", "兑换码不存在");
            return;
        }

        if (giftCode.getServerId() != 0) {
            result.put("code", 3);
            result.put("msg", "该码被使用过");
            return;
        }

        // 获取礼包类型
        Gift gift = giftDao.selectGift(giftCode.getGiftId());
        if (gift == null) {
            result.put("code", 4);
            result.put("msg", "兑换码无效");
            return;
        }

        Date nowDate = new Date();
        if (!(gift.getBeginTime().getTime() <= nowDate.getTime() && gift.getEndTime().getTime() >= nowDate.getTime())) {
            result.put("code", 5);
            result.put("msg", "时效性已过");
            return;
        }

        if (gift.getReuse() == 0) {// 同一个类型不能被重复使用，同一个码只能使用一次
            // 判断玩家是否使用过同类型礼包
            GiftCode used = giftDao.selectGiftCodeByLord("" + gift.getGiftId(), serverId, lordId);
            if (used != null) {
                result.put("code", 6);
                result.put("msg", "同一个类型不能被重复使用，同一个码只能使用一次");
                return;
            }
            // 判断渠道是否对
            if (!platNoIsRight(giftCode.getPlatNo(), platNo)) {
                result.put("code", 7);
                result.put("msg", "渠道不对");
                return;
            }
            giftCode.setServerId(serverId);
            giftCode.setLordId(lordId);
            giftCode.setUseTime(new Date());
            giftDao.updateGiftCode(giftCode);
        } else if (gift.getReuse() == 1) {// 同一个类型可以被同一个玩家多次使用

            //
            if (!platNoIsRight(giftCode.getPlatNo(), platNo)) {
                result.put("code", 8);
                result.put("msg", "同一个类型可以被同一个玩家多次使用，渠道不对");
                return;
            }
            giftCode.setServerId(serverId);
            giftCode.setLordId(lordId);
            giftCode.setUseTime(new Date());
            giftDao.updateGiftCode(giftCode);
        }

        if (gift.getReuse() == 2) {// 同一个兑换码可以被不同角色使用
            // 角色是否使用过这个兑换码
            GiftCodeExt giftCodeExt = giftDao.selectGiftCodeExt(code, serverId, lordId);
            if (giftCodeExt != null) {
                result.put("code", 9);
                result.put("msg", "同一个兑换码可以被不同角色使用，角色是否使用过这个兑换码");
                return;
            }

            // 判断渠道是否对
            if (!platNoIsRight(giftCode.getPlatNo(), platNo)) {
                result.put("code", 10);
                result.put("msg", "10判断渠道是否对");
                return;
            }

            giftCodeExt = new GiftCodeExt();
            giftCodeExt.setGiftCode(code);
            giftCodeExt.setLordId(lordId);
            giftCodeExt.setServerId(serverId);
            giftCodeExt.setPlatNo(platNo);
            giftCodeExt.setUseTime(new Date());
            giftDao.insertGiftCodeExt(giftCodeExt);
        }

        long now = System.currentTimeMillis();
        long begin = gift.getBeginTime().getTime();
        long end = gift.getEndTime().getTime();
        if (gift.getValid() != 1 || now < begin || now > end) {// 兑换码无效
            result.put("code", 11);
            result.put("msg", "兑换码无效11");
            return;
        }

        StringBuilder mailAward = new StringBuilder();
        JSONArray aw = JSONArray.fromObject(gift.getGift());
        for (Object str : aw) {
            JSONArray a = JSONArray.fromObject(str);
            mailAward.append(a.get(0));
            mailAward.append("|");
            mailAward.append(a.get(1));
            mailAward.append("|");
            mailAward.append(a.get(2));
            mailAward.append("&");
        }

        String mailAwardStr = mailAward.substring(0, mailAward.length() - 1);

        String content = "";
        if (actName != null && !actName.equals("")) {
            content = actName;
        }
        BasePb.Base msg = null;
        if (content.equals("")) {
            msg = PbHelper.createSendToMailRq("", 4, "0", 0, lordId + "", "162", "", "", content, mailAwardStr, 0, 0, 0, 0, "");
        } else {
            msg = PbHelper.createSendToMailRq("", 4, "0", 0, lordId + "", "163", "", "", content, mailAwardStr, 0, 0, 0, 0, "");
        }

        String url = null;
        try {
            url = serverSetting.getServerUrl(serverId);

            if (url != null) {
                HttpHelper.sendMsgToGame(url, msg);
            }

        } catch (Exception e) {
            e.printStackTrace();
            result.put("msg", "服务器未开启");
            result.put("code", -100);
            return;
        }

        result.put("ret", "success");
        result.put("msg", "成功");
        result.put("code", 200);
    }

}
