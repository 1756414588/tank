/**
 * @Title: ChatService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年9月21日 下午6:22:05
 * @version V1.0
 */
package com.game.service;

import com.game.chat.domain.*;
import com.game.constant.*;
import com.game.dataMgr.StaticBountyDataMgr;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.Player;
import com.game.domain.p.Lord;
import com.game.domain.p.Mail;
import com.game.domain.p.Man;
import com.game.fortressFight.domain.FortressJobAppoint;
import com.game.grpc.proto.team.CrossTeamProto;
import com.game.manager.*;
import com.game.message.handler.ClientHandler;
import com.game.pb.BasePb.Base;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.AwakenHero;
import com.game.pb.CommonPb.MedalData;
import com.game.pb.CommonPb.Report;
import com.game.pb.CommonPb.TankData;
import com.game.pb.GamePb2.*;
import com.game.server.GameServer;
import com.game.service.teaminstance.TeamInstanceService;
import com.game.service.teaminstance.TeamRpcService;
import com.game.util.*;
import io.netty.channel.ChannelHandlerContext;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.Date;
import java.util.Iterator;
import java.util.List;
import java.util.Map;

/**
 * @author ZhangJun
 * @ClassName: ChatService
 * @Description: 聊天相关
 * @date 2015年9月21日 下午6:22:05
 */
@Service
public class ChatService {
    @Autowired
    private ChatDataManager chatDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private RankDataManager rankDataManager;

    @Autowired
    private TeamInstanceService teamInstanceService;

    @Autowired
    private StaticBountyDataMgr staticBountyDataMgr;

    /**
     * 获得聊天信息
     *
     * @param handler void
     */
    public void getChat(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        GetChatRs.Builder builder = GetChatRs.newBuilder();
        List<CommonPb.Chat> list = chatDataManager.getWorldChat();
        for (CommonPb.Chat e : list) {
            builder.addChat(e);
        }

        Member member = partyDataManager.getMemberById(player.roleId);
        if (member != null) {
            int partyId = member.getPartyId();
            if (partyId != 0) {
                List<CommonPb.Chat> partyChats = chatDataManager.getPartyChat(partyId);
                if (partyChats != null) {
                    for (CommonPb.Chat e : partyChats) {
                        builder.addChat(e);
                    }
                }
            }
        }
        //组队跨服聊天记录
        if (teamInstanceService.isCrossOpen()) {
            List<CommonPb.Chat> crossChat = chatDataManager.getCrossChat();
            if (crossChat != null) {
                for (CommonPb.Chat e : crossChat) {
                    builder.addChat(e);
                }
            }
        }
        handler.sendMsgToPlayer(GetChatRs.ext, builder.build());
    }

    /**
     * Method: createManChat
     *
     * @Description: 普通聊天 @param player @param msg @return @return Chat @throws
     */
    public Chat createManChat(Player player, String msg) {
        ManChat manChat = new ManChat();
        manChat.setPlayer(player);
        manChat.setTime(TimeHelper.getCurrentSecond());
        manChat.setMsg(msg);
        return manChat;
    }

    /**
     * 创建队伍邀请消息
     *
     * @param sysId
     * @param param
     * @param teamId
     * @return Chat
     */
    public Chat createTeamInviteChat(int sysId, int teamId, String... param) {
        TeamInviteChat teamChat = new TeamInviteChat();
        teamChat.setSysId(sysId);
        teamChat.setTeamId(teamId);
        teamChat.setTime(TimeHelper.getCurrentSecond());
        teamChat.setParam(param);
        return teamChat;
    }

    /**
     * 创建叛军红包世界消息
     *
     * @param sysId
     * @param param
     * @return Chat
     */
    public Chat createRebelRedBagChat(int sysId, int uid, String... param) {
        RebelRedBagChat chat = new RebelRedBagChat();
        chat.setSysId(sysId);
        chat.setUid(uid);
        chat.setTime(TimeHelper.getCurrentSecond());
        chat.setParam(param);
        return chat;
    }

    /**
     * 创建系统消息
     *
     * @param sysId
     * @param param
     * @return Chat
     */
    public Chat createSysChat(int sysId, String... param) {
        SystemChat systemChat = new SystemChat();
        systemChat.setSysId(sysId);
        systemChat.setTime(TimeHelper.getCurrentSecond());
        systemChat.setParam(param);
        return systemChat;
    }

