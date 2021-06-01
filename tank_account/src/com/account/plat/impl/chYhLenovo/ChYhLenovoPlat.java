package com.account.plat.impl.chYhLenovo;

import java.io.StringReader;
import java.io.UnsupportedEncodingException;
import java.net.URLDecoder;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Properties;

import javax.annotation.PostConstruct;
import javax.servlet.http.HttpServletResponse;

import net.sf.json.JSONObject;

import org.jdom.Document;
import org.jdom.Element;
import org.jdom.input.SAXBuilder;
import org.springframework.stereotype.Component;
import org.springframework.web.context.request.WebRequest;
import org.xml.sax.InputSource;

import com.account.constant.GameError;
import com.account.domain.Account;
import com.account.plat.PayInfo;
import com.account.plat.PlatBase;
import com.account.plat.impl.kaopu.Base64;
import com.account.plat.impl.self.util.HttpUtils;
import com.account.plat.impl.self.util.MD5;
import com.account.util.RandomHelper;
import com.game.pb.AccountPb.DoLoginRq;
import com.game.pb.AccountPb.DoLoginRs;
import com.lenovo.pay.sign.CpTransSyncSignValid;

import io.netty.handler.codec.base64.Base64Decoder;

class LenovoAccount {
    public String DeviceID;
    public String AccountID;
    public String Username;
}

@Component
public class ChYhLenovoPlat extends PlatBase {
    // sdk server的接口地址
    private static String serverUrl = "";

    private static String APPKEY = "";

    private static String REALM = "";

    @PostConstruct
    public void init() {
        Properties properties = loadProperties("com/account/plat/impl/chYhLenovo/", "plat.properties");
        APPKEY = properties.getProperty("APPKEY");
        serverUrl = properties.getProperty("VERIRY_URL");
        REALM = properties.getProperty("REALM");
    }

