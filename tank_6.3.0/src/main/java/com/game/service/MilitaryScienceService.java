/**
 * @Title: MilitaryScienceService.java
 * @Package com.game.service
 * @author WanYi
 * @date 2016年5月9日 下午5:50:49
 * @version V1.0
 */
package com.game.service;

import com.game.actor.role.PlayerEventService;
import com.game.constant.*;
import com.game.dataMgr.StaticIniDataMgr;
import com.game.dataMgr.StaticMilitaryDataMgr;
import com.game.dataMgr.StaticTankDataMgr;
import com.game.domain.Player;
import com.game.domain.p.MilitaryMaterial;
import com.game.domain.p.MilitaryScience;
import com.game.domain.p.MilitaryScienceGrid;
import com.game.domain.p.Tank;
import com.game.domain.s.*;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.CommonPb.Award;
import com.game.pb.GamePb4.*;
import com.game.pb.GamePb6;
import com.game.util.LogHelper;
import com.game.util.LogUtil;
import com.game.util.PbHelper;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author WanYi
 * @ClassName: MilitaryScienceService
 * @date 2016年5月9日 下午5:50:49
 * 军工科技
 */
@Service
public class MilitaryScienceService {
    @Autowired
    private PlayerDataManager playerDataManager;
    @Autowired
    private PlayerEventService playerEventService;
    @Autowired
    private StaticMilitaryDataMgr staticMilitaryDataMgr;
    @Autowired
    private StaticTankDataMgr staticTankDataMgr;
    @Autowired
    private StaticIniDataMgr staticIniDataMgr;
    @Autowired
    private RewardService rewardService;

    /**
     * 获取军工科技信息 Method: getMilitaryScience
     *
     * @param handler
     * @return void
     * @throws
     */
    public void getMilitaryScience(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        GetMilitaryScienceRs.Builder builder = GetMilitaryScienceRs.newBuilder();

//		if (player.militarySciences.size() == 0) {
        // 初始化军工科技信息
        Collection<Map<Integer, Integer>> c = staticMilitaryDataMgr.getTankIdScieneceIdMap().values();
        for (Map<Integer, Integer> map : c) {
            Iterator<Integer> it = map.values().iterator();
            while (it.hasNext()) {
                int scienceId = it.next();
                int fitTankId = 0;
                int pos = 0;
                // 判断是否效率
                StaticMilitaryDevelopTree tree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(scienceId, 1);
                if (tree.getAttrId() == AttrId.PRODUCT) {
                    fitTankId = tree.getTankId();

                    // 获取效率所在的位置
                    Integer p = staticMilitaryDataMgr.getPosByProductId(scienceId);
                    if (p == null) {
                        System.err.println(scienceId);
                    }
                    pos = staticMilitaryDataMgr.getPosByProductId(scienceId);
                }

                if (!player.militarySciences.containsKey(scienceId)) {
                    MilitaryScience science = new MilitaryScience(scienceId, 0, fitTankId, pos);
                    player.militarySciences.put(scienceId, science);
                }
            }
        }
//		}


        updateDataError(player);

        Iterator<MilitaryScience> it = player.militarySciences.values().iterator();
        while (it.hasNext()) {
            builder.addMilitaryScience(PbHelper.createMilitaryScienecePb(it.next()));
        }

        handler.sendMsgToPlayer(GetMilitaryScienceRs.ext, builder.build());
    }


