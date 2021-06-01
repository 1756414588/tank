package com.account.service;

import com.account.constant.GameError;
import com.account.dao.impl.*;
import com.account.domain.*;
import com.account.handle.PlatHandle;
import com.account.plat.PlatBase;
import com.account.plat.Register;
import com.account.util.*;
import com.alibaba.fastjson.JSON;
import com.alibaba.fastjson.JSONArray;
import com.game.pb.AccountPb.*;
import com.game.pb.InnerPb.VerifyRq;
import com.game.pb.InnerPb.VerifyRs;
import net.sf.json.JSONObject;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.context.request.WebRequest;

import java.text.SimpleDateFormat;
import java.util.*;

public class AccountService {

    public Logger LOG = LoggerFactory.getLogger(AccountService.class);
    @Autowired
    private PlatHandle platHandle;

    @Autowired
    private AccountDao accountDao;

    @Autowired
    private ActiveDao activeDao;

    @Autowired
    private RoleDao roleDao;

    @Autowired
    private AdvertiseDao advertiseDao;

    @Autowired
    private ActionPointDao actionPointDao;

    @Autowired
    private RolePointDao rolePointDao;

    public GameError doLogin(JSONObject param, JSONObject response) {
        if (param == null) {
            return GameError.PARAM_ERROR;
        }

        try {
            String platName = param.getString("plat");
            if (platName == null) {
                return GameError.PARAM_ERROR;
            }
            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return GameError.INVALID_PARAM;
            }

            return plat.doLogin(param, response);
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            LOG.error("e:" + e);
            LOG.error("GameError.SERVER_EXCEPTION");
            return GameError.SERVER_EXCEPTION;
        }
    }

    public GameError doLogin(DoLoginRq req, DoLoginRs.Builder res) {
        if (req == null) {
            return GameError.PARAM_ERROR;
        }

        try {
            String platName = req.getPlat();
            if (platName == null) {
                return GameError.PARAM_ERROR;
            }
            PlatBase plat = platHandle.getPlatInst(platName);
            if (plat == null) {
                return GameError.INVALID_PARAM;
            }

            return plat.doLogin(req, res);
        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            LOG.error("e:" + e);
            LOG.error("GameError.SERVER_EXCEPTION");
            return GameError.SERVER_EXCEPTION;
        }
    }

    public GameError doActive(JSONObject param, JSONObject response) {
        if (param == null) {
            return GameError.PARAM_ERROR;
        }

        try {
            int keyId = param.getInt("keyId");
            String codeStr = param.getString("activeCode");
            if (keyId == 0 || codeStr == null) {
                return GameError.INVALID_PARAM;
            }

            long code = Long.valueOf(codeStr);

            Account account = accountDao.selectByKey(keyId);
            if (account == null) {
                return GameError.INVALID_PARAM;
            }

            if (account.getActive() == 1) {
                return GameError.ACTIVE_AGAIN;
            }

            ActiveCode activeCode = activeDao.selectActiveCode(code);
            if (activeCode == null) {
                return GameError.NO_ACTIVE_CODE;
            }

            if (activeCode.getUsed() == 1) {
                return GameError.USED_ACTIVE_CODE;
            }

            activeCode.setUsed(1);
            activeCode.setAccountKey(keyId);
            activeCode.setUseDate(new Date());
            activeDao.updateActiveCode(activeCode);

            account.setActive(1);
            accountDao.updateActive(account);
            return GameError.OK;

        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            return GameError.INVALID_PARAM;
        }
    }

    public GameError doActive(DoActiveRq req, DoActiveRs.Builder builder) {
        if (req == null) {
            return GameError.PARAM_ERROR;
        }

        try {
            int keyId = req.getKeyId();
            String codeStr = req.getActiveCode();
            if (keyId == 0 || codeStr == null) {
                return GameError.INVALID_PARAM;
            }

            long code = Long.valueOf(codeStr);

            Account account = accountDao.selectByKey(keyId);
            if (account == null) {
                return GameError.INVALID_PARAM;
            }

            if (account.getActive() == 1) {
                return GameError.ACTIVE_AGAIN;
            }

            ActiveCode activeCode = activeDao.selectActiveCode(code);
            if (activeCode == null) {
                return GameError.NO_ACTIVE_CODE;
            }

            if (activeCode.getUsed() == 1) {
                return GameError.USED_ACTIVE_CODE;
            }

            activeCode.setUsed(1);
            activeCode.setAccountKey(keyId);
            activeCode.setUseDate(new Date());
            activeDao.updateActiveCode(activeCode);

            account.setActive(1);
            accountDao.updateActive(account);

            builder.setState(1);
            return GameError.OK;

        } catch (Exception e) {
            // TODO: handle exception
            e.printStackTrace();
            return GameError.INVALID_PARAM;
        }
    }

    public GameError registerAccount(JSONObject param, JSONObject response) {
        if (param == null) {
            return GameError.PARAM_ERROR;
        }

        String platName = param.getString("plat");
        if (platName == null) {
            LOG.error("not have plat");
            return GameError.PARAM_ERROR;
        }

        Register register = platHandle.getRigisterInst(platName);
        if (register == null) {
            return GameError.INVALID_PARAM;
        }

        // Register plat = platHandle.getSelfPlat();
        return register.register(param, response);
    }

    public GameError registerAccount(DoRegisterRq req, DoRegisterRs.Builder builder) {
        if (req == null) {
            return GameError.PARAM_ERROR;
        }

        String platName = req.getPlat();
        if (platName == null) {
            LOG.error("not have plat");
            return GameError.PARAM_ERROR;
        }

        Register register = platHandle.getRigisterInst(platName);
        if (register == null) {
            return GameError.INVALID_PARAM;
        }

        // Register plat = platHandle.getSelfPlat();
        return register.register(req, builder);
    }

    private void recordRecentServer(Account account, int serverId) {
        int[] record = {account.getFirstSvr(), account.getSecondSvr(), account.getThirdSvr()};
        int temp = 0;
        if (record[0] != 0) {
            if (record[0] != serverId) {
                temp = record[2];
                record[2] = record[1];
                record[1] = record[0];
            }
        }

        record[0] = serverId;
        if (record[2] == serverId) {
            record[2] = temp;
        }
        account.setFirstSvr(record[0]);
        account.setSecondSvr(record[1]);
        account.setThirdSvr(record[2]);
        accountDao.updateRecentServer(account);
    }

    public GameError verifyPlayer(VerifyRq req, VerifyRs.Builder builder) {
        int keyId = req.getKeyId();
        int serverId = req.getServerId();
        String token = req.getToken();
        String curVersion = req.getCurVersion();
        String deviceNo = req.getDeviceNo();

        // Base.Builder baseBuilder = Base.newBuilder();
        // baseBuilder.setCmd(VerifyRs.EXT_FIELD_NUMBER);
        // baseBuilder.setParam(param);
        Account account = accountDao.selectByKey(keyId);
        if (account == null) {
            return GameError.INVALID_TOKEN;
        }

        String tokenExist = account.getToken();
        if (tokenExist == null || !tokenExist.equals(token)) {
            return GameError.INVALID_TOKEN;
        }

        this.recordRecentServer(account, serverId);

        builder.setKeyId(keyId);
        builder.setPlatId(account.getPlatId());
        builder.setPlatNo(account.getPlatNo());
        builder.setChildNo(account.getChildNo());
        builder.setCurVersion(curVersion);
        builder.setDeviceNo(deviceNo);
        builder.setServerId(serverId);
        builder.setChannelId(req.getChannelId());

        return GameError.OK;
    }

    /**
     * 记录用户已创建的角色，玩家登陆时进入
     *
     * @param accountKey
     * @param roleId
     * @param roleName
     * @param level
     * @param serverId
     * @param serverName
     * @return
     */
    public String recordRoleLogin(int accountKey, String roleId, String roleName, String level, String serverId,
                                  String serverName) {
        Account account = accountDao.selectByKey(accountKey);
        if (null == account) {
            return "NO ACCOUNT";
        }

        RoleData rd = roleDao.selectRoleDataByAccountKey(account.getKeyId());
        if (null == rd) {
            rd = new RoleData();
            rd.setAccountKey(account.getKeyId());
            rd.setRoles("");
            rd.setSearched(false);
            roleDao.insertRoleData(rd);
        }

        if (!rd.isSearched()) {// 还没有全服查找过的，查找一次
            searchAllRoleData(rd, account);
        }

        // if (!rd.getLordIdSet().contains(roleId)) {
        if (!rd.getServerIdSet().contains(serverId)) {
            Role role = new Role();
            role.setRole_id(roleId);
            role.setRole_name(roleName);
            role.setLevel(level);
            role.setServer_id(serverId);
            role.setServer_name(serverName);
            rd.addRole(role);
            roleDao.updateRoleData(rd);
        } else {// 更新角色信息
            // Role role = rd.getRoleById(roleId);
            Role role = rd.getRoleByServerId(serverId);
            if (null != role) {
                if (!role.getRole_id().equalsIgnoreCase(roleId)) {
                    role.setRole_id(roleId);
                }
                if (!role.getLevel().equalsIgnoreCase(level)) {
                    role.setLevel(level);
                }
                if (!role.getRole_name().equalsIgnoreCase(roleName)) {
                    role.setRole_name(roleName);
                }
                rd.updateRoles();
                roleDao.updateRoleData(rd);
            }
        }

        return "SUCCESS";
    }

    public String getAllRoleVip(int platNo, String platId) {
        // 根据平台id获取用户所有帐号（在所有现网游戏服务器中创建的帐号）
        Account account = accountDao.selectByPlatId(platNo, platId);
        if (null == account) {
            return null;
        }

        RoleData rd = roleDao.selectRoleDataByAccountKey(account.getKeyId());
        if (null == rd) {
            rd = new RoleData();
            rd.setAccountKey(account.getKeyId());
            rd.setRoles("");
            rd.setSearched(false);
            roleDao.insertRoleData(rd);
        }

        if (!rd.isSearched()) {// 还没有全服查找过的，查找一次
            searchAllRoleData(rd, account);
        }

        boolean isUpdate = false;
        List<Role> roleList = rd.getRoleList();
        for (Role role : roleList) {
            if (role.getServer_name().contains("S")) {// 服务器名称中包含serverId
                role.setServer_name(role.getServer_name().replaceAll("S[0-9]{1,4}", "").trim());
                isUpdate = true;
            }
        }

        if (isUpdate) {
            rd.updateRoles();
            roleDao.updateRoleData(rd);
        }

        // 第一次查询 vip
        boolean hasError = false;
        for (Role role : roleList) {
            String vip = searchRoleData(role.getRole_id(), role.getServer_id(), platNo);
            if (vip.length() > 1) {
                JSONObject rsp = JSONObject.fromObject(vip);
                role.setVip(rsp.getString("vip"));
            } else {
                hasError = true;
                break;
            }
        }
        if (hasError) { // 之前查询的信息有误
            searchAllRoleData(rd, account); // 进行一次全服查询
            // 第二次查询 vip
            Iterator<Role> it = rd.getRoleList().iterator();
            while (it.hasNext()) {
                Role role = it.next();
                String vip = searchRoleData(role.getRole_id(), role.getServer_id(), platNo);
                if (vip.length() > 1) {
                    JSONObject rsp = JSONObject.fromObject(vip);
                    role.setVip(rsp.getString("vip"));
                } else {
                    it.remove(); // 剔除查询不到的角色
                }
            }
        }
        if (roleList.size() == 0) {
            return null;
        }
        return JSON.toJSONString(roleList);
    }

    /**
     * 获取用户所有已创建的角色数据
     *
     * @param platNo
     * @param platId
     * @return
     */
    public String getAllRole(int platNo, String platId) {

        // 根据平台id获取用户所有帐号（在所有现网游戏服务器中创建的帐号）
        Account account = accountDao.selectByPlatId(platNo, platId);
        if (null == account) {
            return "NO ACCOUNT";
        }

        RoleData rd = roleDao.selectRoleDataByAccountKey(account.getKeyId());
        if (null == rd) {
            rd = new RoleData();
            rd.setAccountKey(account.getKeyId());
            rd.setRoles("");
            rd.setSearched(false);
            roleDao.insertRoleData(rd);
        }

        if (!rd.isSearched()) {// 还没有全服查找过的，查找一次
            searchAllRoleData(rd, account);
        }

        boolean isUpdate = false;
        Iterator<Role> it = rd.getRoleList().iterator();
        while (it.hasNext()) {
            Role role = it.next();
            if (CheckNull.isNullTrim(role.getRole_name())) {//删掉角色名为空的roles信息
                it.remove();
                isUpdate = true;
            }
            if (role.getServer_name().contains("S")) {// 服务器名称中包含serverId
                role.setServer_name(role.getServer_name().replaceAll("S[0-9]{1,4}", "").trim());
                isUpdate = true;
            }
        }

        if (isUpdate) {
            rd.updateRoles();
            roleDao.updateRoleData(rd);
        }

        // 返回用户所有角色的数据
        return rd.getRoles();
    }


    /**
     * 获取用户所有已创建的角色数据
     *
     * @param platNo
     * @param platId
     * @return
     */
    public String getAllNowRole(int platNo, String platId) {

        // 根据平台id获取用户所有帐号（在所有现网游戏服务器中创建的帐号）
        Account account = accountDao.selectByPlatId(platNo, platId);
        if (null == account) {
            return "NO ACCOUNT";
        }

        RoleData rd = roleDao.selectRoleDataByAccountKey(account.getKeyId());
        if (null == rd) {
            rd = new RoleData();
            rd.setAccountKey(account.getKeyId());
            rd.setRoles("");
            rd.setSearched(false);
            roleDao.insertRoleData(rd);
        }

        searchAllRoleData(rd, account);

        boolean isUpdate = false;
        Iterator<Role> it = rd.getRoleList().iterator();
        while (it.hasNext()) {
            Role role = it.next();
            if (CheckNull.isNullTrim(role.getRole_name())) {//删掉角色名为空的roles信息
                it.remove();
                isUpdate = true;
            }
            if (role.getServer_name().contains("S")) {// 服务器名称中包含serverId
                role.setServer_name(role.getServer_name().replaceAll("S[0-9]{1,4}", "").trim());
                isUpdate = true;
            }
        }

        if (isUpdate) {
            rd.updateRoles();
            roleDao.updateRoleData(rd);
        }

        // 返回用户所有角色的数据
        return rd.getRoles();
    }


    public String searchRoleData(String roleId, String serverId, int platNo) {
        Role role;
        List<GameServerConfig> serverList = DBUtil.getAllGameServerConfig();
        JSONObject json = new JSONObject();
        for (GameServerConfig server : serverList) {
            if (server.getServerId() == (Integer.valueOf(serverId))) {
                StringBuilder url = new StringBuilder("jdbc:mysql://");
                url.append(server.getGameDbIp()).append(":3306/").append(server.getDbName())
                        .append("?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull");
                role = DBUtil.selectRoleData(url.toString(), server.getUserName(), server.getPassword(), roleId);
                if (null != role) {
                    int checkPlatNo = DBUtil.selectRolePlanNo(url.toString(), server.getUserName(),
                            server.getPassword(), roleId);
                    if (platNo == checkPlatNo) {
                        json.put("role_name", role.getRole_name());
                        json.put("vip", role.getVip());
                        return json.toString();
                    } else {
                        return "3"; // 查询渠道与该角色不符合
                    }
                }
            } else {
                return "1"; // 无角色
            }
        }
        return "2"; // 区服ID错误
    }

    private void searchAllRoleData(RoleData rd, Account account) {
        Role role;
        List<GameServerConfig> serverList;
        List<Role> roleList = new ArrayList<Role>();

        List<Integer> serverIdList = new ArrayList<Integer>();
        if (account.getFirstSvr() > 0) {
            serverIdList.add(account.getFirstSvr());
        }
        if (account.getSecondSvr() > 0) {
            serverIdList.add(account.getSecondSvr());
        }
        if (account.getThirdSvr() > 0) {
            serverIdList.add(account.getThirdSvr());
        }
        // 查询数据库信息配置表，获取服务器对应的数据库连接信息
        if (serverIdList.size() == 3) {
            // 如果玩家有三个服务器的登录记录（account最多记录3个），才全服查找，否则只查找已经记录的登录服务器
            serverList = DBUtil.getAllGameServerConfig();
        } else {
            serverList = new ArrayList<GameServerConfig>();
            if (!CheckNull.isEmpty(serverIdList)) {
                Set<Integer> serverIdSet = new HashSet<>();
                serverIdSet.addAll(serverIdList);// 去重
                for (Integer serverId : serverIdSet) {
                    serverList.add(DBUtil.getServerById(serverId));
                }
            }
        }

        // 连接游戏数据库，获取玩家的角色信息
        if (!CheckNull.isEmpty(serverList)) {
            for (GameServerConfig server : serverList) {

                if (server == null) {
                    continue;
                }

                StringBuilder url = new StringBuilder("jdbc:mysql://");
                url.append(server.getGameDbIp()).append(":3306/").append(server.getDbName())
                        .append("?useUnicode=true&characterEncoding=utf-8&zeroDateTimeBehavior=convertToNull");
                role = DBUtil.selectRoleData(url.toString(), server.getUserName(), server.getPassword(),
                        rd.getAccountKey(), server.getServerId());
                if (null != role) {
                    // 记录角色信息
                    role.setServer_id(String.valueOf(server.getServerId()));
                    role.setServer_name(server.getServerName());
                    roleList.add(role);
                }
            }

            String roles = JSON.toJSONString(roleList);
            rd.setRoles(roles);
            rd.setSearched(true);
            rd.setRoleList(roleList);
            roleDao.updateRoleData(rd);
        }
    }

    /**
     * 查询推广渠道的用户是否已激活
     *
     * @param platNo
     * @param idfa
     * @return JSON 格式数据，例如： { "6A58EF1E-EEF2-478D-94EE-709B98407589":"1", "A0A82816-3383-437B-A535-F910162A7097":"0",
     * "A0A82816-3383-437B-A535-F910162A7098":"1" }
     */
    public String idfaHasActivated(int platNo, String idfa) {
        if (CheckNull.isNullTrim(idfa)) {
            return "IDFA NULL";
        }

        String[] idfas = idfa.split(",");
        if (idfas.length == 0) {
            return "IDFA ERROR";
        }

        if (idfas.length > 500) {
            return "IDFA LENGTH TOO LARGE";
        }

        Advertise advertise;
        Map<String, String> map = new LinkedHashMap<String, String>();
        for (String param : idfas) {
            advertise = advertiseDao.selectAdvertiseByIdfa(platNo, param.trim());
            if (null == advertise || !advertise.isActivated()) {
                map.put(param, "0");// 如果idfa无记录，或者未被激活，返回0
            } else {
                map.put(param, "1");
            }
        }

        return JSONArray.toJSONString(map);
    }

    /**
     * 记录推广渠道用户的idfa
     *
     * @param platNo
     * @param request
     * @return JSON 格式数据，例如：{"success":true,"message":"ok"}
     */
    public String idfaRecord(int platNo, WebRequest request) {
        Iterator<String> iterator = request.getParameterNames();
        while (iterator.hasNext()) {
            String paramName = iterator.next();
            PrintHelper.println(paramName + ":" + request.getParameter(paramName));
        }

        IDFAResult result = new IDFAResult();
        String idfa = request.getParameter("idfa");
        String ip = request.getParameter("ip");
        String callbackUrl = request.getParameter("callback");
        if (CheckNull.isNullTrim(idfa) || CheckNull.isNullTrim(callbackUrl)) {
            result.setSuccess(false);
            result.setMessage("param null");
        } else {
            idfa = idfa.trim();
            Advertise advertise = advertiseDao.selectAdvertiseByIdfa(platNo, idfa);
            if (null == advertise) {
                advertise = new Advertise();
                advertise.setIp(ip);
                advertise.setIdfa(idfa);
                advertise.setPlatNo(platNo);
                advertise.setCallbackUrl(callbackUrl);
                advertiseDao.insertAdvertise(advertise);
            }
            result.setSuccess(true);
            result.setMessage("ok");
        }

        return JSONArray.toJSONString(result);
    }

    /**
     * idfa激活，并通知推广渠道
     *
     * @param platNo
     * @param idfa
     * @return
     */
    public String idfaActivate(int platNo, String idfa) {
        if (CheckNull.isNullTrim(idfa)) {
            return "IDFA NULL";
        }
        try {
            Advertise advertise = advertiseDao.selectAdvertiseByIdfa(platNo, idfa.trim());
            if (null == advertise) {
                return "IDFA NOT FOUND, idfa:" + idfa;
            }

            if (advertise.isActivated()) {
                return "success";
            }

            // idfa激活
            advertise.setActivated(true);
            advertiseDao.updateAdvertise(advertise);

            String ret = HttpHelper.doPost(advertise.getCallbackUrl(), "");
            LOG.error("notice idfa result:" + ret);
            IDFAResult result = com.alibaba.fastjson.JSONObject.parseObject(ret, IDFAResult.class);
            if (null != result && result.isSuccess()) {
                return "success";
            }
            return "IDFA RESULT ERROR";
        } catch (Exception e) {
            e.printStackTrace();
            LOG.error(
                    "noticeAdvertise Exception, platNo:" + platNo + ", idfa:" + idfa + ", exception:" + e.getMessage());
            return "IDFA NOTICE EXCEPTION";
        }
    }

    /**
     * 添加设备埋点
     *
     * @param deviceNo
     * @param platNo
     * @param point
     */
    public void addActionPoint(String deviceNo, int platNo, int point) {
        ActionPoint actionPoint = actionPointDao.selectActionPoint(deviceNo);
        if (actionPoint == null) {
            actionPoint = new ActionPoint();
            actionPoint.setDeviceNo(deviceNo);
            actionPoint.setPlatNo(platNo);
            actionPoint.setPoint(point);
            actionPoint.setChangeTime(new Date());
            actionPointDao.insertActionPoint(actionPoint);
            PrintHelper.println("新增设备埋点     设备编号:" + deviceNo + " 渠道号:" + platNo + " 埋点:" + point);
        } else {
            if (actionPoint.getPoint() < point) {
                int oldPoint = actionPoint.getPoint();
                actionPoint.setPoint(point);
                actionPoint.setChangeTime(new Date());
                actionPointDao.updateActionPoint(actionPoint);
                PrintHelper
                        .println("修改设备埋点     设备编号:" + deviceNo + " 渠道号:" + platNo + " 埋点:" + oldPoint + "->" + point);
            }
        }
    }


    /**
     * 玩家行为日志
     *
     * @param plat_no
     * @param server_id
     * @param user_id
     * @param level
     * @param vip
     * @param point
     * @param deviceNo
     */
    public void rolePoint(String platNo, String serverId, String userId, String level, String vip, String point, String deviceNo) {
        RolePoint rolePoint = new RolePoint();
        rolePoint.setPlatNo(platNo);
        rolePoint.setServerId(serverId);
        rolePoint.setUserId(userId);
        rolePoint.setLevel(level);
        rolePoint.setVip(vip);
        rolePoint.setPoint(point);
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        String logTime = simpleDateFormat.format(new Date());
        rolePoint.setLog_time(logTime);
        rolePoint.setDeviceNo(deviceNo);
        ActionPointUtil.insert(rolePointDao, rolePoint);
    }

}
