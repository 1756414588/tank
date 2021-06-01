package com.game.service;

import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticFunctionPlanDataMgr;
import com.game.dataMgr.StaticSecretWeaponDataMgr;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.p.SecretWeapon;
import com.game.domain.p.SecretWeaponBar;
import com.game.domain.s.StaticSecretWeapon;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb6;
import com.game.util.LogLordHelper;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: SecretWeaponService
 * @Description: 秘密武器
 * @date 2017-11-13 18:53
 */
@Service
public class SecretWeaponService {

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private StaticSecretWeaponDataMgr staticSecretWeaponDataMgr;

    @Autowired
    private StaticFunctionPlanDataMgr staticFunctionPlanDataMgr;

    @Autowired
    private ChatService chatService;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;


    /**
     * 获取秘密武器信息
     *
     * @param req
     * @param handler
     */
    public void getSecretWeaponInfo(GamePb6.GetSecretWeaponInfoRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isSecretWeaponOpen()) {
            handler.sendErrorMsgToPlayer(GameError.FUNCTION_NO_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //检测并初始化秘密武器
        checkLevelUp(player);

        GamePb6.GetSecretWeaponInfoRs.Builder builder = GamePb6.GetSecretWeaponInfoRs.newBuilder();
        for (Map.Entry<Integer, SecretWeapon> entry : player.secretWeaponMap.entrySet()) {
            builder.addWeapon(PbHelper.createSecretWeapon(entry.getValue()));
        }
        handler.sendMsgToPlayer(GamePb6.GetSecretWeaponInfoRs.ext, builder.build());
    }

    /**
     * 锁定某个技能栏，防止洗练时将需要的属性洗掉
     *
     * @param req
     * @param handler
     */
    public void lockWeaponBar4Study(GamePb6.LockedWeaponBarRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isSecretWeaponOpen()) {
            handler.sendErrorMsgToPlayer(GameError.FUNCTION_NO_OPEN);
            return;
        }

        int weaponId = req.getWeaponId();
        int barIdx = req.getBarIdx();
        boolean locked = req.getLock();
        if (weaponId < 1 || barIdx < 0) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        StaticSecretWeapon data = staticSecretWeaponDataMgr.getSecretWeapon(weaponId);
        if (data == null || data.getSknMax() <= barIdx) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        SecretWeapon weapon = player.secretWeaponMap.get(weaponId);
        if (weapon == null || weapon.getBars().size() <= barIdx) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        SecretWeaponBar bar = weapon.getBars().get(barIdx);
        bar.setLock(locked);
        GamePb6.LockedWeaponBarRs.Builder builder = GamePb6.LockedWeaponBarRs.newBuilder();
        builder.setWeapon(PbHelper.createSecretWeapon(weapon));
        handler.sendMsgToPlayer(GamePb6.LockedWeaponBarRs.ext, builder.build());
    }

    /**
     * 解锁技能栏,栏位
     *
     * @param req
     * @param handler
     */
    public void unlockWeaponBar(GamePb6.UnlockWeaponBarRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isSecretWeaponOpen()) {
            handler.sendErrorMsgToPlayer(GameError.FUNCTION_NO_OPEN);
            return;
        }

