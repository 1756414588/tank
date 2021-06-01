package merge.v2;

import com.game.constant.PartyType;
import com.game.domain.Member;
import com.game.domain.PartyData;
import com.game.domain.p.Party;
import com.game.domain.p.PartyMember;
import com.game.util.LogUtil;
import merge.MServer;
import merge.MyBatisM;

import java.util.*;

/**
 * @author zhangdh
 * @ClassName: MergePartyUtils
 * @Description: 军团合并
 * @date 2017-08-05 14:34
 */
public class MergePartyUtils {

    private static Member findDefaultLegatus(List<Member> list) {
        // 移交给军团长自动移交至副军团长中贡献最高的，若没副军团长则移交至贡献最高的成员
        Collections.sort(list, new Comparator<Member>() {
            public int compare(Member o1, Member o2) {
                if (o1.getJob() > o2.getJob()) {
                    return 1;
                } else if (o1.getJob() == o2.getJob()) {
                    return o1.getDonate() - o2.getDonate();
                } else {
                    return -1;
                }
            }
        });
        return list.get(0);
    }

    /**
     * 将slave服务器中的工会信息合并到master服务器中<br>
     * 1.查询不在p_smallid表中的p_party_member记录 :: 如果玩家是小号则合服后该玩家的p_party_member记录会被清除<br>
     * 2.如果军团中所有成员都为小号则合服后该军团将不再存在<br>
     * 3.如果军团长为小号则选出一个非小号成员为新的军团长 选择方法参见:{@link MergePartyUtils#findDefaultLegatus(List)}
     * 4.如果军团名字有重复则处理重复的名字
     * 5.处理合服需要清除的军团信息
     * 6.将军团成员保存到Master库中
     *
     * @param dataMgr
     * @param server
     */
    public static void mergeParty(MergeDataMgr dataMgr, MServer slave) {
        int sid = slave.getServerId();
        String sname = slave.getServerName();
        MyBatisM slaveDb = slave.myBatisM;
        //KEY0:军团ID, KEY1:职位ID, KEY2:角色ID, VALUE:成员信息
        Map<Integer, Map<Integer, Map<Long, Member>>> partyMemberMap = new HashMap<>();
        //有效的工会成员
        List<PartyMember> memberEntityList = slaveDb.getPartyDao().selectPartyMemberFilterSmallId();

        LogUtil.error(String.format("server id :%d, sname :%s, party member size :%s", sid, sname, memberEntityList.size()));
        for (PartyMember memberEntity : memberEntityList) {
            try {
                Member member = new Member();
                member.loadMember(memberEntity);
                int partyId = memberEntity.getPartyId();
                Map<Integer, Map<Long, Member>> jobMap = partyMemberMap.get(partyId);
                if (jobMap == null) {
                    partyMemberMap.put(partyId, jobMap = new HashMap<Integer, Map<Long, Member>>());
                }
                Map<Long, Member> mbrMap = jobMap.get(memberEntity.getJob());
                if (mbrMap == null) {
                    jobMap.put(memberEntity.getJob(), mbrMap = new HashMap<Long, Member>());
                }
                mbrMap.put(memberEntity.getLordId(), member);
            } catch (Exception e) {
                LogUtil.error(String.format("server id :%d, server name :%s, member id :%d, parser proto error", sid, sname, memberEntity.getLordId()), e);
                LogUtil.error("合服报错",e);
                System.exit(-1);
            }
        }

        //查询数据库中工会列表
        List<Party> partyList = slaveDb.getPartyDao().selectParyList();
        LogUtil.error(String.format("server id :%d, sname :%s, party size :%s", sid, sname, partyList.size()));
        for (Party partyEntity : partyList) {
            int partyId = partyEntity.getPartyId();
            Map<Integer, Map<Long, Member>> jobMap = partyMemberMap.get(partyId);
            if (jobMap == null || jobMap.isEmpty()) {
                continue;//军团中已经没有成员,没必要合到新服中去
            }

            Map<Long, Member> legatusMap = jobMap.get(PartyType.LEGATUS);
            if (legatusMap == null || legatusMap.isEmpty()) {
                LogUtil.error(String.format("server id :%d, sname :%s, party id :%d, not found legatus", sid, sname, partyId));
                //若军团长为小号重新选出一个军团长
                List<Member> candidate = new ArrayList<>();
                for (Map.Entry<Integer, Map<Long, Member>> jobEntry : jobMap.entrySet()) {
                    candidate.addAll(jobEntry.getValue().values());
                }
                //被选出来的新军团长
                Member legatus = findDefaultLegatus(candidate);
                if (legatus == null) {
                    LogUtil.error(String.format("sid :%d, sname :%s, party Id :%d, find default legatus fail !!!", sid, sname, partyId));
                    continue;//军团不能没有军团长
                }
                Map<Long, Member> oldJobMap = jobMap.get(legatus.getJob());
                if (oldJobMap != null && !oldJobMap.isEmpty()) {
                    oldJobMap.remove(legatus.getLordId());
                }
                legatus.setJob(PartyType.LEGATUS);
                if (legatusMap == null) {
                    jobMap.put(PartyType.LEGATUS, legatusMap = new HashMap<>());
                }
                legatusMap.put(legatus.getLordId(), legatus);
                jobMap.put(PartyType.LEGATUS, legatusMap);
                LogUtil.error(String.format("server id :%d, sname :%s, party id :%d, auto pick out legatus id :%d", sid, sname, partyId, legatus.getLordId()));
            }

            PartyData party = new PartyData(partyEntity);
            String old_party_name = party.getPartyName();
            party.setPartyName(dataMgr.getPartyUniqueName(party.getPartyName(), slave.getNickSuffix(), slave.hasMerge));
            if (!party.getPartyName().equals(old_party_name)) {
                LogUtil.error(String.format("sid :%d, sname :%s, party id :%d, old name :%s, new name :%s",
                        sid, sname, partyId, old_party_name, party.getPartyName()));
            }

            handPartyData(party);

            //将军团信息保存到master.p_party中
            boolean isSucc = dataMgr.saveParty(party.copyData()) > 0;
            if (!isSucc) {
                LogUtil.error(String.format("save sid :%d, sname :%s, party id :%d, fail !!!", sid, sname, party.getPartyId()));
            } else {
                LogUtil.info(String.format("sid :%d, sname :%s, save party :%d, succ", sid, sname, partyId));
            }
        }

        //将军团成员保存到p_party_member表中
        for (Map.Entry<Integer, Map<Integer, Map<Long, Member>>> entry : partyMemberMap.entrySet()) {
            Map<Integer, Map<Long, Member>> jobMap = entry.getValue();
            for (Map.Entry<Integer, Map<Long, Member>> jobEntry : jobMap.entrySet()) {
                Map<Long, Member> mbr = jobEntry.getValue();
                for (Map.Entry<Long, Member> mbrEntry : mbr.entrySet()) {
                    Member member = mbrEntry.getValue();
                    //先将军团长记录下来，后面要给军团长发放军团改名卡
                    if (member.getJob() == PartyType.LEGATUS) {
                        dataMgr.addLegatus(member.getLordId());
                    }

                    //处理军团成员数据
                    handPartyMember(member);

                    if (dataMgr.savePartyMember(member.copyData()) > 0) {
                        LogUtil.info(String.format("save sid :%d, sname :%s, party member :%d, succ", sid, sname, member.getLordId()));
                    }
                }
            }
        }
    }

    /**
     * 处理军团数据
     *
     * @param partyData
     */
    private static void handPartyData(PartyData partyData) {
        //清除军事矿区积分
        partyData.setScore(0);
        //清除申请记录
        partyData.getApplys().clear();
        //百团混战
        partyData.getWarRecords().clear();
        partyData.setRegLv(0);
        partyData.setRegFight(0);
        partyData.setWarRank(0);
        //军情、民情 里面有些有玩家id
        partyData.getTrends().clear();
        //捐赠id里面也有玩家id
        if (partyData.getDonates(1) != null) {
            partyData.getDonates(1).clear();
        }
        if (partyData.getDonates(2) != null) {
            partyData.getDonates(2).clear();
        }

        partyData.getAirshipTeamMap().clear();
        partyData.getAirshipGuardMap().clear();
        partyData.getAirshipLeaderMap().clear();
        partyData.getFreeMap().clear();
    }

    /**
     * 处理军团成员数据
     *
     * @param member
     */
    private static void handPartyMember(Member member) {
        member.setRegParty(0);
        member.setRegLv(0);
        member.setRegTime(0);
        member.setRegFight(0);
        member.setApplyList("|");
        member.getWarRecords().clear();
    }
}
