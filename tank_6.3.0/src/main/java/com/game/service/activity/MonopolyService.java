package com.game.service.activity;

import com.game.constant.ActConst.ActMonopolyConst;
import com.game.constant.*;
import com.game.dataMgr.StaticActivityDataMgr;
import com.game.dataMgr.StaticPropDataMgr;
import com.game.dataMgr.activity.StaticActMonopolyDataMgr;
import com.game.domain.ActivityBase;
import com.game.domain.Player;
import com.game.domain.p.Activity;
import com.game.domain.p.Prop;
import com.game.domain.s.StaticActMonopoly;
import com.game.domain.s.StaticActMonopolyEvt;
import com.game.domain.s.StaticActMonopolyEvtBuy;
import com.game.domain.s.StaticActMonopolyEvtDlg;
import com.game.manager.ActivityDataManager;
import com.game.manager.PlayerDataManager;
import com.game.message.handler.ClientHandler;
import com.game.pb.CommonPb;
import com.game.pb.GamePb5.*;
import com.game.service.PropService;
import com.game.util.LogLordHelper;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;
import com.game.util.TimeHelper;
import org.apache.commons.lang3.RandomUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: MonopolyService
 * @Description: 大富翁
 * statusList:[0-22) 玩家格子信息(每日清空)
 * statusMap: KEY: 0-玩家当前的位置, 1-骰子连续丢中空事件的次数(每日清空), 2-当前购买ID
 * saveMap: KEY: <0 负数表示已经领取过的跑圈宝箱奖励, 0-玩家累计完成的圈数, 1-玩家的能量(活动内不清空), 2-玩家最后一次领取免费精力时间(0-活动刚开启，玩家不能领取免费精力，需要等一个CD周期)
 * @date 2017-11-28 14:58
 */
@Service
public class MonopolyService {

    @Autowired
    private StaticActMonopolyDataMgr staticActMonopolyDataMgr;

    @Autowired
    private StaticActivityDataMgr staticActivityDataMgr;

    @Autowired
    private StaticPropDataMgr staticPropDataMgr;

    @Autowired
    private ActivityDataManager activityDataManager;

    @Autowired
    private PlayerDataManager playerDataManager;

    @Autowired
    private PropService propService;

