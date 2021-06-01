/**
 * @Title: PropService.java
 * @Package com.game.service
 * @Description:
 * @author ZhangJun
 * @date 2015年8月13日 下午5:13:29
 * @version V1.0
 */
package com.game.service;

import com.game.chat.domain.Chat;
import com.game.constant.*;
import com.game.dataMgr.*;
import com.game.domain.Member;
import com.game.domain.Player;
import com.game.domain.UsualActivityData;
import com.game.domain.p.*;
import com.game.domain.s.*;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.StaffingDataManager;
import com.game.manager.WorldDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.CommonPb.Skin;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb3.ComposeSantRq;
import com.game.pb.GamePb3.ComposeSantRs;
import com.game.pb.GamePb5.UsePropChooseRq;
import com.game.pb.GamePb5.UsePropChooseRs;
import com.game.pb.GamePb6.*;
import com.game.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;
import java.util.Map.Entry;

/**
 * @author ZhangJun
 * @ClassName: PropService
 * @Description: 道具相关
 * @date 2015年8月13日 下午5:13:29
 */

@Service
public class PropService {
    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private StaticVipDataMgr staticVipDataMgr;

    @Autowired
    private StaticAwardsDataMgr staticAwardsDataMgr;

    @Autowired
    private StaticLordDataMgr staticLordDataMgr;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private ChatService chatService;

    @Autowired
    private PartyService partyService;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private StaticActionMsgDataMgr staticActionMsgDataMgr;

    @Autowired
    private StaticPartDataMgr staticPartDataMgr;

    @Autowired
    private StaticEquipDataMgr staticEquipDataMgr;

    @Autowired
    private StaticHeroDataMgr staticHeroDataMgr;

    @Autowired
    private StaticMedalDataMgr staticMedalDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr functionPlanDataMgr;
    @Autowired
    private StaffingDataManager staffingDataManager;

    @Autowired
    private FriendService friendService;

    /**
     * Method: getProp
     *
     * @Description: 客户端获取道具数据 @param handler @return void @throws
     */
    public void getProp(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Iterator<Prop> it = player.props.values().iterator();
        GetPropRs.Builder builder = GetPropRs.newBuilder();
        while (it.hasNext()) {
            builder.addProp(PbHelper.createPropPb(it.next()));
        }

        for (PropQue propQue : player.propQue) {
            builder.addQueue(PbHelper.createPropQuePb(propQue));
        }

        handler.sendMsgToPlayer(GetPropRs.ext, builder.build());
    }

