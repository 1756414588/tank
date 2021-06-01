package com.game.service;

import com.game.constant.AwardFrom;
import com.game.constant.GameError;
import com.game.constant.MailType;
import com.game.constant.SystemId;
import com.game.dataMgr.StaticIniDataMgr;
import com.game.dataMgr.StaticLordDataMgr;
import com.game.dataMgr.friend.StaticFriendDataMgr;
import com.game.dataMgr.friend.StaticFriendGiftDataMgr;
import com.game.domain.Player;
import com.game.domain.p.*;
import com.game.domain.p.friend.FriendGive;
import com.game.domain.p.friend.Friendliness;
import com.game.domain.s.StaticLordLv;
import com.game.domain.s.StaticSystem;
import com.game.domain.s.friend.GiveProp;
import com.game.domain.s.friend.StaticFriend;
import com.game.manager.PartyDataManager;
import com.game.manager.PlayerDataManager;
import com.game.manager.SmallIdManager;
import com.game.manager.WorldDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.GamePb1.*;
import com.game.pb.GamePb3.AddTipFriendsRq;
import com.game.pb.GamePb3.AddTipFriendsRs;
import com.game.pb.GamePb3.GetTipFriendsRs;
import com.game.pb.GamePb6;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * 社交服务类
 *
 * @author ChenKui
 * @version 创建时间：2015-9-3 上午10:52:08
 * @declare
 */
@Service
public class FriendService {
    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PartyDataManager partyDataManager;

    @Autowired
    private WorldDataManager worldDataManager;

    @Autowired
    private StaticLordDataMgr lordDataMgr;

    @Autowired
    private SmallIdManager smallIdManager;

    @Autowired
    private MilitaryScienceService militaryScienceService;

    @Autowired
    private StaticIniDataMgr staticIniDataMgr;

    @Autowired
    private StaticFriendDataMgr staticFriendDataMgr;
    @Autowired
    private StaticFriendGiftDataMgr staticFriendGiftDataMgr;

    /**
     * 好友列表
     *
     * @param handler void
     */
    public void getFriend(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Map<Long, Friend> friendMap = player.friends;
        GetFriendRs.Builder builder = GetFriendRs.newBuilder();
        /**
         * 好友列表按照友好度进行排序
         */
        ArrayList<Friend> friends = new ArrayList<>(friendMap.values());
        Collections.sort(friends, new Comparator<Friend>() {
            @Override
            public int compare(Friend o1, Friend o2) {
                return o2.getFriendliness() - o1.getFriendliness();
            }
        });
        Iterator<Friend> it = friends.iterator();
        int today = TimeHelper.getCurrentDay();
        while (it.hasNext()) {
            Friend friend = it.next();
            if (friend.getBlessTime() != today) {
                friend.setBless(0);
            }
            long lordId = friend.getLordId();
            if (smallIdManager.isSmallId(lordId)) {
                continue;
            }

            Friend entity = new Friend(lordId, friend.getBless(), friend.getBlessTime());
            entity.setFriendliness(friend.getFriendliness());
            Player ee = playerDataManager.getPlayer(lordId);
            if (ee == null) {
                it.remove();
                continue;
            }
            Lord lord = ee.lord;
            if (lord == null) {
                continue;
            }
            String partyName = partyDataManager.getPartyNameByLordId(lordId);
            boolean mutualFriend = playerDataManager.checkMutualFriend(player.roleId, lordId);
            int giveCount = playerDataManager.getCurMonthFriendCount(player, lordId);
            Man man = new Man();
            man.setLordId(lordId);
            man.setIcon(lord.getPortrait());
            man.setLevel(lord.getLevel());
            man.setNick(lord.getNick());
            man.setSex(lord.getSex());
            man.setPros(lord.getPros());
            man.setFight(lord.getFight());
            man.setProsMax(lord.getProsMax());
            man.setPartyName(partyName);
            builder.addFriend(PbHelper.createFriendPb(man, entity, mutualFriend, giveCount));
        }
        int totalGiveCount = getCurMonthTotalCount(player);
        builder.setGiveCount(totalGiveCount);
        handler.sendMsgToPlayer(GetFriendRs.ext, builder.build());
    }


