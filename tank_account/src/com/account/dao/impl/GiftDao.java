package com.account.dao.impl;

import java.util.Map;

import com.account.dao.BaseDao;
import com.account.domain.Gift;
import com.account.domain.GiftCode;
import com.account.domain.GiftCodeExt;

public class GiftDao extends BaseDao {
    public Gift selectGift(int giftId) {
        return this.getSqlSession().selectOne("GiftDao.selectGift", giftId);
    }

    public void insertGift(Gift gift) {
        this.getSqlSession().insert("GiftDao.insertGift", gift);
    }

    public void updateGift(Gift gift) {
        this.getSqlSession().update("GiftDao.updateGift", gift);
    }

    public GiftCode selectGiftCode(String giftCode) {
        return this.getSqlSession().selectOne("GiftDao.selectGiftCode", giftCode);
    }

    public GiftCode selectGiftCodeByLord(String giftId, int serverId, long lordId) {
        Map<String, Object> param = this.paramsMap();
        param.put("giftId", giftId);
        param.put("serverId", serverId);
        param.put("lordId", lordId);
        return this.getSqlSession().selectOne("GiftDao.selectGiftCodeByLord", param);
    }

    public void insertGiftCode(GiftCode giftCode) {
        this.getSqlSession().insert("GiftDao.insertGiftCode", giftCode);
    }

    public void updateGiftCode(GiftCode giftCode) {
        this.getSqlSession().update("GiftDao.updateGiftCode", giftCode);
    }

    public GiftCodeExt selectGiftCodeExt(String giftCode, int serverId, long lordId) {
        Map<String, Object> param = this.paramsMap();
        param.put("giftCode", giftCode);
        param.put("serverId", serverId);
        param.put("lordId", lordId);
        return this.getSqlSession().selectOne("GiftDao.selectGiftCodeExt", param);
    }

    public void insertGiftCodeExt(GiftCodeExt giftCode) {
        this.getSqlSession().insert("GiftDao.insertGiftCodeExt", giftCode);
    }
}
