package com.account.service;

import java.util.Iterator;
import java.util.List;
import java.util.Map.Entry;

import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.context.request.WebRequest;

import com.account.common.ServerSetting;
import com.account.dao.impl.ForbidDeviceDao;
import com.account.handle.PlatHandle;
import com.account.msg.impl.php.PhpMsgManager;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.util.HttpHelper;
import com.account.util.PbHelper;
import com.account.util.StringHelper;
import com.game.pb.BasePb.Base;

/**
 * @author ChenKui
 * @version 创建时间：2016-1-8 下午5:11:06
 * @declare
 */

public class PhpRecService {

    public static Logger LOG = LoggerFactory.getLogger(PhpRecService.class);

    @Autowired
    protected ServerSetting serverSetting;

    @Autowired
    private PlatHandle platHandle;

    @Autowired
    private ForbidDeviceDao forbidDeviceDao;

    public int doLogic(WebRequest request, HttpServletResponse response) {

        String toolId = request.getParameter("toolId");
        int getData = 0;
        if (toolId == null) {// 根据toolId判断执行什么业务
            getData = 1;
        }
        int reqCode = 0;
        JSONObject json = new JSONObject();
        String callback = String.valueOf(System.currentTimeMillis());
        json.put("callback", callback);
        if ("sendMail".equals(toolId)) {// 邮件信息{code:200}
            reqCode = sendMailToGame(callback, request, json);
        } else if ("getBag".equals(toolId)) {// 背包请求
            reqCode = getLordBase(callback, request);
        } else if ("getBagBack".equals(toolId)) {// 用户信息
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getTank".equals(toolId)) {// 请求坦克信息
            reqCode = getLordBase(callback, request);
        } else if ("getTankBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getFrom".equals(toolId)) {// 请求布阵信息
            reqCode = getLordBase(callback, request);
        } else if ("getFromBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getHero".equals(toolId)) {// 请求武将信息
            reqCode = getLordBase(callback, request);
        } else if ("getHeroBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getBuild".equals(toolId)) {// 请求建筑信息
            reqCode = getLordBase(callback, request);
        } else if ("getBuildBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMsg(response, code);
        } else if ("getScience".equals(toolId)) {// 请求科技信息
            reqCode = getLordBase(callback, request);
        } else if ("getScienceBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getPart".equals(toolId)) {// 请求配件信息
            reqCode = getLordBase(callback, request);
        } else if ("getPartBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getEquip".equals(toolId)) {// 请求配件信息
            reqCode = getLordBase(callback, request);
        } else if ("getEquipBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getRank".equals(toolId)) {// 请求排行榜
            reqCode = getRankBase(callback, request);
        } else if ("getRankBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getMember".equals(toolId)) {// 请求軍團成員信息
            reqCode = getMember(callback, request);
        } else if ("getMemberBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("forbidden".equals(toolId)) {// 禁言封号
            reqCode = forbidden(request);
        } else if ("forbidById".equals(toolId)) {// 禁言封号
            reqCode = forbidById(request);
        } else if ("notice".equals(toolId)) {// 公告
            reqCode = gmNotice(callback, request, json);
        } else if ("modVip".equals(toolId)) {// VIP修改
            reqCode = modVip(callback, request);
        } else if ("recalcResource".equals(toolId)) {// 重新计算资源产量上限
            reqCode = recalcResource(callback, request);
        } else if ("payRecharge".equals(toolId)) {// 充值补单
            reqCode = payRecharge(callback, request, json, false);
        } else if ("addPayGold".equals(toolId)) {// 补单不记录
            reqCode = payRecharge(callback, request, json, true);
        } else if ("census".equals(toolId)) {// 统计
            reqCode = census(callback, request, json);
        } else if ("modLord".equals(toolId)) {// 修改玩家数据
            reqCode = modLordRq(callback, request);
        } else if ("modMemberJob".equals(toolId)) {// 修改軍團職位
            reqCode = modPartyMemberJob(callback, request);
        } else if ("modProp".equals(toolId)) {// 修改玩家道具数量
            reqCode = modProp(callback, request);
        } else if ("modName".equals(toolId)) {// 修改玩家名字
            reqCode = modName(callback, request);
        } else if ("forbidByDevice".equals(toolId)) {// 封设备号
            reqCode = forbidByDeviceNo(request);
        } else if ("reload".equals(toolId)) {// 重加载配置数据
            reqCode = reloadParamRq(callback, request, json);
        } else if ("modPlatNo".equals(toolId)) { // 角色交换渠道
            reqCode = modPlatNo(response, request);
        } else if ("getMedal".equals(toolId)) {// 获取勋章信息
            reqCode = getLordBase(callback, request);
        } else if ("getMedalBack".equals(toolId)) {// 获取勋章回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getSurplusMedal".equals(toolId)) { // 获取多余勋章
            reqCode = getLordBase(callback, request);
        } else if ("getSurplusMedalBack".equals(toolId)) { // 获取多余勋章回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getMedalChip".equals(toolId)) { // 获取勋章碎片
            reqCode = getLordBase(callback, request);
        } else if ("getMedalChipBack".equals(toolId)) { // 获取勋章碎片回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getMedalMaterial".equals(toolId)) { // 获取勋章材料
            reqCode = getLordBase(callback, request);
        } else if ("getMedalMaterialBack".equals(toolId)) { // 获取勋章材料回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getEquip".equals(toolId)) { // 获取军备详情
            reqCode = getLordBase(callback, request);
        } else if ("getEquipBack".equals(toolId)) { // 获取军备详情回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getSurplusEquip".equals(toolId)) { // 获取多余军备
            reqCode = getLordBase(callback, request);
        } else if ("getSurplusEquipBack".equals(toolId)) { // 获取多余军备回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getLeqMat".equals(toolId)) { // 获取军备材料图纸
            reqCode = getLordBase(callback, request);
        } else if ("getLeqMatBack".equals(toolId)) {// 获取军备材料图纸回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getHuangbao".equals(toolId)) { // 获取荒宝碎片
            reqCode = getLordBase(callback, request);
        } else if ("getHuangbaoBack".equals(toolId)) { // 获取荒宝碎片回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("getMedalBouns".equals(toolId)) {// 勋章展厅展示勋章id
            reqCode = getLordBase(callback, request);
        } else if ("getMedalBounsBack".equals(toolId)) { // 勋章展厅展示勋章id回调
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);
        } else if ("hotfixClass".equals(toolId)) {//热更新Class类
            reqCode = hotfixClass(callback, request);
        } else if ("executeHotfix".equals(toolId)) {//执行热更程序
            reqCode = executeHotfix(callback, request, json);
        } else if ("addAttackFreeBuff".equals(toolId)) {
            reqCode = addAttackFreeBuff(callback, request, json);//增加免战buff
        } else if ("getEnergy".equals(toolId)) {
            reqCode = getEnergtLevel(callback, request);//能源核心
        } else if ("getEnergyBack".equals(toolId)) {
            String code = request.getParameter("code");
            getData = phpBackMultipleMsg(response, code);//能源核心回调
        }else {
            LOG.error("not found toolId :" + toolId);
        }


