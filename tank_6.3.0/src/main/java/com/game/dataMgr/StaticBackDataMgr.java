package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.TreeMap;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.Player;
import com.game.domain.s.StaticBackBuff;
import com.game.domain.s.StaticBackMoney;
import com.game.domain.s.StaticBackOne;
import com.game.util.LogUtil;

/**
 * @author liuyifan
 * @version 2017年6月17日17:09:17
 * @Description: 物品奖励处理s_award
 */
@Component
public class StaticBackDataMgr extends BaseDataMgr{

    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticBackBuff> buffMap = new HashMap<Integer, StaticBackBuff>();
    private Map<Integer, StaticBackMoney> moneyMap = new HashMap<Integer, StaticBackMoney>();
    private Map<Integer, StaticBackOne> oneMap = new HashMap<Integer, StaticBackOne>();
    
    @Override
    public void init() {
        Map<Integer, StaticBackBuff> buffMap  = staticDataDao.selectBackBuffMap();
        Map<Integer, StaticBackMoney> moneyMap  = staticDataDao.selectBackMoneyMap();
        Map<Integer, StaticBackOne> oneMap  = staticDataDao.selectBackOneMap();
        this.buffMap = buffMap;
        this.moneyMap = moneyMap;
        this.oneMap = oneMap;
    }
    public StaticBackBuff getBuffById(int keyId) {
        return buffMap.get(keyId);
    }
    public StaticBackMoney getMoneyById(int keyId) {
        return moneyMap.get(keyId);
    }
    public StaticBackOne getOneById(int keyId) {
        return oneMap.get(keyId);
    }
    
    public List<StaticBackBuff> getBuff(int backTime,Player player){
        if(backTime ==1){
            backTime = 7;
        }else if(backTime ==2){
            backTime = 14;
        }else if(backTime ==3){
            backTime = 21;
        }
        else if(backTime ==4){
            backTime = 28;
        }
        List<StaticBackBuff> list = new ArrayList<StaticBackBuff>();
        Iterator<StaticBackBuff> it = buffMap.values().iterator();
        while (it.hasNext()) {
            StaticBackBuff next = it.next();
            if (next.getBackTime() == backTime) {
               list.add(next);
            }
        }
        return list;
    }
    
    public StaticBackMoney getMoney(int backTime){
        Iterator<StaticBackMoney> it = moneyMap.values().iterator();
        while (it.hasNext()) {
            StaticBackMoney next = it.next();
            if (next.getBackTime() == backTime) {
                return next;
            }
        }
        return null;
    }
    
    public TreeMap<Integer,StaticBackOne> getBackOneList(int backTime){
        if(backTime ==1){
            backTime = 7;
        }else if(backTime ==2){
            backTime = 14;
        }else if(backTime ==3){
            backTime = 21;
        }
        else if(backTime ==4){
            backTime = 28;
        }
        TreeMap<Integer,StaticBackOne> list = new TreeMap<Integer,StaticBackOne>();
        Iterator<StaticBackOne> it = oneMap.values().iterator();
        while (it.hasNext()) {
            StaticBackOne next = it.next();
            if (next.getBackTime() == backTime) {
               list.put(next.getKeyId(),next);
            }
        }
        return list;
    }
    
    public  StaticBackOne getBackOne(int backTime,int day){
        if(backTime ==1){
            backTime = 7;
        }else if(backTime ==2){
            backTime = 14;
        }else if(backTime ==3){
            backTime = 21;
        }
        else if(backTime ==4){
            backTime = 28;
        }
        StaticBackOne staticBackOne = null;
        Iterator<StaticBackOne> it = oneMap.values().iterator();
        while (it.hasNext()) {
            StaticBackOne next = it.next();
            if(backTime==next.getBackTime()&&day == next.getDay()){
                staticBackOne = next;
                return staticBackOne;
            }
        }
        LogUtil.error(String.format("backTime :%s, day :%d", backTime, day));
                return null;
    }
}
