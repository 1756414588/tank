package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.common.ServerHotfix;
import com.game.dao.BaseDao;
import com.game.domain.p.DataNew;
import com.game.domain.p.RedefinedLordId;
import com.game.domain.p.repair.InvestNew;
import com.game.domain.p.repair.MailDelt;
import com.game.domain.p.repair.ReissueItem;
import com.game.util.LogUtil;

/**
 * @author zhangdh
 * @ClassName: DataRepairDao
 * @Description: 线上玩家BUG处理查询类
 * @date 2017-07-03 15:51
 */
public class DataRepairDao extends BaseDao {

    public int insertHotfifxResult(ServerHotfix hotfix) {
        return getSqlSession().insert("insertHotfix", hotfix);
    }

    public Map<Long, RedefinedLordId> selectLordIds() {
        return getSqlSession().selectMap("selectLordIds", "oldId");
    }

    public Map<Long, DataNew> selectMailFromBackUp() {
        return getSqlSession().selectMap("selectMailData", "lordId");
    }

    public List<MailDelt> selectMailDelt(int serverId) {
        return getSqlSession().selectList("selectMailDelt", serverId);
    }

    public List<InvestNew> selectInvestNew() {
        return getSqlSession().selectList("selectInvestNew");
    }

    public void updateInvestNew(InvestNew ivn) {
        getSqlSession().update("updateInvestNew", ivn);
    }

    public List<ReissueItem> selectReissueItem() {
        return getSqlSession().selectList("selectAllRsi");
    }

    public void updateReissueItem(ReissueItem rsi) {
        getSqlSession().update("updateRsiBackGold", rsi);
    }


    public List<DataNew> loadDataBak() {
        List<DataNew> list = new ArrayList<>();
        long curIndex = 0;
        int count = 2000;
        int pageSize = 0;
        while (true) {
            List<DataNew> page = loadData(curIndex, count);
            pageSize = page.size();
            if (pageSize > 0) {
                list.addAll(page);
                curIndex = page.get(pageSize - 1).getLordId();
                LogUtil.error(String.format("p_data_bak list size : " + list.size()));
            } else {
                break;
            }

            if (page.size() < count) {
                break;
            }
        }
        return list;
    }

    private List<DataNew> loadData(long curIndex, int count) {
        Map<String, Object> params = paramsMap();
        params.put("curIndex", curIndex);
        params.put("count", count);
        return this.getSqlSession().selectList("loadDataBak", params);
    }
}
