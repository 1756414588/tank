package com.game.util;

import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.sort.ActRedBag;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.pb.BasePb;
import com.game.pb.CommonPb.Award;
import com.game.pb.GamePb1.SyncMailRq;
import com.game.pb.GamePb5;
import com.game.pb.GamePb6;
import com.game.server.GameServer;
import io.netty.channel.ChannelHandlerContext;

import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StcHelper
 * @Description: 服务器主推给客户端的消息 Server 2 Client
 * @date 2017/4/27 14:06
 */
public final class StcHelper {

    /**
     * 广播发红包信息
     * @param player
     * @param arb
     */
    public static void synSendActRedBag(Player player, ActRedBag arb){
        GamePb6.SynSendActRedBagRq.Builder builder = GamePb6.SynSendActRedBagRq.newBuilder();
        builder.setChat(PbHelper.createRedBagChat(player, arb));
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynSendActRedBagRq.EXT_FIELD_NUMBER, GamePb6.SynSendActRedBagRq.ext, builder.build());
        if (arb.getPartyId()>0){
            syncMessage2Party(arb.getPartyId(), msg);
        }else{
            syncMessage2World(msg);
        }
    }

    /**
     * 同步扫矿外挂检测验证码
     *
     * @param player
     */
    public static void synPlugInScoutMineChecker(Player player, String validCode) {
        if (player != null && player.isLogin) {
            GamePb6.SynPlugInScoutMineRq.Builder builder = GamePb6.SynPlugInScoutMineRq.newBuilder();
            builder.setValidCode(validCode);
            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynPlugInScoutMineRq.EXT_FIELD_NUMBER, GamePb6.SynPlugInScoutMineRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
        }
    }

    /**
     * 通知军团玩家飞艇队伍发生变化
     * @param airshipId
     */
    public static void syncAirshipTeamChange2Party(int partyId, int airshipId, int status){
        GamePb5.SynAirshipTeamRq.Builder builder = GamePb5.SynAirshipTeamRq.newBuilder();
        builder.setAirshipId(airshipId);
        builder.setStatus(status);
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb5.SynAirshipTeamRq.EXT_FIELD_NUMBER, GamePb5.SynAirshipTeamRq.ext, builder.build());
        syncMessage2Party(partyId, msg);
    }

    /**
     * 向世界广播飞艇发生了变化
     *
     * @param airshipId
     */
    public static void syncAirshipChange2World(int airshipId) {
        GamePb5.SynAirshipChangeRq.Builder builder = GamePb5.SynAirshipChangeRq.newBuilder();
        builder.setAirshipId(airshipId);
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb5.SynAirshipChangeRq.EXT_FIELD_NUMBER, GamePb5.SynAirshipChangeRq.ext, builder.build());
        syncMessage2World(msg);
    }

    /**
     * 向军团玩家广播飞艇发生了变化
     *
     * @param airshipId
     */
    public static void syncAirshipChange2Party(int airshipId, int partyId) {
        GamePb5.SynAirshipChangeRq.Builder builder = GamePb5.SynAirshipChangeRq.newBuilder();
        builder.setAirshipId(airshipId);
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb5.SynAirshipChangeRq.EXT_FIELD_NUMBER, GamePb5.SynAirshipChangeRq.ext, builder.build());
        syncMessage2Party(partyId, msg);
    }

    /**
     * 通知玩家飞艇部队发生变化,客户端重新同步队伍信息<br>
     * 此消息主要用在通知玩家自己,让玩家自己更新部队信息
     *
     * @param target
     * @param state
     */
    public static void syncAirshipTeamArmy2Player(Player target, int state) {
        if (target != null && target.isLogin) {
            GamePb5.SynAirshipTeamArmyRq.Builder builder = GamePb5.SynAirshipTeamArmyRq.newBuilder();
            builder.setState(state);
            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb5.SynAirshipTeamArmyRq.EXT_FIELD_NUMBER, GamePb5.SynAirshipTeamArmyRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }

    /**
     * 同步当前解锁的最高技工ID
     *
     * @param player
     */
    public static void syncUnlockTechMax(Player player) {
        if (player != null && player.isLogin) {
            GamePb5.SynUnlockTechnicalRq.Builder builder = GamePb5.SynUnlockTechnicalRq.newBuilder();
            builder.setUnlockTechMax(player.leqInfo.getUnlock_tech_max());
            builder.setFree(player.leqInfo.isFree());
            BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb5.SynUnlockTechnicalRq.EXT_FIELD_NUMBER, GamePb5.SynUnlockTechnicalRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
        }
    }

    /**
     * 向工会频道中在线玩家广播消息
     *
     * @param partyId
     * @param msg
     */
    private static void syncMessage2Party(int partyId, BasePb.Base.Builder msg) {
        List<Member> memberList = GameServer.ac.getBean(PartyDataManager.class).getMemberList(partyId);
        if (memberList != null && !memberList.isEmpty()) {
            PlayerDataManager playerDataManager = GameServer.ac.getBean(PlayerDataManager.class);
            for (Member member : memberList) {
                Player player = playerDataManager.getPlayer(member.getLordId());
                if (player != null && player.ctx != null) {
                    GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
                }
            }
        }
    }

    /**
     * 向世界广播消息
     *
     * @param msg
     */
    private static void syncMessage2World(BasePb.Base.Builder msg) {
        Map<String, Player> onlinePlayers = GameServer.ac.getBean(PlayerDataManager.class).getAllOnlinePlayer();
        for (Map.Entry<String, Player> entry : onlinePlayers.entrySet()) {
            ChannelHandlerContext ctx = entry.getValue().ctx;
            if (ctx != null) {
                GameServer.getInstance().synMsgToPlayer(ctx, msg);
            }
        }

    }
    
    /**
     * 通知玩家邮件删除，客户端同步更新邮件
     *
     * @param target
     */
    public static void syncMail2Player(Player target, List<Award> list) {
        if (target != null && target.isLogin) {
        	SyncMailRq.Builder builder = SyncMailRq.newBuilder();
        	if(list != null ){
                builder.addAllAward(list);
            }
        	BasePb.Base.Builder msg = PbHelper.createSynBase(SyncMailRq.EXT_FIELD_NUMBER, SyncMailRq.ext, builder.build());
            GameServer.getInstance().synMsgToPlayer(target.ctx, msg);
        }
    }
    
    /**
     * 通知玩家帐号在别处登录
     * @param ctx
     */
    public static void synLoginElseWhere(ChannelHandlerContext ctx) {
        GamePb6.SynLoginElseWhereRq.Builder builder = GamePb6.SynLoginElseWhereRq.newBuilder();
        BasePb.Base.Builder msg = PbHelper.createSynBase(GamePb6.SynLoginElseWhereRq.EXT_FIELD_NUMBER, GamePb6.SynLoginElseWhereRq.ext, builder.build());
        GameServer.getInstance().synMsgToPlayer(ctx, msg);
        
        //1秒后关闭连接
        //GameServer.getInstance().mainLogicServer.addTimerEvent(new CloseConnectTimer(ctx), DealType.MAIN);

        GameServer.getInstance().mainLogicServer.addDelayTask(ctx);
    }
}
