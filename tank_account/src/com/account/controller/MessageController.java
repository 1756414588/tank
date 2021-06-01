package com.account.controller;

import com.account.common.ServerSetting;
import com.account.constant.GameError;
import com.account.dao.impl.AccountDao;
import com.account.dao.impl.RoleInfoDao;
import com.account.domain.Account;
import com.account.domain.GameServerConfig;
import com.account.domain.Role;
import com.account.domain.SaveBehavior;
import com.account.domain.form.RoleLog;
import com.account.handle.MessageHandle;
import com.account.handle.PlatHandle;
import com.account.plat.PlatBase;
import com.account.plat.impl.chQzZzzhgGionee.util.StringUtil;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.interfaces.LogRoleCreate2sdk;
import com.account.plat.interfaces.LogRoleLogin2sdk;
import com.account.service.*;
import com.account.util.*;
import com.alibaba.fastjson.JSON;
import com.game.pb.BasePb.Base;
import net.sf.json.JSONArray;
import net.sf.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.request.WebRequest;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.util.*;

@Controller
public class MessageController {
    private MessageHandle clientMessageHandle;
    private MessageHandle serverMessageHandle;
    public static Logger LOG = LoggerFactory.getLogger(MessageController.class);
    @Autowired
    private QueryService queryService;
    @Autowired
    private AnfanService anfanService;
    @Autowired
    private PhpRecService phpRecService;
    @Autowired
    private ServerSetting serverSetting;
    @Autowired
    private AccountService accountService;
    @Autowired
    private ZhtService zhtService;
    @Autowired
    private WxAdService wxAdService;
    @Autowired
    private PlatHandle platHandle;
    @Autowired
    private GiftService giftService;
    @Autowired
    protected AccountDao accountDao;
    @Autowired
    private RoleInfoDao roleInfoDao;
    @Autowired
    private SaveBehaviorService saveBehaviorService;


    public ServerSetting getServerSetting() {
        return serverSetting;
    }

    public void setServerSetting(ServerSetting serverSetting) {
        this.serverSetting = serverSetting;
    }

    public MessageHandle getClientMessageHandle() {
        return clientMessageHandle;
    }

    public void setClientMessageHandle(MessageHandle clientMessageHandle) {
        this.clientMessageHandle = clientMessageHandle;
    }

    public MessageHandle getServerMessageHandle() {
        return serverMessageHandle;
    }

    public void setServerMessageHandle(MessageHandle serverMessageHandle) {
        this.serverMessageHandle = serverMessageHandle;
    }


    @ResponseBody
    @RequestMapping("account.do")
    public byte[] accountLogic(@RequestBody byte[] msgData, WebRequest request) {
        try {
            byte[] backData;
            if (msgData != null && msgData.length != 0) {
                backData = clientMessageHandle.handle(msgData);
            } else {
                backData = MessageHelper.packErrorPbMsg(100, GameError.NOT_WHITE_NAME);
            }
            return backData;
        } catch (Exception e) {
            LOG.error("", e);
            return MessageHelper.packErrorPbMsg(100, GameError.SERVER_EXCEPTION);
        }
    }

    @ResponseBody
    @RequestMapping("inner.do")
    public byte[] innerLogic(@RequestBody byte[] msgData, WebRequest request) {

        try {
            byte[] backData;
            if (msgData != null && msgData.length != 0) {
                backData = serverMessageHandle.handle(msgData);
            } else {
                backData = MessageHelper.packErrorPbMsg(100, GameError.NOT_WHITE_NAME);
            }
            return backData;
        } catch (Exception e) {
            LOG.error("", e);
            return MessageHelper.packErrorPbMsg(100, GameError.SERVER_EXCEPTION);
        }
    }


    @ResponseBody
    @RequestMapping("verify.do")
    public String verifyLogic(@RequestBody String msgStr, WebRequest request) {
        JSONArray msg = new JSONArray();
        try {
            if (msgStr != null) {
                PrintHelper.println(DateHelper.displayDateTime() + "|receive msg:" + msgStr);
                msg = JSONArray.fromObject(msgStr);
            }
            JSONArray backMsg = serverMessageHandle.handle(msg, null);
            PrintHelper.println(DateHelper.displayDateTime() + "|send msg:" + backMsg.toString());
            return backMsg.toString();
        } catch (Exception e) {
            LOG.error("", e);
            return MessageHelper.packErrorJsonMsg("base", GameError.SERVER_EXCEPTION);
        }
    }