    /**
     * 添加好友
     *
     * @param req
     * @param handler void
     */
    public void addFriend(AddFriendRq req, ClientHandler handler) {
        long friendId = req.getFriendId();
        if (friendId == handler.getRoleId().longValue()) {
            handler.sendErrorMsgToPlayer(GameError.FRIEND_HAD);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Map<Long, Friend> friendMap = player.friends;
        if (friendMap.containsKey(friendId)) {
            handler.sendErrorMsgToPlayer(GameError.FRIEND_HAD);
            return;
        }
        Player toFriend = playerDataManager.getPlayer(friendId);
        if (toFriend == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }

        Friend friend = new Friend(friendId, 0, 0);
        friendMap.put(friendId, friend);

        playerDataManager.sendNormalMail(toFriend, MailType.MOLD_FRIEND_ADD, TimeHelper.getCurrentSecond(), player.lord.getNick());

        AddFriendRs.Builder builder = AddFriendRs.newBuilder();
        handler.sendMsgToPlayer(AddFriendRs.ext, builder.build());

        try {
            playerDataManager.synFriendlinessToPlayer(player, toFriend);
        } catch (Exception e) {
            LogUtil.error(String.format("syn friendliness error [%s-%s]", toFriend.roleId, player.roleId), e);
        }

    }

    /**
     * 搜索玩家
     *
     * @param req
     * @param handler void
     */
    public void seachPlayer(SeachPlayerRq req, ClientHandler handler) {
        String nick = req.getNick();

        Player player = playerDataManager.getPlayer(nick);
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        SeachPlayerRs.Builder builder = SeachPlayerRs.newBuilder();
        Man man = new Man();
        man.setLordId(lord.getLordId());
        man.setSex(lord.getSex());
        man.setIcon(lord.getPortrait());
        man.setLevel(lord.getLevel());
        man.setRanks(lord.getRanks());
        man.setFight(lord.getFight());
        man.setPros(lord.getPros());
        man.setProsMax(lord.getProsMax());
        man.setPartyName(partyDataManager.getPartyNameByLordId(lord.getLordId()));
        builder.setMan(PbHelper.createManPb(man));

        handler.sendMsgToPlayer(SeachPlayerRs.ext, builder.build());
    }

    /**
     * 删除好友
     *
     * @param req
     * @param handler void
     */
    public void delFriend(DelFriendRq req, ClientHandler handler) {
        long friendId = req.getFriendId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Map<Long, Friend> friendMap = player.friends;
        if (!friendMap.containsKey(friendId)) {
            handler.sendErrorMsgToPlayer(GameError.FRIEND_NOT_EXIST);
            return;
        }

        Player fPlayer = playerDataManager.getPlayer(friendId);

        if (playerDataManager.checkMutualFriend(player.roleId, friendId)) {
            //若双方互为好友，好友度清零
            friendMap.get(friendId).setFriendliness(0);
            Friend friend = fPlayer.friends.get(player.roleId);
            friend.setFriendliness(0);

        }
        /**
         * 清空祝福增加的友好度记录
         */
        Map<Long, Friendliness> blessFriendlinesses = player.getBlessFriendlinesses();
        if (!blessFriendlinesses.isEmpty()) {
            Iterator<Friendliness> it = blessFriendlinesses.values().iterator();
            while (it.hasNext()) {
                if (it.next().getLordId() == friendId) {
                    it.remove();
                }
            }
        }
        friendMap.remove(friendId);
        DelFriendRs.Builder builder = DelFriendRs.newBuilder();
        handler.sendMsgToPlayer(DelFriendRs.ext, builder.build());

        try {
            playerDataManager.synFriendlinessToPlayer(player, fPlayer);
        } catch (Exception e) {
            LogUtil.error(String.format("syn friendliness error [%s-%s]", fPlayer.roleId, player.roleId), e);
        }
    }

    /**
     * 祝福好友
     *
     * @param req
     * @param handler void
     */
    public void blessFriendRq(BlessFriendRq req, ClientHandler handler) {
        long friendId = req.getFriendId();
        long lordId = handler.getRoleId();
        Player player = playerDataManager.getPlayer(lordId);
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Lord lord = player.lord;
        StaticLordLv staticLordLv = lordDataMgr.getStaticLordLv(lord.getLevel());
        if (staticLordLv == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }
        int currentDay = TimeHelper.getCurrentDay();
        Map<Long, Friend> friendMap = player.friends;
        int blessCount = lord.getBlessCount();
        if (lord.getBlessTime() != currentDay) {
            blessCount = 0;
            lord.setBlessTime(currentDay);
        }
        int exp = 0;
        if (friendId != 0) {// 单独对好友进行祝福
            if (!friendMap.containsKey(friendId) || smallIdManager.isSmallId(friendId)) {
                handler.sendErrorMsgToPlayer(GameError.FRIEND_NOT_EXIST);
                return;
            }
            Player fplayer = playerDataManager.getPlayer(friendId);
            if (fplayer == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_LORD);
                return;
            }
            boolean flag = addBless(fplayer, lordId, currentDay);

            Friend friend = friendMap.get(friendId);
            friend.setBless(1);// 祝福
            friend.setBlessTime(currentDay);
            if (blessCount < 10) {
                exp = staticLordLv.getBlessExp();
                playerDataManager.addExp(player, staticLordLv.getBlessExp());
                blessCount++;
            }
            if (flag) {
                playerDataManager.synBlessToPlayer(fplayer, lord);
            }

            addFriendliness(player, friendId, 1, 1, handler);
        } else {// 一键全祝福
            Iterator<Friend> it = friendMap.values().iterator();
            int count = 0;
            while (it.hasNext()) {
                Friend next = it.next();
                if (smallIdManager.isSmallId(next.getLordId())) {
                    continue;
                }
                if (next.getBlessTime() == currentDay) {// 已经祝福过
                    continue;
                }
                next.setBless(1);
                next.setBlessTime(currentDay);

                Player fplayer = playerDataManager.getPlayer(next.getLordId());
                if (fplayer == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_LORD);
                    return;
                }
                boolean flag = addBless(fplayer, lordId, currentDay);
                if (flag) {
                    playerDataManager.synBlessToPlayer(fplayer, lord);
                }

                addFriendliness(player, next.getLordId(), 1, 1, handler);

                if (blessCount + count < 10) {
                    count++;
                }

            }
            blessCount += count;
            if (count > 0) {
                exp = count * staticLordLv.getBlessExp();
                playerDataManager.addExp(player, exp);
            }
        }
        int realExp = playerDataManager.realExp(player, exp);
        lord.setBlessCount(blessCount);
        lord.setBlessTime(currentDay);
        BlessFriendRs.Builder builder = BlessFriendRs.newBuilder();
        builder.setExp(realExp);
        handler.sendMsgToPlayer(BlessFriendRs.ext, builder.build());
    }

    /**
     * 领取好友祝福
     *
     * @param handler void
     */
    public void getBlessRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Map<Long, Bless> blessMap = player.blesses;
        GetBlessRs.Builder builder = GetBlessRs.newBuilder();
        Iterator<Bless> it = blessMap.values().iterator();
        int currentDay = TimeHelper.getCurrentDay();
        int blessCount = 0;
        while (it.hasNext()) {
            Bless bless = it.next();
            if (bless.getBlessTime() != currentDay) {
                continue;
            }
            long lordId = bless.getLordId();
            if (smallIdManager.isSmallId(lordId)) {
                continue;
            }
            Bless entity = new Bless(lordId, bless.getBlessTime());
            entity.setState(bless.getState());
            Player blessPlayer = playerDataManager.getPlayer(lordId);
            if (blessPlayer == null) {
                continue;
            }
            Lord lord = blessPlayer.lord;
            if (lord == null) {
                continue;
            }
            if (++blessCount > 10) {
                break;
            }
            int sex = lord.getSex();
            String nick = lord.getNick();
            int level = lord.getLevel();
            int icon = lord.getPortrait();
            Man man = new Man(lordId, sex, nick, icon, level);
            builder.addBless(PbHelper.createBlessPb(man, entity));
        }
        handler.sendMsgToPlayer(GetBlessRs.ext, builder.build());
    }

    /**
     * 接受祝福
     *
     * @param req
     * @param handler void
     */
    public void acceptBless(AcceptBlessRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        Map<Long, Bless> blessMap = player.blesses;
        long friendId = req.getFriendId();
        int addEnergy = 0;
        int currentDay = TimeHelper.getCurrentDay();
        Iterator<Bless> beenIt = blessMap.values().iterator();
        int blessCount = 0;
        while (beenIt.hasNext()) {
            Bless bless = beenIt.next();
            if (bless != null && bless.getBlessTime() == currentDay && bless.getState() != 0) {
                blessCount++;
                if (smallIdManager.isSmallId(bless.getLordId())) {
                    continue;
                }
            }
        }
        if (blessCount >= 10) {
            handler.sendErrorMsgToPlayer(GameError.COUNT_NOT_ENOUGH);
            return;
        }

        if (friendId == 0) {
            Iterator<Bless> it = blessMap.values().iterator();
            while (it.hasNext()) {
                Bless bless = it.next();
                if (bless != null && bless.getBlessTime() == currentDay && bless.getState() == 0) {
                    if (smallIdManager.isSmallId(bless.getLordId())) {
                        continue;
                    }
                    bless.setState(1);
                    addEnergy++;
                }
            }
        } else {
            Bless bless = blessMap.get(friendId);
            if (bless != null && bless.getBlessTime() == currentDay && bless.getState() == 0) {
                if (!smallIdManager.isSmallId(bless.getLordId())) {
                    bless.setState(1);
                    addEnergy++;
                }
            }
        }
        // 军工科技材料
        List<Award> awards = new ArrayList<Award>();

        if (addEnergy > 0) {
            addEnergy = addEnergy + blessCount >= 10 ? 10 - blessCount : addEnergy;
            addEnergy = addEnergy < 0 ? 0 : addEnergy;

            for (int i = 0; i < addEnergy; i++) {
                List<Award> a = militaryScienceService.getMilitaryBlessAward(player);
                if (a != null && a.size() > 0) {
                    awards.addAll(a);
                }
            }
            playerDataManager.addPower(player.lord, addEnergy);
        }

        AcceptBlessRs.Builder builder = AcceptBlessRs.newBuilder();
        builder.setEnergy(player.lord.getPower());
        if (awards.size() > 0) {
            builder.addAllAward(awards);
        }
        handler.sendMsgToPlayer(AcceptBlessRs.ext, builder.build());
    }

    /**
     * 获取收藏列表
     *
     * @param handler void
     */
    public void getStoreRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        GetStoreRs.Builder builder = GetStoreRs.newBuilder();
        List<Store> storeList = player.coords;
        for (Store store : storeList) {
            builder.addStore(PbHelper.createStorePb(store));
        }
        handler.sendMsgToPlayer(GetStoreRs.ext, builder.build());
    }

    /**
     * 添加收藏
     *
     * @param req
     * @param handler void
     */
    public void recordStoreRq(RecordStoreRq req, ClientHandler handler) {
        int pos = req.getPos();
        int enemy = req.getEnemy();
        int friend = req.getFriend();
        int isMine = req.getIsMine();
        int type = req.getType();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        RecordStoreRs.Builder builder = RecordStoreRs.newBuilder();
        List<Store> storeList = player.coords;
        Store store = new Store();
        store.setPos(pos);
        store.setType(type);
        store.setEnemy(enemy);
        store.setFriend(friend);
        store.setIsMine(isMine);
        if (type == 1) {
            Player friendPlayer = worldDataManager.getPosData(pos);
            if (friendPlayer != null) {
                Lord lord = friendPlayer.lord;
                Man man = new Man(lord.getLordId(), lord.getSex(), lord.getNick(), lord.getPortrait(), lord.getLevel());
                store.setMan(man);
            } else {
                Lord lord = player.lord;
                Man man = new Man(lord.getLordId(), lord.getSex(), lord.getNick(), lord.getPortrait(), lord.getLevel());
                store.setMan(man);
            }
        } else {
            int mineId = RandomHelper.randomInSize(5) + 1;
            int mineLv = RandomHelper.randomInSize(90) + 1;
            Mine mine = new Mine();
            mine.setMineId(mineId);
            mine.setMineLv(mineLv);
            store.setMine(mine);
        }
        storeList.add(store);
        builder.setStore(PbHelper.createStorePb(store));
        handler.sendMsgToPlayer(RecordStoreRs.ext, builder.build());
    }

    /**
     * 编辑保存收藏
     *
     * @param req
     * @param handler void
     */
    public void markStoreRq(MarkStoreRq req, ClientHandler handler) {
        CommonPb.Store store = req.getStore();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        MarkStoreRs.Builder builder = MarkStoreRs.newBuilder();
        List<Store> storeList = player.coords;
        for (Store entity : storeList) {
            if (store.getPos() == entity.getPos()) {
                entity.setMark(store.getMark());
                entity.setFriend(store.getFriend());
                entity.setEnemy(store.getEnemy());
            }
        }
        handler.sendMsgToPlayer(MarkStoreRs.ext, builder.build());
    }

    /**
     * 删除收藏
     *
     * @param req
     * @param handler void
     */
    public void delStoreRq(DelStoreRq req, ClientHandler handler) {
        int pos = req.getPos();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        DelStoreRs.Builder builder = DelStoreRs.newBuilder();
        List<Store> storeList = player.coords;
        Iterator<Store> it = storeList.iterator();
        while (it.hasNext()) {
            Store next = it.next();
            if (next.getPos() == pos) {
                it.remove();
                break;
            }
        }
        handler.sendMsgToPlayer(DelStoreRs.ext, builder.build());
    }

    /**
     * 增加祝福
     *
     * @param player
     * @param friendId
     * @param now
     * @return boolean
     */
    private boolean addBless(Player player, long friendId, int now) {
        Map<Long, Bless> blessMap = player.blesses;
        Iterator<Bless> it = blessMap.values().iterator();
        int blessCount = 0;
        while (it.hasNext()) {
            Bless next = it.next();
            if (next.getBlessTime() != now || smallIdManager.isSmallId(next.getLordId())) {
                //it.remove();
                continue;
            }
            blessCount++;
        }
        if (blessCount >= 10) {
            return false;
        }
        Bless bless = blessMap.get(friendId);
        if (bless == null) {
            bless = new Bless(friendId, now);
            blessMap.put(friendId, bless);
            return true;
        } else {
            if (bless.getBlessTime() != now) {
                bless.setState(0);// 祝福
                bless.setBlessTime(now);
                blessMap.put(friendId, bless);
                return true;
            }
        }
        return false;
    }

    /**
     * 获取社交图标新消息提示
     *
     * @param handler
     */
    public void getTipFriendsRq(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        long roleId = player.lord.getLordId();
        int playerLv = player.lord.getLevel();
        int minLv = Math.abs(playerLv - 10);
        int maxLv = playerLv + 10;

        GetTipFriendsRs.Builder builder = GetTipFriendsRs.newBuilder();

        Map<String, Player> playerMap = playerDataManager.getAllOnlinePlayer();

        Iterator<Player> it = playerMap.values().iterator();
        int count = 0;
        while (it.hasNext()) {
            Player next = it.next();
            Lord lord = next.lord;
            if (lord == null) {
                continue;
            }

            if (lord.getLordId() == roleId) {
                continue;
            }
            int level = lord.getLevel();
            if (level >= minLv && level <= maxLv && count < 8) {
                count++;
                Man man = new Man();
                man.setLordId(lord.getLordId());
                man.setNick(lord.getNick());
                man.setIcon(lord.getPortrait());
                builder.addMan(PbHelper.createManPb(man));
            }
        }
        handler.sendMsgToPlayer(GetTipFriendsRs.ext, builder.build());
    }

    /**
     * 一键添加好友
     *
     * @param req
     * @param handler
     */
    public void addTipFriendsRq(AddTipFriendsRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }
        AddTipFriendsRs.Builder builder = AddTipFriendsRs.newBuilder();
        Map<Long, Friend> friendMap = player.friends;

        List<Long> lordList = req.getLordIdList();
        for (Long lordId : lordList) {
            if (friendMap.containsKey(lordId)) {
                continue;
            }
            Player toFriend = playerDataManager.getPlayer(lordId);
            if (toFriend == null) {
                continue;
            }
            playerDataManager.sendNormalMail(toFriend, MailType.MOLD_FRIEND_ADD, TimeHelper.getCurrentSecond(), player.lord.getNick());
            Friend friend = new Friend(lordId, 0, 0);
            friendMap.put(lordId, friend);

            try {
                playerDataManager.synFriendlinessToPlayer(toFriend, player);
            } catch (Exception e) {
                LogUtil.error(String.format("syn friendliness error [%s-%s]", toFriend.roleId, player.roleId), e);
            }
        }
        handler.sendMsgToPlayer(AddTipFriendsRs.ext, builder.build());
    }

    /**
     * 增加好友度
     *
     * @param player
     * @param friendId
     * @param type
     * @param handler
     */
    public void addFriendliness(Player player, long friendId, int type, int count, ClientHandler handler) {
        Map<Long, Friend> friendMap = player.friends;
        Friend friend = friendMap.get(friendId);
        if (friend == null) {
            return;
        }

        Player fPlayer = playerDataManager.getPlayer(friendId);
        Lord lord = fPlayer.lord;
        if (lord == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_LORD);
            return;
        }

        if (count < 0) {
            return;
        }

        //校验双方是否互为好友
        if (!playerDataManager.checkMutualFriend(player.roleId, friendId)) {
            return;
        }

        if (type == 1) {
            //祝福增加友好度
            int currentDay = TimeHelper.getCurrentDay();
            Map<Long, Friendliness> blessFriendlinesses = player.getBlessFriendlinesses();
            if (!blessFriendlinesses.isEmpty()) {
                Friendliness friendliness = blessFriendlinesses.get(friendId);
                if (friendliness != null && friendliness.getCreateTime() == currentDay) {
                    //祝福好友，好友度当日只加1
                    return;
                }
            }
        }

        Friend ff = fPlayer.friends.get(player.roleId);

        StaticSystem staticSystem = staticIniDataMgr.getSystemMap().get(SystemId.FRIENDLINESS_MAX);
        if (staticSystem == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Map<Integer, StaticFriend> friendAddMap = staticFriendDataMgr.getFriendAddMap();
        if (friendAddMap.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        StaticFriend staticFriend = friendAddMap.get(type);
        if (staticFriend == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        int friendlinessMax = Integer.valueOf(staticSystem.getValue());

        int friendliness = friend.getFriendliness() + staticFriend.getFriendAdd() * count;
        int ffFriendliness = ff.getFriendliness() + staticFriend.getFriendAdd() * count;

        if (friendliness > friendlinessMax || ffFriendliness > friendlinessMax) {
            //好友度已达上限,则当前好友度为上限值
            friendliness = friendlinessMax;
            ffFriendliness = friendlinessMax;

        }

        friend.setFriendliness(friendliness);
        ff.setFriendliness(ffFriendliness);

        if (type == 1) {
            //祝福记录好友增加友好度记录
            player.getBlessFriendlinesses().put(friendId, new Friendliness(friendId, 1, TimeHelper.getCurrentDay()));
        }


        try {
            playerDataManager.synFriendlinessToPlayer(player, fPlayer);
        } catch (Exception e) {
            LogUtil.error(String.format("syn friendliness error [%s-%s]", fPlayer.roleId, player.roleId), e);
        }

    }

    /**
     * 赠送好友道具
     *
     * @param req
     * @param handler
     */
    public void friendGiveProp(GamePb6.FriendGivePropRq req, ClientHandler handler) {
        int type = req.getType();
        int propId = req.getPropId();
        int count = req.getCount();
        long friendId = req.getFriendId();

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player == null) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_NOT_EXIST);
            return;
        }

        Player fPlayer = playerDataManager.getPlayer(friendId);
        if (fPlayer == null) {
            handler.sendErrorMsgToPlayer(GameError.FRIEND_NOT_EXIST);
            return;
        }

        //检查双方是否互为好友
        if (!playerDataManager.checkMutualFriend(player.roleId, friendId)) {
            handler.sendErrorMsgToPlayer(GameError.NO_MUTUAL_FRIEND);
            return;
        }

        //判断双方友好度
        Friend friend = player.friends.get(friendId);
        StaticSystem staticSystem = staticIniDataMgr.getSystemConstantById(SystemId.CAN_GIVE_PROP_FRIENDLINESS_MAX);
        if (staticSystem == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (friend.getFriendliness() < Integer.valueOf(staticSystem.getValue())) {
            handler.sendErrorMsgToPlayer(GameError.FRIENDLINESS_NOT_ENOUGH);
            return;
        }

        //检查双方等级是否满足
        StaticSystem giveLvLimit = staticIniDataMgr.getSystemConstantById(SystemId.FRIEND_GIVE_PROP_LV_LIMIT);
        if (giveLvLimit == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Integer lvLimit = Integer.valueOf(giveLvLimit.getValue());
        if (player.lord.getLevel() < lvLimit || fPlayer.lord.getLevel() < lvLimit) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }


        /**
         * 检查赠送物品是否在赠送范围内
         */
        GiveProp giveProp = new GiveProp(type, propId);
        boolean enableGiveFlag = staticFriendGiftDataMgr.checkEnableGiveByFriendliness(giveProp, friend.getFriendliness());
        if (!enableGiveFlag) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //检查赠送道具的个数是否符合配置
        boolean checkGiveCount = staticFriendGiftDataMgr.checkGiveCount(giveProp, count);
        if (!checkGiveCount) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        //检查好友获取该道具的个数是否已达上限
        int currentMonthGetPropCount = playerDataManager.getCurrentMonthGetPropCount(fPlayer, type, propId);
        boolean checkFriendReceivePropMaxCount = staticFriendGiftDataMgr.checkFriendReceivePropMaxCount(giveProp, currentMonthGetPropCount);
        if (!checkFriendReceivePropMaxCount) {
            handler.sendErrorMsgToPlayer(GameError.GET_FRIEND_GIVE_PROP_NUM_MAX);
            return;
        }

        /**
         * 检查玩家赠送的物品道具是否足够
         */
        boolean propIsEnougth = playerDataManager.checkPropIsEnougth(player, type, propId, count);
        if (!propIsEnougth) {
            handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
            return;
        }

        Map<Long, FriendGive> friendGiveMap = player.getGiveMap();
        //本月好友赠送次数
        int curMonthFriendCount = playerDataManager.getCurMonthFriendCount(player, friendId);
        //本月好友总赠送次数
        int curMonthTotalCount = getCurMonthTotalCount(player);

        /**
         * 校验好友之间的赠送次数以及玩家当月累计赠送次数
         */
        StaticSystem friendMonthGiveCount = staticIniDataMgr.getSystemConstantById(SystemId.FRIEND_MONTH_GIVE_COUNT);
        if (friendMonthGiveCount == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (curMonthFriendCount >= Integer.valueOf(friendMonthGiveCount.getValue())) {
            handler.sendErrorMsgToPlayer(GameError.FRIEND_CUR_MONTH_GIVE_MAX);
            return;
        }

        StaticSystem friendMonthGiveMaxCount = staticIniDataMgr.getSystemConstantById(SystemId.FRIEND_MONTH_GIVE_MAX_COUNT);
        if (friendMonthGiveMaxCount == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (curMonthTotalCount >= Integer.valueOf(friendMonthGiveMaxCount.getValue())) {
            handler.sendErrorMsgToPlayer(GameError.PLAYER_CUR_MONTH_GIVE_TOTAL_MAX);
            return;
        }

        /**
         * 扣减玩家道具
         */
        CommonPb.Atom2 atom2 = playerDataManager.subProp(player, type, propId, count, AwardFrom.FRIEND_GIVE);

        FriendGive friendGive = new FriendGive(friendId, curMonthFriendCount + 1, System.currentTimeMillis());
        friendGiveMap.put(friendId, friendGive);

        /**
         * 给好友增加获赠道具信息
         */
        playerDataManager.addGetGivePropList(fPlayer, type, propId, count, System.currentTimeMillis());

        //通过邮件发送道具给好友
        List<CommonPb.Award> awards = new ArrayList<CommonPb.Award>();
        awards.add(PbHelper.createAwardPb(type, propId, count));
        playerDataManager.sendAttachMail(AwardFrom.FRIEND_GIVE, fPlayer, awards, MailType.FRIEND_GIVE, TimeHelper.getCurrentSecond(), player.lord.getNick());

        GamePb6.FriendGivePropRs.Builder builder = GamePb6.FriendGivePropRs.newBuilder();
        builder.setAtom2(atom2);
        handler.sendMsgToPlayer(GamePb6.FriendGivePropRs.ext, builder.build());
    }

    /**
     * 获取玩家给所有好友当月赠送的总次数
     *
     * @param player
     * @return
     */
    private int getCurMonthTotalCount(Player player) {
        int curMonthTotalCount = 0;
        Map<Long, FriendGive> friendGiveMap = player.getGiveMap();
        if (friendGiveMap.isEmpty()) {
            return curMonthTotalCount;
        }

        Iterator<FriendGive> it = friendGiveMap.values().iterator();
        while (it.hasNext()) {
            FriendGive next = it.next();
            if (TimeHelper.isSameMonth(next.getGiveTime())) {
                curMonthTotalCount += next.getCount();
            } else {
                //赠送次数每月1日零点清零
                next.setCount(0);
            }
        }
        return curMonthTotalCount;
    }


    /**
     * 设置玩家好友之间的友好度
     *
     * @param player         玩家
     * @param friendNickName 玩家好友昵称
     * @param count          友好度
     */
    public void setPlayerFriendliness(Player player, String friendNickName, Integer count) {
        Player fPlayer = playerDataManager.getPlayer(friendNickName);

        if (fPlayer == null) {
            return;
        }

        if (!playerDataManager.checkMutualFriend(player.roleId, fPlayer.roleId)) {
            return;
        }

        Map<Long, Friend> friends = player.friends;
        Friend friend = friends.get(fPlayer.roleId);
        friend.setFriendliness(count);
        fPlayer.friends.get(player.roleId).setFriendliness(count);
    }


}
