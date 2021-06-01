package com.game.dataMgr.activity;

import com.game.constant.ActConst.ActMonopolyConst;
import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.BaseDataMgr;
import com.game.domain.s.StaticActMonopoly;
import com.game.domain.s.StaticActMonopolyEvt;
import com.game.domain.s.StaticActMonopolyEvtBuy;
import com.game.domain.s.StaticActMonopolyEvtDlg;
import com.game.util.LogUtil;
import com.game.util.RandomHelper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * @author zhangdh
 * @ClassName: StaticActMonopolyDataMgr
 * @Description: 大富翁(圣诞宝藏)基础数据配置
 * @date 2017-11-30 14:35
 */
@Component
public class StaticActMonopolyDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    //大富翁KEY:活动唯一ID, VALUE:活动配置信息
    private Map<Integer, StaticActMonopoly> monopolyMap = new HashMap<>();

    //大富翁事件列表, KEY0:活动ID, KEY1:事件ID, VALUE:活动事件定义
    private Map<Integer, Map<Integer, StaticActMonopolyEvt>> evtMap = new HashMap<>();

    //大富翁事件列表, KEY0:活动ID, KEY1:事件大类型, KEY2:事件小类型, VALUE:事件定义
    private Map<Integer, Map<Integer, Map<Integer, List<StaticActMonopolyEvt>>>> evtTypeMap = new HashMap<>();

    //大富翁购买, KEY0:事件ID, VALUE: 购买信息
    private Map<Integer, List<StaticActMonopolyEvtBuy>> evtBuyMap = new HashMap<>();

    //KEY:购买ID，VALUE:购买信息
    private Map<Integer, StaticActMonopolyEvtBuy> buyMap = new HashMap<>();

