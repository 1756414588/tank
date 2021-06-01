package com.game.dataMgr;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.game.domain.s.StaticMailNew;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Component;

import com.game.dao.impl.s.StaticDataDao;
import com.game.domain.s.StaticMail;
import com.game.domain.s.StaticMailPlat;

/**
 * @author
 * @ClassName: StaticMailDataMgr
 * @Description: 系统邮件配置
 */
@Component
public class StaticMailDataMgr extends BaseDataMgr {
    @Autowired
    private StaticDataDao staticDataDao;

    private Map<Integer, StaticMail> mailMap = new HashMap<Integer, StaticMail>();

    private Map<Integer, List<StaticMailPlat>> mailPlatMap = new HashMap<Integer, List<StaticMailPlat>>();

    private Map<Integer, List<StaticMailNew>> mailNewMap = new HashMap<>();

    /**
     * Overriding: init
     *
     * @see com.game.dataMgr.BaseDataMgr#init()
     */
    @Override
    public void init() {
        Map<Integer, StaticMail> mailMap = staticDataDao.selectMail();
        this.mailMap = mailMap;

        List<StaticMailPlat> mailPlatList = staticDataDao.selectStaticMailPlat();
        Map<Integer, List<StaticMailPlat>> mailPlatMap = new HashMap<Integer, List<StaticMailPlat>>();
        for (StaticMailPlat e : mailPlatList) {
            List<StaticMailPlat> elist = mailPlatMap.get(e.getPlatNo());
            if (elist == null) {
                elist = new ArrayList<StaticMailPlat>();
                mailPlatMap.put(e.getPlatNo(), elist);
            }
            elist.add(e);
        }
        this.mailPlatMap = mailPlatMap;

        List<StaticMailNew> mailNewList = staticDataDao.selectStaticMailNew();
        mailNewMap.clear();
        for (StaticMailNew staticMailNew : mailNewList) {
            List<StaticMailNew> list = mailNewMap.get(staticMailNew.getServerId());
            if (list == null) {
                list = new ArrayList<>();
                mailNewMap.put(staticMailNew.getServerId(), list);
            }
            list.add(staticMailNew);
        }
    }

    public StaticMail getStaticMail(int moldId) {
        return mailMap.get(moldId);
    }

    public List<StaticMailPlat> getPlatMail(int platNo) {
        return mailPlatMap.get(platNo);
    }

    public List<StaticMailNew> getMailNew(int serverId) {
        return mailNewMap.get(serverId);
    }

}