    /**
     * 兼容军工科技重置错误数据
     * @param player
     */
    private void updateDataError(Player player){

        try {

            Collection<Map<Integer, MilitaryScienceGrid>> c = player.militaryScienceGrids.values();
            Map<Integer, MilitaryScience> militarySciences = player.militarySciences;

            for (Map<Integer, MilitaryScienceGrid> hashMap : c) {
                Iterator<MilitaryScienceGrid> it = hashMap.values().iterator();
                while (it.hasNext()) {
                    MilitaryScienceGrid next = it.next();
                    if (next.getStatus() == MilitaryScienceId.EFFICIENCY ) {
                        MilitaryScience science = militarySciences.get(next.getMilitaryScienceId());
                        if( science != null ){
                            StaticMilitaryDevelopTree tree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(science.getMilitaryScienceId(), 1);
                            if( science.getFitTankId() != tree.getTankId()){
                                science.setFitTankId(tree.getTankId());
                                science.setFitPos(staticMilitaryDataMgr.getPosByProductId(science.getMilitaryScienceId()));
                            }

                        }
                    }
                }
            }

        } catch (Exception e) {
            LogUtil.error(e);
        }

    }

    /**
     * 军工科技升级 Method: upMilitaryScience
     *
     * @param handler
     * @return void
     * @throws
     */
    public void upMilitaryScience(UpMilitaryScienceRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        UpMilitaryScienceRs.Builder builder = UpMilitaryScienceRs.newBuilder();

        // 判断该科技id 的坦克小类型是否激活
        int tankId = staticMilitaryDataMgr.getTankIdByScienceId(req.getMilitaryScienceId());

        // 通过tankId 获取科技信息字典数据
        StaticMilitary staticMilitary = staticMilitaryDataMgr.getStaticMilitaryByTankId(tankId);

        boolean isUnLock = checkIsUnLock(player, staticMilitary);
        if (!isUnLock) {
            // 若没解锁,通知客户端未解锁
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_LOCKED);
            return;
        }

