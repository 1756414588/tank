package com.account.plat.impl.chYhSw;

import java.io.IOException;
import java.io.StringReader;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.JDOMException;
import org.jdom.input.SAXBuilder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;
import org.xml.sax.InputSource;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;

@Component
public class ChYhSwPlat extends PlatBase {

    private static String serverUrl = "";

    private static String SiteId;

    private static String GameId;

    private static String MD5Key;

    private static String SignKey;

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhSw/", "plat.properties");
        SiteId = properties.getProperty("SiteId");
        GameId = properties.getProperty("GameId");
        MD5Key = properties.getProperty("MD5Key");
        SignKey = properties.getProperty("SignKey");
        serverUrl = properties.getProperty("VERIRY_URL");
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.OK;
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        String[] vParam = sid.split("_");
        if (vParam.length < 2) {
            return GameError.PARAM_ERROR;
        }

        String userId = vParam[0];
        if (!verifyAccount(vParam[0], vParam[1])) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), userId);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(getPlatNo());
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
            return authorityRs;
        }

        response.addAllRecent(super.getRecentServers(account));
        response.setKeyId(account.getKeyId());
        response.setToken(account.getToken());
        response.setUserInfo(userId);

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    private static String getParamsStr(Map<String, String> params) {
        Object[] keys = params.keySet().toArray();
        Arrays.sort(keys);
        String k, v;
        String str = "";
        for (int i = 0; i < keys.length; i++) {
            k = (String) keys[i];
            if (k.equals("sign") || k.equals("plat") || k.equals("sign_type")) {
                continue;
            }

            if (params.get(k) == null || params.get(k).equals("")) {
                continue;
            }

            v = (String) params.get(k);

            if (i != 0) {
                str += "|";
            }
            str += v;
        }
        return str;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhSw");
        try {
            LOG.error("pay chYhSw content:" + content);
            LOG.error("[开始参数]");
            Iterator<String> iterator = request.getParameterNames();
            Map<String, String> params = new HashMap<>();
            while (iterator.hasNext()) {
                String paramName = iterator.next();
                LOG.error(paramName + ":" + URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
                params.put(paramName, URLDecoder.decode(request.getParameter(paramName), "UTF-8"));
            }
            LOG.error("[结束参数]");

            String orderNo = request.getParameter("orderNo");
            String gameId = request.getParameter("gameId");
            String guid = request.getParameter("guid");
            String money = request.getParameter("money");
            String coins = request.getParameter("coins");
            String coinMes = request.getParameter("coinMes");
            String time = request.getParameter("time");
            String extInfo = request.getParameter("extInfo");
            String sign = request.getParameter("sign");

            String signStr = getParamsStr(params) + "|" + SignKey;
            LOG.error("[签名原文]" + signStr);
            String signCheck = MD5.md5Digest(signStr).toUpperCase();
            LOG.error("[签名结果]" + signCheck);

            if (!sign.equals(signCheck)) {  // 签名失败
                LOG.error("chYhSw sign error");
                return "0";
            }

            String[] v = extInfo.split("_");

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = guid;
            payInfo.orderId = orderNo;

            payInfo.serialId = extInfo;
            payInfo.serverId = Integer.valueOf(v[0]);
            payInfo.roleId = Long.valueOf(v[1]);
            payInfo.realAmount = Double.valueOf(money);
            payInfo.amount = (int) (payInfo.realAmount / 1);
            int code = payToGameServer(payInfo);

            if (code == 0) {
                LOG.error("chYhSw 充值发货成功 ");
            } else if (code == 1) {
                LOG.error("chYhSw 重复的订单号！！ " + code);
            } else {
                LOG.error("chYhSw 充值发货失败！！ " + code);
                return "1";
            }
            return "0";
        } catch (Exception e) {
            LOG.error("chYhSw 充值异常:" + e.getMessage());
            e.printStackTrace();
            return "error";
        }
    }

    private boolean verifyAccount(String guid, String accessToken) {
        LOG.error("chYhSw 开始调用sidInfo接口");
        //  sign=upper(md5(upper(urlencode(siteId|time|guid|gameid|accessToken|md5Key))))
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String time = sdf.format(new Date());

        String signStr = SiteId + "|" + time + "|" + guid + "|" + GameId + "|" + accessToken + "|" + MD5Key;
        LOG.error("待签名字符串:" + signStr);
        try {
            String sign = MD5.md5Digest(URLEncoder.encode(signStr, "utf-8").toUpperCase()).toUpperCase();
            LOG.error("签名:" + sign);
            String body = "guid=" + guid + "&gameId=" + GameId + "&accessToken=" + accessToken + "&siteId=" + SiteId + "&time=" + time + "&sign=" + sign;
            LOG.error("请求参数:" + body);
            String result = HttpUtils.sentPost(serverUrl, body);
            LOG.error("[响应结果]" + result);
            String code = getXmlAttr(result, "msgId");
            if (code.equals("0")) {
                LOG.error("验证成功");
                return true;
            }
            LOG.error("验证失败 ");
            return false;
        } catch (Exception e) {
            LOG.error("chYhSw 接口返回异常:" + e.getMessage());
            e.printStackTrace();
            return false;
        } finally {
            LOG.error("调用sidInfo接口结束");
        }
    }

    private String getXmlAttr(String xml, String attr) throws JDOMException, IOException {
        StringReader read = new StringReader(xml);
        InputSource source = new InputSource(read);
        SAXBuilder saxBuilder = new SAXBuilder();
        Document doc = saxBuilder.build(source);
        Element root = doc.getRootElement();
        List<?> node = root.getChildren();
        Element element = (Element) node.get(0);
        return element.getAttributeValue(attr);
    }

}