    /**
     * 创建系统消息
     *
     * @param chatPb
     * @return Chat
     */
    public Chat createSysChat(com.game.pb.CommonPb.Chat chatPb) {
        SystemChat systemChat = new SystemChat();
        systemChat.setSysId(chatPb.getSysId());
        systemChat.setTime(chatPb.getTime());

        if (chatPb.getParamCount() > 0) {
            String[] arr = (String[]) chatPb.getParamList().toArray(new String[chatPb.getParamCount()]);
            systemChat.setParam(arr);
        }
        return systemChat;
    }

    /**
     * 创建招募消息
     *
     * @param player
     * @param sysId
     * @param param
     * @return Chat
     */
    private Chat createRecruitChat(Player player, int sysId, String... param) {
        ManShare manShare = new ManShare();
        manShare.setPlayer(player);
        manShare.setTime(TimeHelper.getCurrentSecond());
        manShare.setParam(param);
        manShare.setSysId(sysId);
        return manShare;
    }

    /**
     * 创建分享战报
     *
     * @param player
     * @param chatId
     * @param reportKey
     * @param param
     * @return Chat
     */
    private Chat createReportShare(Player player, int chatId, int reportKey, String... param) {
        ManShare manShare = new ManShare();
        manShare.setPlayer(player);
        manShare.setTime(TimeHelper.getCurrentSecond());
        manShare.setId(chatId);
        manShare.setParam(param);
        manShare.setReport(reportKey);
        return manShare;
    }

    /**
     * 分享坦克信息
     *
     * @param player
     * @param tankData
     * @return Chat
     */
    private Chat createTankShare(Player player, TankData tankData) {
        ManShare manShare = new ManShare();
        manShare.setPlayer(player);
        manShare.setTime(TimeHelper.getCurrentSecond());
        manShare.setTankData(tankData);
        return manShare;
    }

    /**
     * 创建将领分享信息
     *
     * @param player
     * @param heroId
     * @return Chat
     */
    private Chat createHeroShare(Player player, int heroId) {
        ManShare manShare = new ManShare();
        manShare.setPlayer(player);
        manShare.setTime(TimeHelper.getCurrentSecond());
        manShare.setHeroId(heroId);
        return manShare;
    }

    /**
     * 创建勋章分享信息
     *
     * @param player
     * @param medalData
     * @return Chat
     */
    private Chat createMedalShare(Player player, MedalData medalData) {
        ManShare manShare = new ManShare();
        manShare.setPlayer(player);
        manShare.setTime(TimeHelper.getCurrentSecond());
        manShare.setMedalData(medalData);
        return manShare;
    }

    /**
     * 创建觉醒将领分享信息
     *
     * @param player
     * @param awakenHero
     * @return Chat
     */
    private Chat createAwakenHeroShare(Player player, AwakenHero awakenHero) {
        ManShare manShare = new ManShare();
        manShare.setPlayer(player);
        manShare.setTime(TimeHelper.getCurrentSecond());
        manShare.setAwakenHero(awakenHero);
        return manShare;
    }

    // public void sendSysHorn(String c) {
    // sendHornChat(createSysChat(SysChatId.SYS_HORN, c), 1);
    // }