    /**
     * 获取玩家
     *
     * @param req
     * @param handler
     */
    public void getMonopolyInfo(GetMonopolyInfoRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }
        int activityId = activityBase.getActivityId();
        StaticActMonopoly data = staticActMonopolyDataMgr.getStaticActMonopoly(activityId);
        if (data == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //初始化数据
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        
        //刷新每日记录数据
        activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        
        List<Long> statusList = activity.getStatusList();
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        
        //活动开启时给玩家100点精力
        Integer drawFreeEnergySec = saveMap.get(ActMonopolyConst.SAVE_MAP_DRAW_FREE_ENERGY);//最后领取免费精力时间 0表示活动刚开启 还没领取过
        Integer pos = statusMap.get(ActMonopolyConst.STATUS_MAP_POS);
        boolean notIni = statusList.get(0) == 0 && pos == null;//棋子是否在初始状态
        if (notIni || (pos != null && pos >= ActMonopolyConst.GRID_SIZE)) {//棋子处于初始状态或已经走完一圈
            StaticActMonopolyEvt emptyData = staticActMonopolyDataMgr.getSpecialEvt(activityId, ActMonopolyConst.EVT_EMPTY);
            StaticActMonopolyEvt finishData = staticActMonopolyDataMgr.getSpecialEvt(activityId, ActMonopolyConst.EVT_FINISH);
            if (emptyData == null || finishData == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            //刷新格子
            List<Integer> grids = refreshGrid(emptyData, finishData, activityId);
            LogUtil.info("刷新格子 "+String.format("lordId :%d, nick :%s, activityId :%d, grids :%s", player.roleId, player.lord.getNick(), activityId, Arrays.toString(grids.toArray())));
            for (int i = 0; i < grids.size(); i++) {
                statusList.set(i, grids.get(i).longValue());
            }
            //初始化玩家位置
            statusMap.put(ActMonopolyConst.STATUS_MAP_POS, pos = 0);
            //清除连续丢骰子为空事件的记录
            statusMap.put(ActMonopolyConst.STATUS_MAP_EMPTY_CONT, 0);
        }

        //活动刚开启时给予100精力，且不能领取免费精力
        Integer energy = saveMap.get(ActMonopolyConst.SAVE_MAP_ENERGY);
        if (energy == null) {
            int startSec = (int) (activityBase.getBeginTime().getTime() / 1000);
            saveMap.put(ActMonopolyConst.SAVE_MAP_DRAW_FREE_ENERGY, drawFreeEnergySec = startSec);
            saveMap.put(ActMonopolyConst.SAVE_MAP_ENERGY, energy = data.getFreeEnergy());
        }

        GetMonopolyInfoRs.Builder builder = GetMonopolyInfoRs.newBuilder();
        //格子信息
        for (Long v : statusList) {
            builder.addEvent(v.intValue());
        }
        //格子中的位置
        builder.setPos(statusMap.get(ActMonopolyConst.STATUS_MAP_POS));
        //已经完成的回合
        Integer finishRound = saveMap.get(ActMonopolyConst.SAVE_MAP_FINISH_COUNT);
        builder.setFinishRound(finishRound != null ? finishRound : 0);
        builder.setEnergy(energy);
        builder.setDrawFreeEnergySec(drawFreeEnergySec);
        //已经领取的宝箱ID
        for (Map.Entry<Integer, Integer> entry : saveMap.entrySet()) {
            if (entry.getKey() < 0) {
                builder.addDrawRound(Math.abs(entry.getKey()));
            }
        }

        handler.sendMsgToPlayer(GetMonopolyInfoRs.ext, builder.build());
    }


    /**
     * 刷新格子<br>
     *
     * @param evts       事件列表
     * @param emptyData  空事件对象
     * @param finishData 游戏完成事件对象
     * @return
     */
    private List<Integer> refreshGrid(StaticActMonopolyEvt emptyData, StaticActMonopolyEvt finishData, int activityId) {
        List<Integer> grids = new ArrayList<>(ActMonopolyConst.GRID_SIZE);
        for (int i = 0; i < ActMonopolyConst.GRID_SIZE; i++) {
            grids.add(0);
        }


        //1)	1号/25号格子必定为起/终点（start）；
        grids.set(0, finishData.getId());

        //2)	2-5号格子中必定出现1格为“遇到战斗”（雪人图标）事件；
        int gridIdx = RandomUtils.nextInt(1, 5);
        StaticActMonopolyEvt fightEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.FIGHT);
        grids.set(gridIdx, fightEvt.getId());

        //3)	6号格子必定为“神秘事件”（问号图标）；
        StaticActMonopolyEvt mysteryEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.MYSTERY);
        grids.set(5, mysteryEvt.getId());

