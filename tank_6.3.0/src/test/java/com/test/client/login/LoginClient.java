package com.test.client.login;

import java.util.List;
import java.util.Random;

import com.game.constant.GameError;
import com.game.pb.BasePb.Base;
import com.game.pb.GamePb1.BeginGameRq;
import com.game.pb.GamePb1.BeginGameRs;
import com.game.pb.GamePb1.CreateRoleRq;
import com.game.pb.GamePb1.CreateRoleRs;
import com.game.pb.GamePb1.RoleLoginRq;
import com.game.util.CheckNull;
import com.game.util.LogUtil;

import com.test.client.ClientLogger;
import com.test.client.BaseClient;

/**
 * @Description 简单测试登录协议的客户端模拟类
 * @author TanDonghai
 * @date 创建时间：2016年10月31日 下午2:36:25
 *
 */
public class LoginClient extends BaseClient {

    public LoginClient(String serverIp, int port) {
        super(serverIp, port);
    }

    public static void main(String[] args) throws InterruptedException {
        // 游戏服务器IP
        String serverIp = "127.0.0.1";
        // 游戏服务器端口
        int port = 9203;
        if (null != args && args.length >= 2) {
            serverIp = args[0].trim();
            port = Integer.parseInt(args[1].trim());
        }

        // 启动客户端线程
        LoginClient client = new LoginClient(serverIp, port);
        Thread thread = new Thread(client);
        thread.start();

        // 等待与服务器建立连接
        while (client.connecting) {
            Thread.sleep(1000);
            ClientLogger.print("连接服务器...");
        }

        if (!client.connected) {
            ClientLogger.print("连接服务器失败，即将退出");
            return;
        }

        // 发送开始游戏协议
        BeginGameRs rs = client.beginGame();
        if (null == rs) {
            ClientLogger.print("开始游戏失败，退出...");
            return;
        }

        // 角色未创建，创建角色
        if (rs.getState() == 1) {
            CreateRoleRs createRs = client.createRole(rs.getNameList());
            if (null == createRs || createRs.getState() != 1) {
                LogUtil.error("角色创建失败，退出...");
                return;
            }
        }

        // 角色登录
        client.roleLogin();
    }

    /**
     * 角色登录
     */
    private void roleLogin() {
        RoleLoginRq.Builder builder = RoleLoginRq.newBuilder();

        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(RoleLoginRq.EXT_FIELD_NUMBER);
        baseBuilder.setExtension(RoleLoginRq.ext, builder.build());
        sendMsgToServer(baseBuilder);
    }

    /**
     * 创建角色
     * 
     * @param nameList
     * @return
     */
    private CreateRoleRs createRole(List<String> nameList) {
        String nick = null;
        if (!CheckNull.isEmpty(nameList)) {
            nick = nameList.get(0);
        } else {
            nick = "nick" + new Random().nextInt(1000);
        }

        CreateRoleRq.Builder builder = CreateRoleRq.newBuilder();
        builder.setPortrait(1);
        builder.setNick(nick);
        builder.setSex(1);
        builder.build();

        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(CreateRoleRq.EXT_FIELD_NUMBER);
        baseBuilder.setExtension(CreateRoleRq.ext, builder.build());
        sendMsgToServer(baseBuilder);

        Base rs = getMessage(CreateRoleRs.EXT_FIELD_NUMBER, 5000);
        if (null != rs && rs.getCmd() == CreateRoleRs.EXT_FIELD_NUMBER && rs.getCode() == GameError.OK.getCode()) {
            return rs.getExtension(CreateRoleRs.ext);
        }
        return null;
    }

    /**
     * 开始游戏
     * 
     * @return
     */
    private BeginGameRs beginGame() {
        BeginGameRq.Builder builder = BeginGameRq.newBuilder();
        builder.setServerId(1);
        builder.setKeyId(44105);
        builder.setToken("d4a0e95b2a334bbfbab951aafeb3049c");
        builder.setDeviceNo("00000000-2625-0b64-7b72-55e30033c587");
        builder.setCurVersion("3.9.1");

        Base.Builder baseBuilder = Base.newBuilder();
        baseBuilder.setCmd(BeginGameRq.EXT_FIELD_NUMBER);
        baseBuilder.setExtension(BeginGameRq.ext, builder.build());
        sendMsgToServer(baseBuilder);

        Base rs = getMessage(BeginGameRs.EXT_FIELD_NUMBER, 5000);
        if (null != rs && rs.getCmd() == BeginGameRs.EXT_FIELD_NUMBER && rs.getCode() == GameError.OK.getCode()) {
            return rs.getExtension(BeginGameRs.ext);
        }
        return null;
    }
}
