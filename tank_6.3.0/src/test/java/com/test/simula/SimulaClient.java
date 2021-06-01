package com.test.simula;

import com.game.pb.*;
import com.game.util.HttpUtils;
import com.game.util.NumberHelper;
import com.google.protobuf.ExtensionRegistry;
import io.netty.bootstrap.Bootstrap;
import io.netty.buffer.PooledByteBufAllocator;
import io.netty.channel.ChannelFuture;
import io.netty.channel.ChannelOption;
import io.netty.channel.nio.NioEventLoopGroup;
import io.netty.channel.socket.nio.NioSocketChannel;

import java.io.BufferedReader;
import java.io.InputStreamReader;

/**
 * @author zhangdh
 * @ClassName: SimulaClient
 * @Description: 模拟器客户端
 * @date 2017/5/2 10:07
 */
public class SimulaClient {

    //IP
    public static String ip = "192.168.0.121";

    //端口
    public static int port = 9203;

    public static int sid = 41;

    public static String deviceNo = "00000000-2625-0b64-7b72-55e30033c587";

    public static String plat_id = "self";

    public static String account_ip = "192.168.1.166:9200";

    public static String base_version = "1.0.1";

    public static String version = "1.3.8";
    static public ExtensionRegistry registry = ExtensionRegistry.newInstance();

    static {
        AccountPb.registerAllExtensions(registry);
        CommonPb.registerAllExtensions(registry);
        GamePb1.registerAllExtensions(registry);
        GamePb2.registerAllExtensions(registry);
        GamePb3.registerAllExtensions(registry);
        GamePb4.registerAllExtensions(registry);
        GamePb5.registerAllExtensions(registry);
        GamePb6.registerAllExtensions(registry);
        InnerPb.registerAllExtensions(registry);
        CrossGamePb.registerAllExtensions(registry);
    }

    //帐号地址
    public static String account_addr = "http://192.168.1.166:9200/tank_account/account/account.do";

//    public static String self_addr = "http://192.168.2.141:8080/tank_account/account/account.do";

