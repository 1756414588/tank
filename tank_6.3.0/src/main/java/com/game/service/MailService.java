package com.game.service;

import com.alibaba.fastjson.JSON;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.lordequip.LordEquip;
import com.game.domain.s.StaticHero;
import com.game.domain.s.StaticLordEquip;
import com.game.domain.s.StaticMail;
import com.game.domain.s.StaticSystem;
import com.game.manager.GlobalDataManager;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.GamePb1;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb2.GetMailByIdRq;
import com.game.pb.GamePb2.GetMailByIdRs;
import com.game.pb.GamePb2.GetMailListRq;
import com.game.pb.GamePb2.GetMailListRs;
import com.game.util.*;
import org.apache.commons.lang3.StringUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ChenKui
 * @version 创建时间：2015-9-4 下午3:02:55
 * @declare 邮件
 */
@Service
public class MailService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private GlobalDataManager globalDataManager;

    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private StaticMailDataMgr staticMailDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    /**
     * 处理邮件列表协议
     *
     * @param req
     * @param handler void
     */
    public void getMailListRq(GetMailListRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetMailListRs.Builder builder = GetMailListRs.newBuilder();
        if (req.hasType()) {
            int type = req.getType();
            if (type == MailType.ARENA_MAIL) {
                Iterator<Mail> it = player.getMails().values().iterator();
                while (it.hasNext()) {
                    Mail mail = it.next();
                    if (mail.getType() == type) {
                        builder.addMailShow(PbHelper.createMailShowPb(mail));
                    }
                }
            } else if (type == MailType.ARENA_GLOBAL_MAIL) {
                Iterator<Mail> it = globalDataManager.gameGlobal.getMails().iterator();
                while (it.hasNext()) {
                    builder.addMailShow(PbHelper.createMailShowPb(it.next()));
                }
            }
        } else {
            Iterator<Mail> it = player.getMails().values().iterator();
            while (it.hasNext()) {
                Mail mail = it.next();
                if (mail.getType() != MailType.ARENA_MAIL && mail.getType() != MailType.ARENA_GLOBAL_MAIL) {
                    builder.addMailShow(PbHelper.createMailShowPb(mail));
                }
            }
        }

        handler.sendMsgToPlayer(GetMailListRs.ext, builder.build());
    }

    /**
     * 处理查看某邮件协议
     *
     * @param req
     * @param handler void
     */
    public void getMailById(GetMailByIdRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetMailByIdRs.Builder builder = GetMailByIdRs.newBuilder();

        Mail mail = null;
        int type = 0;
        if (req.hasType()) {
            type = req.getType();
        }

        if (type == MailType.ARENA_GLOBAL_MAIL) {
            Iterator<Mail> it = globalDataManager.gameGlobal.getMails().iterator();
            Mail e;
            while (it.hasNext()) {
                e = it.next();
                if (e.getKeyId() == keyId) {
                    mail = e;
                    break;
                }
            }
        } else {
            mail = player.getMail(keyId);
        }

        if (mail == null) {
            handler.sendErrorMsgToPlayer(GameError.MAIL_NOT_EXIST);
            return;
        }

        int state = mail.getState();
        if (state == MailType.STATE_UNREAD) {
            player.updMailState(mail, MailType.STATE_READ);
        }

        if (state == MailType.STATE_UNREAD_ITEM) {
            player.updMailState(mail, MailType.STATE_READ_ITEM);
        }
        // if (mailtype == MailType.NORMAL_MAIL) {
        // String sendNane = mail.getSendName();
        // if (sendNane != null && !sendNane.equals("")) {
        // Player send = playerDataManager.getPlayer(sendNane);
        // if (send != null && send.lord != null) {
        // mail.setLv(send.lord.getLevel());
        // mail.setVipLv(send.lord.getVip());
        // }
        // }
        // }

        CommonPb.Mail pbMail = PbHelper.createMailPb(mail);

        if (StringUtils.isNotEmpty(mail.getSendName())) {
            Player fPlayer = playerDataManager.getPlayer(mail.getSendName());
            if (fPlayer !=  null) {
                boolean isFriend = playerDataManager.checkFriend(player, fPlayer.roleId);
                builder.setFriendState(isFriend ? 1 : 0);
            }
        }

        builder.setMail(pbMail);

        handler.sendMsgToPlayer(GetMailByIdRs.ext, builder.build());
    }

    // public void getMailRq(ClientHandler handler) {
    // Player player = playerDataManager.getPlayer(handler.getRoleId());
    // GetMailRs.Builder builder = GetMailRs.newBuilder();
    // Iterator<Mail> it = player.mails.values().iterator();
    // while (it.hasNext()) {
    // builder.addMail(PbHelper.createMailPb(it.next()));
    // }
    // handler.sendMsgToPlayer(GetMailRs.ext, builder.build());
    // }

    /**
     * 发送邮件
     *
     * @param req
     * @param handler void
     */
    public void sendMailRq(SendMailRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null || player.lord == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        if (lord.getLevel() < 15) {
            handler.sendErrorMsgToPlayer(GameError.NEED_LV_15);
            return;
        }
        CommonPb.Mail mailp = req.getMail();
        int type = req.getType();
        String title = mailp.getTitle();
        if (title != null) {
            title = EmojiHelper.filterEmoji(title);
        }
        String content = mailp.getContont();
        if (content != null) {
            content = EmojiHelper.filterEmoji(content);
        }
        if (title.length() > 30) {
            title = title.substring(0, 30);
        }
        if (content.length() > 400) {
            content = content.substring(0, 400);
        }
        SendMailRs.Builder builder = SendMailRs.newBuilder();
        String sendName = lord.getNick();
        if (type == 0) {
            if (mailp.getToNameList().size() == 0) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }
            Mail myMail = addMail(player, MailType.SEND_MAIL, MailType.STATE_UNREAD, title, content, sendName);
            myMail.setToName(mailp.getToNameList());
            for (String nick : mailp.getToNameList()) {

                Player fPlayer = playerDataManager.getPlayer(nick);
                Mail mail = addMail(fPlayer, MailType.NORMAL_MAIL, MailType.STATE_UNREAD, title, content, sendName);
                if (mail != null) {
                    List<String> toName = new ArrayList<String>();
                    toName.add(fPlayer.lord.getNick());
                    mail.setToName(toName);
                    mail.setLv(player.lord.getLevel());
                    mail.setVipLv(player.lord.getVip());
                    playerDataManager.synMailToPlayer(fPlayer, mail);
                }

            }
            builder.setMail(PbHelper.createMailPb(myMail));
        } else {
            Member member = partyDataManager.getMemberById(handler.getRoleId());
            if (member == null || member.getJob() != PartyType.LEGATUS) {
                handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
                return;
            }
            int partyId = member.getPartyId();
            List<Member> memberList = partyDataManager.getMemberList(partyId);
            if (memberList == null || memberList.size() == 0) {
                handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
                return;
            }

            Iterator<Member> it = memberList.iterator();
            while (it.hasNext()) {
                Member next = it.next();
                long memberId = next.getLordId();
                Player playerMember = playerDataManager.getPlayer(memberId);
                if (playerMember == null) {
                    continue;
                }
                Mail partyMail = addMail(playerMember, MailType.NORMAL_MAIL, MailType.STATE_UNREAD, title, content, sendName);
                List<String> toName = new ArrayList<String>();
                toName.add(playerMember.lord.getNick());
                partyMail.setToName(toName);
                partyMail.setVipLv(player.lord.getVip());
                partyMail.setLv(player.lord.getLevel());

                playerDataManager.synMailToPlayer(playerMember, partyMail);
            }

            // playerDataManager.sendAttachMail(player, awards, moldId, now,
            // param)

            Mail myMail = addMail(player, MailType.SEND_MAIL, MailType.STATE_UNREAD, title, content, sendName);
            builder.setMail(PbHelper.createMailPb(myMail));
        }
        handler.sendMsgToPlayer(SendMailRs.ext, builder.build());
    }

    /**
     * 收取一个附件
     *
     * @return
     */
    private CommonPb.Award getReward(CommonPb.Award award, int type, int id, long count, Player player) {
        switch (type) {
            case AwardType.EQUIP:
                if (award.getParamCount() >= 1) {
                    int equipLv = award.getParam(0);// 等级
                    int starLv = 0;
                    if (award.getParamList().size() >= 2) {
                        starLv = award.getParam(1);// 星级
                    }
                    if (starLv > Constant.EQUIP_STAR_LV) {
                        starLv = Constant.EQUIP_STAR_LV;
                    }
                    Equip equip = playerDataManager.addEquip(player, id, equipLv, 0, AwardFrom.MAIL_ATTACH);
                    int itemKeyId = equip.getKeyId();
                    equip.setStarlv(starLv);
                    return PbHelper.createAwardPbWithParam(type, id, count, itemKeyId, equipLv, equip.getStarlv());
                }
                break;
            case AwardType.PART:
                if (award.getParamCount() == 2) {
                    int partStrengthLv = award.getParam(0);// 强化等级
                    int partRefitLv = award.getParam(1);// 改造等级

                    int itemKeyId = playerDataManager.addPart(player, id, 0, partStrengthLv, partRefitLv, AwardFrom.MAIL_ATTACH).getKeyId();
                    return PbHelper.createAwardPbWithParam(type, id, count, itemKeyId, partStrengthLv, partRefitLv);
                }
                break;
            case AwardType.MEDAL:
                if (award.getParamCount() == 2) {
                    int strengthLv = award.getParam(0);// 强化等级
                    int refitLv = award.getParam(1);// 改造等级

                    int itemKeyId = playerDataManager.addMedal(player, id, 0, strengthLv, refitLv, AwardFrom.MAIL_ATTACH).getKeyId();
                    return PbHelper.createAwardPbWithParam(type, id, count, itemKeyId, strengthLv, refitLv);
                }
                break;
            case AwardType.AWARK_HERO:// 觉醒将领
                // 如果有技能参数则设置技能
                if (award.getParamCount() == 5) {

                    int heroKeyId = playerDataManager.addAwakenHero(player, id, AwardFrom.MAIL_ATTACH).getKeyId();

                    List<Integer> list = new ArrayList<>(5);// 觉醒技能

                    AwakenHero hero = player.awakenHeros.get(heroKeyId);
                    int heroId;
                    StaticHero newHero = staticHeroDataMgr.getStaticHero(id);
                    heroId = newHero.getAwakenHeroId();
                    if (heroId == 0) {
                        heroId = id;
                    }

                    // 设置技能
                    for (int i = 0; i < 5; i++) {
                        list.add(award.getParam(i));
                    }

                    Map<Integer, Integer> skillMap = hero.getSkillLv();
                    List<Integer> skillArr = staticHeroDataMgr.getStaticHero(heroId).getAwakenSkillArr();
                    for (int i = 0; i < 5; i++) {
                        skillMap.put(skillArr.get(i), list.get(i));
                    }

                    // 已经觉醒的将领发有觉醒将领头像的道具
                    if (list.get(0) == 4) {
                        playerDataManager.sendAwakenHeroIconMail(heroId, newHero.getHeroName(), player);
                    }

                    return PbHelper.createAwardPbWithParamList(type, id, count, heroKeyId, list);
                }
                break;
            case AwardType.LORD_EQUIP:// 军备
                int paramCount = award.getParamCount();
                if (paramCount > 0) {
                    int leqId = playerDataManager.addLordEquip(player, id, AwardFrom.MAIL_ATTACH).getKeyId();
                    // 设置军备技能
                    List<Integer> list = new ArrayList<>(5);// 技能
                    LordEquip leq = player.leqInfo.getStoreLordEquips().get(leqId);
                    List<List<Integer>> skillList = leq.getLordEquipSkillList();
                    StaticLordEquip staticLordEquip = staticEquipDataMgr.getStaticLordEquip(leq.getEquipId());
                    int normalBox = staticLordEquip.getNormalBox();
                    int maxSkillLevel = staticLordEquip.getMaxSkillLevel();
                    int superBox = staticLordEquip.getSuperBox();
                    int maxLvNum = 0; // 最大等级技能数目（判断是否显示锁定技能格子）
                    for (int i = 0; i < paramCount; i++) {
                        // 超过默认技能格子，判断是否有超级洗练格子并且都满级
                        if (i == normalBox) {
                            if (superBox == 0) {
                                break;
                            }
                            if (maxLvNum < normalBox) {
                                break;
                            }
                        }

                        int skillId = award.getParam(i);
                        int lv = skillId % 100;
                        if (lv < 1 || lv > maxSkillLevel)
                            lv = 1;
                        if (lv == maxSkillLevel)
                            maxLvNum++;
                        List<Integer> leSkill = new ArrayList<>(2);
                        leSkill.add(skillId);
                        leSkill.add(lv);
                        skillList.add(leSkill);
                        list.add(skillId);
                    }
                    return PbHelper.createAwardPbWithParamList(type, id, count, leqId, list);
                }
                break;

            case AwardType.TACTICS:
                int itemKeyId = playerDataManager.addAward(player, type, id, count, AwardFrom.MAIL_ATTACH);
                Tactics tactics = player.tacticsInfo.getTacticsMap().get(itemKeyId);
                return PbHelper.createAwardPbWithParam(type, id, count, itemKeyId, tactics.getLv(), tactics.getExp());
        }

        if (type != AwardType.RED_PACKET) {
            int itemKeyId = playerDataManager.addAward(player, type, id, count, AwardFrom.MAIL_ATTACH);
            // 通过邮件发放的经验奖励，返回给客户端的经验值是未经加成计算的，所以特别情况下，会出现服务端该角色已升级，但客户端未升级现象
            return PbHelper.createAwardPb(type, id, count, itemKeyId);
        }
        int gold = playerDataManager.giveRedPacketGold(player, id, (int) count);
        return PbHelper.createAwardPb(AwardType.GOLD, 0, gold);
    }

    /**
     * 领取邮件附件
     *
     * @param req
     * @param handler void
     */
    public void rewardMailRq(RewardMailRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        RewardMailRs.Builder builder = RewardMailRs.newBuilder();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Mail mail = player.getMail(keyId);
        if (mail == null) {
            handler.sendErrorMsgToPlayer(GameError.MAIL_NOT_EXIST);
            return;
        }

        if (mail.getState() != MailType.STATE_READ_ITEM) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        player.updMailState(mail, MailType.STATE_NO_ITEM);

        List<CommonPb.Award> awards = mail.getAward();
        if (awards != null) {
            for (CommonPb.Award e : awards) {
                int type = e.getType();
                int id = e.getId();
                long count = e.getCount();

                CommonPb.Award pbAward = getReward(e, type, id, count, player);
                builder.addAward(pbAward);
            }
        }

        LogHelper.logGetAttachMail(player.lord, mail.getMoldId(), mail.getKeyId());

        handler.sendMsgToPlayer(RewardMailRs.ext, builder.build());
    }

    /**
     * 一键收取所有邮件附件
     *
     * @param req
     * @param handler
     */
    public void rewardAllMailRq(RewardAllMailRq req, ClientHandler handler) {
        // 功能开关
        if (!staticFunctionPlanDataMgr.isOptimizeMailOpen())
            return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Iterator<Entry<Integer, Mail>> it = player.getMails().entrySet().iterator();
        RewardAllMailRs.Builder builder = RewardAllMailRs.newBuilder();
        int reqType = req.getType();

        List<CommonPb.Award> allAwards = new LinkedList<>();

        while (it.hasNext()) {
            Mail mail = it.next().getValue();
            if (mail == null) {
                continue;
            }

            if (mail.getType() != reqType) {
                continue;
            }

            if (mail.getState() != MailType.STATE_READ_ITEM && mail.getState() != MailType.STATE_UNREAD_ITEM) {
                continue;
            }

            player.updMailState(mail, MailType.STATE_NO_ITEM);

            // 附件先保存在列表，因为收取附件的时候有可能会发送邮件
            List<Award> award = mail.getAward();


            if (award != null) {
                allAwards.addAll(award);
            } else {
                LogUtil.error("rewardAllMailRq error" + JSON.toJSONString(mail));
            }


            LogHelper.logGetAttachMail(player.lord, mail.getMoldId(), mail.getKeyId());
        }

        // 领取附件
        if (allAwards.size() > 0) {
            for (CommonPb.Award e : allAwards) {
                int type = e.getType();
                int id = e.getId();
                long count = e.getCount();

                CommonPb.Award pbAward = getReward(e, type, id, count, player);
                builder.addAward(pbAward);
            }
        }

        handler.sendMsgToPlayer(RewardAllMailRs.ext, builder.build());
    }


    /**
     * @param player
     * @param type     1玩家邮件2自己发送邮件
     * @param state    1未读2已读3未读含附件4已读含附件5已读已领附件
     * @param title    标题
     * @param content  内容
     * @param sendName 发送者昵称
     * @return
     */
    private Mail addMail(Player player, int type, int state, String title, String content, String sendName) {
        if (player == null) {
            return null;
        }
        Mail mail = new Mail(player.maxKey(), type, state, TimeHelper.getCurrentSecond(), title, content, sendName);
        // 邮件超过500封删掉最老邮件
        Iterator<Mail> it = player.getMails().values().iterator();
        int count = 0;
        Mail toDelMail = null;
        while (it.hasNext()) {
            Mail next = it.next();

            if (type == 3 || type == 11) {
                if ((next.getType() == 3 || next.getType() == 11) && next.getCollections() != 1) {
                    count++;
                    if (toDelMail == null) {
                        toDelMail = next;
                    } else {
                        if (toDelMail.getTime() > next.getTime()) {
                            toDelMail = next;
                        }
                    }
                }
            } else {
                if (next.getType() == type && next.getCollections() != 1) {
                    count++;
                    if (toDelMail == null) {
                        toDelMail = next;
                    } else {
                        if (toDelMail.getTime() > next.getTime()) {
                            toDelMail = next;
                        }
                    }
                }
            }


        }

        // 邮箱超过设置上限，则删除最老邮件，如果邮件有附件，则帮玩家领取
        if (isLimit(type, count)) {
            player.delMail(toDelMail);
            if (toDelMail.getAward() != null && toDelMail.getAward().size() > 0) {
                // 领取附件
                getDelRewardMail(player, toDelMail);
                LogLordHelper.autoDelMail(AwardFrom.AUTO_DEL_MAIL, player, toDelMail);
            }
        }

        // if (type == MailType.NORMAL_MAIL && count >
        // MailType.MAIL_COUNT_MAX_1) {
        // player.mails.remove(toDelMail.getKeyId());
        // if (toDelMail.getAward() != null && toDelMail.getAward().size() > 0)
        // {
        // LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord,
        // toDelMail);
        // }
        // }
        // if (type == MailType.SEND_MAIL && count > 20) {
        // player.mails.remove(toDelMail.getKeyId());
        // if (toDelMail.getAward() != null && toDelMail.getAward().size() > 0)
        // {
        // LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord,
        // toDelMail);
        // }
        // }
        player.addNewMail(mail);
        return mail;
    }

    /**
     * 是否超过邮箱上限
     *
     * @param type  邮箱类型
     * @param count 邮件数量
     * @return
     */
    private boolean isLimit(int type, int count) {
        switch (type) {
            case MailType.NORMAL_MAIL:
                return count > MailType.MAIL_COUNT_MAX_1;
            case MailType.SEND_MAIL:
                return count > MailType.MAIL_COUNT_MAX_2;
            case MailType.REPORT_MAIL:
                return count > MailType.MAIL_COUNT_MAX_3;
            case MailType.SYSTEM_MAIL:
                return count > MailType.MAIL_COUNT_MAX_4;
            case 11:
                return count > MailType.MAIL_COUNT_MAX_3;
        }
        return false;
    }

    /**
     * 删除过期邮件
     */
    public void delExpiredMail() {
        StaticSystem sSys = staticIniDataMgr.getSystemConstantById(44);
        // 在此时间之前的发送邮件都删除
        int time = TimeHelper.getCurrentSecond() - Integer.parseInt(sSys.getValue()) * TimeHelper.DAY_S;
        Map<Long, Player> players = playerDataManager.getPlayers();
        Iterator<Player> playersIt = players.values().iterator();
        Player player;
        Iterator<Mail> mailIt;
        Mail mail;

        while (playersIt.hasNext()) {
            List<Award> returnList = new ArrayList<>();
            boolean isDelMail = false;// 是否有邮件被删除
            player = playersIt.next();
            mailIt = player.getMails().values().iterator();
            while (mailIt.hasNext()) {
                mail = mailIt.next();
                if (mail.getTime() <= time) {
                    if (mail.getCollections() == 1) {
                        continue;
                    }

                    player.delMail(mailIt, mail);
                    isDelMail = true;
                    LogUtil.common(String.format("lordId :%d, remove mail by system timer, mail id :%d, type :%d", player.roleId,
                            mail.getKeyId(), mail.getType()));

                    List<Award> list = getDelRewardMail(player, mail);
                    if (list != null && list.size() > 0) {
                        returnList.addAll(list);
                        LogLordHelper.autoDelMail(AwardFrom.AUTO_DEL_MAIL, player, mail);
                    }
                }
            }
            // 如果有邮件删除，则通知客户端同步邮件
            if (isDelMail) {
                // 如果自动领取了附件，则发邮件通知玩家
                if (returnList.size() > 0) {
                    StaticMail staticMail = staticMailDataMgr.getStaticMail(MailType.MOLD_MAIL_EXPIRED);
                    Mail sendMail = new Mail(player.maxKey(), staticMail.getType(), staticMail.getMoldId(), MailType.STATE_UNREAD,
                            TimeHelper.getCurrentSecond());
                    player.addNewMail(sendMail);
                }

                StcHelper.syncMail2Player(player, returnList);
            }
        }
    }

    /**
     * 自动删除邮件之前帮用户领取有附件的邮件
     */
    public List<Award> getDelRewardMail(Player player, Mail mail) {
        if (mail == null) {
            return null;
        }

        List<Award> awards = mail.getAward();

        if (awards != null && awards.size() > 0) {
            // 附件已取
            if (mail.getState() == MailType.STATE_NO_ITEM) {
                return null;
            }
            player.updMailState(mail, MailType.STATE_NO_ITEM);
            List<Award> returnAwards = new ArrayList<>();
            for (CommonPb.Award e : awards) {
                int type = e.getType();
                int id = e.getId();
                long count = e.getCount();

                CommonPb.Award pbAward = getReward(e, type, id, count, player);
                returnAwards.add(pbAward);
            }
            LogHelper.logGetAttachMail(player.lord, mail.getMoldId(), mail.getKeyId());
            return returnAwards;
        }

        return null;
    }

    public void collectionsMailRq(GamePb1.CollectionsMailRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        int keyId = req.getKeyId();
        Mail mail = null;
        Iterator<Mail> it = player.getMails().values().iterator();

        int count = 0;

        while (it.hasNext()) {
            Mail tempMail = it.next();
            if (keyId == tempMail.getKeyId()) {
                mail = tempMail;
            }

            if (tempMail.getCollections() == 1) {
                count++;
            }
        }

        if (mail == null) {
            handler.sendErrorMsgToPlayer(GameError.MAIL_NOT_EXIST);
            return;
        }

        if (req.getType() == 1 && count >= MailType.MAIL_COUNT_MAX_5) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        mail.setCollections(req.getType() == 1 ? 1 : 0);
        player.updMailState(mail, mail.getState());


        delMail(player, mail.getType());

        GamePb1.CollectionsMailRs.Builder builder = GamePb1.CollectionsMailRs.newBuilder();
        builder.setKeyId(keyId);
        handler.sendMsgToPlayer(GamePb1.CollectionsMailRs.ext, builder.build());
    }


    private void delMail(Player player, int type) {
        Iterator<Mail> it = player.getMails().values().iterator();
        int mailCount = 0;
        Mail toDelMail = null;
        while (it.hasNext()) {
            Mail next = it.next();
            if (type == 3 || type == 11) {
                if ((next.getType() == 3 || next.getType() == 11) && next.getCollections() != 1) {
                    mailCount++;
                    if (toDelMail == null) {
                        toDelMail = next;
                    } else {
                        if (toDelMail.getTime() > next.getTime()) {
                            toDelMail = next;
                        }
                    }
                }
            } else {
                if (next.getType() == type && next.getCollections() != 1) {
                    mailCount++;
                    if (toDelMail == null) {
                        toDelMail = next;
                    } else {
                        if (toDelMail.getTime() > next.getTime()) {
                            toDelMail = next;
                        }
                    }
                }
            }
        }

        // 邮箱超过设置上限，则删除最老邮件，如果邮件有附件，则帮玩家领取
        if (isLimit(type, mailCount)) {
            player.delMail(toDelMail);
            if (toDelMail.getAward() != null && toDelMail.getAward().size() > 0) {
                // 领取附件
                List<Award> returnList = getDelRewardMail(player, toDelMail);
                LogLordHelper.autoDelMail(AwardFrom.AUTO_DEL_MAIL, player, toDelMail);

                StcHelper.syncMail2Player(player, returnList);
            } else {
                StcHelper.syncMail2Player(player, null);
            }
        }


    }


    /**
     * 删除邮件
     *
     * @param req
     * @param handler void
     */
    public void delMailRq(DelMailRq req, ClientHandler handler) {
        long keyId = req.getKeyId();
        int type = req.getType();
        int delType = req.getDelType();

        if (type == 5) {
            delType = 1;
        }

        DelMailRs.Builder builder = DelMailRs.newBuilder();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (keyId > 0) {
            Iterator<Mail> it = player.getMails().values().iterator();
            while (it.hasNext()) {
                Mail mail = it.next();
                if (keyId == mail.getKeyId()) {
                    player.delMail(it, mail);
                    if (mail.getAward() != null && mail.getAward().size() > 0) {
                        LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                    }
                    break;
                }
            }
        } else {


            //删除所有
            if (delType == 1) {
                Iterator<Mail> it = player.getMails().values().iterator();
                while (it.hasNext()) {
                    Mail mail = it.next();

                    if (type == 3 || type == 11) {
                        if ((mail.getType() == 3 || mail.getType() == 11) && mail.getCollections() != 1) {
                            player.delMail(it, mail);
                            if (mail.getAward() != null && mail.getAward().size() > 0) {
                                LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                            }
                        }
                    } else {
                        if (mail.getType() == type && mail.getCollections() != 1) {
                            player.delMail(it, mail);
                            if (mail.getAward() != null && mail.getAward().size() > 0) {
                                LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                            }
                        }
                    }

                }
            }


            //已读
            if (delType == 2) {
                Iterator<Mail> it = player.getMails().values().iterator();
                while (it.hasNext()) {
                    Mail mail = it.next();

                    if (type == 3 || type == 11) {
                        if ((mail.getType() == 3 || mail.getType() == 11) && (mail.getState() == 2 || mail.getState() == 5) && mail.getCollections() != 1) {
                            player.delMail(it, mail);
                            if (mail.getAward() != null && mail.getAward().size() > 0) {
                                LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                            }
                        }
                    } else {
                        if (mail.getType() == type && (mail.getState() == 2 || mail.getState() == 5) && mail.getCollections() != 1) {
                            player.delMail(it, mail);
                            if (mail.getAward() != null && mail.getAward().size() > 0) {
                                LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                            }
                        }
                    }


                }
            }


            //系统邮件
            if (type == 1 && delType == 3) {
                Iterator<Mail> it = player.getMails().values().iterator();
                while (it.hasNext()) {
                    Mail mail = it.next();
                    if (mail.getType() == type && mail.getSendName() == null) {
                        player.delMail(it, mail);
                        if (mail.getAward() != null && mail.getAward().size() > 0) {
                            LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                        }
                    }
                }

            }


            //空白邮件
            if (type == 4 && delType == 4) {
                Iterator<Mail> it = player.getMails().values().iterator();
                while (it.hasNext()) {
                    Mail mail = it.next();
                    if (mail.getType() == type && (mail.getState() == 1 || mail.getState() == 2 || mail.getState() == 5)) {
                        player.delMail(it, mail);
                        if (mail.getAward() != null && mail.getAward().size() > 0) {
                            LogLordHelper.mail(AwardFrom.DEL_MAIL, player.account, player.lord, mail);
                        }
                    }
                }

            }

        }

        handler.sendMsgToPlayer(DelMailRs.ext, builder.build());
    }
}
