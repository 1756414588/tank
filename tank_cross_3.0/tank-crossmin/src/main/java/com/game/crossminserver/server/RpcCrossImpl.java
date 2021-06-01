package com.game.crossminserver.server;

import com.game.service.rpc.HeartbeatImpl;
import com.game.service.seniormine.SeniorMineRpcServiceImpl;
import com.game.service.teaminstance.TeamRpcServiceImpl;
import io.grpc.BindableService;

import java.util.ArrayList;
import java.util.List;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/3/6 17:33
 * @description：cross impl
 */
public class RpcCrossImpl {

    public static List<BindableService> serviceList = new ArrayList<>();

    static {
        serviceList.add(new HeartbeatImpl());
        serviceList.add(new TeamRpcServiceImpl());
        serviceList.add(new SeniorMineRpcServiceImpl());
    }
}