    /**
     * Method: partyRecruit
     *
     * @Description: 发布军团招募消息 @param handler @return void @throws
     */
    public void partyRecruit(ClientHandler handler) {
        int now = TimeHelper.getCurrentSecond();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (now - player.recruitTime < TimeHelper.HALF_HOUR_S) {
            handler.sendErrorMsgToPlayer(GameError.PARTY_RECRUIT_CD);
            return;
        }

        Member member = partyDataManager.getMemberById(player.roleId);
        if (member == null || member.getPartyId() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        if (member.getJob() != PartyType.LEGATUS) {
            handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
            return;
        }

        PartyData partyData = partyDataManager.getParty(member.getPartyId());
        if (partyData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
            return;
        }

        Chat chat = null;
        if (partyData.getSlogan() != null) {
            chat = createRecruitChat(player, SysChatId.RECRUIT_5, partyData.getPartyName(), partyData.getSlogan());
        } else if (partyData.getApplyLv() > 0 && partyData.getApplyFight() == 0) {
            chat = createRecruitChat(player, SysChatId.RECRUIT_1, partyData.getPartyName());
        } else if (partyData.getApplyLv() == 0 && partyData.getApplyFight() > 0) {
            chat = createRecruitChat(player, SysChatId.RECRUIT_2, partyData.getPartyName());
        } else if (partyData.getApplyLv() == 0 && partyData.getApplyFight() == 0) {
            chat = createRecruitChat(player, SysChatId.RECRUIT_3, partyData.getPartyName());
        } else if (partyData.getApplyLv() > 0 && partyData.getApplyFight() > 0) {
            chat = createRecruitChat(player, SysChatId.RECRUIT_4, partyData.getPartyName());
        }

        sendWorldChat(chat);
        player.recruitTime = now;
        PartyRecruitRs.Builder builder = PartyRecruitRs.newBuilder();
        handler.sendMsgToPlayer(PartyRecruitRs.ext, builder.build());
    }

    /**
     * 分享挑战战力top5 Method: shareChallengeTop5 @Description: @return void @throws
     */
    public void shareChallengeFightRankTop5(Player player, Player guardPlayer, Mail mail, int result) {
        if (rankDataManager.isFightRankTop5(guardPlayer.lord.getLordId())) {
            if (result == 1) {
                sendWorldChat(createSysChat(SysChatId.Challenge_GOD_WIN, player.lord.getNick(), "" + mail.getKeyId()));
            } else if (result == 2) {
                sendWorldChat(createSysChat(SysChatId.Challenge_GOD_FAIL, player.lord.getNick(), "" + mail.getKeyId()));
            }
        }
    }

    /**
     * 分享信息协议处理
     *
     * @param req
     * @param handler void
     */
    public void shareChat(ShareReportRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int now = TimeHelper.getCurrentSecond();
        if (now - player.chatTime < 5) {
            handler.sendErrorMsgToPlayer(GameError.CHAT_CD);
            return;
        }

        int reportKey = 0;
        int channel = req.getChannel();

        Chat chat = null;
        if (req.hasReportKey()) {
            reportKey = req.getReportKey();
            Mail mail = player.getMail(reportKey);
            if (mail == null) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            Report report = mail.getReport();
            if (report == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_REPORT);
                return;
            }

            chat = createReportShare(player, mail.getMoldId(), reportKey, mail.getParam());
        } else if (req.hasTankData()) {
            CommonPb.TankData tankData = req.getTankData();
            if (!canShareTank(player, tankData.getTankId())) {
                handler.sendErrorMsgToPlayer(GameError.TANK_NOT_FOUND_IN_TANKS);
                return;
            }
            chat = createTankShare(player, tankData);
        } else if (req.hasHeroId()) {
            chat = createHeroShare(player, req.getHeroId());
        } else if (req.hasMedalData()) {
            CommonPb.MedalData medalData = req.getMedalData();
            chat = createMedalShare(player, medalData);
        } else if (req.hasAwakenHeroKeyId()) {
            com.game.domain.p.AwakenHero awakenHero = player.awakenHeros.get(req.getAwakenHeroKeyId());
            if (awakenHero == null) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
            chat = createAwakenHeroShare(player, PbHelper.createAwakenHeroPb(awakenHero));
        }

        if (channel == 1) {// 世界
            sendWorldChat(chat);
        } else {// 军团
            Member member = partyDataManager.getMemberById(player.roleId);
            if (member == null || member.getPartyId() == 0) {
                handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
                return;
            }

            sendPartyChat(chat, member.getPartyId());
        }

        player.chatTime = now;

        ShareReportRs.Builder builder = ShareReportRs.newBuilder();
        handler.sendMsgToPlayer(ShareReportRs.ext, builder.build());
    }

