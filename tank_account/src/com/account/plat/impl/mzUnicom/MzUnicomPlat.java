package com.account.plat.impl.mzUnicom;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.MD5Util;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.DateHelper;
import com.account.util.RandomHelper;
import com.account.util.StringXmlUtil;
import com.alibaba.fastjson.JSON;
import com.game.pb.AccountPb;
import net.sf.json.JSONObject;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;
import org.w3c.dom.Document;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;
import java.util.*;

@Component
public class MzUnicomPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String Secretkey = "";
    private static String CLIENT_ID = "";
    private static String CLIENT_SECRET = "";

    private static Map<String, ResultMsg> data = Collections.synchronizedMap(new HashMap<String, ResultMsg>());
    private static Map<String, String> dataAccount = Collections.synchronizedMap(new HashMap<String, String>());

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/mzUnicom/", "plat.properties");
        serverUrl = properties.getProperty("serverUrl");
        Secretkey = properties.getProperty("Secretkey");
        CLIENT_ID = properties.getProperty("client_id");
        CLIENT_SECRET = properties.getProperty("client_secret");

    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public GameError doLogin(AccountPb.DoLoginRq req, AccountPb.DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length != 3) {
            return GameError.PARAM_ERROR;
        }
        String access_token = vParam[1];
        String userId = vParam[2];

        if (!verifyAccount(userId, access_token)) {
            return GameError.SDK_LOGIN;
        }
        Account account = accountDao.selectByPlatId(getPlatNo(), userId);

        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();

            account.setPlatNo(this.getPlatNo());
            account.setPlatId(userId);
            account.setAccount(getPlatNo() + "_" + userId);
            account.setPasswd(userId);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setToken(token);
            account.setDeviceNo(deviceNo);
            Date now = new Date();
            account.setLoginDate(now);
            account.setCreateDate(now);
            accountDao.insertWithAccount(account);

        } else {
            String token = RandomHelper.generateToken();
            account.setToken(token);
            account.setBaseVersion(baseVersion);
            account.setVersionNo(versionNo);
            account.setDeviceNo(deviceNo);
            account.setLoginDate(new Date());
            accountDao.updateTokenAndVersion(account);
        }

        GameError authorityRs = super.checkAuthority(account);
        if (authorityRs != GameError.OK) {
            LOG.error("authorityRs:" + authorityRs);
            return authorityRs;
        }

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());

        if (isActive(account)) {
            response.setActive(1);

        } else {
            response.setActive(0);
        }
        return GameError.OK;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {

        String serviceid = request.getParameter("serviceid");

        String result = null;

        //根据serviceid，判断服务含义
        if ("validateorderid".equals(serviceid)) {
            //校验订单
            result = processValidateOrderId(request, content, response);
        } else {
            //支付结果通知
            result = _payBack(request, content, response);
        }

        LOG.error("result " + result);

        return result;

    }


    /**
     * 充值
     *
     * @param request
     * @param content
     * @param response
     * @return
     */
    public String _payBack(WebRequest request, String content, HttpServletResponse response) {

        try {
            LOG.error("pay mzUnicom " + content);

            Document document = StringXmlUtil.stringToXml(content);

            String orderid = StringXmlUtil.getNodeValue(document, "/callbackReq/orderid");
            LOG.error("pay mzUnicom xml解析后对应参数 orderid :" + orderid);


            ResultMsg resultMsg = data.get(orderid);

            if (resultMsg != null) {
                dataAccount.remove(resultMsg.getGameaccount());
            }
            data.remove(orderid);


            String ordertime = StringXmlUtil.getNodeValue(document, "/callbackReq/ordertime");
            LOG.error("pay mzUnicom xml解析后对应参数 ordertime :" + ordertime);


            String cpid = StringXmlUtil.getNodeValue(document, "/callbackReq/cpid");
            LOG.error("pay mzUnicom xml解析后对应参数 cpid :" + cpid);


            String appid = StringXmlUtil.getNodeValue(document, "/callbackReq/appid");
            LOG.error("pay mzUnicom xml解析后对应参数 appid :" + appid);


            String fid = StringXmlUtil.getNodeValue(document, "/callbackReq/fid");
            LOG.error("pay mzUnicom xml解析后对应参数 fid :" + fid);


            String consumeCode = StringXmlUtil.getNodeValue(document, "/callbackReq/consumeCode");
            LOG.error("pay mzUnicom xml解析后对应参数 consumeCode :" + consumeCode);


            String payfee = StringXmlUtil.getNodeValue(document, "/callbackReq/payfee");
            LOG.error("pay mzUnicom xml解析后对应参数 payfee :" + payfee);


            String payType = StringXmlUtil.getNodeValue(document, "/callbackReq/payType");
            LOG.error("pay mzUnicom xml解析后对应参数 payType :" + payType);

            String hRet = StringXmlUtil.getNodeValue(document, "/callbackReq/hRet");
            LOG.error("pay mzUnicom xml解析后对应参数 hRet :" + hRet);

            String status = StringXmlUtil.getNodeValue(document, "/callbackReq/status");
            LOG.error("pay mzUnicom xml解析后对应参数 status :" + status);

            String signMsg = StringXmlUtil.getNodeValue(document, "/callbackReq/signMsg");
            LOG.error("pay mzUnicom xml解析后对应参数 signMsg :" + signMsg);

            if (!"0".equals(hRet)) {
                LOG.error("pay mzUnicom hRet error orderid=" + orderid + " hRet=" + hRet);
                return getResult(2);
            }

            if (!"00000".equals(status)) {
                LOG.error("pay mzUnicom hRet error orderid=" + orderid + " status=" + status);
                return getResult(3);
            }


            String str = "orderid=%s&ordertime=%s&cpid=%s&appid=%s&fid=%s&consumeCode=%s&payfee=%s&payType=%s&hRet=%s&status=%s&Key=%s";
            String md5Str = String.format(str, orderid, ordertime, cpid, appid, fid, consumeCode, payfee, payType, hRet, status, Secretkey);
            String sign = MD5Util.toMD5(md5Str);

            if (!sign.equals(signMsg)) {
                LOG.error("pay mzUnicom sign error str=" + md5Str);
                LOG.error("pay mzUnicom sign error md5=" + sign + " signMsg=" + signMsg);
                return getResult(4);
            }

            String decodeOrderId = decodeOrderId(orderid);
            String[] infos = decodeOrderId.split("_");
            if (infos.length < 3) {
                LOG.error("pay mzUnicom error cpid=" + cpid);
                return getResult(5);
            }

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.childNo = super.getPlatNo();
            payInfo.platId = infos[1];
            payInfo.orderId = orderid;
            payInfo.serialId = decodeOrderId;
            payInfo.serverId = Integer.valueOf(infos[0]);
            payInfo.roleId = Long.valueOf(infos[1]);
            payInfo.realAmount = Double.valueOf(payfee) / 100;
            payInfo.amount = (int) (payInfo.realAmount / 1);

            int code = payToGameServer(payInfo);
            if (code != 0) {
                LOG.error("mzUnicom  充值发货失败 " + code);
                if (code == 2) {
                    return getResult(1);
                }
            } else {
                LOG.error("mzUnicom  充值发货成功 " + code);
            }
            return getResult(1);

        } catch (Exception e) {
            LOG.error("mzUnicom 充值异常:" + e.getMessage());
            e.printStackTrace();
            return getResult(6);
        }

    }

    /**
     * 验证账号
     *
     * @param user_id
     * @param access_token
     * @return
     */

    private boolean verifyAccount(String user_id, String access_token) {
        LOG.error("mzUnicom  开始调用sidInfo接口");
        try {

            Map<String, String> headerMap = new HashMap<>();
            headerMap.put("client_id", CLIENT_ID);
            headerMap.put("client_secret", CLIENT_SECRET);
            headerMap.put("access_token", access_token);
            String result = HttpUtils.sentPost(serverUrl, "", headerMap);
            LOG.error("mzUnicom 响应结果" + result);
            if (result == null || result.equals("")) {
                return false;
            }

            JSONObject jsonObject = JSONObject.fromObject(result);
            return user_id.equals(jsonObject.getString("user_id"));

        } catch (Exception e) {
            LOG.error("mzUnicom 验证账号error " + e.getMessage());
            return false;
        }
    }


    private String getResult(int code) {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><callbackRsp>" + code + "</callbackRsp>";
    }

    public String processValidateOrderId(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay order mzUnicom " + content);

        Document document = StringXmlUtil.stringToXml(content);

        String orderid = StringXmlUtil.getNodeValue(document, "/checkOrderIdReq/orderid");
        LOG.error("pay order mzUnicom xml解析后对应参数 orderid :" + orderid);

        String signMsg = StringXmlUtil.getNodeValue(document, "/checkOrderIdReq/signMsg");
        LOG.error("pay order mzUnicom xml解析后对应参数 signMsg :" + signMsg);

        String md5Str = "orderid=" + orderid + "&Key=" + Secretkey;
        String sign = MD5.md5Digest(md5Str);
        if (!sign.equals(signMsg)) {
            LOG.error("pay mzUnicom order sign error str=" + md5Str);
            LOG.error("pay mzUnicom order sign error md5=" + sign + " signMsg=" + signMsg);
            return getOrderResult(1);
        }

        ResultMsg resultMsg = data.get(orderid);


        if (resultMsg == null) {
            LOG.error("pay mzUnicom error orderid=" + orderid);
            return getOrderResult(1);
        }

        data.remove(orderid);
        dataAccount.remove(resultMsg.getGameaccount());
        return getOrderResult(0, resultMsg);
    }

    @Override
    public String order(WebRequest request, String content) {
        //<checkOrderIdRsp>0</checkOrderIdRsp>//0-验证成功1-验证失败，必填
        //<gameaccount>xxx</ gameaccount>//游戏账号，长度<=64，联网必填
        //<imei>xxx</ imei>//设备标识，联网必填，单机尽量上报
        //<macaddress>xxx</ macaddress>//MAC地址去掉冒号，联网必填，单机尽量
        //<ipaddress>xxx</ ipaddress>//IP地址，去掉点号，补零到每地址段3位，如：192168000001，联网必填，单机尽量
        //<serviceid>xxx</ serviceid>//12位沃商店计费点（业务代码），必填
        //<channelid>xxx</ channelid>//渠道ID，必填，如00012243
        //<cpid>xxx</ cpid>//沃商店CPID，必填
        //<ordertime>xxx</ ordertime>//订单时间戳，14位时间格式，联网必填，单机尽量yyyyMMddhhmmss
        //<appversion>xxx</ appversion>//应用版本号，必填，长度<=32

        LOG.error("pay mzUnicom order.do content=" + content);

        Map<String, String[]> parameterMap = request.getParameterMap();
        LOG.error("pay mzUnicom order.do parameterMap=" + JSON.toJSONString(parameterMap));

        String orderid = request.getParameter("orderid");

        if (orderid == null) {
            orderid = request.getParameter("orderid ");
        }
        LOG.error("pay mzUnicom order.do orderid=" + orderid);
        String gameaccount = request.getParameter("gameaccount");
        String imei = request.getParameter("imei");
        String macaddress = request.getParameter("macaddress");
        String serviceid = request.getParameter("serviceid");
        String channelid = request.getParameter("channelid");
        String cpid = request.getParameter("cpid");
        String ordertime = DateHelper.getDateTime(new Date());

        ResultMsg ResultMsg = new ResultMsg();

        ResultMsg.setGameaccount(gameaccount);
        ResultMsg.setImei(imei);
        ResultMsg.setMacaddress(macaddress);
        ResultMsg.setServiceid(serviceid);
        ResultMsg.setChannelid(channelid);
        ResultMsg.setCpid(cpid);
        ResultMsg.setOrdertime(ordertime);
        ResultMsg.setOrderId32(orderid);
        ResultMsg.setOrderId10(decodeOrderId(orderid));


        String cacheOrderid = dataAccount.get(gameaccount);
        if (cacheOrderid != null) {
            data.remove(cacheOrderid);
        }

        if (dataAccount.size() > 10000) {
            LOG.error("pay mzUnicom clear dataAccount size=" + dataAccount.size());
            dataAccount.clear();
        }

        if (data.size() > 10000) {
            LOG.error("pay mzUnicom clear data size=" + data.size());
            data.clear();
        }

        dataAccount.put(gameaccount, orderid);
        data.put(orderid, ResultMsg);

        LOG.error("pay mzUnicom order size=" + data.size() + " orderid=" + orderid + " ResultMsg=" + com.alibaba.fastjson.JSON.toJSONString(ResultMsg));

        return "1";
    }

    /**
     * @param code
     * @param resultMsg
     * @return
     */
    private String getOrderResult(int code, ResultMsg resultMsg) {

        String str = "<?xml version=\"1.0\" encoding=\"UTF-8\"?>" +
                "<paymessages>" +
                "<checkOrderIdRsp>" + code + "</checkOrderIdRsp>" +
                "<gameaccount>" + resultMsg.getGameaccount() + "</gameaccount>" +
                "<imei>" + resultMsg.getImei() + "</imei>" +
                "<macaddress>" + resultMsg.getMacaddress() + "</macaddress>" +
                "<ipaddress>" + resultMsg.getIpaddress() + "</ipaddress>" +
                "<serviceid>" + resultMsg.getServiceid() + "</serviceid>" +
                "<channelid>" + resultMsg.getChannelid() + "</channelid>" +
                "<cpid>" + resultMsg.getCpid() + "</cpid>" +
                "<ordertime>" + resultMsg.getOrdertime() + "</ordertime>" +
                "<appversion>" + resultMsg.getAppversion() + "</appversion>" +
                "</paymessages>";

        return str;

    }

    private String getOrderResult(int code) {
        return "<?xml version=\"1.0\" encoding=\"UTF-8\"?><paymessages><checkOrderIdRsp>" + code + "</checkOrderIdRsp></paymessages>";

    }

    public static String byteArrayToHexString(byte[] b) {
        StringBuffer resultSb = new StringBuffer();
        for (int i = 0; i < b.length; i++) {
            resultSb.append(byteToHexString(b[i]));
        }
        return resultSb.toString();
    }

    private static String byteToHexString(byte b) {
        int n = b;
        if (n < 0)
            n = 256 + n;
        int d1 = n / 16;
        int d2 = n % 16;
        return hexDigits[d1] + hexDigits[d2];
    }

    private final static String[] hexDigits = {"0", "1", "2", "3", "4", "5",
            "6", "7", "8", "9", "A", "B", "C", "D", "E", "F"};


    /**
     * 把32进制的 orderid 转换成10进制的
     *
     * @param orderStr
     * @return
     */
    private String decodeOrderId(String orderStr) {
        String[] str = orderStr.split("_");
        StringBuffer stringBuffer = new StringBuffer();
        stringBuffer.append(str[0]);
        stringBuffer.append("_");
        stringBuffer.append(Long.valueOf(str[1], 32));
        stringBuffer.append("_");
        stringBuffer.append(str[2]);
        return stringBuffer.toString();
    }
}
