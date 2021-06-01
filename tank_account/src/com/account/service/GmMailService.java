package com.account.service;

import java.util.Date;
import java.util.List;
import java.util.UUID;

import net.sf.json.JSONArray;
import net.sf.json.JSONObject;

import org.springframework.beans.factory.annotation.Autowired;

import com.account.constant.GameError;
import com.account.dao.impl.GmMailDao;
import com.account.domain.GmMail;

public class GmMailService {

    @Autowired
    private GmMailDao gmMailDao;

    public GameError getGmMails(JSONObject response) {
        List<GmMail> gmList = gmMailDao.selectUnClose();
        JSONArray mailList = new JSONArray();
        if (gmList != null) {
            for (GmMail gmMail : gmList) {
                JSONObject mail = new JSONObject();
                mail.put("ae", gmMail.getAe());
                mail.put("type", gmMail.getType());
                mail.put("gmName", gmMail.getGmName());
                mail.put("title", gmMail.getTitle());
                mail.put("content", gmMail.getContent());
                mail.put("param", gmMail.getParam());
                mail.put("condition", gmMail.getCondition());
                mail.put("conditionType", gmMail.getConditionType());
                mail.put("conditionValue", gmMail.getConditionValue());
                mail.put("awards", gmMail.getAwards());
                mail.put("beginDate", gmMail.getBeginDate().getTime());
                mail.put("endDate", gmMail.getEndDate().getTime());
                mail.put("alive", gmMail.getAlive());
                mail.put("delModel", gmMail.getDelModel());
                mailList.add(mail);
            }
        }
        response.put("mailList", mailList);
        return GameError.OK;
    }

    public GameError writeGmMail(int type, String gmName, String title, String content, String param, int condition, int conditionType, int conditionValue,
                                 String awards, long beginDate, long endDate, long alive, int delModel, JSONObject response) {
        GmMail gmMail = new GmMail();
        gmMail.setAe(UUID.randomUUID().toString());
        gmMail.setType(type);
        gmMail.setGmName(gmName);
        gmMail.setTitle(title);
        gmMail.setContent(content);
        gmMail.setParam(param);
        gmMail.setCondition(condition);
        gmMail.setConditionType(conditionType);
        gmMail.setConditionValue(conditionValue);
        gmMail.setAwards(awards);
        gmMail.setBeginDate(new Date(beginDate));// 开启时间
        gmMail.setEndDate(new Date(endDate));// 结束时间
        gmMail.setAlive(alive);
        gmMail.setDelModel(delModel);
        gmMailDao.createGmMail(gmMail);
        return GameError.OK;
    }

    public GameError modifyGmMail(String ae, int type, String title, String content, String awards, long beginDate, long endDate, long alive, int delModel,
                                  JSONObject response) {
        GmMail gmMail = gmMailDao.selectGMailAE(ae);
        if (gmMail == null) {
            return GameError.OK;
        }
        gmMail.setType(type);
        gmMail.setTitle(title);
        gmMail.setContent(content);
        gmMail.setAwards(awards);
        gmMail.setBeginDate(new Date(beginDate));// 开启时间
        gmMail.setEndDate(new Date(endDate));// 结束时间
        gmMail.setAlive(alive);
        gmMail.setDelModel(delModel);
        gmMailDao.updateGmMail(gmMail);
        return GameError.OK;
    }

    public GameError writeLocalGmMail(JSONArray gmMailList, JSONObject response) {
        int size = gmMailList.size();
        for (int i = 0; i < size; i++) {
            JSONObject jsonObject = gmMailList.getJSONObject(i);
            String ae = jsonObject.getString("ae");
            GmMail gmMail = gmMailDao.selectGMailAE(ae);
            if (gmMail == null) {
                int type = jsonObject.getInt("type");
                String gmName = jsonObject.getString("gmName");
                String title = jsonObject.getString("title");
                String content = jsonObject.getString("content");
                String param = jsonObject.getString("param");
                int condition = jsonObject.getInt("condition");
                int conditionType = jsonObject.getInt("conditionType");
                int conditionValue = jsonObject.getInt("conditionValue");
                String awards = jsonObject.getString("awards");
                Long beginDate = jsonObject.getLong("beginDate");
                Long endDate = jsonObject.getLong("endDate");
                Long alive = jsonObject.getLong("alive");
                int delModel = jsonObject.getInt("delModel");

                gmMail = new GmMail();
                gmMail.setAe(ae);
                gmMail.setType(type);
                gmMail.setGmName(gmName);
                gmMail.setTitle(title);
                gmMail.setContent(content);
                gmMail.setParam(param);
                gmMail.setCondition(condition);
                gmMail.setConditionType(conditionType);
                gmMail.setConditionValue(conditionValue);
                gmMail.setAwards(awards);
                gmMail.setBeginDate(new Date(beginDate));
                gmMail.setEndDate(new Date(endDate));
                gmMail.setAlive(alive);
                gmMail.setDelModel(delModel);
                gmMailDao.createGmMail(gmMail);
            }
        }
        return GameError.OK;
    }

}
