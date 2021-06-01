package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Advertisement;
/**
* @ClassName: AdvertisementDao 
* @Description: 玩家广告
* @author
 */
public class AdvertisementDao extends BaseDao {
    public Advertisement selectAdvertisement(long lordId) {
        return this.getSqlSession().selectOne("AdvertisementDao.selectAdvertisement", lordId);
    }

    public int insertAdvertisement(Advertisement ad) {
        return this.getSqlSession().insert("AdvertisementDao.insertAdvertisement", ad);
    }

    public void updateAdvertisement(Advertisement ad) {
        this.getSqlSession().update("AdvertisementDao.updateAdvertisement", ad);
    }

    public List<Advertisement> load() {
        List<Advertisement> list = new ArrayList<>();
        long curIndex = 0L;
        int count = 1000;
        int pageSize = 0;
        while (true) {
            List<Advertisement> page = load(curIndex, count);
            pageSize = page.size();
            if (pageSize > 0) {
                list.addAll(page);
                curIndex = page.get(pageSize - 1).getLordId();
            } else {
                break;
            }

            if (pageSize < count) {
                break;
            }
        }
        return list;
    }

    private List<Advertisement> load(long curIndex, int count) {
        Map<String, Object> params = paramsMap();
        params.put("curIndex", curIndex);
        params.put("count", count);
        return this.getSqlSession().selectList("AdvertisementDao.load", params);
    }

}