        MilitaryScience science = player.militarySciences.get(req.getMilitaryScienceId());
        if (science == null) {
            // 未初始化军工科技id信息
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_NO_INIT);
            return;
        }
        // 判断等级是否达到上限了
        if (science.getLevel() >= staticMilitaryDataMgr.getMaxScienceLevel(req.getMilitaryScienceId())) {
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_LEVEL_MAX_LIMIT);
            return;
        }

        // 判断资源够不够
        StaticMilitaryDevelopTree staticMiltaryDevelipTree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(science.getMilitaryScienceId(),
                science.getLevel() + 1);

        // 材料
        List<List<Integer>> materials = staticMiltaryDevelipTree.getMaterials();
        for (List<Integer> list : materials) {
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            // 判断材料是否够
            if (!playerDataManager.checkPropIsEnougth(player, type, id, count)) {
                handler.sendErrorMsgToPlayer(GameError.SCIENCE_Military_NOT_ENOUGH);
                return;
            }
        }

        // 扣资源
        for (List<Integer> list : materials) {
            int type = list.get(0);
            int id = list.get(1);
            int count = list.get(2);
            builder.addAtom2(playerDataManager.subProp(player, type, id, count, AwardFrom.UP_MILITARY_SCIENCE));
        }

        // 升级
        science.setLevel(science.getLevel() + 1);
        builder.setMilitaryScienceId(science.getMilitaryScienceId());
        builder.setLevel(science.getLevel());
        handler.sendMsgToPlayer(UpMilitaryScienceRs.ext, builder.build());

        // 记录日志
        LogHelper.logUpMilitaryScience(player.lord, science.getMilitaryScienceId(), science.getLevel());
    }


    /**
     * 重置军工科技
     *
     * @param handler
     */
    public void resetMilitaryScience(GamePb6.ResetMilitaryScienceRq rq, ClientHandler handler) {
        int type = rq.getType();
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        StaticSystem constant = staticIniDataMgr.getSystemConstantById(SystemId.LAB_VIP);

        if (player.lord.getVip() < Integer.valueOf(constant.getValue())) {
            handler.sendErrorMsgToPlayer(GameError.VIP_NOT_ENOUGH);
            return;
        }


        Map<Integer, MilitaryScience> militarySciences = player.militarySciences;

        List<Integer> scienceIds = new ArrayList<>();


        for (Map.Entry<Integer, MilitaryScience> e : militarySciences.entrySet()) {

            MilitaryScience science = e.getValue();

            if (science.getLevel() <= 0) {
                continue;
            }

            // 判断资源够不够
            StaticMilitaryDevelopTree staticMiltaryDevelipTree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(science.getMilitaryScienceId(), science.getLevel());

            if (staticMiltaryDevelipTree != null) {
                StaticTank staticTank = staticTankDataMgr.getStaticTank(staticMiltaryDevelipTree.getTankId());
                if (staticTank.getCanBuild() == 0) {
                    if (type == staticTank.getType()) {
                        scienceIds.add(science.getMilitaryScienceId());
                    }

                } else if (staticTank.getCanBuild() == 1) {
                    if (type == (staticTank.getType() + 4)) {
                        scienceIds.add(science.getMilitaryScienceId());
                    }
                }
            }
        }


        if (scienceIds.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        //返还物品
        Map<Integer, Map<Integer, Integer>> itemMap = new HashMap<>();


        for (Integer scienceId : scienceIds) {
            MilitaryScience militaryScience = player.militarySciences.get(scienceId);

            for (int level = militaryScience.getLevel(); level > 0; level--) {
                StaticMilitaryDevelopTree staticMiltaryDevelipTree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(militaryScience.getMilitaryScienceId(), level);

                List<List<Integer>> materials = staticMiltaryDevelipTree.getMaterials();

                for (List<Integer> list : materials) {

                    int itemType = list.get(0);
                    int itemId = list.get(1);
                    int itemCount = list.get(2);

                    if (!itemMap.containsKey(itemType)) {
                        itemMap.put(itemType, new HashMap<Integer, Integer>());
                    }

                    if (!itemMap.get(itemType).containsKey(itemId)) {
                        itemMap.get(itemType).put(itemId, 0);

                    }
                    itemMap.get(itemType).put(itemId, itemMap.get(itemType).get(itemId) + itemCount);

                }

            }

        }


        if (itemMap == null || itemMap.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }


        GamePb6.ResetMilitaryScienceRs.Builder builder = GamePb6.ResetMilitaryScienceRs.newBuilder();

        List<List<Integer>> add = new ArrayList<>();
        int gold = 0;

        for (int e : itemMap.keySet()) {
            Map<Integer, Integer> e1 = itemMap.get(e);
            for (Map.Entry<Integer, Integer> e2 : e1.entrySet()) {

                List<Integer> itemList = new ArrayList<>();
                itemList.add(e);
                itemList.add(e2.getKey());
                itemList.add(e2.getValue());
                add.add(itemList);
                CommonPb.Award awardPb = PbHelper.createAwardPb(itemList.get(0), itemList.get(1), itemList.get(2));
                builder.addAward(awardPb);

                if (itemList.get(0) == AwardType.MILITARY_MATERIAL) {
                    StaticMilitaryMaterial staticMilitaryMaterial = staticMilitaryDataMgr.getStaticMilitaryMaterial(itemList.get(1));
                    if (staticMilitaryMaterial != null) {
                        gold += Math.ceil((staticMilitaryMaterial.getValueRatio() * itemList.get(2)) / 1000f);
                    }

                }
            }

        }


        if (player.lord.getGold() < gold) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, gold, AwardFrom.RESET_MILITARY_SCIENCE);

        rewardService.addItem(player, AwardFrom.RESET_MILITARY_SCIENCE, add);

        for (Integer scienceId : scienceIds) {
            MilitaryScience militaryScience = player.militarySciences.get(scienceId);
            militaryScience.setLevel(0);
            StaticMilitary staticMilitary = staticMilitaryDataMgr.getStaticMilitaryByTankId(militaryScience.getFitTankId());

            if (militaryScience.getFitTankId() > 0) {
                // 卸载操作
                MilitaryScienceGrid grid = player.militaryScienceGrids.get(militaryScience.getFitTankId()).get(militaryScience.getFitPos());

                int status = staticMilitary.getGridStatus().get(grid.getPos() - 1).get(0);
                if (status == MilitaryScienceId.EFFICIENCY) {
                    grid.setStatus(MilitaryScienceId.EFFICIENCY);
                    grid.setMilitaryScienceId(staticMilitary.getProductScienceId());
                } else {
                    grid.setStatus(MilitaryScienceId.HAVE_UN_LOCK);
                    grid.setMilitaryScienceId(0);
                    militaryScience.setFitTankId(0);
                    militaryScience.setFitPos(0);

                }

                builder.addMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(grid));
            }

        }

        builder.setGold(player.lord.getGold());
        Iterator<MilitaryScience> it = player.militarySciences.values().iterator();
        while (it.hasNext()) {
            builder.addMilitaryScience(PbHelper.createMilitaryScienecePb(it.next()));
        }

        handler.sendMsgToPlayer(GamePb6.ResetMilitaryScienceRs.ext, builder.build());
    }


    /**
     * 判断是否解锁 Method: checkIsUnLock
     *
     * @param player
     * @param staticMilitary
     * @return void
     * @throws
     */
    private boolean checkIsUnLock(Player player, StaticMilitary staticMilitary) {
        // 通过解锁条件判断是否解锁
        if (staticMilitary.getPukCondition() == 0) {
            // 无条件,已解锁
            return true;
        } else {
            // 获取解锁条件
            StaticMilitaryDevelopTree staticMilitaryDevelopTree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(staticMilitary.getPukCondition(), 1);
            List<List<Integer>> requestList = staticMilitaryDevelopTree.getRequire();
            for (List<Integer> list : requestList) {
                int id = list.get(0);
                int level = list.get(1);

                MilitaryScience science = player.militarySciences.get(id);
                if (science == null || science.getLevel() < level) {
                    // 未解锁
                    return false;
                }
            }
            return true;
        }
    }

    /**
     * 获取军工科技格子状态 Method: getMilitaryScienceGrid
     *
     * @param handler
     * @return void
     * @throws
     */
    public void getMilitaryScienceGrid(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());

        GetMilitaryScienceGridRs.Builder builder = GetMilitaryScienceGridRs.newBuilder();