    @ResponseBody
    @RequestMapping("payCallback.do")
    public String payCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "FAILURE";
            }
            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 根据平台具体要求，定向到正确的平台关键字（用于指向对应的平台处理类），无特殊要求的，返回原来的平台关键字
     *
     * @param request
     * @param platName
     * @return
     */
    private String redirectPlat(WebRequest request, String platName) {
        String result = platName;
        if ("muzhiJh".equals(platName)) {
            /**
             * 回调过来会多传一个paytype参数，如果是1 或者没有这个参数 是老的支付验证，2是新的支付验证
             */
            String paytype = request.getParameter("paytype");
            if (!CheckNull.isNullTrim(paytype) && "2".equals(paytype)) {
                result = "muzhiJhly";
            }
        }
        return result;
    }

    @ResponseBody
    @RequestMapping("order.do")
    public String orderLogic(@RequestBody String msgStr, WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "FAILURE";
            }

            return plat.order(request, msgStr);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    @ResponseBody
    @RequestMapping("balance.do")
    public String balanceLogic(@RequestBody String msgStr, WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "FAILURE";
            }

            return plat.balance(request, msgStr);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    @ResponseBody
    @RequestMapping("roleInfo.do")
    public String roleInfoLogic(@RequestBody String msgStr, WebRequest request) {
        try {
            String platId = request.getParameter("platId");
            String serverId = request.getParameter("serverId");
            return queryService.twQueryRoleInfo(platId, Integer.valueOf(serverId));
        } catch (Exception e) {
            LOG.error("", e);
            JSONObject res = new JSONObject();
            res.put("state", 6);
            return res.toString();
        }
    }

    @ResponseBody
    @RequestMapping("gift.do")
    public String giftLogic(@RequestBody String msgStr, WebRequest request) {
        try {
            LOG.error("msg:" + msgStr);
            return giftService.generateGift(JSONObject.fromObject(msgStr));
        } catch (Exception e) {
            LOG.error("", e);
            return "param error!";
        }

    }

    @ResponseBody
    @RequestMapping("tool.do")
    public void gmTool(@RequestBody String msgStr, WebRequest request, HttpServletRequest req, HttpServletResponse response) {
        try {
            LOG.error("ip:" + req.getRemoteAddr());
            phpRecService.doLogic(request, response);
        } catch (Exception e) {
            LOG.error("", e);
        }
        LOG.error("操作已执行完毕");
    }

    @ResponseBody
    @RequestMapping("platLogin.do")
    public String qbaoLogin(@RequestBody String msgStr, WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "FAILURE";
            }
            return "";
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }

    }

    /**
     * 草花硬核新增支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chYhNewPayCallback.do")
    public String chYhNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chYh");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, null);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花手Q微信支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chSqWxPayCallback.do")
    public String chSqWxPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chSqWx");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花手Q微信2支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chSqWx2PayCallback.do")
    public String chSqWx2PayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chSqWx2");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花烈火坦克 新版本支付回调 (ios)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chlhtkIosNewPayCallback.do")
    public String chlhtkIosNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chlhtk_appstore");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, null);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花血色军团 新版本支付回调 (ios)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chxsjtIosNewPayCallback.do")
    public String chxsjtIosNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chxsjt_appstore");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, null);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花战地警戒 新版本支付回调 (ios)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chzdjjIosNewPayCallback.do")
    public String chzdjjIosNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chzdjj_appstore");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, null);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花新版本支付回调 (ios)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chIosNewPayCallback.do")
    public String chIosNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("ch_appstore");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, null);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花新版本华为支付回调 (安卓)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chHwPayCallback.do")
    public String chHwPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("caohua");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, "hw");
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花新版本支付回调 (安卓)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chNewPayCallback.do")
    public String chNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("caohua");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, "new");
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 安峰新版本支付回调 (ios)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("afIosNewPayCallback.do")
    public String afIosNewPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("af_appstore");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.newPayBack(request, msgStr, response, null);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 安峰元宝充值支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("afYBPayCallback.do")
    public String afYBPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {
            String platName = request.getParameter("plat");
            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null || !platHandle.isNeedYBPayCallBackPlatNo(plat.getPlatNo())) {
                return "PLAT ERROR";
            }

            return anfanService.yBPayBack(request, msgStr, response, plat.getPlatNo());
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * inTouch支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("inTouchPayCallback.do")
    public String inTouchPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("mzyw");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 拇指inTouch支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("mzInTouchPayCallback.do")
    public String mzInTouchPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("mzIntouch");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花硬核华为支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chYhHwPayCallback.do")
    public String chYhHwpayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chYhHw");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花硬核华为支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chHj4HwPayCallback.do")
    public String chHj4HwpayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chHj4Hw");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    /**
     * 草花硬核顺网支付回调
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping("chYhSwPayCallback.do")
    public String chYhSwPayCallbackLogic(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("chYhSw");
            if (plat == null) {
                return "FAILURE";
            }

            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            // TODO: handle exception
            LOG.error("", e);
            return "EXCEPTION";
        }
    }


    /**
     * 获取用户所有已创建的角色信息并查询VIP，返回json字符串
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "getAllRoleVip.do", produces = "text/html;charset=UTF-8")
    public String getAllRoleVip(WebRequest request, HttpServletResponse response) {
        JSONObject json = new JSONObject();
        try {
            String platName = request.getParameter("plat");
            String platId = request.getParameter("user_id");

            if (platName == null || platId == null) { // 参数错误
                json.put("state", "-1");
                json.put("msg", "param error");
                PrintHelper.println("return : " + json.toString());
                return json.toString();
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null || !platHandle.isNeedRecordRolePlatNo(plat.getPlatNo())) { // 渠道错误
                json.put("state", "-2");
                json.put("msg", "plat error");
                PrintHelper.println("return : " + json.toString());
                return json.toString();
            }
            // 用户的平台id
            PrintHelper.println("getAllRoleVip, plat:" + platName + ", user_id:" + platId);
            String roles = accountService.getAllRoleVip(plat.getPlatNo(), platId);

            if (roles == null) { // 查无账号信息
                json.put("state", "-3");
                json.put("msg", "no account");
                PrintHelper.println("return : " + json.toString());
                return json.toString();
            } else {
                json.put("state", "0");
                json.put("role", roles);
                PrintHelper.println("return : " + json.toString());
                return json.toString();
            }
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("获取角色信息出错:" + e.getMessage());
            json.put("state", "-4");
            json.put("msg", "exception");
            return json.toString();
        }
    }

    /**
     * 获取用户所有已创建的角色信息，返回json字符串
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "getAllRole.do", produces = "text/html;charset=UTF-8")
    public String getAllRole(WebRequest request, HttpServletResponse response) {
        try {
            String platName = request.getParameter("plat");
            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null || !platHandle.isNeedRecordRolePlatNo(plat.getPlatNo())) {
                return "PLAT ERROR";
            }

            int platNo = plat.getPlatNo();
            // 用户的平台id
            String platId = request.getParameter("user_id");
            PrintHelper.println("getAllRole, plat:" + platName + ", user_id:" + platId);

            String roles = accountService.getAllRole(platNo, platId);
            PrintHelper.println("getAllRole result, roles:" + roles);
            return roles;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("获取角色信息出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 玩家登录时，记录用户已创建的角色（只记录需要记录的渠道的玩家信息）
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping("recordRoleLogin.do")
    public String recordRoleLogin(WebRequest request, RoleLog role) {
        try {
            int platNo = Integer.valueOf(request.getParameter("platNo"));
            PlatBase plat = platHandle.getPlatInst(platNo);
            try {
                // 将数据存在数据库里 等待渠道sdk通过getAllRole来取
                if (plat != null && platHandle.isNeedRecordRolePlatNo(platNo) && (role.getSubject() == null || LogRoleLogin2sdk.EVENT_SUBJECT.equals(role.getSubject()))) {
                    PrintHelper.println("recordRoleLogin, :" + platNo + ", accountKey:" + role.getAccountKey() + ", " + role.toString());
                    accountService.recordRoleLogin(role.getAccountKey(), role.getRoleId() + "", role.getRoleName(), role.getLevel(), role.getServerId(), role.getServerName());
                }
            } catch (Exception e) {
                LOG.error("", e);
                PrintHelper.println("记录角色信息出错 1:" + e.getMessage());
            }

            try {
                if (plat != null) {
                    // 向sdk发送日志
                    plat.logRole2sdk(role);
                }
            } catch (Exception e) {
                LOG.error("", e);
                PrintHelper.println("记录角色信息出错 向sdk发送日志 :" + e.getMessage());
            }

            try {
                // 拇指创建角色上报
                if (plat != null && plat.getAppId() != null && LogRoleCreate2sdk.EVENT_SUBJECT.equals(role.getSubject())) {
                    MuZhiRoleInfoReportedData.reportedData(role, plat.getAppId());
                }
            } catch (Exception e) {
                LOG.error("", e);
                PrintHelper.println("记录角色信息出错 拇指创建角色上报 :" + e.getMessage());
            }

        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("记录角色信息出错 0 :" + e.getMessage());
            return "0";
        }
        return "1";
    }


    /**
     * 查询idfa是否已激活
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "idfaActivated.do")
    public String idfaActivated(WebRequest request, HttpServletResponse response) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String idfa = request.getParameter("idfa");
            PrintHelper.println("idfaActivated, platName:" + platName + ", idfa:" + idfa);

            String result = accountService.idfaHasActivated(plat.getPlatNo(), idfa);
            PrintHelper.println("idfa查询 result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("IDFA查询出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 玩家下载客户端包时，记录玩家的idfa
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "idfaRecord.do")
    public String idfaRecord(WebRequest request, HttpServletResponse response) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String result = accountService.idfaRecord(plat.getPlatNo(), request);
            PrintHelper.println("idfa记录 result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("IDFA记录出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * idfa激活
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "idfaActivate.do")
    public String idfaActivate(WebRequest request, HttpServletResponse response) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String idfa = request.getParameter("idfa");
            String result = accountService.idfaActivate(plat.getPlatNo(), idfa);
            PrintHelper.println("idfa激活 ,idfa:" + idfa + ", result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("IDFA激活出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 埋点记录
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping("actionPoint.do")
    public void actionPoint(WebRequest request) {
        try {
            String deviceNo = request.getParameter("deviceNo");
            String platName = request.getParameter("platName");
            int point = Integer.valueOf(request.getParameter("point"));
            PlatBase platBase = platHandle.getPlatInst(platName);
            if (platBase == null) {
                return;
            }
            if (!platHandle.isNeedActionPointPlatNo(platBase.getPlatNo())) {
                return;
            }
            accountService.addActionPoint(deviceNo, platBase.getPlatNo(), point);
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("记录埋点信息出错:" + e.getMessage());
        }
    }

    /**
     * 智汇推点击信息
     *
     * @param request
     */
    @ResponseBody
    @RequestMapping("zhtInfo.do")
    public String zhtInfo(WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String result = zhtService.zhtInfo(plat.getPlatNo(), request);
            PrintHelper.println("智汇推result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("智汇推信息出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 激活智汇推
     *
     * @param request
     */
    @ResponseBody
    @RequestMapping("zhtCheck.do")
    public String zhtCheck(WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String muid = request.getParameter("muid");
            String result = zhtService.checkZhtIdfa(plat.getPlatNo(), muid);
            PrintHelper.println("zht激活 ,zht:" + muid + ", result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("智汇推激活出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 微信广告点击信息
     *
     * @param request
     */
    @ResponseBody
    @RequestMapping("wxadInfo.do")
    public String wxadInfo(WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String result = wxAdService.wxInfo(plat.getPlatNo(), request);
            PrintHelper.println("微信广告result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("微信广告信息出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 激活微信广告
     *
     * @param request
     */
    @ResponseBody
    @RequestMapping("wxadCheck.do")
    public String wxadCheck(WebRequest request) {
        try {
            String platName = request.getParameter("plat");
            if (platName == null) {
                return "FAILURE";
            }

            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return "PLAT ERROR";
            }

            String muid = request.getParameter("muid");
            String result = wxAdService.checkWxIdfa(plat.getPlatNo(), muid);
            PrintHelper.println("wxad激活 ,wxad:" + muid + ", result:" + result);
            return result;
        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("微信广告激活出错:" + e.getMessage());
            return "EXCEPTION";
        }
    }

    /**
     * 极趣获取server信息
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "getJQServerInfo.do", produces = "text/html;charset=UTF-8")
    public String getJQServerInfo(WebRequest request) {
        com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();

        try {

            PlatBase plat = platHandle.getPlatInst("jq_appstore");
            if (plat == null) {
                result.put("err_code", 1);
                result.put("desc", "jq_appstore is null 1");
                return result.toJSONString();
            }

            List<JSONObject> serverList = serverSetting.getServerList("jq_appstore");
            if (serverList == null) {
                result.put("err_code", 1);
                result.put("desc", "jq_appstore is null 2");
                return result.toJSONString();
            }

            com.alibaba.fastjson.JSONArray serverJson = new com.alibaba.fastjson.JSONArray();

            for (int i = 0; i < serverList.size(); i++) {
                JSONObject json = new JSONObject();
                json.put("serv_id", serverList.get(i).getInt("id"));
                json.put("serv_name", serverList.get(i).getString("name"));
                serverJson.add(json);
            }

            result.put("err_code", 0);
            result.put("serv", serverJson);

            return result.toString();

        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("获取服務器信息出错:" + e.getMessage());
            result.put("err_code", 1);
            result.put("desc", "system error");
            return result.toJSONString();
        }
    }

    /**
     * 极趣获取用户信息
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping(value = "getJQRoleInfo.do", produces = "text/html;charset=UTF-8")
    public String getJQRoleInfo(WebRequest request, HttpServletResponse response) {

        com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();
        try {

            String serverId = request.getParameter("serv_id");
            String usr_name = URLDecoder.decode(request.getParameter("usr_name"), "utf-8");

            LOG.error("getJQRoleInfo  param  " + serverId + " " + usr_name);

            if (usr_name == null) {
                result.put("err_code", 1);
                result.put("desc", "usr_name is null");
                return result.toJSONString();
            }

            PlatBase plat = platHandle.getPlatInst("jq_appstore");
            if (plat == null) {
                result.put("err_code", 1);
                result.put("desc", "没有该平台信息");
                return result.toJSONString();
            }

            GameServerConfig serverConfig = DBUtil.getServerById(Integer.valueOf(serverId));
            // serverConfig = new GameServerConfig();
            // serverConfig.setServerIp("127.0.0.1");
            // serverConfig.setDbName("empire_1");
            // serverConfig.setUserName("root");
            // serverConfig.setPassword("admin");
            if (serverConfig == null) {
                result.put("err_code", 1);
                result.put("desc", "serverConfig is null " + serverId);
                return result.toJSONString();
            }
            LOG.error("getJQRoleInfo  GameServerConfig  " + JSON.toJSONString(serverConfig));

            StringBuilder url = new StringBuilder("jdbc:mysql://");
            url.append(serverConfig.getGameDbIp()).append(":3306/").append(serverConfig.getDbName()).append("?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull");
            Role ro = DBUtil.selectRoleDataInfo(url.toString(), serverConfig.getUserName(), serverConfig.getPassword(), usr_name);

            if (ro == null) {
                result.put("err_code", 1);
                result.put("desc", "没有该用户");
                return result.toJSONString();
            }
            result.put("err_code", 0);
            result.put("usr_name", ro.getRole_name());
            result.put("usr_rank", Integer.valueOf(ro.getLevel()));
            result.put("player_id", Long.valueOf(ro.getRole_id()));

            return result.toJSONString();

        } catch (Exception e) {
            LOG.error("", e);
            PrintHelper.println("获取角色信息出错:" + e.getMessage());
            result.put("err_code", 1);
            result.put("desc", "system error");
            return result.toJSONString();
        }
    }

    /**
     * 极趣获取订单号
     *
     * @param request
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"getJQOrderId.do"}, produces = {"text/html;charset=UTF-8"})
    public String getJQOrderId(WebRequest request) {

        com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();

        String player_id = request.getParameter("player_id");
        String serv_id = request.getParameter("serv_id");

        if (player_id == null || serv_id == null) {
            result.put("err_code", 1);
            result.put("desc", "player_id or serv_id is null");
            return result.toJSONString();
        }

        String orderId = serv_id + "_" + player_id + "_" + System.currentTimeMillis();

        result.put("err_code", 0);
        result.put("desc", orderId);

        return result.toJSONString();
    }

    /**
     * 极趣版本支付回调 (ios)
     *
     * @param msgStr
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"jqPayCallback.do"}, produces = {"text/html;charset=UTF-8"})
    public String jqPayCallback(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        com.alibaba.fastjson.JSONObject result = new com.alibaba.fastjson.JSONObject();

        try {

            PlatBase plat = platHandle.getPlatInst("jq_appstore");
            if (plat == null) {
                result.put("err_code", 1);
                result.put("desc", "plat config is null");
                return result.toJSONString();
            }

            return plat.newPayBack(request, msgStr, response, null);

        } catch (Exception e) {
            LOG.error("", e);
            result.put("err_code", 1);
            result.put("desc", "system error");
            return result.toJSONString();
        }
    }

    /**
     * 拇指查询角色信息
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"queryRoleInfos.do"}, method = RequestMethod.POST, produces = {"text/html;charset=UTF-8"})
    public String queryRoleInfos(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            Map<Integer, String> platNoInfo = new HashMap<>();
            Collection<PlatBase> values = platHandle.getPlatNoMap().values();
            for (PlatBase p : values) {
                if (p.getAppId() != null) {
                    platNoInfo.put(p.getPlatNo(), p.getAppId());
                }
            }

            String decode = URLDecoder.decode(msgStr, "utf-8");
            JSONObject param = JSONObject.fromObject(decode);
            String data = param.getString("data");
            String sign = param.getString("sign");

            LOG.error("data=" + data);
            LOG.error("sign=" + sign);

            // 签名公式："data="+data+"apikey="+ Api_key
            String signStr = "data=" + data + "apikey=" + "WaRbG8";
            String md5 = MD5Util.toMD5(signStr);

            JSONObject result = new JSONObject();
            if (!md5.equals(sign)) {
                LOG.error("md5 error  signStr=" + signStr + " sign=" + sign + " md5=" + md5);
                result.put("code", 1);
                result.put("msg", "签名错误");
                return result.toString();
            }

            String decrypt = AESUtil.decrypt(data, "N6xCnO793woohat7", "N6xCnO793woohat7");
            // LOG.error("decrypt=" + decrypt);

            JSONObject jsonObject = JSONObject.fromObject(decrypt);
            String user_id = jsonObject.getString("userid");

            String[] uids = user_id.split(",");
            JSONArray jsonArray = new JSONArray();

            List<Map<String, String>> roleInfo = DBUtil.getRoleInfo(new ArrayList<Integer>(platNoInfo.keySet()), uids);
            if (roleInfo != null && !roleInfo.isEmpty()) {
                for (Map<String, String> info : roleInfo) {
                    String platNo = info.get("platNo");
                    String serverId = info.get("serverId");

                    String AppId = platNoInfo.get(Integer.valueOf(platNo));
                    if (AppId == null) {
                        continue;
                    }

                    GameServerConfig serverConfig = DBUtil.getServerById(Integer.valueOf(serverId));

                    com.alibaba.fastjson.JSONObject jsonObject1 = new com.alibaba.fastjson.JSONObject();
                    jsonObject1.put("ServerId", serverId);
                    jsonObject1.put("ServerName", info.get("serverId"));
                    if (serverConfig != null) {
                        jsonObject1.put("ServerName", serverConfig.getServerName());
                    }

                    jsonObject1.put("RoleId", info.get("lordId"));
                    jsonObject1.put("RoleName", info.get("nick"));
                    jsonObject1.put("RoleLevel", info.get("level"));
                    jsonObject1.put("ChargeNum", info.get("topup"));
                    jsonObject1.put("RoleVipLv", info.get("vip"));
                    jsonObject1.put("UserId", info.get("platId"));
                    jsonObject1.put("Gameid", AppId);
                    jsonArray.add(jsonObject1);
                }
            }

            result.put("data", jsonArray);
            result.put("code", 0);
            result.put("msg", "成功");
            return result.toString();
        } catch (Exception e) {
            LOG.error("", e);
            JSONObject result = new JSONObject();
            result.put("code", 2);
            result.put("msg", "服务器内部错误");
            return result.toString();
        }
    }

    /**
     * 玩家行为日志打点
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"rolePoint.do"}, produces = {"text/html;charset=UTF-8"})
    public String actionPoint(WebRequest request, HttpServletResponse response) {
        String platNo = request.getParameter("platNo");
        String serverId = request.getParameter("serverId");
        String userId = request.getParameter("userId");
        String level = request.getParameter("level");
        String vip = request.getParameter("vip");
        String point = request.getParameter("point");
        String deviceNo = request.getParameter("deviceNo");

        if (platNo == null || serverId == null || userId == null || level == null || vip == null || point == null) {
            return "0";
        }

        try {
            // accountService.rolePoint(platNo, serverId, userId, level, vip, point, deviceNo);
        } catch (Exception e) {
            LOG.error("", e);
        }
        return "1";
    }

    @ResponseBody
    @RequestMapping(value = {"getInfo.do"}, produces = {"text/html;charset=UTF-8"})
    public String getChannelInfo(WebRequest request, HttpServletResponse response) {

        String toolId = request.getParameter("toolId");

        if ("getChannelInfo".equals(toolId)) {
            com.alibaba.fastjson.JSONArray result = new com.alibaba.fastjson.JSONArray();

            Map<Integer, PlatBase> platNoMap = platHandle.getPlatNoMap();
            for (PlatBase p : platNoMap.values()) {

                com.alibaba.fastjson.JSONObject jsonObject = new com.alibaba.fastjson.JSONObject();

                jsonObject.put("platNo", p.getPlatNo());
                jsonObject.put("childNo", p.getPlatNo2());
                jsonObject.put("platName", p.getDesc());
                jsonObject.put("platCode", p.getPlatName());

                if (p.getPlatType() != null) {
                    jsonObject.put("platTypeId", p.getPlatType().getPlatTypeId());
                }

                result.add(jsonObject);
            }
            return result.toJSONString();

        }
        return "error";
    }

    /**
     * 跨服热加载指令
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"reloadCrossIni.do"}, produces = {"text/html;charset=UTF-8"})
    public String reloadCrossIni(WebRequest request, HttpServletResponse response) {
        try {
            String urlList = request.getParameter("urlList");

            if (urlList == null || urlList.trim().equals("")) {
                return "error urlList is null";
            }
            JSONArray urls = null;
            try {
                urls = JSONArray.fromObject(urlList);
            } catch (Exception e) {
                LOG.error("", e);
                return "error urlList JSONArray";
            }

            String type = request.getParameter("type");

            if (!type.equals("1") && !type.equals("2")) {
                return "error type 1 or 2";
            }

            JSONArray result = new JSONArray();
            for (Object url : urls) {
                JSONObject us = new JSONObject();
                try {
                    Base reloadParamBaseRq = PbHelper.createReloadParamBaseRq("", Integer.valueOf(type));
                    Base back = HttpHelper.sendMailMsgToGame(url.toString(), reloadParamBaseRq);
                    LOG.error("back:" + back);
                    us.put(url, "success");
                } catch (Exception e) {
                    LOG.error("", e);
                    us.put(url, "fail");
                }
                result.add(us);
            }
            return result.toString();
        } catch (NumberFormatException e) {
            LOG.error("", e);
            return "error";
        }
    }

    /**
     * 拇指查询角色信息
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"queryMuzhiRoleInfos.do"}, method = RequestMethod.POST, produces = {"text/html;charset=UTF-8"})
    public String queryMuzhiRoleInfos(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            List<Integer> platNoList = new ArrayList<>();
            platNoList.add(81);
            platNoList.add(501);
            platNoList.add(509);
            platNoList.add(511);
            platNoList.add(140);
            platNoList.add(127);
            platNoList.add(136);
            platNoList.add(146);
            platNoList.add(156);
            platNoList.add(157);
            platNoList.add(158);
            platNoList.add(159);
            platNoList.add(162);
            platNoList.add(179);
            platNoList.add(503);
            platNoList.add(504);
            platNoList.add(505);
            platNoList.add(506);
            platNoList.add(507);
            platNoList.add(509);
            platNoList.add(511);
            platNoList.add(520);
            platNoList.add(521);
            platNoList.add(523);
            platNoList.add(524);
            platNoList.add(525);
            platNoList.add(526);
            platNoList.add(527);
            platNoList.add(572);
            platNoList.add(573);
            platNoList.add(574);

            String decode = URLDecoder.decode(msgStr, "utf-8");
            JSONObject param = JSONObject.fromObject(decode);
            String data = param.getString("data");
            String sign = param.getString("sign");

            LOG.error("queryMuzhiRoleInfos data=" + data);
            LOG.error("queryMuzhiRoleInfos sign=" + sign);

            String signStr = "data=" + data + "actkey=" + "stE7PRxhOy";
            String md5 = MD5Util.toMD5(signStr);

            JSONObject result = new JSONObject();
            if (!md5.equals(sign)) {
                LOG.error("queryMuzhiRoleInfos md5 error  signStr=" + signStr + " sign=" + sign + " md5=" + md5);
                LOG.error("msgStr =" + msgStr);
                result.put("code", 1);
                result.put("msg", "签名错误");
                return result.toString();
            }

            String decrypt = AESUtil.decrypt(data, "drOl6tD44k0lc9OE", "drOl6tD44k0lc9OE");

            JSONObject jsonObject = JSONObject.fromObject(decrypt);
            String user_id = jsonObject.getString("user_id");
            String os_type = jsonObject.getString("os_type");
            JSONArray jsonArray = new JSONArray();

            List<Map<String, String>> roleInfo = DBUtil.getRoleInfo(platNoList, user_id);
            if (roleInfo != null && !roleInfo.isEmpty()) {
                for (Map<String, String> info : roleInfo) {

                    int platNo = Integer.valueOf(info.get("platNo"));

                    if (os_type.equals("ios") && platNo < 500) {
                        continue;
                    }
                    if (os_type.equals("android") && platNo >= 500) {
                        continue;
                    }

                    String serverId = info.get("serverId");
                    GameServerConfig serverConfig = DBUtil.getServerById(Integer.valueOf(serverId));
                    com.alibaba.fastjson.JSONObject jsonObject1 = new com.alibaba.fastjson.JSONObject();
                    jsonObject1.put("ServerId", serverId);
                    if (serverConfig != null) {
                        jsonObject1.put("ServerName", serverConfig.getServerName());
                    } else {
                        PrintHelper.println("queryMuzhiRoleInfos serverConfig is null :" + serverId);
                    }

                    jsonObject1.put("RoleId", info.get("lordId"));
                    jsonObject1.put("RoleName", info.get("nick"));
                    jsonObject1.put("RoleLevel", info.get("level"));
                    jsonArray.add(jsonObject1);
                }
            } else {
                List<Account> accounts = accountDao.selectByAccount(user_id, platNoList);

                if (accounts != null && !accounts.isEmpty()) {

                    for (Account account : accounts) {

                        if (os_type.equals("ios") && account.getPlatNo() < 500) {
                            continue;
                        }
                        if (os_type.equals("android") && account.getPlatNo() >= 500) {
                            continue;
                        }

                        String roles = accountService.getAllNowRole(account.getPlatNo(), user_id);

                        if (!"NO ACCOUNT".equals(roles)) {
                            com.alibaba.fastjson.JSONArray parseObject = com.alibaba.fastjson.JSONArray.parseArray(roles);
                            if (!parseObject.isEmpty()) {
                                for (Object o : parseObject) {
                                    com.alibaba.fastjson.JSONObject jsonObject1 = com.alibaba.fastjson.JSONObject.parseObject(o.toString());

                                    com.alibaba.fastjson.JSONObject json = new com.alibaba.fastjson.JSONObject();

                                    String serverId = jsonObject1.getString("server_id");
                                    GameServerConfig serverConfig = DBUtil.getServerById(Integer.valueOf(serverId));
                                    json.put("ServerId", serverId);
                                    if (serverConfig != null) {
                                        json.put("ServerName", serverConfig.getServerName());
                                    } else {
                                        PrintHelper.println("queryMuzhiRoleInfos 2 serverConfig is null :" + serverId);
                                    }
                                    json.put("RoleId", jsonObject1.getString("role_id"));
                                    json.put("RoleName", jsonObject1.getString("role_name"));
                                    json.put("RoleLevel", jsonObject1.getString("level"));
                                    jsonArray.add(json);
                                }
                            }

                        }

                    }

                }

            }

            result.put("data", jsonArray);
            result.put("code", 0);
            result.put("msg", "成功");
            return result.toString();
        } catch (Exception e) {
            LOG.error("", e);
            JSONObject result = new JSONObject();
            result.put("code", 2);
            result.put("msg", "服务器内部错误");
            return result.toString();
        }
    }

    /**
     * 拇指领取游戏里面的礼包码
     *
     * @param request
     * @param response
     * @return
     */
    @ResponseBody
    @RequestMapping(value = {"getRewardCode.do"}, method = RequestMethod.POST, produces = {"text/html;charset=UTF-8"})
    public String getRewardCode(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            String decode = URLDecoder.decode(msgStr, "utf-8");
            JSONObject param = JSONObject.fromObject(decode);
            String data = param.getString("data");
            String sign = param.getString("sign");

            LOG.error("getRewardCode data=" + data);
            LOG.error("getRewardCode sign=" + sign);

            String signStr = "data=" + data + "actkey=" + "stE7PRxhOy";
            String md5 = MD5Util.toMD5(signStr);

            JSONObject result = new JSONObject();
            if (!md5.equals(sign)) {
                LOG.error("queryMuzhiRoleInfos md5 error  signStr=" + signStr + " sign=" + sign + " md5=" + md5);
                LOG.error("msgStr =" + msgStr);
                result.put("code", -1);
                result.put("msg", "签名错误");
                return result.toString();
            }

            String decrypt = AESUtil.decrypt(data, "drOl6tD44k0lc9OE", "drOl6tD44k0lc9OE");

            JSONObject jsonObject = JSONObject.fromObject(decrypt);
            String server_id = jsonObject.getString("server_id");
            String role_id = jsonObject.getString("role_id");
            String gift_code = jsonObject.getString("gift_code");
            String actName = null;
            if (jsonObject.containsKey("actName")) {
                actName = jsonObject.getString("actName");
            }
            if (actName != null) {
                actName = URLDecoder.decode(actName, "utf-8");
            }
            giftService.useGiftCode(result, Long.valueOf(role_id), Integer.valueOf(server_id), -1, gift_code, actName);
            LOG.error("getRewardCode roleId=" + role_id + " result =" + result.toString() + " jsonObject=" + jsonObject.toString());
            return result.toString();
        } catch (Exception e) {
            LOG.error("", e);
            JSONObject result = new JSONObject();
            result.put("code", -2);
            result.put("msg", "服务器内部错误");
            return result.toString();
        }
    }

    @ResponseBody
    @RequestMapping("mzUnicomPayCallbackMzUnicom.do")
    public String payCallbackLogicMzUnicom(@RequestBody String msgStr, WebRequest request, HttpServletResponse response) {
        try {

            PlatBase plat = platHandle.getPlatInst("mzUnicom");
            if (plat == null) {
                return "FAILURE";
            }
            return plat.payBack(request, msgStr, response);
        } catch (Exception e) {
            LOG.error("", e);
            return "EXCEPTION";
        }
    }

    @ResponseBody
    @RequestMapping(value = {"getPlatInfo.do"}, produces = {"text/html;charset=UTF-8"})
    public String getPlatInfo(WebRequest request, HttpServletResponse response) {

        String platTypeId = request.getParameter("platTypeId");

        com.alibaba.fastjson.JSONArray result = new com.alibaba.fastjson.JSONArray();

        Map<Integer, PlatBase> platNoMap = platHandle.getPlatNoMap();
        for (PlatBase p : platNoMap.values()) {

            if (p.getPlatType() != null && p.getPlatType().getPlatTypeId() == Integer.valueOf(platTypeId)) {
                com.alibaba.fastjson.JSONObject jsonObject = new com.alibaba.fastjson.JSONObject();
                jsonObject.put("platNo", p.getPlatNo());
                jsonObject.put("childNo", p.getPlatNo2());
                jsonObject.put("platName", p.getDesc());
                jsonObject.put("platCode", p.getPlatName());
                jsonObject.put("platTypeId", p.getPlatType().getPlatTypeId());
                result.add(jsonObject);
            }

        }
        return result.toJSONString();
    }

    @ResponseBody
    @RequestMapping(value = {"oppoCallback.do"}, produces = {"text/html;charset=UTF-8"})
    public void getPlatInfo(HttpServletRequest request, HttpServletResponse response) {
        UrlRedirectAction.redirectUrl(request, response);
    }


    @ResponseBody
    @RequestMapping("gameRoleInfo.do")
    public void gameRoleInfo(WebRequest request, RoleLog role) {
        long time = System.currentTimeMillis();

        if (role.getRoleId() != 0 && !StringUtil.isNullOrEmpty(role.getPlatId()) && role.getPlatNo() != 0) {
            roleInfoDao.insertRoleLog(role);
        }
        LOG.info("gameRoleInfo roleId={},platId={},platNo={}, 耗时 {} ms", role.getRoleId(), role.getPlatId(), role.getPlatNo(), System.currentTimeMillis() - time);
    }


    @RequestMapping("saveBehavior.do")
    @ResponseBody
    public String saveBehavior(WebRequest request, HttpServletRequest req, HttpServletResponse response) {
        try {
            String deviceNo = request.getParameter("deviceNo");
            String platName = request.getParameter("platName");
            String lordIdRq = request.getParameter("lordId");
            String areaIdRq = request.getParameter("areaId");
            String content = request.getParameter("content");
            saveBehaviorService.insertBehavior(new SaveBehavior(deviceNo, platName, areaIdRq, lordIdRq, content));
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "success";
    }

}
