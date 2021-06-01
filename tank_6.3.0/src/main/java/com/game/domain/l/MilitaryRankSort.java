package com.game.domain.l;

import com.game.domain.p.Lord;
import com.game.util.UnsafeSortInfo;

/**
 * @author zhangdh
 * @ClassName: MilitaryRankSort
 * @Description: 军功排名对象
 * @date 2017-05-26 15:41
 */
public class MilitaryRankSort implements UnsafeSortInfo.ISortVO<MilitaryRankSort> {
    private long lordId; //角色ID
    private int militaryRank; //军衔
    private long militaryRankUpTime; //军衔升级时间
    

    public MilitaryRankSort(long lordId, int militaryRank, long militaryRankUpTime) {
        this.lordId = lordId;
        this.militaryRank = militaryRank;
        this.militaryRankUpTime = militaryRankUpTime;
    }

    public MilitaryRankSort(Lord lord){
        this.lordId = lord.getLordId();
        this.militaryRank = lord.getMilitaryRank();
        this.militaryRankUpTime = lord.getMilitaryRankUpTime();
    }

    @Override
    public String getKey() {
        return String.valueOf(lordId);
    }

    @Override
    public long getValue() {
        return militaryRank;
    }

    public long getLordId() {
        return lordId;
    }

    @Override
    public int compareTo(MilitaryRankSort o) {
        if (militaryRank > o.militaryRank) {
            return -1;
        } else if (militaryRank < o.militaryRank) {
            return 1;
        } else {
            if (militaryRankUpTime < o.militaryRankUpTime) {
                return -1;
            } else {
                return militaryRankUpTime > o.militaryRankUpTime ? 1 : 0;
            }
        }
    }

    @Override
    public String toString() {
        return "MilitaryRankSort{" +
                "lordId=" + lordId +
                ", militaryRank=" + militaryRank +
                ", militaryRankUpTime=" + militaryRankUpTime +
                '}';
    }

}