//		if (player.militaryScienceGrids.size() == 0) {
        // 初始化军工科技格子信息
        for (StaticMilitary m : staticMilitaryDataMgr.getMilitartList()) {
            Map<Integer, MilitaryScienceGrid> map = player.militaryScienceGrids.get(m.getTankId());
            if (map == null) {
                map = new HashMap<>();
                player.militaryScienceGrids.put(m.getTankId(), map);
            }
            List<List<Integer>> list = m.getGridStatus();
            for (int i = 0; i < list.size(); i++) {
                int pos = i + 1;
                int status = list.get(i).get(0);
                MilitaryScienceGrid grid = map.get(pos);
                if (grid == null) { // 判断新增的格子
                    int scienceId = 0;
                    if (status == MilitaryScienceId.EFFICIENCY) {
                        scienceId = m.getProductScienceId();
                    }
                    put(player.militaryScienceGrids, new MilitaryScienceGrid(m.getTankId(), pos, status, scienceId));
                } else {
                    if (grid.getStatus() != status && grid.getStatus() == 2 && status == 1) { // 被锁的格子 启用
                        grid.setStatus(1);
                    }

                    if (status == MilitaryScienceId.EFFICIENCY && grid.getMilitaryScienceId() != m.getProductScienceId()) {
                        grid.setMilitaryScienceId(m.getProductScienceId());
                    }
                }
            }
        }
