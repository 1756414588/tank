package com.account.util;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.account.domain.form.RoleLog;
import com.account.plat.impl.kaopu.MD5Util;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.alibaba.fastjson.JSONObject;

/**
 * @author GuiJie
 * @description 拇指创建角色信息上报
 * @created 2018/02/26 10:44
 */
public class MuZhiRoleInfoReportedData {

    public static void main(String[] args) throws Exception {
//[2018.03.16 09:42:48.944]muzhi roleInfo reportedData false
// {"accountKey":26148340,"createTime":1521164568903,"level":"1","platId":"49565097",
// "roleId":"50103020007018","roleName":"米切尔森西瑞尔","serverId":"302",
// "serverName":"S301 闪击波兰","subject":"LOG_ROLE_CREATE_2_GDPS"}

        RoleLog role = new RoleLog();
        role.setPlatId("49565097");
        role.setServerId("302");
        role.setServerName("S301 闪击波兰");
        //role.setRoleId("50103020007018");
        role.setRoleName("米切尔森西瑞尔");
        role.setLevel("1");
        reportedData(role, "431");
    }

    public static Logger LOG = LoggerFactory.getLogger(MuZhiRoleInfoReportedData.class);

    private static String url = "http://gm.91muzhi.com:8080/sdk/userRoleInfo/updateRoleInfo.do";

    public static void reportedData(RoleLog role, String gameId) throws Exception {

        JSONObject param = new JSONObject();

        param.put("game_id", gameId);
        param.put("encrypt", "MD5");

        JSONArray jSONArray = new JSONArray();

        JSONObject data = new JSONObject();
        data.put("user_id", role.getPlatId());
        data.put("game_id", gameId);
        data.put("ServerId", role.getServerId());
        data.put("ServerName", role.getServerName());
        data.put("RoleId", role.getRoleId());
        data.put("RoleName", role.getRoleName());
        data.put("RoleLevel", role.getLevel());
        data.put("ChargeNum", "0");
        data.put("RoleVipLv", "0");
        jSONArray.add(data);

        String dataStr = AESUtil.encrypt(jSONArray.toJSONString(), "N6xCnO793woohat7", "N6xCnO793woohat7");
        param.put("data", dataStr);

        String signStr = "data=" + dataStr + "apikey=" + "WaRbG8";
        String md5 = MD5Util.toMD5(signStr);

        param.put("sign", md5);

        String result = HttpHelper.doPost(url, param.toJSONString());
        if (!"success".equals(result)) {
            LOG.error("muzhi roleInfo reportedData 1 " + result + " " + JSON.toJSONString(role));
            LOG.error("muzhi roleInfo reportedData 2 param =" + param.toJSONString());
        }
    }
}
