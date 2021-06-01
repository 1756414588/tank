package merge.v2;

import com.game.domain.p.Arena;
import com.game.util.LogUtil;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: MergeArenaUtils
 * @Description:
 * @date 2017-08-08 15:05
 */
public class MergeArenaUtils {

    private static void sortArena(List<Arena> sorts) {
        //将剩余数据排序后追加到排行榜
        Collections.sort(sorts, new Comparator<Arena>() {
            @Override
            public int compare(Arena o1, Arena o2) {
                if (o1.getRank() != o2.getRank()) {
                    return o1.getRank() - o2.getRank();
                }
                if (o1.getFight() != o2.getFight()) {
                    long l = o2.getFight() - o1.getFight();
                    return l > 0 ? 1 : -1;
                }
                if (o1.getScore() != o2.getScore()) {
                    return o2.getScore() - o1.getScore();
                }
                return (int) (o1.getLordId() - o2.getLordId());
            }
        });
    }


    /**
     * 重新对竞技场排名后将玩家插入Master数据库
     * @param dataMgr
     */
    public static void mergeArena(MergeDataMgr dataMgr) {
        List<Arena> totalArena = new ArrayList<>();
        for (Map.Entry<Integer, List<Arena>> entry : dataMgr.getArenaMap().entrySet()) {
            totalArena.addAll(entry.getValue());
        }
        sortArena(totalArena);
        int rank = 1;
        for (Arena arena : totalArena) {
            arena.setRank(rank++);
            dataMgr.saveArena(arena);
            LogUtil.error("加入竞技场[lordId=" + arena.getLordId() + ":rank=" + arena.getRank() + "]:" + arena.getScore());
        }
    }

}