//		}

        Collection<Map<Integer, MilitaryScienceGrid>> c = player.militaryScienceGrids.values();

        for (Map<Integer, MilitaryScienceGrid> hashMap : c) {
            Iterator<MilitaryScienceGrid> it = hashMap.values().iterator();
            while (it.hasNext()) {
                builder.addMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(it.next()));
            }
        }

        handler.sendMsgToPlayer(GetMilitaryScienceGridRs.ext, builder.build());
    }

    /**
     * Method: 将军工科技格子状态加入map中
     *
     * @param militaryScienceGrids
     * @param militaryScienceGrid
     * @return void
     * @throws
     */
    private void put(Map<Integer, Map<Integer, MilitaryScienceGrid>> militaryScienceGrids, MilitaryScienceGrid militaryScienceGrid) {
        Map<Integer, MilitaryScienceGrid> map = militaryScienceGrids.get(militaryScienceGrid.getTankId());
        if (map == null) {
            map = new HashMap<>();
            militaryScienceGrids.put(militaryScienceGrid.getTankId(), map);
        }
        map.put(militaryScienceGrid.getPos(), militaryScienceGrid);
    }

    /**
     * 装配或者卸载军工科技 Method: fitMilitaryScience
     *
     * @param fitMilitaryScienceRq
     * @param handler
     * @return void
     * @throws
     */
    public void fitMilitaryScience(FitMilitaryScienceRq req, ClientHandler handler) {
        FitMilitaryScienceRs.Builder builder = FitMilitaryScienceRs.newBuilder();
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        MilitaryScience science = player.militarySciences.get(req.getMilitaryScienceId());
        // 判断是否有位置(tankId为0表示没有装配)
        if (science.getFitTankId() == 0) {
            // 装配操作
            // 等级为0不可装配
            if (science.getLevel() == 0) {
                handler.sendErrorMsgToPlayer(GameError.SCIENCE_LEVE_CAN_NOT_FIT);
                return;
            }

            StaticMilitaryDevelopTree tree = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(science.getMilitaryScienceId(), science.getLevel());
            StaticMilitary staticMilitary = staticMilitaryDataMgr.getStaticMilitaryByTankId(req.getTankId());

            // 判断能否装配到tankId上(范围)
            if (science.getFitTankId() == req.getTankId() || !isCanFitScope(tree, req.getTankId())) {
                // 不能装载该坦克
                handler.sendErrorMsgToPlayer(GameError.SCIENCE_FIT_SCOPE_IS_NOT_RIGHT);
                return;
            }

            // 判断格子够不够
            if (staticMilitary.getGridStatus().size() < req.getPos()) {
                handler.sendErrorMsgToPlayer(GameError.SCIENCE_FIT_POS_IS_NOT_RIGHT);
                return;
            }

            // 判断格子能不能装载(1未解锁2未开放3效率 都不能装载)
            MilitaryScienceGrid grid = player.militaryScienceGrids.get(req.getTankId()).get(req.getPos());
            if (grid.getStatus() == MilitaryScienceId.LOCK || grid.getStatus() == MilitaryScienceId.UN_OPEN || grid.getStatus() == MilitaryScienceId.EFFICIENCY) {
                handler.sendErrorMsgToPlayer(GameError.SCIENCE_POS_CAN_NOT_FIT);
                return;
            }

            // 若已经占用,需要替换下来
            if (grid.getStatus() == MilitaryScienceId.HAVE_POS) {
                MilitaryScience science2 = player.militarySciences.get(grid.getMilitaryScienceId());
                science2.setFitTankId(0);
                science2.setFitPos(0);
                builder.addMilitaryScience(PbHelper.createMilitaryScienecePb(science2));
            }

            science.setFitTankId(req.getTankId());
            science.setFitPos(req.getPos());
            grid.setStatus(MilitaryScienceId.HAVE_POS);
            grid.setMilitaryScienceId(science.getMilitaryScienceId());
            builder.setMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(grid));
        } else {
            // 卸载操作
            MilitaryScienceGrid grid = player.militaryScienceGrids.get(science.getFitTankId()).get(science.getFitPos());
            grid.setStatus(MilitaryScienceId.HAVE_UN_LOCK);
            grid.setMilitaryScienceId(0);

            science.setFitTankId(0);
            science.setFitPos(0);
            builder.setMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(grid));
        }

        builder.addMilitaryScience(PbHelper.createMilitaryScienecePb(science));

        handler.sendMsgToPlayer(FitMilitaryScienceRs.ext, builder.build());

        //重新计算玩家最强实力
        playerEventService.calcStrongestFormAndFight(player);
    }

    /**
     * 从范围上判断是否可以装配 Method: isCanFit
     *
     * @param scienceId
     * @param tankId
     * @return boolean
     * @throws
     * @Description:
     */
    private boolean isCanFitScope(StaticMilitaryDevelopTree tree, int tankId) {
        List<List<Integer>> list = tree.getScope();
        for (List<Integer> list2 : list) {
            if (list2.get(0) == tankId) {
                return true;
            }
        }
        return false;
    }

    /**
     * Method: militaryRefitTankRq
     *
     * @param extension
     * @param militaryRefitTankHandler
     * @return void
     * @throws
     * @Description: 军工科技改造
     */
    public void militaryRefitTankRq(MilitaryRefitTankRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int tankId = req.getTankId();
        int count = req.getCount();

        // 改造条件判断
        Integer acitveId = staticMilitaryDataMgr.getAcitveId(tankId);
        if (acitveId == null) {
            // 该坦克不能被改造,或者配置改造信息错误
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_RefitTank_NO_CONFIG);
            return;
        }
        if (player.militarySciences.get(acitveId).getLevel() == 0) {
            // 改造未激活
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_RefitTank_UN_ACTIVE);
            return;
        }

        if (count <= 0 || count > 1000) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        StaticMilitary staticMilitary = staticMilitaryDataMgr.getStaticMilitaryByTankId(tankId);
        if (staticMilitary == null) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        int refitBaseTankId = staticMilitary.getMilitaryRefitBaseTankId();
        if (refitBaseTankId == 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        if (!playerDataManager.checkPropIsEnougth(player, AwardType.TANK, refitBaseTankId, count)) {
            handler.sendErrorMsgToPlayer(GameError.TANK_COUNT);
            return;
        }

        // 判断资源够不够
        List<List<Long>> list = staticMilitary.getMilitaryRefitConsume();

        for (List<Long> list2 : list) {
            if (list2.size() > 0) {
                long type = list2.get(0);
                long id = list2.get(1);
                long num = list2.get(2);

                if (!playerDataManager.checkPropIsEnougth(player, (int) type, (int) id, num * count)) {
                    handler.sendErrorMsgToPlayer(GameError.RESOURCE_NOT_ENOUGH);
                    return;
                }
            }
        }

        MilitaryRefitTankRs.Builder builder = MilitaryRefitTankRs.newBuilder();

        // 扣资源
        for (List<Long> list2 : list) {
            if (list2.size() > 0) {
                long type = list2.get(0);
                long id = list2.get(1);
                long num = list2.get(2);
                builder.addAtom2(playerDataManager.subProp(player, (int) type, (int) id, num * count, AwardFrom.MILITARY_REFIT_TANK));
            }
        }

        // 减坦克
        builder.addAtom2(playerDataManager.subProp(player, AwardType.TANK, refitBaseTankId, count, AwardFrom.MILITARY_REFIT_TANK));

        // 坦克改造
        Tank t = playerDataManager.addTank(player, tankId, count, AwardFrom.MILITARY_REFIT_TANK);
        builder.addAtom2(CommonPb.Atom2.newBuilder().setKind(AwardType.TANK).setId(tankId).setCount(t.getCount()).build());

        handler.sendMsgToPlayer(MilitaryRefitTankRs.ext, builder.build());

        // 记录日志
        LogHelper.logMilitaryRefitTank(player.lord, tankId, count);
    }

    /**
     * Method: getMilitaryMaterial
     * 军工材料列表
     *
     * @param getMilitaryMaterialHandler
     * @return void
     * @throws
     */
    public void getMilitaryMaterial(ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        Iterator<MilitaryMaterial> it = player.militaryMaterials.values().iterator();
        GetMilitaryMaterialRs.Builder builder = GetMilitaryMaterialRs.newBuilder();
        while (it.hasNext()) {
            builder.addMilitaryMaterial(PbHelper.createMilitaryMaterialPb(it.next()));
        }
        handler.sendMsgToPlayer(GetMilitaryMaterialRs.ext, builder.build());
    }

    /**
     * Method: CaulMilitaryProduceReduceTime
     *
     * @param player
     * @param tankId
     * @return int
     * @throws
     * @Description: 获取军工科技效率提升生产和改造的时间
     */
    public int caulMilitaryProduceReduceTime(Player player, int tankId) {
        Integer scienceId = staticMilitaryDataMgr.getProductId(tankId);
        if (scienceId == null) {
            return 0;
        }

        MilitaryScience m = player.militarySciences.get(scienceId);
        if (m == null || m.getLevel() == 0) {
            return 0;
        }

        List<List<Integer>> list = staticMilitaryDataMgr.getStaticMilitaryDevelopTree(scienceId, m.getLevel()).getEffect();
        return list.get(0).get(2);
    }

    /**
     * Method: unLockMilitaryGrid
     *
     * @param extension
     * @param unLockMilitaryGridHandler
     * @return void
     * @throws
     * @Description: 解锁科技格子
     */
    public void unLockMilitaryGrid(UnLockMilitaryGridRq req, ClientHandler handler) {
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        int tankId = req.getTankId();

        StaticMilitary staticMilitary = staticMilitaryDataMgr.getStaticMilitaryByTankId(tankId);
        if (staticMilitary == null) {
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_MILITARY_NO_CONFIG);
            return;
        }

        UnLockMilitaryGridRs.Builder builder = UnLockMilitaryGridRs.newBuilder();

        // 获取该tankId 的所有位置信息
        Map<Integer, MilitaryScienceGrid> map = player.militaryScienceGrids.get(tankId);
        boolean flag = false;
        for (int i = 1; i <= map.size(); i++) {
            MilitaryScienceGrid grid = map.get(i);
            if (grid.getStatus() == MilitaryScienceId.LOCK) {
                // 判断是第几个解锁的格子
                Integer index = staticMilitaryDataMgr.getUnLockIndex(tankId, grid.getPos());
                if (index == null) {
                    // 该位置没有配置解锁格子信息
                    handler.sendErrorMsgToPlayer(GameError.SCIENCE_THE_POS_UN_LOCK_NO_CONFIG);
                    return;
                }

                List<List<Integer>> list = staticMilitary.getUnLockConsumeMap().get(index);
                for (List<Integer> list2 : list) {
                    int type = list2.get(1);
                    int id = list2.get(2);
                    int count = list2.get(3);
                    // 判断材料是否够
                    if (!playerDataManager.checkPropIsEnougth(player, type, id, count)) {
                        handler.sendErrorMsgToPlayer(GameError.SCIENCE_UN_LOCK_Material_NOT_ENOUGTH);
                        return;
                    }
                }

                for (List<Integer> list2 : list) {
                    int type = list2.get(1);
                    int id = list2.get(2);
                    int count = list2.get(3);

                    // 扣材料
                    builder.addAtom2(playerDataManager.subProp(player, type, id, count, AwardFrom.UNLOCK_SCIECE_GRID));
                }

                grid.setStatus(MilitaryScienceId.HAVE_UN_LOCK);

                builder.setMilitaryScienceGrid(PbHelper.createMilitaryScieneceGridPb(grid));

                handler.sendMsgToPlayer(UnLockMilitaryGridRs.ext, builder.build());

                // 记录日志
                LogHelper.logUnLockMilitaryGrid(player.lord, tankId, grid.getPos());

                flag = true;
                break;
            }
        }

        if (!flag) {
            // 没有能解锁的格子
            handler.sendErrorMsgToPlayer(GameError.SCIENCE_NO_GRID_NEED_UN_LOCK);
        }
    }

    /**
     * 判断军工是否开启 Method: isBeginMilitary
     *
     * @param level
     * @return boolean
     * @throws
     * @Description:
     */
    public boolean isBeginMilitary(int level) {
        return level >= 30;
    }

    /**
     * 获取好友祝福军工材料奖励 Method: getMilitaryBlessAward
     *
     * @return List<Award>
     * @throws
     * @Description:
     */
    public List<Award> getMilitaryBlessAward(Player player) {
        if (!isBeginMilitary(player.lord.getLevel())) {
            return null;
        }
        StaticMilitaryBless s = staticMilitaryDataMgr.getStaticMilitaryBless();
        List<Award> awards = new ArrayList<>();
        if (s.getWeight() <= 0) {
            return awards;
        }
        if (s.getAwardOne() != null && !s.getAwardOne().isEmpty()) {
            int prob = RandomHelper.randomInSize(s.getWeight());
            int accumulate = 0;
            for (List<Integer> award : s.getAwardOne()) {
                int type = award.get(0);
                int id = award.get(1);
                int count = award.get(2);
                accumulate += award.get(3);
                if (prob < accumulate) {
                    int keyId = playerDataManager.addAward(player, type, id, count, AwardFrom.FRIEND_BLESS);
                    awards.add(PbHelper.createAwardPb(type, id, count, keyId));
                    break;
                }
            }
        }
        return awards;
    }


    /**
     * gm军工科技升级
     *
     * @param player
     * @param scienceId
     * @param level
     */
    public void gmUpMilitaryScience(Player player, int scienceId, int level) {
        MilitaryScience science = player.militarySciences.get(scienceId);
        if (science == null) {
            return;
        }

        // 判断等级是否达到上限了
        if (level >= staticMilitaryDataMgr.getMaxScienceLevel(scienceId)) {
            level = staticMilitaryDataMgr.getMaxScienceLevel(scienceId);
        }
        // 升级
        science.setLevel(level);
    }

    /**
     * gm军工科技升级
     *
     * @param player
     * @param tankId
     */
    public void gm2UpMilitaryScience(Player player, int tankId) {
        Map<Integer, Map<Integer, Integer>> tankIdScieneceIdMap = staticMilitaryDataMgr.getTankIdScieneceIdMap();


        if (tankId == 0) {
            Collection<Map<Integer, Integer>> values = tankIdScieneceIdMap.values();
            for (Map<Integer, Integer> v : values) {

                if (v != null && !v.isEmpty()) {
                    for (Integer scienceId : v.keySet()) {
                        MilitaryScience science = player.militarySciences.get(scienceId);
                        if (science == null) {
                            return;
                        }

                        int level = 100;
                        // 判断等级是否达到上限了
                        if (level >= staticMilitaryDataMgr.getMaxScienceLevel(scienceId)) {
                            level = staticMilitaryDataMgr.getMaxScienceLevel(scienceId);
                        }
                        // 升级
                        science.setLevel(level);
                    }
                }
            }


        } else {
            Map<Integer, Integer> integerIntegerMap = tankIdScieneceIdMap.get(tankId);

            if (integerIntegerMap != null && !integerIntegerMap.isEmpty()) {
                for (Integer scienceId : integerIntegerMap.keySet()) {
                    MilitaryScience science = player.militarySciences.get(scienceId);
                    if (science == null) {
                        return;
                    }

                    int level = 100;
                    // 判断等级是否达到上限了
                    if (level >= staticMilitaryDataMgr.getMaxScienceLevel(scienceId)) {
                        level = staticMilitaryDataMgr.getMaxScienceLevel(scienceId);
                    }
                    // 升级
                    science.setLevel(level);
                }
            }
        }


    }

}