        //4)	7-12号格子中必定出现1格为“遇到战斗”事件；
        gridIdx = RandomUtils.nextInt(6, 12);
        fightEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.FIGHT);
        grids.set(gridIdx, fightEvt.getId());

        //5)	13号格子必定为“魔法结界”（六芒星图标）；
        StaticActMonopolyEvt magicEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.MAGIC);
        grids.set(12, magicEvt.getId());

        //6)	14-17号格子中必定出现1格为“遇到战斗”事件；
        gridIdx = RandomUtils.nextInt(13, 17);
        fightEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.FIGHT);
        grids.set(gridIdx, fightEvt.getId());

        //7)	18号格子必定为“爱心帐篷”（帐篷图标）；
        StaticActMonopolyEvt tentEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.TENT);
        grids.set(17, tentEvt.getId());

        //8)	19-23号格子中必定出现1格为“遇到战斗”事件；
        gridIdx = RandomUtils.nextInt(18, 23);
        fightEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.FIGHT);
        grids.set(gridIdx, fightEvt.getId());

        //9)	24号格子必定为“金币事件”（金币图标）；
        StaticActMonopolyEvt goldEvt = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_DLG, ActMonopolyConst.EvtDlg.GOLD);
        grids.set(23, goldEvt.getId());

        //10)	7-12号格子和19-23号格子各必定出现1格为“购买”事件；
        StaticActMonopolyEvt buyEvt6_12 = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_BUY, ActMonopolyConst.EvtBuy.DEFUALT);
        refreshGridStart2End(grids, 6, 13, 1, buyEvt6_12.getId());
        StaticActMonopolyEvt buyEvt19_12 = staticActMonopolyDataMgr.getEventByType(activityId, ActMonopolyConst.EVT_BUY, ActMonopolyConst.EvtBuy.DEFUALT);
        refreshGridStart2End(grids, 18, 24, 1, buyEvt19_12.getId());

        //补2个空格子
        int emptyEvtId = emptyData.getId();
        refreshGridStart2End(grids, 1, 6, 2, emptyEvtId);
        refreshGridStart2End(grids, 6, 12, 2, emptyEvtId);
        refreshGridStart2End(grids, 12, 18, 2, emptyEvtId);
        refreshGridStart2End(grids, 18, 24, 2, emptyEvtId);

        //剩余的全部随机宝箱事件
        List<StaticActMonopolyEvt> boxEvts = staticActMonopolyDataMgr.getAllBoxEvent(activityId);
        for (int i = 0; i < ActMonopolyConst.GRID_SIZE; i++) {
            Integer eid = grids.get(i);
            if (eid == 0) {
                int size = boxEvts.size();
                if (size == 0) {
                    grids.set(i, emptyEvtId);
                } else {
                    int evtIdx = RandomUtils.nextInt(0, size);
                    StaticActMonopolyEvt evt = boxEvts.remove(evtIdx);
                    grids.set(i, evt.getId());
                }
            }
        }
        return grids;
    }

    /**
     * 刷新一批格子[start, end)
     *
     * @param evts          带权重的事件列表
     * @param grids         总格子信息
     * @param start         刷新起始位置 include
     * @param end           刷新结束位置 exclude
     * @param emptyEvtCount
     */
    private void refreshGridStart2End(List<Integer> grids, int start, int end, int count, int evtId) {
        List<Integer> gridIdxs = new ArrayList<>();
        for (int i = start; i < end; i++) {
            if (grids.get(i) == 0) {
                gridIdxs.add(i);
            }
        }
        for (int i = 0; i < count; i++) {
            if (!gridIdxs.isEmpty()) {
                Integer gridIdx = gridIdxs.remove(RandomHelper.randomInSize(gridIdxs.size()));
                grids.set(gridIdx, evtId);
            }
        }

    }

    /**
     * 投骰子
     *
     * @param req
     * @param handler
     */
    public void throwDiceRq(ThrowDiceRq req, ClientHandler handler) {
        int point = req.getPoint();//方式 0 普通 1-6 意念骰子选择的点数
        if (point < 0 || point > 6) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //活动对应的配置不存在
        StaticActMonopoly data = staticActMonopolyDataMgr.getStaticActMonopoly(activityBase.getActivityId());
        if (data == null || data.getCost() < 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        Map<Integer, Integer> saveMap = activity.getSaveMap();

        //已经完成本轮跑环
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Integer pos = statusMap.get(ActMonopolyConst.STATUS_MAP_POS);
        if (pos == null) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        if (pos >= ActMonopolyConst.GRID_SIZE) {
            handler.sendErrorMsgToPlayer(GameError.ACT_MONOPOLY_GRID_FINISH);
            return;
        }

        //格子信息
        List<Long> statusList = activity.getStatusList();
        //连续投中空格子次数
        Integer emptyCont = statusMap.get(ActMonopolyConst.STATUS_MAP_EMPTY_CONT);
        //完成的圈数
        Integer finishRound = saveMap.get(ActMonopolyConst.SAVE_MAP_FINISH_COUNT);
        //精力
        Integer energy = saveMap.get(ActMonopolyConst.SAVE_MAP_ENERGY);
        //投中的点数
        int dicePoint = 0;
        if (point == 0) {
            //精力不足
            if (energy == null || energy < data.getCost()) {
                handler.sendErrorMsgToPlayer(GameError.ACT_MONOPOLY_ENERGY_NOT_ENOUGH);
                return;
            }
            if (emptyCont != null && emptyCont >= data.getEmptyCont()) {
                //玩家连续3次走空后，第4次必定能走到下个距离自己最近的事件格子上去。
                for (int i = pos + 1; i < statusList.size(); i++) {
                    if (statusList.get(i) > ActMonopolyConst.EVT_FINISH) {
                        dicePoint = i - pos;
                        break;
                    }
                }
                //如果没有找到事件点，或者事件点太遥远则随机一个点
                if (dicePoint > 6 || dicePoint == 0) {
                    dicePoint = RandomHelper.randomInSize(6) + 1;
                }
                emptyCont = 0;
            } else {
                //随机骰子,完成的圈数不一样骰子的概率也不一样
                TreeMap<Integer, List<Integer>> diceMap = data.getDiceProb();
                Map.Entry<Integer, List<Integer>> entry = diceMap.ceilingEntry(finishRound != null ? finishRound : 0);
                if (entry == null) {
                    LogUtil.common(String.format("nick :%s, finish round :%d dict prob, not found", player.lord.getNick(), finishRound));
                    entry = diceMap.lastEntry();
                }
                //随机到的点数
                dicePoint = RandomHelper.getRandomIndex(entry.getValue()) + 1;
                if (statusList.get(pos) == ActMonopolyConst.EVT_EMPTY) {
                    //如果随机到空事件,则记录下连续投空的次数
                    emptyCont = emptyCont != null ? emptyCont + 1 : 1;
                }
            }
        } else {
            //意念骰子不足
            if (!playerDataManager.checkPropIsEnougth(player, AwardType.PROP, PropId.MONOPOLY_FIX_DICE, 1)) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            dicePoint = point;
            emptyCont = 0;
        }

        int newPos = pos + dicePoint;
        StaticActMonopolyEvt evtData = null;
        StaticActMonopolyEvtBuy buyData = null;
        if (newPos < ActMonopolyConst.GRID_SIZE) {//是否已达终点
            int evtId = statusList.get(newPos).intValue();
            evtData = staticActMonopolyDataMgr.getEvent(activity.getActivityId(), evtId);
            if (evtData == null) {
                handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                return;
            }
            if (evtData.getType() == ActMonopolyConst.EVT_BUY) {//触发购买事件
                //打折出售类商品
                List<StaticActMonopolyEvtBuy> buys = staticActMonopolyDataMgr.getBuys(evtId);
                if (buys == null) {
                    handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
                    return;
                }
                buyData = RandomHelper.getRandomByProb(buys);
            }
        }


        CommonPb.Atom2 atom2 = null;
        if (point > 0) {
            //扣除意念骰子
            atom2 = playerDataManager.subProp(player, AwardType.PROP, PropId.MONOPOLY_FIX_DICE, 1, AwardFrom.ACT_MOMOPOLY_THROW_DICE);
        } else {
            //扣除精力
            saveMap.put(ActMonopolyConst.SAVE_MAP_ENERGY, energy -= 20);
        }
        //保存新位置
        statusMap.put(ActMonopolyConst.STATUS_MAP_POS, pos = newPos);
        //保存连续空事件次数
        statusMap.put(ActMonopolyConst.STATUS_MAP_EMPTY_CONT, emptyCont);
        //设置商品购买事件中的购买ID
        if (buyData != null) {
            statusMap.put(ActMonopolyConst.STATUS_MAP_BUY_ID, buyData.getId());
        }

        //设置已完成的游戏次数
        if (pos >= ActMonopolyConst.GRID_SIZE) {
            finishRound = finishRound != null ? finishRound + 1 : 1;
            saveMap.put(ActMonopolyConst.SAVE_MAP_FINISH_COUNT, finishRound);
        }

       
        ThrowDiceRs.Builder builder = ThrowDiceRs.newBuilder();
      
        if (evtData != null && evtData.getType() == ActMonopolyConst.EVT_BOX) {  //获得奖励事件
            List<Integer> list = RandomHelper.getRandomByWeight(evtData.getRdAward());
            CommonPb.Award pbAward = playerDataManager.addAwardBackPb(player, list, AwardFrom.ACT_MOMOPOLY_THROW_DICE);
            builder.addAward(pbAward);

            //发送系统广播
            List<CommonPb.Award> awardList = new ArrayList<>();
            awardList.add(pbAward);
            propService.sendJoinActivityMsg(activityBase.getActivityId(), player, awardList);
        }
        builder.setPos(pos);
        builder.setEnergy(energy != null ? energy : 0);
        builder.setFinishRound(finishRound != null ? finishRound : 0);
        if (buyData != null) {
            builder.setBuyId(buyData.getId());
        }
        //剩余意念骰子信息
        if (atom2 != null) {
            builder.setAtom2(atom2);
        }

        //返回客户端
        handler.sendMsgToPlayer(ThrowDiceRs.ext, builder.build());
    }

    /**
     * 购买或者使用精力丹
     *
     * @param req
     * @param handler
     */
    public void buyOrUseEnergy(BuyOrUseEnergyRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        StaticActMonopoly data = staticActMonopolyDataMgr.getStaticActMonopoly(activityBase.getActivityId());
        if (data == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //活动参与等级不足
        Player player = playerDataManager.getPlayer(handler.getRoleId());
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        CommonPb.Atom2 atom2 = null;
        if (req.getIsBuy()) {
            if (player.lord.getGold() < data.getEnergyPrice()) {
                handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
                return;
            }
            //扣除金币
            playerDataManager.subGold(player, data.getEnergyPrice(), AwardFrom.ACT_MOMOPOLY_BUY_ENERGY);
        } else {
            Prop prop = player.props.get(PropId.MONOPOLY_ENERGY);
            if (prop == null || prop.getCount() < 1) {
                handler.sendErrorMsgToPlayer(GameError.PROP_NOT_ENOUGH);
                return;
            }
            atom2 = playerDataManager.subProp(player, AwardType.PROP, PropId.MONOPOLY_ENERGY, 1, AwardFrom.ACT_MOMOPOLY_USE_ENERGY_PROP);
        }


        //给予精力
        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        Integer energy = saveMap.get(ActMonopolyConst.SAVE_MAP_ENERGY);
        energy = energy != null ? energy + data.getAddEnergy() : data.getAddEnergy();
        saveMap.put(ActMonopolyConst.SAVE_MAP_ENERGY, energy);


        BuyOrUseEnergyRs.Builder builder = BuyOrUseEnergyRs.newBuilder();
        builder.setGold(player.lord.getGold());
        builder.setEnergy(energy);
        if (atom2 != null) builder.setAtom2(atom2);
        handler.sendMsgToPlayer(BuyOrUseEnergyRs.ext, builder.build());
    }


    /**
     * 购买打折商品
     *
     * @param req
     * @param handler
     */
    public void buyDiscountGoods(BuyDiscountGoodsRq req, ClientHandler handler) {
        int buyId = req.getBuyId();
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //活动参与等级不足
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        //购买ID 错误
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        if (statusMap.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        Integer saveBuyId = statusMap.get(ActMonopolyConst.STATUS_MAP_BUY_ID);
        if (saveBuyId == null || saveBuyId != buyId) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        //商品购买信息未配置
        StaticActMonopolyEvtBuy buyData = staticActMonopolyDataMgr.getStaticActMonopolyBuy(buyId);
        if (buyData == null || buyData.getBuyGold() < 1 || buyData.getAward() == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //金币不足
        if (player.lord.getGold() < buyData.getBuyGold()) {
            handler.sendErrorMsgToPlayer(GameError.GOLD_NOT_ENOUGH);
            return;
        }

        playerDataManager.subGold(player, buyData.getBuyGold(), AwardFrom.ACT_MOMOPOLY_BUY_GOODS);

        //给予奖励
        List<CommonPb.Award> awards = playerDataManager.addAwardsBackPb(player, buyData.getAward(), AwardFrom.ACT_MOMOPOLY_BUY_GOODS);
        BuyDiscountGoodsRs.Builder builder = BuyDiscountGoodsRs.newBuilder();
        builder.setGold(player.lord.getGold());
        builder.addAllAward(awards);

        handler.sendMsgToPlayer(BuyDiscountGoodsRs.ext, builder.build());
    }

    /**
     * 选择对话内容
     *
     * @param req
     * @param handler
     */
    public void selectDialog(SelectDialogRq req, ClientHandler handler) {
        int dlgId = req.getDlgId();
        if (dlgId < 1) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        //选项ID不存在
        StaticActMonopolyEvtDlg dlgData = staticActMonopolyDataMgr.getStaticActMonopolyEvtDlg(dlgId);
        if (dlgData == null) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        //活动不存在
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //活动参与等级不足
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        List<Long> statusList = activity.getStatusList();
        if (statusList.get(0) == 0) {//客户算未刷新数据
            handler.sendErrorMsgToPlayer(GameError.ACT_NOT_REFRESH_DATA);
            return;
        }
        Map<Integer, Integer> statusMap = activity.getStatusMap();
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        Integer pos = statusMap.get(ActMonopolyConst.STATUS_MAP_POS);
        Integer energy = saveMap.get(ActMonopolyConst.SAVE_MAP_ENERGY);

        //玩家位置在起点
        if (pos == null || pos <= 0 || pos >= ActMonopolyConst.GRID_SIZE) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        //当前位置所在的事件ID
        int eid = statusList.get(pos).intValue();
        if (eid != dlgData.getEid()) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }

        //消耗精力
        int costEnergy = dlgData.getCostEnergy();
        if (costEnergy > 0) {
            if (energy == null || energy < costEnergy) {
                handler.sendErrorMsgToPlayer(GameError.ACT_MONOPOLY_ENERGY_NOT_ENOUGH);
                return;
            }
            saveMap.put(ActMonopolyConst.SAVE_MAP_ENERGY, energy -= costEnergy);
        }


        List<CommonPb.Award> pbAwards = null;
        //获得固定奖励
        if (dlgData.getFixAward() != null && !dlgData.getFixAward().isEmpty()) {
            pbAwards = playerDataManager.addAwardsBackPb(player, dlgData.getFixAward(), AwardFrom.ACT_MOMOPOLY_CHOOSE_DLG);
        }

        //获得随机奖励
        if (dlgData.getRdAward() != null && !dlgData.getRdAward().isEmpty()) {
            List<Integer> list = RandomHelper.getRandomByWeight(dlgData.getRdAward());
            if (pbAwards == null) pbAwards = new ArrayList<>();
            pbAwards.add(playerDataManager.addAwardBackPb(player, list, AwardFrom.ACT_MOMOPOLY_CHOOSE_DLG));

            //发送系统广播
            propService.sendJoinActivityMsg(activityBase.getActivityId(), player, pbAwards);
        }

        SelectDialogRs.Builder builder = SelectDialogRs.newBuilder();
        builder.setEnergy(energy != null ? energy : 0);
        if (pbAwards != null) {
            builder.addAllAward(pbAwards);
        }

        handler.sendMsgToPlayer(SelectDialogRs.ext, builder.build());
    }


    /**
     * 领取游戏完成次数奖励
     *
     * @param req
     * @param handler
     */
    public void drawFinishCountAward(DrawFinishCountAwardRq req, ClientHandler handler) {
        int cnt = req.getCnt();
        if (cnt < 1) {
            handler.sendErrorMsgToPlayer(GameError.PARAM_ERROR);
            return;
        }
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //活动数据未配置
        StaticActMonopoly data = staticActMonopolyDataMgr.getStaticActMonopoly(activityBase.getActivityId());
        List<List<Integer>> list = data != null ? data.getFinishAward().get(cnt) : null;
        if (list == null || list.isEmpty()) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }


        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //活动参与等级不足
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        Integer finishCount = saveMap.get(ActMonopolyConst.SAVE_MAP_FINISH_COUNT);
        if (finishCount == null || finishCount < cnt) {
            handler.sendErrorMsgToPlayer(GameError.INVALID_PARAM);
            return;
        }

        //已经领取该奖励
        if (saveMap.containsKey(-cnt)) {
            handler.sendErrorMsgToPlayer(GameError.ACT_GETAWARD);
            return;
        }

        //记录领取信息
        saveMap.put(-cnt, 1);

        //给予奖励
        List<CommonPb.Award> awards = playerDataManager.addAwardsBackPb(player, list, AwardFrom.ACT_MOMOPOLY_DRAW_FINISH_COUNT);

        //发送系统广播
        propService.sendJoinActivityMsg(activityBase.getActivityId(), player, awards);

        DrawFinishCountAwardRs.Builder builder = DrawFinishCountAwardRs.newBuilder();
        builder.addAllAward(awards);
        handler.sendMsgToPlayer(DrawFinishCountAwardRs.ext, builder.build());
    }

    /**
     * 领取免费精力
     *
     * @param req
     * @param handler
     */
    public void drawFreeEnergyRq(DrawFreeEnergyRq req, ClientHandler handler) {
        ActivityBase activityBase = staticActivityDataMgr.getActivityById(ActivityConst.ACT_MONOPOLY);
        if (activityBase == null) {
            handler.sendErrorMsgToPlayer(GameError.ACTIVITY_NOT_OPEN);
            return;
        }

        //活动对应的配置不存在
        StaticActMonopoly data = staticActMonopolyDataMgr.getStaticActMonopoly(activityBase.getActivityId());
        int freeEnergyGet = data != null ? data.getFreeEnergy() : 0;
        if (freeEnergyGet <= 0) {
            handler.sendErrorMsgToPlayer(GameError.NO_CONFIG);
            return;
        }

        Player player = playerDataManager.getPlayer(handler.getRoleId());
        //活动参与等级不足
        if (player.lord.getLevel() < activityBase.getStaticActivity().getMinLv()) {
            handler.sendErrorMsgToPlayer(GameError.LV_NOT_ENOUGH);
            return;
        }

        Activity activity = activityDataManager.getActivityInfo(player, ActivityConst.ACT_MONOPOLY);
        Map<Integer, Integer> saveMap = activity.getSaveMap();
        Integer drawFreeEnergySec = saveMap.get(ActMonopolyConst.SAVE_MAP_DRAW_FREE_ENERGY);
        int startSec = (int) (activityBase.getBeginTime().getTime() / 1000);
        int curSec = (int) (System.currentTimeMillis() / 1000);
        int periodSec = TimeHelper.HOUR_S * 12;
        int lastFreeSec = getLastFreeEnergyDrawSec(startSec, curSec, periodSec);
        //本次免费精力已经领取
        if (drawFreeEnergySec >= lastFreeSec) {
            handler.sendErrorMsgToPlayer(GameError.ACT_MONOPOLY_FREE_ENERGY_DRAW);
            return;
        }

        //记录领取时间
        saveMap.put(ActMonopolyConst.SAVE_MAP_DRAW_FREE_ENERGY, drawFreeEnergySec = curSec);
        Integer beforeEnergy = saveMap.get(ActMonopolyConst.SAVE_MAP_ENERGY);
        Integer remainEnergy = beforeEnergy != null ? beforeEnergy + freeEnergyGet : freeEnergyGet;
        saveMap.put(ActMonopolyConst.SAVE_MAP_ENERGY, remainEnergy);
        //记录免费领取精力
        LogLordHelper.logDrawActMonopolyFreeEnergy(AwardFrom.ACT_MOMOPOLY_DRAW_FREE_ENERGY, player, beforeEnergy != null ? beforeEnergy : 0, freeEnergyGet, remainEnergy);

        DrawFreeEnergyRs.Builder builder = DrawFreeEnergyRs.newBuilder();
        builder.setDrawFreeEnergySec(drawFreeEnergySec);
        builder.setEnergy(remainEnergy);
        handler.sendMsgToPlayer(DrawFreeEnergyRs.ext, builder.build());
    }

    private int getLastFreeEnergyDrawSec(int startSec, int curSec, int periodSec) {
        return curSec - ((curSec - startSec) % periodSec);
    }

//    public static void main(String[] args) {
//        int curSec = TimeHelper.getCurrentSecond();
//        String startTime = "2017-12-05 00:00:00";
//        Date start = DateHelper.parseDate(startTime);
//        int startSec = (int) (start.getTime() / 1000);
//        int lastFreeDrawSec = getLastFreeDrawSec(startSec, curSec, TimeHelper.HOUR_S * 12);
//        String lastFreeTime = DateHelper.formatDateMiniTime(new Date(lastFreeDrawSec * 1000L));
//        LogUtil.info(String.format("活动开始时间 :%s, 最后一次可以领取免费精力时间 :%s", startTime, lastFreeTime));
//    }

}
