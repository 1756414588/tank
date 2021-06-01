package merge.v2;

import com.game.domain.GameGlobal;
import com.game.domain.p.DbGlobal;
import com.game.domain.p.WorldStaffing;
import com.game.util.LogUtil;
import com.google.protobuf.InvalidProtocolBufferException;
import merge.MServer;

import java.util.ArrayList;
import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class MergeGlobalUtils {


    public static void mergeGlobal(MergeDataMgr dataMgr, List<MServer> slaves) {

        try {
            List<WorldStaffing> list = new ArrayList<>();

            for (MServer s : slaves) {
                DbGlobal dbGlobal = s.myBatisM.getGlobalDao().selectGlobal();
                byte[] worldStaffingData = dbGlobal.getWorldStaffing();
                WorldStaffing worldStaffing = new WorldStaffing();
                GameGlobal.dserWorldStaffing(worldStaffingData, worldStaffing);
                list.add(worldStaffing);
                LogUtil.error("世界矿点等级 serverId=" + s.getServerId() + " worldStaffingExp=" + worldStaffing.getExp());

            }

            Collections.sort(list, new Comparator<WorldStaffing>() {
                @Override
                public int compare(WorldStaffing o1, WorldStaffing o2) {

                    if (o2.getExp() > o1.getExp()) {
                        return 1;
                    } else if (o2.getExp() > o1.getExp()) {
                        return -1;
                    } else {
                        return 0;
                    }

                }
            });


            for (WorldStaffing s : list) {
                LogUtil.error("世界矿点等级排序 worldStaffingExp=" + s.getExp());
            }


            if (list.size() != 0) {
                GameGlobal gameGlobal = new GameGlobal();
                DbGlobal dbGlobal = gameGlobal.ser(true);
                dbGlobal.setWorldStaffing(GameGlobal.serWorldStaffing(list.get(0)));
                LogUtil.error("世界矿点等级处理完毕合并后 exp=" + list.get(0).getExp());
                dataMgr.getMasterDao().getGlobalDao().insertGlobal(dbGlobal);
            }

        } catch (InvalidProtocolBufferException e) {
            LogUtil.error("合服报错",e);
            System.exit(-1);
        }


    }

}