        int weaponId = req.getWeaponId();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        SecretWeapon weapon = player.secretWeaponMap.get(weaponId);
        if (weapon == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticSecretWeapon data = staticSecretWeaponDataMgr.getSecretWeapon(weaponId);
        //技能洗练权重列表
        List<List<Integer>> skillWeight = data != null ? staticSecretWeaponDataMgr.getStudyWeight(data.getId()) : null;
        List<Integer> unLockCost = data != null ? data.getUnlockCost() : null;
        if (skillWeight == null || unLockCost == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //技能栏已经开启满了
        List<SecretWeaponBar> bars = weapon.getBars();
        if (bars.size() >= data.getSknMax() || bars.size() >= unLockCost.size()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        //解锁金币不足，或者配置文件错误
        int goldCost = unLockCost.get(weapon.getBars().size());
        if (goldCost < 0 || player.lord.getGold() < goldCost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        //扣除金币
        if (goldCost > 0) {
            playerDataManager.subGold(player, goldCost, AwardFrom.SECRET_WEAPON_UNLOCK);
        }

        //获得新的技能栏
        List<Integer> skill = RandomHelper.getRandomByWeight(skillWeight, 1);
        SecretWeaponBar bar = new SecretWeaponBar(skill.get(0));
        weapon.getBars().add(bar);
        if (weapon.getBars().size() >= data.getSknMax()) {
            //解锁下一个秘密武器
            List<StaticSecretWeapon> openList = staticSecretWeaponDataMgr.getOpenSecretWeapon(data);
            if (openList != null && !openList.isEmpty()) {
                for (StaticSecretWeapon openData : openList) {
                    SecretWeapon openWeapon = player.secretWeaponMap.get(openData.getId());
                    if (openWeapon == null) {
                        player.secretWeaponMap.put(openData.getId(), openWeapon = new SecretWeapon(openData.getId()));
                        chatService.sendWorldChat(chatService.createSysChat(SysChatId.SecretWeapon, player.lord.getNick(), String.valueOf(openData.getId())));
                    }
                }
            }
        }

        GamePb6.UnlockWeaponBarRs.Builder builder = GamePb6.UnlockWeaponBarRs.newBuilder();
        builder.setWeapon(PbHelper.createSecretWeapon(weapon));
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb6.UnlockWeaponBarRs.ext, builder.build());
    }

    /**
     * 技能学习(洗练)
     *
     * @param req
     * @param handler
     */
    public void studyWeaponSkill(GamePb6.StudyWeaponSkillRq req, ClientHandler handler) {
        if (!staticFunctionPlanDataMgr.isSecretWeaponOpen()) {
            handler.sendErrorMsgToPlayer(GameError.FUNCTION_NO_OPEN);
            return;
        }

        int weaponId = req.getWeaponId();
        if (weaponId < 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        SecretWeapon weapon = player.secretWeaponMap.get(weaponId);
        if (weapon == null) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        //秘密武器没配置
        StaticSecretWeapon data = staticSecretWeaponDataMgr.getSecretWeapon(weaponId);
        List<List<Integer>> skillWeight = data != null ? staticSecretWeaponDataMgr.getStudyWeight(data.getId()) : null;
        if (skillWeight == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }


        //获取锁定条数
        List<SecretWeaponBar> bars = weapon.getBars();
        int lockCount = 0;
        for (SecretWeaponBar bar : bars) {
            if (bar.isLock()) lockCount++;
        }

        //技能栏全部被锁定或者锁定条目数超过配置的可锁定数目
        int lockIdx = lockCount - 1;
        if (lockCount >= bars.size() || lockIdx >= data.getStudyLockCost().size()) {
            handler.sendErrorMsgToPlayer(GameError.SECRET_WEAPON_STUDY_LOCK_MAX);
            return;
        }

        int lockGoldCost = lockCount > 0 ? data.getStudyLockCost().get(lockIdx) : 0;
        if (lockGoldCost > 0 && player.lord.getLordId() < lockGoldCost) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        List<Integer> propList = data.getStudyProp();
        if (propList == null || propList.size() != 2) {
            handler.sendErrorMsgToPlayer(GameError.STATIC_DATA_ERROR);
            return;
        }
        int propId = propList.get(0);
        int costCount = propList.get(1);

        GamePb6.StudyWeaponSkillRs.Builder builder = GamePb6.StudyWeaponSkillRs.newBuilder();
        if (playerDataManager.checkPropIsEnougth(player, AwardType.PROP, propId, costCount)) {
            CommonPb.Atom2 atom = playerDataManager.subProp(player, AwardType.PROP, propId, costCount, AwardFrom.SECRET_WEAPON_STUDY);
            builder.setAtom2(atom);
            if (lockGoldCost > 0) {
                playerDataManager.subGold(player, lockGoldCost, AwardFrom.SECRET_WEAPON_STUDY);
            }
            LogLordHelper.logSecretWeaponStudy(AwardFrom.SECRET_WEAPON_STUDY, player, lockCount, lockGoldCost, propId, costCount);
        } else {
            int goldCost = lockGoldCost + data.getStudyCost();
            if (player.lord.getGold() < goldCost) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            playerDataManager.subGold(player, goldCost, AwardFrom.SECRET_WEAPON_STUDY);
            LogLordHelper.logSecretWeaponStudy(AwardFrom.SECRET_WEAPON_STUDY, player, lockCount, goldCost, 0, 0);
        }

        //洗练
        for (SecretWeaponBar bar : bars) {
            if (!bar.isLock()) {
                List<Integer> skill = RandomHelper.getRandomByWeight(skillWeight, 1);
                bar.setSid(skill.get(0));
            }
        }

        builder.setWeapon(PbHelper.createSecretWeapon(weapon));
        builder.setGold(player.lord.getGold());
        handler.sendMsgToPlayer(GamePb6.StudyWeaponSkillRs.ext, builder.build());

        //秘密武器洗练次数活动
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_SECRET_STUDY_COUNT);
        if (activity != null) {
            List<Long> statusList = activity.getStatusList();
            Long studyCount = statusList.get(0);
            statusList.set(0, studyCount != null ? studyCount + 1L : 1L);
        }
    }

    /**
     * 等级达到时初始化秘密武器
     *
     * @param player
     */
    public void checkLevelUp(Player player) {
        if (staticFunctionPlanDataMgr.isSecretWeaponOpen() &&
                player.lord.getLevel() >= Constant.SECRET_WEAPON_OPEN_LEVEL &&
                player.secretWeaponMap.isEmpty()) {
            StaticSecretWeapon defualtIni = staticSecretWeaponDataMgr.getPlayerFunctionOpenDefault();
            if (defualtIni != null) {
                player.secretWeaponMap.put(defualtIni.getId(), new SecretWeapon(defualtIni.getId()));
            }
        }
    }

}