    public static void main(String[] args) throws Exception {
        AccountPb.DoLoginRq.Builder reqBuilder = AccountPb.DoLoginRq.newBuilder();
        reqBuilder.setSid(SimulaAccout.getString());
        reqBuilder.setBaseVersion(base_version);
        reqBuilder.setVersion(version);
        reqBuilder.setDeviceNo(deviceNo);
        reqBuilder.setPlat(plat_id);
        BasePb.Base.Builder baseBuilder = BasePb.Base.newBuilder();
        baseBuilder.setCmd(AccountPb.DoLoginRq.EXT_FIELD_NUMBER);
        baseBuilder.setExtension(AccountPb.DoLoginRq.ext, reqBuilder.build());
        byte[] reqArr = baseBuilder.build().toByteArray();
        byte[] resArr = HttpUtils.sendPbByte(account_addr, reqArr);
        if (reqArr == null) throw new NullPointerException();
        int size = NumberHelper.getShort(resArr, 0);
        byte[] arr = new byte[size];
        System.arraycopy(resArr, 2, arr, 0, size);

        BasePb.Base base = BasePb.Base.parseFrom(arr, registry);
        AccountPb.DoLoginRs pbRes = base.getExtension(AccountPb.DoLoginRs.ext);
        SimulaAccout.keyId = pbRes.getKeyId();
        SimulaAccout.token = pbRes.getToken();

        NioEventLoopGroup group = new NioEventLoopGroup();
        try {
            Bootstrap b = new Bootstrap();
            b.group(group).channel(NioSocketChannel.class);
            // 通过NoDelay禁用Nagle,使消息立即发出去，不用等待到一定的数据量才发出去
            b.option(ChannelOption.TCP_NODELAY, true);
            b.option(ChannelOption.ALLOCATOR, PooledByteBufAllocator.DEFAULT);
            b.option(ChannelOption.SO_KEEPALIVE, true);
            b.option(ChannelOption.SO_BACKLOG, 1024);
            b.handler(new SimulaHandler());

            ChannelFuture connect = b.connect(ip, port).sync();
            connect.channel().writeAndFlush(SimulaRequestFactory.createBeginGameReqest());
            connect.awaitUninterruptibly();
        } catch (Exception e) {
            e.printStackTrace();
        }

        new Thread(new Runnable() {
            @Override
            public void run() {
                //开始处理逻辑
                BufferedReader reader = new BufferedReader(new InputStreamReader(System.in));
                String readLine;
                while (System.currentTimeMillis() > 0) {
                    try {
                        readLine = reader.readLine().trim();
                        if ("exit".equals(readLine)) {
                            System.exit(0);
                        }

                        String[] cmds = readLine.split(",");
                        int header = Integer.parseInt(cmds[0]);

                        if (header == GamePb6.ResetFightLabGraduateUpRq.EXT_FIELD_NUMBER) {//6029
                            SimulaRequestFactory.ResetFightLabGraduateUpRq(cmds[0]);
                        }
                        if (header == GamePb6.ResetMilitaryScienceRq.EXT_FIELD_NUMBER) {//6800
                            SimulaRequestFactory.ResetMilitaryScienceRq(cmds[0]);
                        }
//                        else if(header == GamePb6.GetFestivalRewardRq.EXT_FIELD_NUMBER){//6502
//                            SimulaRequestFactory.GetFestivalRewardRq(cmds[1]);
//                        }else if(header == GamePb6.GetFestivalLoginRewardRq.EXT_FIELD_NUMBER){//6504
//                            SimulaRequestFactory.GetFestivalLoginRewardRq(cmds[0]);
//                        }else if(header == GamePb6.GetActLuckyInfoRq.EXT_FIELD_NUMBER){//6504
//                            SimulaRequestFactory.GetActLuckyInfoRq(cmds[0]);
//                        }else if(header == GamePb6.GetActLuckyRewardRq.EXT_FIELD_NUMBER){//6504
//                            SimulaRequestFactory.GetActLuckyRewardRq(cmds[1]);
//                        }
//                        if (header == GamePb6.GetRedPlanInfoRq.EXT_FIELD_NUMBER) {//6200
//                            SimulaRequestFactory.GetRedPlanInfoRq(readLine);
//                        } else if(header == GamePb6.MoveRedPlanRq.EXT_FIELD_NUMBER){ //6202
//                            SimulaRequestFactory.MoveRedPlanRq(readLine);
//                        }else if(header == GamePb6.RedPlanRewardRq.EXT_FIELD_NUMBER){//6204
//                            SimulaRequestFactory.RedPlanRewardRq(readLine);
//                        }else if(header == GamePb6.RedPlanBuyFuelRq.EXT_FIELD_NUMBER){//6206
//                            SimulaRequestFactory.RedPlanBuyFuelRq(readLine);
//                        }else if(header == GamePb6.GetRedPlanBoxRq.EXT_FIELD_NUMBER){//6208
//                            SimulaRequestFactory.GetRedPlanBoxRq(readLine);
//                        }else if(header == GamePb6.GetRedPlanAreaInfoRq.EXT_FIELD_NUMBER){//6210
//                            SimulaRequestFactory.GetRedPlanAreaInfoRq(readLine);
//                        }

//                        if (header == GamePb1.DoSomeRq.EXT_FIELD_NUMBER) {//353 GM指令
//                            SimulaRequestFactory.sendGm(readLine);
//                        } else if (header == GetActMedalofhonorInfoRq.EXT_FIELD_NUMBER) {
//                            SimulaRequestFactory.sendGetActMedalofhonorInfoRq();
//                        } else if (header == OpenActMedalofhonorRq.EXT_FIELD_NUMBER) {
//                            SimulaRequestFactory.sendOpenMedalofhonorOpen(readLine);
//                        } else if (header == SearchActMedalofhonorTargetsRq.EXT_FIELD_NUMBER) {
//                            SimulaRequestFactory.sendSearchMedalofhonor(readLine);
//                        } else if (header == GetSecretWeaponInfoRq.EXT_FIELD_NUMBER) {//5151
//                            SimulaRequestFactory.sendGetSecretWeaponInfoRs();
//                        } else if (header == UnlockWeaponBarRq.EXT_FIELD_NUMBER) {//5153
//                            SimulaRequestFactory.sendUnlockWeaponBarRq(readLine);
//                        } else if (header == LockedWeaponBarRq.EXT_FIELD_NUMBER) {//5155
//                            SimulaRequestFactory.sendLockedWeaponBarRq(readLine);
//                        } else if (header == GamePb6.StudyWeaponSkillRq.EXT_FIELD_NUMBER) {//5157
//                            SimulaRequestFactory.sendStudyWeaponSkillRq(readLine);
//                        } else if (header == GamePb6.GetAttackEffectRq.EXT_FIELD_NUMBER) {//5201
//                            SimulaRequestFactory.sendGetAttackEffectRq();
//                        } else if (header == GamePb5.GetMonopolyInfoRq.EXT_FIELD_NUMBER) {//4541
//                            SimulaRequestFactory.sendGetMonopolyRq();
//                        } else if (header == GamePb5.BuyOrUseEnergyRq.EXT_FIELD_NUMBER) {//4545
//                            SimulaRequestFactory.sendBuyEnergyRq();
//                        } else if (header == GamePb5.ThrowDiceRq.EXT_FIELD_NUMBER) {//4543
//                            SimulaRequestFactory.sendThrowDiceRq(readLine);
//                        } else if (header == GamePb6.GetFightLabItemInfoRq.EXT_FIELD_NUMBER) {//6001
//                            SimulaRequestFactory.getFightLabItemInfoRq(readLine);
//                        } else if (header == GamePb6.GetFightLabInfoRq.EXT_FIELD_NUMBER) {//6003
//                            SimulaRequestFactory.getFightLabInfoRq(readLine);
//                        } else if (header == GamePb6.SetFightLabPersonCountRq.EXT_FIELD_NUMBER) {//6005
//                            SimulaRequestFactory.setFightLabPersonCountRq(readLine);
//                        } else if (header == GamePb6.UpFightLabTechUpLevelRq.EXT_FIELD_NUMBER) {//6007
//                            SimulaRequestFactory.upFightLabTechUpLevelRq(readLine);
//                        } else if (header == GamePb6.ActFightLabArchActRq.EXT_FIELD_NUMBER) {//6009
//                            SimulaRequestFactory.actFightLabArchActRq(readLine);
//                        } else if (header == GamePb6.GetFightLabResourceRq.EXT_FIELD_NUMBER) {//6011
//                            SimulaRequestFactory.getFightLabResourceRq(readLine);
//                        } else if (header == GamePb6.GetFightLabGraduateInfoRq.EXT_FIELD_NUMBER) {//6013
//                            SimulaRequestFactory.getFightLabGraduateInfoRq(readLine);
//                        } else if (header == GamePb6.UpFightLabGraduateUpRq.EXT_FIELD_NUMBER) {//6015
//                            SimulaRequestFactory.upFightLabGraduateUpRq(readLine);
//                        } else if (header == GamePb6.GetFightLabGraduateRewardRq.EXT_FIELD_NUMBER) {//6017
//                            SimulaRequestFactory.getFightLabGraduateRewardRq(readLine);
//                        } else if (header == GamePb2.AttackPosRq.EXT_FIELD_NUMBER) {//429
//                            SimulaRequestFactory.sendAttackPosRq(readLine);
//                        } else if (header == GamePb5.GetActLotteryExploreRq.EXT_FIELD_NUMBER) {//4601
//                            SimulaRequestFactory.sendActLotteryExplore();
//                        } else if (header == GamePb5.GetActRedBagInfoRq.EXT_FIELD_NUMBER) {//4611
//                            SimulaRequestFactory.sendGetActRedBagInfoRq();
//                        } else if (header == GamePb5.DrawActRedBagStageAwardRq.EXT_FIELD_NUMBER) {//4613
//                            SimulaRequestFactory.sendDrawActRedBagStageAwardRq(readLine);
//                        } else if (header == GamePb5.GetActRedBagListRq.EXT_FIELD_NUMBER) {//4615
//                            SimulaRequestFactory.sendGetActRedBagListRq();
//                        } else if (header == GamePb5.GrabRedBagRq.EXT_FIELD_NUMBER) {//4617
//                            SimulaRequestFactory.sendGrabRedBagRq(readLine);
//                        } else if (header == GamePb5.SendActRedBagRq.EXT_FIELD_NUMBER) {//4621
//                            SimulaRequestFactory.sendActRedBag(readLine);
//                        }else if (header == GamePb6.GetFightLabSpyInfoRq.EXT_FIELD_NUMBER) {//6019
//                            SimulaRequestFactory.GetFightLabSpyInfoRq();
//                        }else if (header == GamePb6.ActFightLabSpyAreaRq.EXT_FIELD_NUMBER) {//6021
//                            SimulaRequestFactory.ActFightLabSpyAreaRq();
//                        }else if (header == GamePb6.RefFightLabSpyTaskRq.EXT_FIELD_NUMBER) {//6023
//                            SimulaRequestFactory.RefFightLabSpyTaskRq();
//                        }else if (header == GamePb6.ActFightLabSpyTaskRq.EXT_FIELD_NUMBER) {//6025
//                            SimulaRequestFactory.ActFightLabSpyTaskRq();
//                        }else if (header == GamePb6.GctFightLabSpyTaskRewardRq.EXT_FIELD_NUMBER) {//6027
//                            SimulaRequestFactory.GctFightLabSpyTaskRewardRq();
//                        }
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
        }).start();
    }


}