//    //大富翁对话事件对话列表， KEY0:事件ID, KEY1:唯一ID, VALUE:对话信息
//    private Map<Integer, Map<Integer, StaticActMonopolyEvtDlg>> evtDlgMap = new HashMap<>();

    // KEY:对话ID, VALUE:对话信息
    private Map<Integer, StaticActMonopolyEvtDlg> dlgMap = new HashMap<>();

    @Override
    public void init() {
        iniMonopolyConfig();
        iniMonopolyEvents();
        iniBuyEventDetails();
        iniDlgEventDetails();
    }

    /**
     * 初始化大富翁配置信息
     */
    private void iniMonopolyConfig() {
        monopolyMap.clear();
        Map<Integer, StaticActMonopoly> monopolyMap0 = staticDataDao.selectStaticActMonopoly();
        for (Map.Entry<Integer, StaticActMonopoly> entry : monopolyMap0.entrySet()) {
            monopolyMap.put(entry.getValue().getActivityId(), entry.getValue());
        }
    }

    /**
     * 初始化大富翁事件定义
     */
    private void iniMonopolyEvents() {
        evtMap.clear();
        evtTypeMap.clear();
        Map<Integer, StaticActMonopolyEvt> dataMap = staticDataDao.selectStaticActMonopolyEvt();
        for (Map.Entry<Integer, StaticActMonopolyEvt> entry : dataMap.entrySet()) {
            StaticActMonopolyEvt data = entry.getValue();
            Map<Integer, StaticActMonopolyEvt> map = evtMap.get(data.getActivityId());
            if (map == null) evtMap.put(data.getActivityId(), map = new HashMap<Integer, StaticActMonopolyEvt>());
            map.put(data.getId(), data);

            Map<Integer, Map<Integer, List<StaticActMonopolyEvt>>> actMap = evtTypeMap.get(data.getActivityId());
            if (actMap == null) {
                evtTypeMap.put(data.getActivityId(), actMap = new HashMap<Integer, Map<Integer, List<StaticActMonopolyEvt>>>());
            }
            Map<Integer, List<StaticActMonopolyEvt>> tyMap = actMap.get(data.getType());
            if (tyMap == null) {
                actMap.put(data.getType(), tyMap = new HashMap<Integer, List<StaticActMonopolyEvt>>());
            }
            List<StaticActMonopolyEvt> styList = tyMap.get(data.getSty());
            if (styList == null) {
                tyMap.put(data.getSty(), styList = new ArrayList<StaticActMonopolyEvt>());
            }
            styList.add(data);
        }
    }

    /**
     * 初始化对话框事件明细
     */
    private void iniDlgEventDetails() {
        dlgMap = staticDataDao.selectStaticActMonopolyEvtDlg();
    }

    /**
     * 初始化购买事件明细
     */
    private void iniBuyEventDetails() {
        evtBuyMap.clear();
        buyMap = staticDataDao.selectStaticActMonopolyEvtBuy();
        for (Map.Entry<Integer, StaticActMonopolyEvtBuy> entry : buyMap.entrySet()) {
            StaticActMonopolyEvtBuy data = entry.getValue();
            List<StaticActMonopolyEvtBuy> buys = evtBuyMap.get(data.getEid());
            if (buys == null) evtBuyMap.put(data.getEid(), buys = new ArrayList<StaticActMonopolyEvtBuy>());
            buys.add(data);
        }
    }

    public StaticActMonopoly getStaticActMonopoly(int activityId) {
        StaticActMonopoly data = monopolyMap.get(activityId);
        if (data == null) {
            LogUtil.error(String.format("not found monopoly activity id :%d", activityId));
        }
        return data;
    }

    /**
     * 获取活动列表
     *
     * @param activityId
     * @return
     */
    public Map<Integer, StaticActMonopolyEvt> getEvtMap(int activityId) {
        Map<Integer, StaticActMonopolyEvt> dataMap = evtMap.get(activityId);
        if (dataMap == null) {
            LogUtil.error(String.format("not found monopoly activity id :%d", activityId));
        }
        return dataMap;
    }

    /**
     * 获取事件信息
     *
     * @param activityId
     * @param eid
     * @return
     */
    public StaticActMonopolyEvt getEvent(int activityId, int eid) {
        Map<Integer, StaticActMonopolyEvt> map = evtMap.get(activityId);
        StaticActMonopolyEvt data = map != null ? map.get(eid) : null;
        if (data == null) {
            LogUtil.error(String.format("not found monopoly event activityId :%d, eid :%d", activityId, eid));
        }
        return data;
    }

    /**
     * 获取特殊事件对象(空事件, 完成游戏事件)
     *
     * @param activityId
     * @param evtTy
     * @return
     */
    public StaticActMonopolyEvt getSpecialEvt(int activityId, int evtTy) {
        Map<Integer, StaticActMonopolyEvt> map = evtMap.get(activityId);
        if (map != null) {
            for (Map.Entry<Integer, StaticActMonopolyEvt> entry : map.entrySet()) {
                if (entry.getValue().getType() == evtTy) {
                    return entry.getValue();
                }
            }
        }
        LogUtil.error(String.format("not found activity id :%d, special event ty :%d", activityId, evtTy));
        return null;
    }


    /**
     * 获取购买事件对应的购买列表
     *
     * @param evtId
     * @return
     */
    public List<StaticActMonopolyEvtBuy> getBuys(int evtId) {
        List<StaticActMonopolyEvtBuy> list = evtBuyMap.get(evtId);
        if (list == null) {
            LogUtil.error(String.format("not found buy list evtId :%d", evtId));
        }
        return list;
    }

    /**
     * 获取购买对象
     *
     * @param buyId
     * @return
     */
    public StaticActMonopolyEvtBuy getStaticActMonopolyBuy(int buyId) {
        StaticActMonopolyEvtBuy data = buyMap.get(buyId);
        if (data == null) {
            LogUtil.error("not found buyId :" + buyId);
        }
        return data;
    }


    public StaticActMonopolyEvtDlg getStaticActMonopolyEvtDlg(int dlgId) {
        StaticActMonopolyEvtDlg data = dlgMap.get(dlgId);
        if (data == null) {
            LogUtil.error("not found dlg id :" + dlgId);
        }
        return data;
    }


    /**
     * 获取指定大类型与小类型的事件
     *
     * @param activityId
     * @return 如果配置有指定的小事件类型则根据权重返回改小事件类型下一个随机事件，否则返回空事件
     */
    public StaticActMonopolyEvt getEventByType(int activityId, int bty, int sty) {
        Map<Integer, Map<Integer, List<StaticActMonopolyEvt>>> actMap = evtTypeMap.get(activityId);
        Map<Integer, List<StaticActMonopolyEvt>> btyMap = actMap != null ? actMap.get(bty) : null;
        List<StaticActMonopolyEvt> styList = btyMap != null ? btyMap.get(sty) : null;
        if (styList == null) {
            LogUtil.error(String.format("not found evt activityId :%d, bty :%d, sty :%d", activityId, bty, sty));
            return getSpecialEvt(activityId, ActMonopolyConst.EVT_EMPTY);
        }
        return RandomHelper.getRandomByProb(styList);
    }

    public List<StaticActMonopolyEvt> getAllBoxEvent(int activityId) {
        List<StaticActMonopolyEvt> evts = new ArrayList<>();
        Map<Integer, Map<Integer, List<StaticActMonopolyEvt>>> actMap = evtTypeMap.get(activityId);
        Map<Integer, List<StaticActMonopolyEvt>> btyMap = actMap != null ? actMap.get(ActMonopolyConst.EVT_BOX) : null;
        if (btyMap == null) {
            LogUtil.error("not found box event activityId :" + activityId);
        }else{
            for (Map.Entry<Integer, List<StaticActMonopolyEvt>> entry : btyMap.entrySet()) {
                evts.addAll(entry.getValue());
            }
        }
        return evts;
    }

}