    @Override
    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder response) {
        if (!req.hasSid() || !req.hasBaseVersion() || !req.hasVersion() || !req.hasDeviceNo()) {
            return GameError.PARAM_ERROR;
        }

        String sid = req.getSid();
        String baseVersion = req.getBaseVersion();
        String versionNo = req.getVersion();
        String deviceNo = req.getDeviceNo();

        LenovoAccount lenovoAccount = verifyAccount(sid);
        if (lenovoAccount == null) {
            return GameError.SDK_LOGIN;
        }

        Account account = accountDao.selectByPlatId(getPlatNo(), lenovoAccount.AccountID);
        if (account == null) {
            String token = RandomHelper.generateToken();
            account = new Account();
            account.setPlatNo(this.getPlatNo());
            account.setPlatId(lenovoAccount.AccountID);
            account.setAccount(getPlatNo() + "_" + lenovoAccount.AccountID);
            account.setPasswd(lenovoAccount.AccountID);
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

        if (isActive(account)) {
            response.setActive(1);
        } else {
            response.setActive(0);
        }

        return GameError.OK;
    }

    @Override
    public GameError doLogin(JSONObject param, JSONObject response) {
        return GameError.SDK_LOGIN;
    }

    @Override
    public String payBack(WebRequest request, String content, HttpServletResponse response) {
        LOG.error("pay chYhLx");

        String transdata = request.getParameter("transdata");
        String sign = request.getParameter("sign");

        try {
            LOG.error("[接收到的参数]" + "transdata:" + transdata + "|" + "sign:" + sign);
            JSONObject requestParam = JSONObject.fromObject(transdata);
            String transid = requestParam.getString("transid");
            if (!CpTransSyncSignValid.validSign(transdata.toString(), sign, APPKEY)) {
                LOG.error("签名不一致");
                return "FAILURE";
            }

            Integer result = requestParam.getInt("result");
            String cpprivate = requestParam.getString("cpprivate");
            Integer money = requestParam.getInt("money");
            if (result == null || result != 0) {
                LOG.error("支付结果失败");
                return "SUCCESS";
            }

            String[] infos = cpprivate.split("_");
            if (infos.length != 3) {
                LOG.error("自有参数有问题");
                return "SUCCESS";
            }

            int serverid = Integer.valueOf(infos[0]);
            Long lordId = Long.valueOf(infos[1]);

            PayInfo payInfo = new PayInfo();
            payInfo.platNo = getPlatNo();
            payInfo.platId = String.valueOf(lordId);
            payInfo.orderId = transid;

            payInfo.serialId = cpprivate;
            payInfo.serverId = serverid;
            payInfo.roleId = lordId;
            payInfo.realAmount = Double.valueOf(money) / 100;
            payInfo.amount = (int) payInfo.realAmount;
            int code = payToGameServer(payInfo);
            if (code == 0) {
                LOG.error("chYhLx 返回充值成功");
            } else {
                LOG.error("chYhLx 返回充值失败");
            }
            return "SUCCESS";
        } catch (Exception e) {
            e.printStackTrace();
        }
        return "SUCCESS";
    }

    private JSONObject xmlElements(String xmlDoc) {
        JSONObject rs = new JSONObject();
        StringReader read = new StringReader(xmlDoc);
        InputSource source = new InputSource(read);
        SAXBuilder sb = new SAXBuilder();

        try {
            Document doc = sb.build(source);
            Element root = doc.getRootElement();
            @SuppressWarnings("unchecked")
            List<Element> jiedian = root.getChildren();
            Element et = null;
            for (int i = 0; i < jiedian.size(); i++) {
                et = jiedian.get(i);
                rs.put(et.getName(), et.getTextTrim());
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return rs;
    }

    private LenovoAccount verifyAccount(String sid) {
        LOG.error("chYhLx 开始调用sidInfo接口");

        HashMap<String, String> params = new HashMap<String, String>();
        params.put("lpsust", sid);
        params.put("realm", REALM);

        String result = HttpUtils.sendGet(serverUrl, params);
        LOG.error("[响应结果]" + result);

        JSONObject userInfo = xmlElements(result);
        LOG.error(userInfo.toString());
        if (userInfo != null && !userInfo.containsKey("Code")) {
            if (!userInfo.containsKey("AccountID") || !userInfo.containsKey("DeviceID") || !userInfo.containsKey("Username")) {
                return null;
            }
            LenovoAccount lenovoAccount = new LenovoAccount();
            lenovoAccount.AccountID = userInfo.getString("AccountID");
            lenovoAccount.DeviceID = userInfo.getString("DeviceID");
            lenovoAccount.Username = userInfo.getString("Username");

            LOG.error("chYhLx 验证成功 ");
            return lenovoAccount;
        } else {
            return null;
        }

    }

    public static void main(String[] args) {
        JSONObject json = new JSONObject();
        json.put("transtype", "0");
        json.put("result	", "0");
        json.put("transtime", "2017-05-01 11:29:48");
        json.put("count", "1");
        json.put("paytype", "5");
        json.put("money", "1000");
        json.put("waresid", "72994");
        json.put("appid", "1605170145627.app.ln");
        json.put("exorderno", "20_2018049_1493609342793");
        json.put("feetype", "0");
        json.put("transid", "2170501112948253059081532");
        json.put("cpprivate", "20_2018049_1493609342793");

        String sign = "aTLTG2IrgvfnDbOHdMHPJ3FKgBH4DyD/5S2E9FO6m3tJIZwbkDRmI1jA6q4bS5v3yQ5DF0Ewp5vKvRGigiBlDjyyiiPqvsaSfqPb741bBtLVd1Vnkap5itpyf2Oblhvvdwn+xEmVX+GdUh3gvi2t1cmHEYvziklLgfok5WBDr2c=";
        String appkey = "MIICdQIBADANBgkqhkiG9w0BAQEFAASCAl8wggJbAgEAAoGBALzmi/vqtxwye+hi/xyoiZ3mpbYWKSjRnzaROqJopUaLNQSJAkmkhYQxJ5aR6966yiKuCFmx2s/RDSN7UiQ8aSn+2fcRy/dhQ4BojZNRaqmLOTqDyKQYHaCmIGhe6t7DSojCoXt+VbDCXEtWKuxKajcx+c3cTioFIHfKRaEDLxSLAgMBAAECgYA6w+4gfLBiUUJC1SlQHQ5S1QIQV2yOikfhjeSTycJA4+Wmd4kCp+/xY+lQ6ixaqflgOIvYe3/6zqors52mMDT2lpmwIRZ1CMGxsnAmFlpEJZNIU3R7wYxogv48JQa1iJxvjuCHZRA8pKLMwJk00OCKmMZljIol66NGqk7lKuc8YQJBAObbzi6A7CvKusnMOpeb0+QnTv/IMuI/XoNSOtYqxAYWyoPuXzec1GJzeMuLNjAaG0ccApL9dMjARUBBkQlE4p8CQQDRePoxgx6BYO8nsoX/d2kd9hI0iN1rzvbBO5SBiEWKMslnVMIZ7OxiuqXMS11g0ApSa0z7eCeG5UQy2tVw2BKVAkB+msre+/sJJRv88VCstlulAt2zLrKhG0mU0TLNIxTvle4oHkD/ubVL7LGxRr5H8PlGrRjITdGPCsqvq4WDxNBXAkAprQciOLMmDJIodMViOXDJjD69AwoCvA+uDFuUlfc38rjNfTiNDe1OC1KXXds7OskC8uRDF/nNReoWsCFNLUAtAkAAo0SwcIASUvrMy0M7gjxhx/iela8tu6EqbWoBNFYOl390F1Q0H72unWSSgknZOlug4ayN6JMOJdCSW2Y5WLWt";
//		s = "ROgSzAbPu3wZ3kjoml8Z8y1Q0MrjrLn3JBaT7U+8HKk6Ox+yCNGOqchc0aVtyJoWP5EoTa8PnqOt77ul4+fwxOfVgbGodkSdhqvU9s6NzpBYUNX0bYej7fHCcRYac0FJRvYA+uwP/DNCLy24n3qD+q5TXRN6dPpnb4g4gI0kBUk=";
//		String s1 = "aTLTG2IrgvfnDbOHdMHPJ3FKgBH4DyD/5S2E9FO6m3tJIZwbkDRmI1jA6q4bS5v3yQ5DF0Ewp5vKvRGigiBlDjyyiiPqvsaSfqPb741bBtLVd1Vnkap5itpyf2Oblhvvdwn+xEmVX+GdUh3gvi2t1cmHEYvziklLgfok5WBDr2c=";


        if (CpTransSyncSignValid.validSign(json.toString(), sign, appkey)) {
            //LOG.error();
        }
    }
}