        if (getData != 200) {// 如果不是拉取数值
            json.put("code", reqCode);
            PhpMsgManager.getInstance().sendMsg(response, json);
        } else {

        }
        return 200;
    }

    /**
     * @return
     */
    protected int msgToGameServer(int serverId, Base msg) {
        String url = serverSetting.getServerUrl(serverId);
        if (url == null) {// 无法取到游戏服地址
            return 2;
        }
        try {
            LOG.error("url " + url + "|packets " + msg);
            Base back = HttpHelper.sendMailMsgToGame(url, msg);
            if (back != null && back.getCode() == 200) {
                LOG.error("发送消息成功" + back.getCmd());
                return 200;
            }
            return 3;
        } catch (Exception e) {
            e.printStackTrace();
            return 100;
        }
    }

    /**
     * 给所有的game发送消息
     *
     * @param msg
     * @return
     */
    protected int msgToAllGameServer(Base msg, JSONObject json) {
        try {
            JSONArray arr = new JSONArray();
            Iterator<Entry<Integer, JSONObject>> it = serverSetting.getMailServerList().entrySet().iterator();
            while (it.hasNext()) {
                Entry<Integer, JSONObject> en = it.next();
                int id = en.getKey();
                JSONObject s1 = en.getValue();
                String url = s1.getString("url");
                LOG.error("url " + url + "|packets " + msg);
                Base back = HttpHelper.sendMailMsgToGame(url, msg);
                if (back == null) {
                    int[] res = {id, -1};
                    arr.add(res);
                } else {
                    if (back.getCode() == 200) {
                        LOG.error("发送消息成功|" + back.getCmd());
                    }
                    int[] res = {id, back.getCode()};
                    arr.add(res);
                }
            }
            json.put("res", arr);
            return 200;
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0;
    }

    /**
     * 增加免战BUFF
     *
     * @param marking
     * @param request
     * @param json
     * @return
     */
    private int addAttackFreeBuff(String marking, WebRequest request, JSONObject json) {
        String serverId = request.getParameter("sid");
        String lordIds = request.getParameter("lordIds");
        String second_str = request.getParameter("second");
        String sendMail = request.getParameter("sendMail");
        if (serverId == null || second_str == null) {
            return 0;
        }
        List<Long> ids = StringHelper.parserString2ListLong(lordIds);
        boolean bSendMail = "1".equals(sendMail);
        int second = Integer.parseInt(second_str);
        Base msg = PbHelper.createAddAttackFreeBuffRq(ids, second, bSendMail);
        if (serverId.equals("0")) {
            return msgToAllGameServer(msg, json);
        } else {
            LOG.error("serverId ：" + serverId);
            JSONArray arr = new JSONArray();
            String[] serverIds = serverId.split("\\|");
            for (int i = 0; i < serverIds.length; i++) {
                int sid = Integer.parseInt(serverIds[i]);
                int code = msgToGameServer(sid, msg);
                arr.add(new int[]{sid, code});
            }
            json.put("res", arr);
            return 200;
        }
    }

    /**
     * 服务器热更新Class
     *
     * @param marking
     * @param request
     * @return
     */
    private int executeHotfix(String marking, WebRequest request, JSONObject json) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        Base msg = PbHelper.createExecuteHotfixRq();
        if (serverId.equals("0")) {
            return msgToAllGameServer(msg, json);
        } else {
            LOG.error("serverId ：" + serverId);
            JSONArray arr = new JSONArray();
            String[] serverIds = serverId.split("\\|");
            for (int i = 0; i < serverIds.length; i++) {
                int sid = Integer.parseInt(serverIds[i]);
                int code = msgToGameServer(sid, msg);
                arr.add(new int[]{sid, code});
            }
            json.put("res", arr);
            return 200;
        }
    }

    /**
     * 服务器热更新Class
     *
     * @param marking
     * @param request
     * @return
     */
    private int hotfixClass(String marking, WebRequest request) {
        String hotfixId = request.getParameter("hotfixId");
        Base msg = PbHelper.createHotfixRq(hotfixId);
        int sid = Integer.parseInt(request.getParameter("sid"));
        return msgToGameServer(sid, msg);
    }

    /**
     * 获取玩家的基础信息
     *
     * @param marking
     * @param request
     * @return
     */
    public int getLordBase(String marking, WebRequest request) {
        long lordId = Long.parseLong(request.getParameter("lordId"));
        int sid = Integer.parseInt(request.getParameter("sid"));
        int type = Integer.parseInt(request.getParameter("type"));
        Base msg = PbHelper.createLordBaseRq(marking, lordId, type);
        return msgToGameServer(sid, msg);
    }

    /**
     * 获取排行榜信息
     *
     * @param marking
     * @param request
     * @return
     */
    public int getRankBase(String marking, WebRequest request) {
        int type = Integer.parseInt(request.getParameter("type"));
        int num = Integer.parseInt(request.getParameter("num"));
        int sid = Integer.parseInt(request.getParameter("sid"));
        Base msg = PbHelper.createRankBaseRq(marking, type, num);
        return msgToGameServer(sid, msg);
    }

    /**
     * 获取軍團成員信息
     *
     * @param marking
     * @param request
     * @return
     */
    public int getMember(String marking, WebRequest request) {
        String partyName = request.getParameter("partyName");
        int sid = Integer.parseInt(request.getParameter("sid"));
        Base msg = PbHelper.createPartyMembersRq(marking, partyName);
        return msgToGameServer(sid, msg);
    }

    /**
     * @param response
     * @param jsonCallback
     * @param code
     * @return
     */
    public int phpBackMultipleMsg(HttpServletResponse response, String code) {
        JSONArray jsona = PhpMsgManager.getInstance().getMultipleMsg(code);
        PhpMsgManager.getInstance().sendMultiple(response, jsona);
        return 200;
    }

    public int phpBackMsg(HttpServletResponse response, String code) {
        JSONObject json = PhpMsgManager.getInstance().getMsg(code);
        PhpMsgManager.getInstance().sendMsg(response, json);
        return 200;
    }

    /**
     * 发送邮件
     *
     * @param request
     * @return
     */
    public int sendMailToGame(String marking, WebRequest request, JSONObject json) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }

        // 发送类型,渠道,在线
        int type = Integer.parseInt(request.getParameter("type"));
        String channelNo = request.getParameter("channel");
        int online = Integer.parseInt(request.getParameter("online"));
        String to = request.getParameter("to");
        String title = request.getParameter("title");
        String moldId = request.getParameter("moldId");
        String content = request.getParameter("content");
        String mailAward = request.getParameter("mailAward");
        int alv = Integer.parseInt(request.getParameter("alv"));
        int blv = Integer.parseInt(request.getParameter("blv"));
        int avip = Integer.parseInt(request.getParameter("avip"));
        int bvip = Integer.parseInt(request.getParameter("bvip"));
        String partys = request.getParameter("partys");
        String sendName = "";

        LOG.error("[send mail] channelNo=" + type + "|channel=" + channelNo + "|online=" + online + "|to=" + to + "|title=" + title + "|moldId="
                + moldId + "|content=" + content + "|alv=" + alv + "|blv=" + blv + "|avip=" + avip + "|bvip=" + bvip + "|mailAward=" + mailAward + "|partys=" + partys);

        Base msg = PbHelper.createSendToMailRq(marking, type, channelNo, online, to, moldId, sendName, title, content, mailAward, alv, blv, avip, bvip, partys);

        if (serverId.equals("0")) {
            return msgToAllGameServer(msg, json);
        } else {
            LOG.error("[send mail serverId]" + serverId);
            JSONArray arr = new JSONArray();
            String[] serverIds = serverId.split("\\|");
            for (int i = 0; i < serverIds.length; i++) {
                int sid = Integer.parseInt(serverIds[i]);
                int code = msgToGameServer(sid, msg);
                arr.add(new int[]{sid, code});
            }
            json.put("res", arr);
            LOG.error("[send mail res]" + json.toString());
            return 200;
        }
    }

    /**
     * 禁言封号
     *
     * @param request
     */
    public int forbidden(WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 1;
        }
        String nick = request.getParameter("nick").trim();
        String forbiddenId = request.getParameter("forbiddenId");
        long time = Long.valueOf(request.getParameter("time").trim());//封禁时间
        Base msg = PbHelper.createForbiddenRq(nick, Integer.valueOf(forbiddenId), time);
        int sid = Integer.parseInt(serverId);
        return msgToGameServer(sid, msg);

    }

    /**
     * 禁言封号
     *
     * @param request
     */
    public int forbidById(WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 1;
        }
        long lordId = Long.valueOf(request.getParameter("lordId").trim());
        String forbiddenId = request.getParameter("forbiddenId");
        long time = Long.valueOf(request.getParameter("time").trim());//封禁时间
        Base msg = PbHelper.createForbiddenRq(lordId, Integer.valueOf(forbiddenId), time);
        int sid = Integer.parseInt(serverId);
        return msgToGameServer(sid, msg);

    }

    /**
     * GM公告
     *
     * @param request
     */
    public int gmNotice(String marking, WebRequest request, JSONObject json) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        String notice = request.getParameter("notice");
        Base msg = PbHelper.createNoticeRq(marking, notice);
        LOG.error("serverId ：" + serverId);
        if (serverId.equals("0")) {
            msgToAllGameServer(msg, json);
        } else {
            JSONArray arr = new JSONArray();
            String[] serverIds = serverId.split("\\|");
            for (int i = 0; i < serverIds.length; i++) {
                int sid = Integer.parseInt(serverIds[i]);
                int code = msgToGameServer(sid, msg);
                arr.add(new int[]{sid, code});
            }
            json.put("res", arr);
        }
        return 200;
    }

    /**
     * 修改vip等级
     *
     * @param request
     * @return
     */
    public int modVip(String marking, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);
        long lordId = Long.parseLong(request.getParameter("lordId"));
        int type = Integer.parseInt(request.getParameter("type"));
        int typeValue = Integer.parseInt(request.getParameter("typeValue"));

        Base msg = PbHelper.createVipBaseRq(marking, lordId, type, typeValue);
        return msgToGameServer(sid, msg);
    }

    public int recalcResource(String marking, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);

        Base msg = PbHelper.createRecalcBaseRq();
        return msgToGameServer(sid, msg);
    }

    public int payRecharge(String marking, WebRequest request, JSONObject json, boolean nbbd) {
        // String md5Code =
        String serverId = request.getParameter("sid");
        String lordId = request.getParameter("lordId");
        String money = request.getParameter("money");
        String orderId = request.getParameter("orderId");
        String platNo = request.getParameter("platNo");
        String platId = request.getParameter("platId");
        // String currDate = request.getParameter("currDate");
        // String sign = request.getParameter("sign");
        if (serverId == null) {
            return 0;
        }
        if (nbbd) {
            if (orderId == null) {
                orderId = "";
            }
            orderId = PlatBase.ODERID_NBBD + orderId;
        }
        int sid = Integer.parseInt(serverId);
        int pNo = Integer.parseInt(platNo);
        int pmoney = Integer.parseInt(money);
        double realAmount = Double.parseDouble(money);
        long roleId = Long.parseLong(lordId);

        PlatBase plat = platHandle.getPlatInst("anfan");
        PayInfo payInfo = new PayInfo();
        payInfo.amount = pmoney;
        payInfo.realAmount = realAmount;
        payInfo.orderId = orderId;
        payInfo.serialId = sid + "_" + roleId + "_" + payInfo.orderId;
        payInfo.platId = platId;
        payInfo.platNo = pNo;
        payInfo.serverId = sid;
        payInfo.roleId = roleId;
        int ret = plat.payToGameServer(payInfo);
        JSONArray arr = new JSONArray();
        if (ret == 0) {
            arr.add(new int[]{sid, 200});
            json.put("res", arr);
            return 200;
        } else {
            arr.add(new int[]{sid, ret});
            json.put("res", arr);
        }
        return ret;
    }

    public int census(String marking, WebRequest request, JSONObject json) {
        String serverId = request.getParameter("sid");

        if (serverId == null) {
            return 0;
        }
        int alv = Integer.parseInt(request.getParameter("alv"));
        int blv = Integer.parseInt(request.getParameter("blv"));
        int vip = Integer.parseInt(request.getParameter("vip"));
        int type = Integer.parseInt(request.getParameter("type"));
        int id = Integer.parseInt(request.getParameter("id"));
        int count = Integer.parseInt(request.getParameter("count"));

        Base msg = PbHelper.createCensusBaseRq(marking, alv, blv, vip, type, id, count);
        if (serverId.equals("0")) {
            return msgToAllGameServer(msg, json);
        } else {
            LOG.error("serverId ：" + serverId);
            JSONArray arr = new JSONArray();
            String[] serverIds = serverId.split("\\|");
            for (int i = 0; i < serverIds.length; i++) {
                int sid = Integer.parseInt(serverIds[i]);
                int code = msgToGameServer(sid, msg);
                arr.add(new int[]{sid, code});
            }
            json.put("res", arr);
            return 200;
        }
    }

    /**
     * 修改角色信息
     *
     * @param request
     * @return
     */
    public int modLordRq(String marking, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);
        long lordId = Long.parseLong(request.getParameter("lordId"));
        int type = Integer.parseInt(request.getParameter("type"));
        int keyId = Integer.parseInt(request.getParameter("keyId"));
        int value = Integer.parseInt(request.getParameter("value"));

        Base msg = PbHelper.createModLordBaseRq(marking, lordId, type, keyId, value);
        return msgToGameServer(sid, msg);
    }

    /**
     * 修改角色道具数量
     *
     * @param request
     * @return
     */
    public int modProp(String marking, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);
        long lordId = Long.parseLong(request.getParameter("lordId"));
        int type = Integer.parseInt(request.getParameter("type"));
        String props = request.getParameter("props");

        Base msg = PbHelper.createModPropRq(marking, lordId, type, props);
        return msgToGameServer(sid, msg);
    }

    /**
     * 修改玩家名字
     *
     * @param marking
     * @param request
     * @return
     */
    public int modName(String marking, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);
        long lordId = Long.parseLong(request.getParameter("lordId"));
        String name = request.getParameter("name");

        Base msg = PbHelper.createModNameRq(marking, lordId, name);
        return msgToGameServer(sid, msg);
    }

    /**
     * 修改軍團職位
     *
     * @param marking
     * @param request
     * @return
     */
    public int modPartyMemberJob(String marking, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);
        long lordId = Long.parseLong(request.getParameter("lordId"));
        int job = Integer.parseInt(request.getParameter("job"));

        Base msg = PbHelper.createModPartyMemberJob(marking, lordId, job);
        return msgToGameServer(sid, msg);
    }

    /**
     * 封设备号
     *
     * @param request
     */
    public int forbidByDeviceNo(WebRequest request) {
        String deviceNo = request.getParameter("device");
        forbidDeviceDao.addForbidDevice(deviceNo);
        return 200;
    }

    /**
     * 热加载游戏服配置数据
     *
     * @param marking
     * @param request
     * @return
     */
    public int reloadParamRq(String marking, WebRequest request, JSONObject json) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
