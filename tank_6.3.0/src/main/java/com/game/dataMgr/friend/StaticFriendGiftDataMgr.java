package com.game.dataMgr.friend;

import com.game.dao.impl.s.StaticDataDao;
import com.game.dataMgr.BaseDataMgr;
import com.game.domain.s.friend.GiveProp;
import com.game.domain.s.friend.StaticFriendGift;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;
import org.springframework.util.CollectionUtils;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Component
public class StaticFriendGiftDataMgr extends BaseDataMgr {

    @Autowired
    private StaticDataDao staticDataDao;

    /**
     * 赠送道具最低友好度，key:赠送道具（type,id）,value:最低友好度
     */
    private Map<GiveProp, Long> givePropFriendlinessMap = new HashMap<>();
    /**
     * 赠送道具赠送个数，key:赠送道具（type,id），value:赠送个数
     */
    private Map<GiveProp, Integer> givePropCountMap = new HashMap<>();

    /**
     * 赠送道具接收次数限制，key:赠送道具（type,id）,value:接收次数限制
     */
    private Map<GiveProp, Integer> givePropReceiveCountMap = new HashMap<>();

    @Override
    public void init() {
        givePropFriendlinessMap.clear();
        givePropCountMap.clear();
        givePropReceiveCountMap.clear();
        List<StaticFriendGift> staticFriendGifts = staticDataDao.selectFriendGiftList();

        for (StaticFriendGift friendGift : staticFriendGifts) {
            List<Integer> propList = friendGift.getProp();
            if (CollectionUtils.isEmpty(propList)) {
                continue;
            }

            if (propList.size() != 4) {
                continue;
            }

            long friendliness = friendGift.getFriend();
            Integer type = propList.get(0);
            Integer id = propList.get(1);
            Integer giveCount = propList.get(2);
            Integer maxNum = propList.get(3);

            GiveProp giveProp = new GiveProp(type, id);
            givePropFriendlinessMap.put(giveProp, friendliness);
            givePropCountMap.put(giveProp, giveCount);
            givePropReceiveCountMap.put(giveProp, maxNum);
        }
    }

    /**
     * 根据友好度检查该类型道具是否可赠送
     *
     * @param giveProp        道具类型, 道具id
     * @param curFriendliness 当前友好度
     * @return
     */
    public boolean checkEnableGiveByFriendliness(GiveProp giveProp, long curFriendliness) {

        if (givePropFriendlinessMap.isEmpty()) {
            return false;
        }

        if (!givePropFriendlinessMap.containsKey(giveProp)) {
            return false;
        }

        Long friendliness = givePropFriendlinessMap.get(giveProp);

        if (curFriendliness >= friendliness) {
            return true;
        }

        return false;
    }

    /**
     * 检查赠送道具的个数是否符合配置
     *
     * @param giveProp
     * @param curCount
     * @return
     */
    public boolean checkGiveCount(GiveProp giveProp, int curCount) {

        if (givePropCountMap.isEmpty()) {
            return false;
        }

        if (!givePropCountMap.containsKey(giveProp)) {
            return false;
        }

        Integer count = givePropCountMap.get(giveProp);
        if (curCount != count) {
            return false;
        }

        return true;
    }

    /**
     * 检查好友获取该道具的个数是否已达上限
     *
     * @param giveProp
     * @param curCount
     * @return
     */
    public boolean checkFriendReceivePropMaxCount(GiveProp giveProp, int curCount) {

        if (givePropReceiveCountMap.isEmpty()) {
            return false;
        }

        if (!givePropReceiveCountMap.containsKey(giveProp)) {
            return false;
        }

        Integer maxReceiveCount = givePropReceiveCountMap.get(giveProp);
        if (curCount >= maxReceiveCount) {
            return false;
        }

        return true;
    }

}