    /**
     * Method: buyProp
     *
     * @Description: 玩家购买道具 @param req @param handler @return void @throws
     */
    public void buyProp(BuyPropRq req, ClientHandler handler) {
        int propId = req.getPropId();
        int count = req.getCount();
        if (count <= 0 || count > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (staticProp.getCanBuy() != 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Lord lord = player.lord;
        int cost = staticProp.getPrice() * count;
        if (lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        if (!playerDataManager.subGold(player, cost, AwardFrom.BUY_PROP)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Prop prop = playerDataManager.addProp(player, propId, count, AwardFrom.BUY_PROP);

        BuyPropRs.Builder builder = BuyPropRs.newBuilder();
        builder.setGold(lord.getGold());
        builder.setCount(prop.getCount());
        handler.sendMsgToPlayer(BuyPropRs.ext, builder.build());
    }

    /**
     * Method: composeSant
     *
     * @Description: 合成将神魂 @param req @param handler @return void @throws
     */
    public void composeSant(ComposeSantRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Prop prop = player.props.get(PropId.SANT_HERO_CHIP);
        if (prop == null || prop.getCount() < 50) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        playerDataManager.subProp(player, prop, 50, AwardFrom.COMPOSE_SANT);
        playerDataManager.addProp(player, PropId.SANT_HERO, 1, AwardFrom.COMPOSE_SANT);

        ComposeSantRs.Builder builder = ComposeSantRs.newBuilder();
        builder.addAward(PbHelper.createAwardPb(AwardType.PROP, PropId.SANT_HERO, 1));
        handler.sendMsgToPlayer(ComposeSantRs.ext, builder.build());
    }

    /**
     * Method: useProp
     *
     * @Description: 玩家使用道具 @param req @param handler @return void @throws
     */
    public void useProp(UsePropRq req, ClientHandler handler) {
        int propId = req.getPropId();
        int count = req.getCount();

        if (propId < 641 || propId > 644) {
            if (count <= 0 || count > 100) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
        } else {
            // 红色方案道具最多使用数量不少100000
            if (count <= 0 || count > 100000) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Prop prop = player.props.get(propId);
        if (prop == null || prop.getCount() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PROP);
            return;
        }

        if (prop.getCount() < count) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        UsePropRs.Builder builder = UsePropRs.newBuilder();
        int type = staticProp.getEffectType();
        // 1.获得资源、物品 2.获得效果加成 3.加速 4.随机箱子 5.普通道具物品 6.特殊功能道具7.军团战事福利箱 8.军团贡献箱
        for (int i = 0; i < count; i++) {
            if (type == 1) {
                List<List<Integer>> effectValue = staticProp.getEffectValue();
                if (effectValue == null || effectValue.isEmpty()) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                builder.addAllAward(playerDataManager.addAwardsBackPb(player, effectValue, AwardFrom.USE_PROP));
            } else if (type == 2) {
                List<List<Integer>> effectValue = staticProp.getEffectValue();
                if (effectValue == null || effectValue.isEmpty()) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }

                for (List<Integer> one : effectValue) {
                    if (one.size() != 2 || one.get(1) <= 0) {
                        continue;
                    }

                    Effect effect = playerDataManager.addEffect(player, one.get(0), one.get(1));
                    if (effect != null) {
                        builder.addEffect(PbHelper.createEffectPb(effect));
                    }
                }
            } else if (type == 3) {// 加速类道具一般在相关模块调用

            } else if (type == 4) {
                List<List<Integer>> effectValue = staticProp.getEffectValue();
                if (effectValue == null || effectValue.isEmpty()) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                List<Integer> one = effectValue.get(0);
                if (one.size() != 1) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                List<List<Integer>> awards = staticAwardsDataMgr.getAwards(one.get(0));

                List<CommonPb.Award> pbAward = playerDataManager.addAwardsBackPb(player, awards, AwardFrom.USE_PROP);
                builder.addAllAward(pbAward);

                // 发送开宝箱的消息
                sendOpenBoxMsg(propId, player, pbAward);

            } else if (type == 6) {
                if (!req.hasParam()) {
                    handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                    return;
                }

                String param = req.getParam();

                if (propId >= PropId.HORN_1 && propId <= PropId.HORN_4) {// 喇叭
                    int silence = player.lord.getSilence();
                    if (silence > 0) {
                        int currentTime = Integer.parseInt(String.valueOf(new Date().getTime() / 1000));
                        if (silence == 1) {
                            handler.sendErrorMsgToPlayer(GameError.CHAT_SILENCE);
                            return;
                        } else if (silence > currentTime) {
                            LogUtil.silence(player.lord.getLordId() + " is Silence role time: " + (silence - currentTime) + "(" + silence
                                    + "-" + currentTime + ")");
                            handler.sendErrorMsgToPlayer(GameError.CHAT_SILENCE);
                            return;
                        }
                    }
                    Chat chat = chatService.createManChat(player, param);
                    chatService.sendHornChat(chat, propId - 59);

                } else if (propId == PropId.CHANGE_NAME) {// 身份铭牌
                    param = param.replaceAll(" ", "");
                    param = EmojiHelper.replace(param);
                    if (param == null || param.isEmpty() || param.length() >= 12) {
                        handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                        return;
                    }

                    if (EmojiHelper.containsEmoji(param)) {
                        handler.sendErrorMsgToPlayer(GameError.INVALID_CHAR);
                        return;
                    }

                    if (!playerDataManager.takeNick(param)) {
                        handler.sendErrorMsgToPlayer(GameError.SAME_NICK);
                        return;
                    }

                    playerDataManager.replaceName(player, param);
                    playerDataManager.rename(player, param);
                } else if (propId == PropId.PARTY_RENAME_CARD) {// 军团改名卡
                    param = param.replaceAll(" ", "");
                    if (param == null || param.isEmpty() || param.length() >= 12) {
                        handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                        return;
                    }

                    if (EmojiHelper.containsEmoji(param)) {
                        handler.sendErrorMsgToPlayer(GameError.INVALID_CHAR);
                        return;
                    }

                    Member member = partyDataManager.getMemberById(handler.getRoleId());
                    if (member == null || member.getPartyId() == 0) {
                        handler.sendErrorMsgToPlayer(GameError.PARTY_HAD);
                        return;
                    }

                    // 判断是否是军团长
                    if (member.getJob() != PartyType.LEGATUS) {
                        handler.sendErrorMsgToPlayer(GameError.AUTHORITY_ERR);
                        return;
                    }

                    // 判断是否名字已存在
                    if (partyDataManager.isExistPartyName(param)) {
                        handler.sendErrorMsgToPlayer(GameError.SAME_PARTY_NAME);
                        return;
                    }

                    partyService.rename(member.getPartyId(), param, handler);
                } else if (propId == PropId.SCOUT) {// 矿点侦查
                    Player target = playerDataManager.getPlayer(param);
                    if (target == null || !target.isActive() || target.roleId == player.roleId) {
                        handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
                        return;
                    }

                    Army e = null;
                    int index = 0;
                    for (Army army : target.armys) {
                        if (army.getState() == ArmyState.COLLECT && !army.getSenior() && !army.isCrossMine()) {
                            // e = army;
                            // break;
                            index++;
                        }
                    }

                    if (index != 0) {
                        int which = RandomHelper.randomInSize(index);
                        index = 0;
                        for (Army army : target.armys) {
                            if (army.getState() == ArmyState.COLLECT && !army.getSenior() && !army.isCrossMine()) {
                                if (index == which) {
                                    e = army;
                                    break;
                                }
                                index++;
                            }
                        }
                    }

                    if (e != null) {
                        StaticMine staticMine = worldDataManager.evaluatePos(e.getTarget());
                        playerDataManager.sendNormalMail(player, MailType.MOLD_SCOUT_SUCCESS, TimeHelper.getCurrentSecond(),
                                target.lord.getNick(), String.valueOf(staticMine.getLv() + staffingDataManager.getWorldMineLevel()), String.valueOf(staticMine.getType()),
                                String.valueOf(e.getTarget()));
                    } else {
                        playerDataManager.sendNormalMail(player, MailType.MOLD_SCOUT_FAIL, TimeHelper.getCurrentSecond(),
                                target.lord.getNick());
                    }

                } else if (propId == PropId.INDICATOR) {// 定位仪
                    Player target = playerDataManager.getPlayer(param);
                    if (target == null || !target.isActive() || target.roleId == player.roleId) {
                        handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
                        return;
                    }

                    playerDataManager.sendNormalMail(player, MailType.MOLD_SCOUT, TimeHelper.getCurrentSecond(), target.lord.getNick(),
                            String.valueOf(target.lord.getPos()));
                }
            } else if (type == 8) {
                // 军团贡献箱
                List<List<Integer>> effectValue = staticProp.getEffectValue();
                if (CheckNull.isEmpty(effectValue)) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                List<Integer> one = effectValue.get(0);
                if (one.size() != 1) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }

                Member member = partyDataManager.getMemberById(player.roleId);
                if (member == null || member.getPartyId() == 0) {
                    handler.sendErrorMsgToPlayer(GameError.NO_PARTY);
                    return;
                }

                // 增加玩家的军团贡献
                int donate = one.get(0);
                member.setDonate(member.getDonate() + donate);
                member.setWeekAllDonate(member.getWeekAllDonate() + donate);
                LogLordHelper.contribution(AwardFrom.USE_PROP, player.account, player.lord, member.getDonate(), member.getWeekAllDonate(),
                        donate);
            } else if (type == 9) {
                // 激活挂件道具
                List<List<Integer>> effectValue = staticProp.getEffectValue();
                if (CheckNull.isEmpty(effectValue)) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                List<Integer> one = effectValue.get(0);
                if (one.size() != 1) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                int pendantId = one.get(0);
                StaticPendant staticPendant = staticLordDataMgr.getPendant(pendantId);
                if (staticPendant == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                Pendant pendant = playerDataManager.addPendant(player, staticPendant);
                if (pendant == null) {
                    handler.sendErrorMsgToPlayer(GameError.HAVED);
                    return;
                }
                playerDataManager.setPendant(player, pendantId);
                builder.addAward(PbHelper.createAwardPb(0, pendantId, pendant.isForeverHold() ? 1 : 0, pendant.getEndTime()));
            } else if (type == 10) {
                // 肖像道具
                List<List<Integer>> effectValue = staticProp.getEffectValue();
                if (CheckNull.isEmpty(effectValue)) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                List<Integer> one = effectValue.get(0);
                if (one.size() != 1) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                int id = one.get(0);
                StaticPortrait staticPortrait = staticLordDataMgr.getPortraitMap().get(id);
                if (staticPortrait == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                Portrait portrait = playerDataManager.addPortrait(player, staticPortrait);
                if (portrait == null) {
                    handler.sendErrorMsgToPlayer(GameError.HAVED);
                    return;
                }
                playerDataManager.setPortrait(player, id);
                builder.addAward(PbHelper.createAwardPb(0, id, portrait.isForeverHold() ? 1 : 0, portrait.getEndTime()));
            } else if (type == 11) { // 使用征收道具后根据当前资源产量获得资源
                usePropEffectType11(player, staticProp, builder);
            } else if (type == 20) {// 战舰占用 道具自动建造+4H

            }
        }

        if (propId >= PropId.RED_PACKET_1 && propId <= PropId.RED_PACKET_4) {
            // 红包
            if (!req.hasParam()) {
                handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
                return;
            }

            String param = req.getParam();
            String[] nicks = param.split("&");
            if (count % nicks.length != 0) {
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
            }

            int everyGet = count / nicks.length;

            List<Player> targets = new ArrayList<>();
            for (String nick : nicks) {
                Player target = playerDataManager.getPlayer(nick);
                if (target == null || !target.isActive() || target.roleId == player.roleId) {
                    handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
                    return;
                }
                targets.add(target);
            }

            List<Award> awards = new ArrayList<>();
            awards.add(PbHelper.createAwardPb(AwardType.RED_PACKET, propId, everyGet));

            int now = TimeHelper.getCurrentSecond();
            for (Player target : targets) {
                playerDataManager.sendAttachMail(AwardFrom.RED_PACKET, target, awards, MailType.MOLD_RED_PACKET, now,
                        player.lord.getNick());

                useRedPacketAddFriendliness(handler, propId, everyGet, player, target);
            }
        }

        playerDataManager.subProp(player, prop, count, AwardFrom.USE_PROP);

        builder.setCount(prop.getCount());
        handler.sendMsgToPlayer(UsePropRs.ext, builder.build());
    }

    /**
     * 使用红包增加友好度
     *
     * @param handler
     * @param propId
     * @param count
     * @param player
     * @param target
     */
    private void useRedPacketAddFriendliness(ClientHandler handler, int propId, int count, Player player, Player target) {
        switch (propId) {
            case PropId.RED_PACKET_1:
                friendService.addFriendliness(player, target.roleId, 2, count, handler);
                break;
            case PropId.RED_PACKET_2:
                friendService.addFriendliness(player, target.roleId, 3, count, handler);
                break;
            case PropId.RED_PACKET_3:
                friendService.addFriendliness(player, target.roleId, 4, count, handler);
                break;
            case PropId.RED_PACKET_4:
                friendService.addFriendliness(player, target.roleId, 5, count, handler);
                break;
            default:
                break;
        }
    }

    /**
     * 使用效果类型为11的道具
     *
     * @param player
     * @param staticProp
     * @param builder
     */
    private void usePropEffectType11(Player player, StaticProp staticProp, UsePropRs.Builder builder) {
        List<List<Integer>> effectValue = staticProp.getEffectValue();
        if (effectValue == null || effectValue.isEmpty()) {
            return;
        }
        for (List<Integer> one : effectValue) {
            // [奖励类型,资源类型,征收时间]
            if (one.size() != 3)
                continue;
            int awardType = one.get(0), resId = one.get(1), timeSec = one.get(2);
            // 每分钟资源的常量
            long out = playerDataManager.getResourceOutMinutes(player, one.get(1));
            out = out * (timeSec / 60); // 征收时间
            playerDataManager.addAward(player, awardType, resId, out, AwardFrom.USE_PROP);
            builder.addAward(PbHelper.createAwardPb(awardType, resId, out));
        }
    }

    /**
     * Method: useProp
     *
     * @Description: 玩家使用道具 @param req @param handler @return void @throws
     */
    public void usePropChoose(UsePropChooseRq req, ClientHandler handler) {
        int propId = req.getPropId();
        int count = req.getCount();
        if (count <= 0 || count > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Prop prop = player.props.get(propId);
        if (prop == null || prop.getCount() == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_PROP);
            return;
        }

        if (prop.getCount() < count) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (staticProp.getEffectType() != 8) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        boolean has = false;
        int awardType = req.getChooseType();
        int awardId = req.getChooseId();
        for (int i = 0; i < staticProp.getEffectValue().size(); i++) {
            List<Integer> list = staticProp.getEffectValue().get(i);
            if (list.get(1) == awardId && list.get(0) == awardType) {
                has = true;
                break;
            }
        }

        if (!has) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        playerDataManager.subProp(player, prop, count, AwardFrom.USE_PROP);
        playerDataManager.addAward(player, awardType, awardId, count, AwardFrom.USE_PROP);

        UsePropChooseRs.Builder builder = UsePropChooseRs.newBuilder();
        builder.setCount(prop.getCount());
        builder.addAward(PbHelper.createAwardPb(awardType, awardId, count));

        handler.sendMsgToPlayer(UsePropChooseRs.ext, builder.build());
    }

    /**
     * Method: sendOpenBoxMsg
     *
     * @Description: 开宝箱发世界公告 @param propId @param player @param pbAward @return void @throws
     */
    public void sendOpenBoxMsg(int propId, Player player, List<CommonPb.Award> pbAward) {
        // 判断是否符合发送消息条件
        Map<Integer, List<EndConditionItem>> map = staticActionMsgDataMgr.getMsgMap(ActionMsgConst.OPEN_BOX);
        List<EndConditionItem> list = map.get(propId);
        if (list != null) {
            for (CommonPb.Award award : pbAward) {
                for (EndConditionItem item : list) {
                    boolean flag = true;
                    if (item.getItemType() != 0) {
                        flag = (item.getItemType() == award.getType());
                    }
                    if (flag && item.getItemId() != 0) {
                        flag = (item.getItemId() == award.getId());
                    }
                    if (flag && item.getQuality() != 0) {
                        // 判断是否正确的品质
                        flag = isCorrectQuality(award.getType(), award.getId(), item.getQuality());
                    }
                    if (flag && item.getStar() != 0) {
                        flag = isCorrectStar(award.getType(), award.getId(), item.getStar());
                    }
                    if (flag) {
                        // 发送消息
                        chatService.sendWorldChat(chatService.createSysChat(item.getChatId(), player.lord.getNick(),
                                AwardType.PROP + ":" + propId, award.getType() + ":" + award.getId()));
                    }
                }
            }
        }
    }

    /**
     * Method: sendOpenBoxMsg 参加活动获得物品发世界公告 @Description: @param player @param pbAward @return void @throws
     */
    public void sendJoinActivityMsg(int acitivityId, Player player, List<CommonPb.Award> pbAward) {
        Map<Integer, List<Award>> chatIds = getJoinActivityMsgChatIds(acitivityId, player, pbAward);
        if (!chatIds.isEmpty()) {
            for (Map.Entry<Integer, List<Award>> entry : chatIds.entrySet()) {
                for (Award award : entry.getValue()) {
                    chatService.sendWorldChat(chatService.createSysChat(entry.getKey(), player.lord.getNick(),
                            award.getType() + ":" + award.getId(), "" + acitivityId));
                }
            }
        }
    }

    /**
     * 像世界频道广播并加入活动本身显示屏
     *
     * @param player
     * @param pbAward
     * @param limit       Broadcast 保留最大长度
     */
    public void sendJoinActivityMsgAdd2Broadcast(UsualActivityData usualActivityData, Player player, List<CommonPb.Award> pbAward,
                                                 int limit) {
        Map<Integer, List<Award>> chatIds = getJoinActivityMsgChatIds(usualActivityData.getActivityId(), player, pbAward);
        if (!chatIds.isEmpty()) {
            List<String[]> broadcast = usualActivityData.getBroadcast();
            for (Map.Entry<Integer, List<Award>> entry : chatIds.entrySet()) {
                for (Award award : entry.getValue()) {
                    chatService.sendWorldChat(chatService.createSysChat(entry.getKey(), player.lord.getNick(),
                            award.getType() + ":" + award.getId(), "" + usualActivityData.getActivityId()));
                    broadcast.add(new String[]{player.lord.getNick(), String.valueOf(award.getType()), String.valueOf(award.getId()),
                            String.valueOf(award.getCount())});
                }
            }
            while (broadcast.size() > limit) {
                broadcast.remove(0);
            }
        }
    }

    /**
     * 活动中获得的道具需要广播信息
     *
     * @param acitivityId 活动ID
     * @param player
     * @param pbAward     活动中获取到的奖励
     * @return 需要广播的道具列表, KEY:广播ID, VALUE:道具列表
     */
    public Map<Integer, List<CommonPb.Award>> getJoinActivityMsgChatIds(int acitivityId, Player player, List<CommonPb.Award> pbAward) {
        Map<Integer, List<CommonPb.Award>> chatIds = new HashMap<>();
        // 判断是否符合发送消息条件
        Map<Integer, List<EndConditionItem>> map = staticActionMsgDataMgr.getMsgMap(ActionMsgConst.JOIN_ACTION);
        List<EndConditionItem> list = map.get(acitivityId);
        if (list != null) {
            for (CommonPb.Award award : pbAward) {
                for (EndConditionItem item : list) {
                    boolean flag = true;
                    if (item.getItemType() != 0) {
                        flag = (item.getItemType() == award.getType());
                    }
                    if (flag && item.getItemId() != 0) {
                        flag = (item.getItemId() == award.getId());
                    }
                    if (flag && item.getQuality() != 0) {
                        // 判断是否正确的品质
                        flag = isCorrectQuality(award.getType(), award.getId(), item.getQuality());
                    }
                    if (flag && item.getStar() != 0) {
                        flag = isCorrectStar(award.getType(), award.getId(), item.getStar());
                    }
                    if (flag) {
                        List<Award> chatAwardList = chatIds.get(item.getChatId());
                        if (chatAwardList == null)
                            chatIds.put(item.getChatId(), chatAwardList = new ArrayList<>());
                        chatAwardList.add(award);
                    }
                }
            }
        }
        return chatIds;
    }

    /**
     * Method: isCorrectStar 判断是否是正确的星级 @Description: @param type @param id @param star @return @return boolean @throws
     */
    private boolean isCorrectStar(int type, int id, int star) {
        if (type == AwardType.HERO) {
            return staticHeroDataMgr.getStaticHero(id).getStar() == star;
        }
        return false;
    }

    /**
     * @param quality Method: isCorrectQuality @Description: 判断是否是正确的品质 @param type @param id @return @return
     *                boolean @throws
     */
    private boolean isCorrectQuality(int type, int id, int quality) {
        if (type == AwardType.PART || type == AwardType.CHIP) {
            return staticPartDataMgr.getStaticPart(id).getQuality() == quality;
        } else if (type == AwardType.EQUIP) {
            return staticEquipDataMgr.getStaticEquip(id).getQuality() == quality;
        } else if (type == AwardType.MEDAL || type == AwardType.MEDAL_CHIP) {
            return staticMedalDataMgr.getStaticMedal(id).getQuality() == quality;
        }
        return false;
    }

    /**
     * 生产道具等待队列最大数
     *
     * @param lord
     * @return int
     */
    private int getPropQueWaitCount(Lord lord) {
        StaticVip staticVip = staticVipDataMgr.getStaticVip(lord.getVip());
        if (staticVip != null) {
            return staticVip.getWaitQue();
        }
        return 0;
    }

    /**
     * 创建道具生产队列
     *
     * @param player
     * @param propId
     * @param count
     * @param period
     * @param endTime
     * @return PropQue
     */
    private PropQue createQue(Player player, int propId, int count, int period, int endTime) {
        PropQue propQue = new PropQue(player.maxKey(), propId, count, 1, period, endTime);
        return propQue;
    }

    /**
     * 创建道具等待生产队列
     *
     * @param player
     * @param propId
     * @param count
     * @param period
     * @param endTime
     * @return PropQue
     */
    private PropQue createWaitQue(Player player, int propId, int count, int period, int endTime) {
        PropQue propQue = new PropQue(player.maxKey(), propId, count, 0, period, endTime);
        return propQue;
    }

    /**
     * Method: buildProp
     *
     * @Description: 制造车间生产道具 @param req @param handler @return void @throws
     */
    public void buildProp(BuildPropRq req, ClientHandler handler) {
        int propId = req.getPropId();
        int count = req.getCount();
        if (count <= 0 || count > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int buildingLv = PlayerDataManager.getBuildingLv(BuildingId.WORKSHOP, player.building);
        if (buildingLv < 1) {
            handler.sendErrorMsgToPlayer(GameError.BUILD_LEVEL);
            return;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (staticProp.getCanBuild() != 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        int stoneCost = staticProp.getStoneCost() * count;
        int skillBook = staticProp.getSkillBook() * count;
        int heroChip = staticProp.getHeroChip() * count;
        List<List<Integer>> buildCost = staticProp.getBuildCost();

        Resource resource = player.resource;
        Prop bookProp = null;
        Prop chipProp = null;
        BuildPropRs.Builder builder = BuildPropRs.newBuilder();
        if (stoneCost > 0) {
            if (resource.getStone() < stoneCost) {
                handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                return;
            }
        }

        if (skillBook > 0) {
            bookProp = player.props.get(PropId.SKILL_BOOK);
            if (bookProp == null || bookProp.getCount() < skillBook) {
                handler.sendErrorMsgToPlayer(GameError.BOOK_NOT_ENOUGH);
                return;
            }
        }

        if (heroChip > 0) {
            chipProp = player.props.get(PropId.HERO_CHIP);
            if (chipProp == null || chipProp.getCount() < heroChip) {
                handler.sendErrorMsgToPlayer(GameError.HERO_CHIP_NOT_ENOUGH);
                return;
            }
        }

        // 道具不足
        if (buildCost != null) {
            for (List<Integer> cost : buildCost) {
                int size = cost != null ? cost.size() : 0;
                if (size != 3) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                if (!playerDataManager.checkPropIsEnougth(player, cost.get(0), cost.get(1), cost.get(2) * count)) {
                    handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                    return;
                }
            }
        }

        List<PropQue> propQue = player.propQue;
        int queSize = propQue.size();
        PropQue que = null;
        int now = TimeHelper.getCurrentSecond();
        int haust = staticProp.getBuildTime() * count;
        if (queSize == 0) {
            que = createQue(player, propId, count, haust, now + haust);
            propQue.add(que);
        } else {
            if (queSize > 0 && queSize < getPropQueWaitCount(player.lord) + 1) {
                que = createWaitQue(player, propId, count, haust, now + haust);
                propQue.add(que);
            } else {
                handler.sendErrorMsgToPlayer(GameError.MAX_PROP_QUE);
                return;
            }
        }

        if (stoneCost > 0) {
            playerDataManager.modifyStone(player, -stoneCost, AwardFrom.BUILD_PROP);
            builder.setStone(resource.getStone());
        }

        if (skillBook > 0) {
            playerDataManager.subProp(player, bookProp, skillBook, AwardFrom.BUILD_PROP);
            builder.setSkillBook(bookProp.getCount());
        }

        if (heroChip > 0) {
            playerDataManager.subProp(player, chipProp, heroChip, AwardFrom.BUILD_PROP);
            builder.setHeroChip(chipProp.getCount());
        }

        if (buildCost != null) {
            for (List<Integer> cost : buildCost) {
                builder.addAtom2(playerDataManager.subProp(player, cost.get(0), cost.get(1), cost.get(2) * count, AwardFrom.BUILD_PROP));
            }
        }

        builder.setQueue(PbHelper.createPropQuePb(que));
        handler.sendMsgToPlayer(BuildPropRs.ext, builder.build());
    }

    /**
     * 生产完毕 产生道具
     *
     * @param props
     * @param propQue void
     */
    private void dealPropQue(Map<Integer, Prop> props, PropQue propQue) {
        Prop prop = props.get(propQue.getPropId());
        if (prop == null) {
            prop = new Prop(propQue.getPropId(), propQue.getCount());
            prop.setPropId(propQue.getPropId());
            prop.setCount(propQue.getCount());
            props.put(prop.getPropId(), prop);
        } else {
            prop.setCount(prop.getCount() + propQue.getCount());
        }
    }

    /**
     * 生产完毕 玩家增加道具
     *
     * @param player
     * @param list
     * @param now    void
     */
    private void dealPropQue(Player player, List<PropQue> list, int now) {
        Map<Integer, Prop> props = player.props;
        Iterator<PropQue> it = list.iterator();
        int endTime = 0;
        while (it.hasNext()) {
            PropQue propQue = it.next();
            if (propQue.getState() == 1) {
                endTime = propQue.getEndTime();
                if (now >= endTime) {
                    dealPropQue(props, propQue);
                    it.remove();
                    continue;
                }
                break;
            } else {
                if (endTime == 0) {
                    endTime = now;
                }

                endTime += propQue.getPeriod();
                if (now >= endTime) {
                    dealPropQue(props, propQue);
                    it.remove();
                    continue;
                }

                propQue.setState(1);
                propQue.setEndTime(endTime);
                break;
            }
        }
    }

    /**
     * Method: speedPropQue
     *
     * @Description: 加速道具生产 @param req @param handler @return void @throws
     */
    public void speedPropQue(SpeedQueRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        int cost = req.getCost();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<PropQue> list = player.propQue;
        PropQue que = null;
        for (PropQue e : list) {
            if (e.getKeyId() == keyId) {
                que = e;
                break;
            }
        }

        if (que == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
            return;
        }

        if (que.getState() == 0) {
            handler.sendErrorMsgToPlayer(GameError.SPEED_WAIT_QUE);
            return;
        }

        int now = TimeHelper.getCurrentSecond();
        int leftTime = que.getEndTime() - now;
        if (leftTime <= 0) {
            leftTime = 1;
        }

        if (cost == 1) {// 金币
            int sub = (int) Math.ceil(leftTime / 60.0);
            Lord lord = player.lord;
            if (lord.getGold() < sub) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, sub, AwardFrom.SPEED_PROP_QUE);
            que.setEndTime(now);

            dealPropQue(player, list, now);

            SpeedQueRs.Builder builder = SpeedQueRs.newBuilder();
            builder.setGold(lord.getGold());
            handler.sendMsgToPlayer(SpeedQueRs.ext, builder.build());
            return;
        } else {// 道具
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
    }

    /**
     * Method: cancelPropQue
     *
     * @Description: 取消道具生产 @param req @param handler @return void @throws
     */
    public void cancelPropQue(CancelQueRq req, ClientHandler handler) {
        int keyId = req.getKeyId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        List<PropQue> list = player.propQue;
        PropQue que = null;

        for (PropQue e : list) {
            if (e.getKeyId() == keyId) {
                que = e;
                break;
            }
        }

        if (que == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_EXIST_QUE);
            return;
        }

        int propId = que.getPropId();
        int count = que.getCount();
        StaticProp staticProp = staticPropDataMgr.getStaticProp(propId);
        if (staticProp == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        list.remove(que);

        int stoneCost = staticProp.getStoneCost() * count / 2;
        int bookCount = staticProp.getSkillBook() * count / 2;
        int heroChip = staticProp.getHeroChip() * count / 2;
        List<List<Integer>> buildCost = staticProp.getBuildCost();

        if (bookCount > 0) {
            playerDataManager.addProp(player, PropId.SKILL_BOOK, bookCount, AwardFrom.CANCEL_PROP_QUE);
        }

        if (heroChip > 0) {
            playerDataManager.addProp(player, PropId.HERO_CHIP, heroChip, AwardFrom.CANCEL_PROP_QUE);
        }

        List<Award> backList = null;
        if (buildCost != null && !buildCost.isEmpty()) {
            List<List<Integer>> backAward = new ArrayList<>();
            for (List<Integer> cost : buildCost) {
                int backCount = cost.get(2) * count / 2;
                if (backCount > 0) {
                    List<Integer> back = new ArrayList<>();
                    back.add(cost.get(0));
                    back.add(cost.get(1));
                    back.add(backCount);
                    backAward.add(back);
                }
            }
            if (!backAward.isEmpty()) {
                backList = playerDataManager.addAwardsBackPb(player, backAward, AwardFrom.CANCEL_PROP_QUE);
            }
        }

        Resource resource = player.resource;
        CancelQueRs.Builder builder = CancelQueRs.newBuilder();
        if (stoneCost > 0) {
            playerDataManager.modifyStone(player, stoneCost, AwardFrom.CANCEL_PROP_QUE);
            builder.setStone(resource.getStone());
        }

        if (backList != null) {
            builder.addAllAward(backList);
        }

        handler.sendMsgToPlayer(CancelQueRs.ext, builder.build());
    }

    /**
     * Method: propQueTimerLogic
     *
     * @Description: 制造车间制造道具队列定时器逻辑 @return void @throws
     */
    public void propQueTimerLogic() {
        Iterator<Player> iterator = playerDataManager.getRecThreeMonOnlPlayer().values().iterator();
        int now = TimeHelper.getCurrentSecond();
        while (iterator.hasNext()) {
            Player player = iterator.next();

			/*if(player.is3MothLogin()){
				continue;
			}*/

            if (!player.isActive()) {
                continue;
            }

            if (!player.propQue.isEmpty()) {
                try {
                    dealPropQue(player, player.propQue, now);
                } catch (Exception e) {
                    LogUtil.error("制造车间制造道具队列定时器报错, lordId:" + player.lord.getLordId(), e);
                }
            }
        }
    }

    /**
     * 返回皮肤列表
     *
     * @param req
     */
    public void getSkins(GetSkinsRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isSkinOpen())
            return;

        int type = req.getType();

        Player player = playerDataManager.getPlayer(handler.getRoleId());

        List<Skin.Builder> skinList = getSkin(type, player);
        GetSkinsRs.Builder builder = GetSkinsRs.newBuilder();
        for (Skin.Builder skinBuilder : skinList) {
            builder.addSkin(skinBuilder.build());
        }

        handler.sendMsgToPlayer(GetSkinsRs.ext, builder.build());
    }

    /**
     * 购买皮肤/铭牌/聊天气泡
     */
    public void buySkin(BuySkinRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isSkinOpen())
            return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int skinId = req.getSkinId();
        int count = req.getCount();

        if (count <= 0 || count > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticSkin staticSkin = staticPropDataMgr.getStaticSkin(skinId);
        if (staticSkin == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (staticSkin.getCanbuy() != 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // vip等级达到才能购买、使用
        if (staticSkin.getVip() > player.lord.getVip()) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }

        // 购买铭牌
        if (staticSkin.getType() != SkinType.SKIN) {
            buyOtherSkin(skinId, count, player, staticSkin, handler);
            return;
        }

        Lord lord = player.lord;
        StaticProp staticProp = staticPropDataMgr.getStaticSkinProp(skinId);
        int cost = staticProp.getPrice() * count;

        // 金币不够
        if (lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        if (!playerDataManager.subGold(player, cost, AwardFrom.BUY_SKIN)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 购买的皮肤放入道具表里
        playerDataManager.addProp(player, staticSkin.getItem(), count, AwardFrom.BUY_SKIN);

        // 获取皮肤列表
        List<Skin.Builder> skinList = getSkin(staticSkin.getType(), player);
        BuySkinRs.Builder builder = BuySkinRs.newBuilder();

        builder.setGold(player.lord.getGold());

        for (Skin.Builder skinBuilder : skinList) {
            builder.addSkin(skinBuilder.build());
        }

        handler.sendMsgToPlayer(BuySkinRs.ext, builder.build());
    }

    /**
     * 购买铭牌、气泡
     *
     * @param skinId
     * @param count
     * @param player
     * @param staticSkin
     * @param handler
     */
    private void buyOtherSkin(int skinId, int count, Player player, StaticSkin staticSkin, ClientHandler handler) {
        Lord lord = player.lord;

        int cost = staticSkin.getPrice() * count;

        // 金币不够
        if (lord.getGold() < cost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        AwardFrom from = null;
        switch (staticSkin.getType()) {
            case SkinType.NAMEPLATE:
                from = AwardFrom.BUY_NAMEPLATE;
                break;
            case SkinType.BUBBLE:
                from = AwardFrom.BUY_BUBBLE;
                break;
            default:
                handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
                return;
        }

        if (!playerDataManager.subGold(player, cost, from)) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        // 购买的皮肤放入道具表里
        playerDataManager.addSkin(player, skinId, count, staticSkin.getType());

        // 获取皮肤列表
        List<Skin.Builder> skinList = getSkin(staticSkin.getType(), player);
        BuySkinRs.Builder builder = BuySkinRs.newBuilder();

        builder.setGold(player.lord.getGold());

        for (Skin.Builder skinBuilder : skinList) {
            builder.addSkin(skinBuilder.build());
        }

        handler.sendMsgToPlayer(BuySkinRs.ext, builder.build());
    }

    /**
     * 使用皮肤/铭牌/聊天气泡
     *
     * @param req
     */
    public void useSkin(UseSkinRq req, ClientHandler handler) {
        if (!functionPlanDataMgr.isSkinOpen())
            return;

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int skinId = req.getSkinId();
        int count = req.getCount();

        if (count < 1 || count > 100) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticSkin staticSkin = staticPropDataMgr.getStaticSkin(skinId);
        if (staticSkin == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        // vip等级达到才能购买、使用
        if (staticSkin.getVip() > player.lord.getVip()) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }

        if (staticSkin.getType() != SkinType.SKIN) {
            useOtherSkin(skinId, count, player, staticSkin, handler);
            return;
        }

        GameError error = useSkin(skinId, count, player, staticSkin);

        if (error != GameError.OK) {
            handler.sendErrorMsgToPlayer(error);
            return;
        }

        // 获取当前皮肤效果
        Effect effect = player.surface == 0 ? new Effect(0, -1) : player.effects.get(player.surface + 10);

        UseSkinRs.Builder builder = UseSkinRs.newBuilder();

        builder.setEffect(PbHelper.createEffectPb(effect));

        // 设置剩余数量
        int propId = staticSkin.getItem();
        if (propId == 0) {
            builder.setCount(0);
        } else {
            Prop prop = player.props.get(staticSkin.getItem());
            builder.setCount(prop == null ? 0 : prop.getCount());
        }
        List<Skin.Builder> skinList = getSkin(staticSkin.getType(), player);
        for (Skin.Builder skinBuilder : skinList) {
            builder.addSkin(skinBuilder.build());
        }

        handler.sendMsgToPlayer(UseSkinRs.ext, builder.build());
    }

    /**
     * 使用铭牌、气泡
     *
     * @param staticSkin
     */
    private void useOtherSkin(int skinId, int count, Player player, StaticSkin staticSkin, ClientHandler handler) {
        int type = staticSkin.getType();

        if (type != SkinType.NAMEPLATE && type != SkinType.BUBBLE) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        Map<Integer, com.game.domain.Skin> skinMap = player.getSkin(type);
        Map<Integer, Effect> usedMap = player.getUsedSkin(type);

        int skinCount = 0;

        // 如果使用的皮肤是当前皮肤，则从已购买map里扣除数量;否则：如果已使用map里没有该皮肤，则设置为当前皮肤，从已购买map里扣除皮肤
        if (skinId == player.getCurrentSkin(type) || !usedMap.containsKey(skinId)) {
            com.game.domain.Skin skin = skinMap.get(skinId);

            if (skin == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_PROP);
                return;
            }

            if (skin.getCount() < count) {
                handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
                return;
            }
            // 扣除拥有的皮肤
            skin.setCount(skin.getCount() - count);

            skinCount = skin.getCount();

            // 全部使用则删除该皮肤
            if (skinCount == 0) {
                skinMap.remove(skinId);
            }

            // 如果之前使用过该皮肤，则增加使用时间。如第一次使用，则加入使用皮肤map中。
            Effect effect = usedMap.get(skinId);
            int effectivetime = staticSkin.getEffectivetime();
            if (effect == null) {
                effect = new Effect(0, effectivetime == 0 ? 0 : TimeHelper.getCurrentSecond() + staticSkin.getEffectivetime() * count);
                usedMap.put(skinId, effect);
            } else {
                if (effectivetime > 0) {
                    effect.setEndTime(effect.getEndTime() + staticSkin.getEffectivetime() * count);
                }
            }
        }

        player.setCurrentSkin(type, skinId);

        List<Skin.Builder> skinList = getSkin(staticSkin.getType(), player);

        UseSkinRs.Builder builder = UseSkinRs.newBuilder();

        for (Skin.Builder skinBuilder : skinList) {
            builder.addSkin(skinBuilder.build());
        }

        builder.setCount(skinCount);

        handler.sendMsgToPlayer(UseSkinRs.ext, builder.build());
    }

    /**
     * 使用皮肤具体逻辑
     *
     * @param skinId
     * @param count  = 1
     * @param player
     * @return
     */
    private GameError useSkin(int skinId, int count, Player player, StaticSkin staticSkin) {
        // 使用默认皮肤
        if (staticSkin.getItem() == 0) {
            // 取消旧皮肤effect
            if (player.surface != 0) {
                Effect effect = player.effects.remove(player.surface + 10);
                player.surfaceSkins.put(effect.getEffectId(), effect);
                playerDataManager.vaildEffect(player, player.surface + 10, -1);
                player.surface = 0;
            }
            return GameError.OK;
        }

        StaticProp staticProp = staticPropDataMgr.getStaticSkinProp(skinId);

        if (staticProp == null) {
            return GameError.NO_CONFIG;
        }

        // 查找当前effect中是否有使用过该皮肤所带effect
        Effect effect = player.surfaceSkins.get(staticSkin.getEffectId());

        // 如果已经使用过该皮肤，但该皮肤已被替换且皮肤还未过期，本次则不消耗道具，同时不增加buff时长
        if (effect != null && effect.getEffectId() != player.surface + 10) {
            playerDataManager.addEffect(player, effect.getEffectId(), 0);
            return GameError.OK;
        }

        // 如果是正在使用该皮肤或第一次使用该皮肤，则消耗一个皮肤道具，加成时间增加
        Prop prop = player.props.get(staticProp.getPropId());
        if (prop == null || prop.getCount() == 0) {
            return GameError.NO_PROP;
        }

        if (prop.getCount() < count) {
            return GameError.PROP_NOT_ENOUGH;
        }

        List<List<Integer>> effectValue = staticProp.getEffectValue();
        if (effectValue == null || effectValue.isEmpty()) {
            return GameError.NO_CONFIG;
        }

        for (int i = 0; i < count; i++) {
            for (List<Integer> one : effectValue) {
                if (one.size() != 2 && one.get(1) <= 0) {
                    continue;
                }

                playerDataManager.addEffect(player, one.get(0), one.get(1));
            }
        }

        playerDataManager.subProp(player, prop, count, AwardFrom.USE_SKIN);
        return GameError.OK;
    }

    /**
     * 返回皮肤列表
     *
     * @param player
     * @return
     */
    private List<Skin.Builder> getSkin(int type, Player player) {
        if (type != SkinType.SKIN) {
            return getOtherSkin(player, type);
        }

        StaticSkin staticSkin;
        Effect effect;
        List<Skin.Builder> list = new ArrayList<>();
        Skin.Builder skinBuilder;
        // 状态 0 没有该皮肤，不可使用 1 有该皮肤，未使用 2 正在使用 3 使用过，被替换
        for (Entry<Integer, StaticSkin> entry : staticPropDataMgr.getStaticSkinByType(type).entrySet()) {
            skinBuilder = Skin.newBuilder();
            staticSkin = entry.getValue();
            skinBuilder.setSkinId(staticSkin.getId());
            int propId = staticSkin.getItem();
            int effectId = staticSkin.getEffectId();
            // 非默认皮肤
            if (propId != 0) {
                effect = player.surfaceSkins.get(effectId);
                // 没有使用该皮肤，则查找背包是否有该皮肤
                if (effect == null) {
                    Prop prop = player.props.get(propId);
                    // 如果玩家背包没有该道具
                    if (prop == null || prop.getCount() == 0) {
                        skinBuilder.setStatus(0);
                    } else {
                        // 背包有该道具，则状态为1
                        skinBuilder.setStatus(1);
                        skinBuilder.setCount(prop.getCount());
                    }
                } else {// 该皮肤已经使用过或正在使用
                    if (player.surface == effectId - 10) { // 正在使用
                        skinBuilder.setStatus(2);
                    } else {
                        skinBuilder.setStatus(3);
                    }
                    int count = 0;
                    Prop prop = player.props.get(propId);
                    if (prop != null) {
                        count = prop.getCount();
                    }
                    skinBuilder.setCount(count);
                    skinBuilder.setRemaining(effect.getEndTime() - TimeHelper.getCurrentSecond());
                }
            } else { // 默认皮肤
                if (player.surface == 0) {
                    skinBuilder.setStatus(2);
                } else {
                    skinBuilder.setStatus(1);
                }
                skinBuilder.setRemaining(-1);
            }
            list.add(skinBuilder);
        }
        return list;
    }

    /**
     * 获取其他类型的皮肤（2 铭牌 3 聊天气泡等）
     *
     * @param player
     * @param type
     * @return List<Skin.Builder>
     */
    private List<Skin.Builder> getOtherSkin(Player player, int type) {
        StaticSkin staticSkin;
        Effect effect;
        List<Skin.Builder> list = new ArrayList<>();
        Skin.Builder skinBuilder;
        Integer skinId;

        Map<Integer, com.game.domain.Skin> map = player.getSkin(type);
        Map<Integer, Effect> usedMap = player.getUsedSkin(type);

        // 当前正在使用的皮肤(type 2 铭牌 3 聊天气泡)
        int currentSkin = player.getCurrentSkin(type);
        Map<Integer, StaticSkin> staticSkinByType = staticPropDataMgr.getStaticSkinByType(type);
        for (Entry<Integer, StaticSkin> entry : staticSkinByType.entrySet()) {
            skinBuilder = Skin.newBuilder();
            staticSkin = entry.getValue();
            skinId = staticSkin.getId();
            skinBuilder.setSkinId(staticSkin.getId());
            // 在已使用map里则为正在使用状态
            if (usedMap.containsKey(skinId)) {
                // 当前使用的皮肤
                if (skinId == currentSkin) {
                    skinBuilder.setStatus(2);
                } else {// 已使用被替换
                    skinBuilder.setStatus(3);
                }
                int count = 0;
                com.game.domain.Skin skin = map.get(skinId);
                if (skin != null) {
                    count = skin.getCount();
                }
                effect = usedMap.get(skinId);
                skinBuilder.setCount(count);
                skinBuilder.setRemaining(effect.getEndTime() - TimeHelper.getCurrentSecond());
            } else {
                // 如果玩家已购买皮肤且可使用数大于0则状态为已拥有
                if (map.containsKey(skinId)) {
                    com.game.domain.Skin skin = map.get(skinId);
                    if (skin.getCount() > 0) {
                        skinBuilder.setStatus(1);
                        skinBuilder.setCount(skin.getCount());
                    } else {
                        skinBuilder.setStatus(0);
                    }
                } else {
                    // 没有购买该道具或者时间到期被清除掉
                    skinBuilder.setStatus(0);
                }
            }
            list.add(skinBuilder);
        }

        return list;
    }
}