//		int sid = Integer.parseInt(serverId);
        int type = Integer.parseInt(request.getParameter("type"));
        Base msg = PbHelper.createReloadParamBaseRq(marking, type);
        if (serverId.equals("0")) {
            return msgToAllGameServer(msg, json);
        } else {
            LOG.error("serverId ：" + serverId);
            JSONArray arr = new JSONArray();
            String[] serverIds = serverId.split("\\|");
            for (int i = 0; i < serverIds.length; i++) {
                int sid = Integer.parseInt(serverIds[i]);
                int code = msgToGameServer(sid, msg);
                arr.add(new int[]{sid, code});
            }
            json.put("res", arr);
            return 200;
        }
//		return msgToGameServer(sid, msg);
    }

    /**
     * 交换玩家lordid与登录天数
     *
     * @param request
     * @return
     */
    private int modPlatNo(HttpServletResponse response, WebRequest request) {
        String serverId = request.getParameter("sid");
        if (serverId == null) {
            return 0;
        }
        int sid = Integer.parseInt(serverId);
        long oldLordId = Long.parseLong(request.getParameter("oldLordId"));
        long newLordId = Long.parseLong(request.getParameter("newLordId"));
        Base msg = PbHelper.createModPlatNoRq(oldLordId, newLordId);
        return msgToGameServer(sid, msg);

    }


    /**
     * 获取服务器 能源核心等级 及 淬炼等级
     *
     * @param marking
     * @param request
     * @return
     */
    public int getEnergtLevel(String marking, WebRequest request) {
        int sid = Integer.parseInt(request.getParameter("sid"));
        long lordId = Long.parseLong(request.getParameter("T"));
        Base msg = PbHelper.createEnergyRq(marking, lordId);
        return msgToGameServer(sid, msg);
    }

}
