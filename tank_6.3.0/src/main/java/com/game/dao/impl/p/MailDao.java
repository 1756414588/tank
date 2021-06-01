package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.NewMail;

/**
 * @ClassName:MailDao
 * @author zc
 * @Description:
 * @date 2017年9月27日
 */
public class MailDao extends BaseDao {
    public List<NewMail> selectByLordId(Long lordId) {
        return this.getSqlSession().selectList("MailDao.selectByLordId", lordId);
    }
    
    public int insertMail(NewMail newMail) {
        return this.getSqlSession().insert("MailDao.insertMail", newMail);
    }

    public int updateState(NewMail newMail) {
        return this.getSqlSession().update("MailDao.updateState", newMail);
    }


    public int delMail(NewMail newMail) {
        return this.getSqlSession().delete("MailDao.delMail", newMail);
    }

    public Map<Long, List<NewMail>> loadMail() {
        Map<Long, List<NewMail>> map = new HashMap<>();
        long curIndex = 0;
        int count = 2000;
        int pageSize = 0;
        long lordId;
        List<NewMail> page;
        List<NewMail> mailList = null;
        while (true) {
            page = loadMail(curIndex, count);
            pageSize = page.size();
            if (pageSize > 0) {
                for (NewMail newMail : page) {
                    lordId = newMail.getLordId();
                    mailList = map.get(lordId);
                    if (mailList == null) {
                        mailList = new ArrayList<>();
                        map.put(lordId, mailList);
                    }
                    mailList.add(newMail);
                }
            } else {
                break;
            }

            if (page.size() < count) {
                break;
            }
            
            curIndex = page.get(pageSize - 1).getId();
        }
        return map;
    }

    private List<NewMail> loadMail(long curIndex, int count) {
        Map<String, Object> params = paramsMap();
        params.put("curIndex", curIndex);
        params.put("count", count);
        
        return this.getSqlSession().selectList("MailDao.loadNewMail", params);
    }

}