    /**
     * 从聊天窗点战报进去协议处理
     *
     * @param req
     * @param handler void
     */
    public void getReport(GetReportRq req, ClientHandler handler) {
        String nick = req.getName();
        int reportKey = req.getReportKey();
        Player target = playerDataManager.getPlayer(nick);
        if (target == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        GetReportRs.Builder builder = GetReportRs.newBuilder();
        Mail mail = target.getMail(reportKey);
        if (mail == null || mail.getReport() == null) {
            builder.setState(2);
        } else {
            builder.setState(1);
            builder.setReport(mail.getReport());
        }

        handler.sendMsgToPlayer(GetReportRs.ext, builder.build());
    }

    /**
     * Method: sendWorldChat
     *
     * @Description: 发送世界消息 @param chat @return void @throws
     */
    public void sendWorldChat(Chat chat) {
        CommonPb.Chat b = chatDataManager.addWorldChat(chat);
        Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();

        SynChatRq.Builder builder = SynChatRq.newBuilder();
        builder.setChat(b);
        Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());

        ChannelHandlerContext ctx;
        while (it.hasNext()) {
            ctx = it.next().ctx;
            if (ctx != null) {
                GameServer.getInstance().synMsgToPlayer(ctx, msg);
            }
        }
    }

    /**
     * 发送跨服聊天,和只发给自己的
     *
     * @param chat
     * @param player
     * @param type
     */
    public void sendWorldChat(Chat chat, Player player, int type) {
        CommonPb.Chat b = null;
        switch (type) {
            case Chat.WORLD_CHANNEL:
                b = chatDataManager.addWorldChat(chat);
                break;
            case Chat.CROSSTEAM_CHANNEL:
                b = chatDataManager.addCrossChat(chat);
                break;
        }
        SynChatRq.Builder builder = SynChatRq.newBuilder();
        builder.setChat(b);
        Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());
        if (player != null) {
            ChannelHandlerContext ctx = player.ctx;
            if (ctx != null) {
                GameServer.getInstance().synMsgToPlayer(ctx, msg);
            }
        } else {
            Map<String, Player> allOnlinePlayer = playerDataManager.getAllOnlinePlayer();
            for (Player player1 : allOnlinePlayer.values()) {
                if (player1 != null && player1.ctx != null) {
                    GameServer.getInstance().synMsgToPlayer(player1.ctx, msg);
                }
            }
        }
    }



    /*  *//**
     * 跨服发消息,只发给自己
     *
     * @param chat
     * @param player
     *//*
    public void sendCrossChatToMe(Chat chat, Player player) {
        CommonPb.Chat b = chatDataManager.addCrossChat(chat);
        SynChatRq.Builder builder = SynChatRq.newBuilder();
        builder.setChat(b);
        Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());
        ChannelHandlerContext ctx = player.ctx;
        if (ctx != null) {
            GameServer.getInstance().synMsgToPlayer(ctx, msg);
        }
    }*/

    /**
     * Method: sendHornChat
     *
     * @Description: 发送喇叭消息 @param chat @param style @return void @throws
     */
    public void sendHornChat(Chat chat, int style) {
        CommonPb.Chat b = chatDataManager.addHornChat(chat, style);
        Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();

        SynChatRq.Builder builder = SynChatRq.newBuilder();
        builder.setChat(b);
                Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());

        ChannelHandlerContext ctx;
        while (it.hasNext()) {
            ctx = it.next().ctx;
            if (ctx != null) {
                GameServer.getInstance().synMsgToPlayer(ctx, msg);
            }
        }
    }

    /**
     * 发送私聊消息
     *
     * @param chat
     * @param lordId
     * @return boolean
     */
    public boolean sendPrivateChat(Chat chat, long lordId) {
        Player player = playerDataManager.getPlayer(lordId);
        if (player != null && player.isLogin) {
            CommonPb.Chat b = chatDataManager.createPrivateChat(chat);

            SynChatRq.Builder builder = SynChatRq.newBuilder();
            builder.setChat(b);
            Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());

            GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            return true;
        } else {
            return false;
        }
    }

    /**
     * 发送军团消息
     *
     * @param chat
     * @param partyId void
     */
    public void sendPartyChat(Chat chat, int partyId) {
        CommonPb.Chat b = chatDataManager.addPartyChat(chat, partyId);
        SynChatRq.Builder builder = SynChatRq.newBuilder();
        builder.setChat(b);
        Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());

        List<Member> list = partyDataManager.getMemberList(partyId);
        Player player = null;
        for (Member member : list) {
            player = playerDataManager.getPlayer(member.getLordId());
            if (player != null && player.isLogin) {
                GameServer.getInstance().synMsgToPlayer(player.ctx, msg);
            }
        }
    }

    // public void sendGmChat(Chat chat) {
    //
    // }

    /**
     * 发送消息
     *
     * @param req
     * @param handler void
     */
    public void doChat(DoChatRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            LogUtil.error("dochat null!!!!!!!!!!!!!!!!!!!!!!!!!!!!!! " + handler.getRoleId());
            return;
        }
        int channel = req.getChannel();
        int shareType = 0;
        if (req.hasShareType()) {
            shareType = req.getShareType();
        }
        int now = TimeHelper.getCurrentSecond();
        if (now - player.chatTime < 5) {
            handler.sendErrorMsgToPlayer(GameError.CHAT_CD);
            return;
        }
        // if (shareType == 0) {
        // if( channel ==1){
        // if (player.lord.getSilence() > 0) {
        // Chat chat = createManChat(player, req.getMsgList().get(0));
        // sendWorldChat(chat, player);
        // player.chatTime = now;
        // DoChatRs.Builder builder = DoChatRs.newBuilder();
        // handler.sendMsgToPlayer(DoChatRs.ext, builder.build());
        // return;
        // }
        // }
        // }

        if (player.lord.getSilence() > 0) {
            int currentTime = Integer.parseInt(String.valueOf(new Date().getTime() / 1000));
            if (player.lord.getSilence() == 1) {
                handler.sendErrorMsgToPlayer(GameError.CHAT_SILENCE);
                return;
            } else if (player.lord.getSilence() > currentTime) {
                LogUtil.silence(player.lord.getLordId() + " is Silence role time: " + (player.lord.getSilence() - currentTime) + "("
                        + player.lord.getSilence() + "-" + currentTime + ")");
                handler.sendErrorMsgToPlayer(GameError.CHAT_SILENCE);
                return;
            }
        }

        List<String> msg = req.getMsgList();

        if (shareType == 0) {// 聊天
            if (msg.isEmpty()) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            String content = msg.get(0);
            if (content.length() > 40) {
                handler.sendErrorMsgToPlayer(GameError.MAX_CHAT_LENTH);
                return;
            }

            content = EmojiHelper.filterEmoji(content);

            if (ChatHelper.isCorrect(content)) {
                content = "*******";
            }
            Chat chat = createManChat(player, content);
            if (channel == Chat.WORLD_CHANNEL) {// 世界频道
                boolean flag = checkChat(player, content, chat, channel, now, handler, "wordChat");
                if (flag) {
                    LogUtil.chat("wordChat|" + player.account.getServerId() + "|" + player.lord.getNick() + "|" + player.roleId + "|" + content);
                    sendWorldChat(chat);
                }
            } else if (channel == Chat.PARTY_CHANNEL) {// 军团
                Member member = partyDataManager.getMemberById(player.roleId);
                if (member == null || member.getPartyId() == 0) {
                    handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
                    return;
                }
                LogUtil.chat("partyChat|" + player.account.getServerId() + "|" + player.lord.getNick() + "|" + player.roleId + "|" + content);
                sendPartyChat(chat, member.getPartyId());
            } else if (channel == Chat.GM_CHANNEL) {// 客服

            } else if (channel == Chat.PRIVATE_CHANNEL) {// 私聊
                long target = 0;
                if (!req.hasTarget()) {
                    handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                    return;
                }
                target = req.getTarget();
                if (!sendPrivateChat(chat, target)) {
                    handler.sendErrorMsgToPlayer(GameError.TARGET_NOT_ONLINE);
                    return;
                }
                LogUtil.chat("privateChat|" + player.account.getServerId() + "|" + player.lord.getNick() + "|" + player.roleId + "|" + content);
            } else if (channel == Chat.CROSSTEAM_CHANNEL) {
                if (teamInstanceService.isCrossOpen()) {
                    if (staticBountyDataMgr.getBountyConfig().getLv() > player.lord.getLevel()) {
                        handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
                        return;
                    }
                    boolean flag = checkChat(player, content, chat, channel, now, handler, "crossWordChat");
                    if (flag) {
                        CrossTeamProto.RpcCodeTeamResponse response = TeamRpcService.chat(handler.getRoleId(), content, player);
                        if (response == null) {
                            handler.sendErrorMsgToPlayer(GameError.CROSS_CHAT_ERR);
                            return;
                        }
                        if (response.getCode() == GameError.OK.getCode()) {
                            player.chatTime = now;
                            DoChatRs.Builder builder = DoChatRs.newBuilder();
                            handler.sendMsgToPlayer(DoChatRs.ext, builder.build());
                            LogUtil.chat("crossWordChat|" + player.account.getServerId() + "|" + player.lord.getNick() + "|" + player.roleId + "|" + content);
                            return;
                        }
                    }
                }
                handler.sendErrorMsgToPlayer(GameError.CROSS_CHAT_ERR);
                return;
            }
        }
        player.chatTime = now;
        DoChatRs.Builder builder = DoChatRs.newBuilder();
        handler.sendMsgToPlayer(DoChatRs.ext, builder.build());
        return;
    }

    public boolean checkChat(Player player, String content, Chat chat, int channel, int now, ClientHandler handler, String logName) {
        boolean compare = false;
        boolean send = true;
        player.lastChats.offer(content);
        if (content != null && content.length() >= Constant.AD_MIN_COUNT) {
            while (player.lastChats.size() > Constant.AD_COMPARE_COUNT) {
                player.lastChats.remove();
            }
            compare = true;
        }
        if (compare && player.lastChats.size() >= Constant.AD_COMPARE_COUNT && ChatHelper.isSamely(player.lastChats, Constant.AD_RATE) >= Constant.AD_COMPARE_COUNT) {

            LogUtil.chat(logName + "|" + player.account.getServerId() + "|" + player.lord.getNick() + "|" + player.roleId + "|" + content);
            sendWorldChat(chat, player, channel);//只发给自己
            player.chatTime = now;
            DoChatRs.Builder builder = DoChatRs.newBuilder();
            handler.sendMsgToPlayer(DoChatRs.ext, builder.build());
            send = false;
        }
        return send;
    }


    /**
     * Method: sendWorldChat
     *
     * @Description: 发送屏蔽某玩家的消息 @param chat @return void @throws
     */
    public void sendScreen(Chat chat, Player player) {
        CommonPb.Chat b = chatDataManager.addWorldChat(chat);
        Iterator<Player> it = playerDataManager.getAllOnlinePlayer().values().iterator();
        SynChatRq.Builder builder = SynChatRq.newBuilder();
        builder.setScreenPlayerName(player.lord.getNick());
        builder.setChat(b);
        Base.Builder msg = PbHelper.createSynBase(SynChatRq.EXT_FIELD_NUMBER, SynChatRq.ext, builder.build());
        ChannelHandlerContext ctx;
        while (it.hasNext()) {
            Player next = it.next();
            ctx = next.ctx;
            if (ctx != null) {
                if (player.lord.getLordId() != next.lord.getLordId()) {
                    GameServer.getInstance().synMsgToPlayer(ctx, msg);
                }
            }
        }
    }

    /**
     * 搜索玩家
     *
     * @param name
     * @param handler void
     */
    public void searchOl(String name, ClientHandler handler) {
        SearchOlRs.Builder builder = SearchOlRs.newBuilder();
        Player target = playerDataManager.getOnlinePlayer(name);
        if (target != null) {
            Lord lord = target.lord;
            Man man = new Man(lord.getLordId(), lord.getSex(), lord.getNick(), lord.getPortrait(), lord.getLevel());

            if (TimeHelper.isFortresssOpen()) {
                FortressJobAppoint f = GameServer.ac.getBean(WarDataManager.class).getFortressJobAppointMapByLordId()
                        .get(handler.getRoleId());

                if (f != null && f.getEndTime() >= TimeHelper.getCurrentSecond()) {
                    man.setJobId(f.getJobId());
                }
            }

            man.setRanks(lord.getRanks());
            man.setFight(lord.getFight());
            man.setPros(lord.getPros());
            man.setProsMax(lord.getProsMax());
            man.setPartyName(partyDataManager.getPartyNameByLordId(lord.getLordId()));
            builder.setMan(PbHelper.createManPb(man));
        }

        handler.sendMsgToPlayer(SearchOlRs.ext, builder.build());
    }

    private boolean canShareTank(Player player, int tankId) {
        return player.tanks.containsKey(tankId);
    }

}
