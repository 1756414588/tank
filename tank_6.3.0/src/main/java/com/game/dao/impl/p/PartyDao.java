package com.game.dao.impl.p;

import java.util.List;

import com.game.dao.BaseDao;
import com.game.domain.p.Party;
import com.game.domain.p.PartyMember;
/**
* @ClassName: PartyDao 
* @Description: 军团相关
* @author
 */
public class PartyDao extends BaseDao {

    public int selectMaxPartyIdInThisServer(int id_flag){
        Integer maxId = this.getSqlSession().selectOne("PartyDao.selectMaxPartyIdInThisServer", id_flag);
        return maxId != null ? maxId : 0;
    }

	public List<Party> selectParyList() {
		return this.getSqlSession().selectList("PartyDao.selectParyList");
	}
	
//	public List<Party> selectParyLvList() {
//		return this.getSqlSession().selectList("PartyDao.selectParyLvList");
//	}
//
//	public Map<Integer, Party> lord() {
//		return this.getSqlSession().selectMap("PartyDao.selectParyList", "partyId");
//	}
//
//	public Party selectPary(int partyId) {
//		return this.getSqlSession().selectOne("PartyDao.selectPary", partyId);
//	}
//
	public int updatePary(Party party) {
		return this.getSqlSession().update("PartyDao.updatePary", party);
	}

	public void insertPary(Party party) {
		this.getSqlSession().insert("PartyDao.insertPary", party);
	}
	
	public int insertFullParty(Party party) {
		return this.getSqlSession().insert("PartyDao.insertFullParty", party);
	}

	public List<PartyMember> selectParyMemberList() {
		return this.getSqlSession().selectList("PartyDao.selectParyMemberList");
	}
//
//	public Map<Long, PartyMember> lordMember() {
//		return this.getSqlSession().selectMap("PartyDao.selectParyMemberList", "lordId");
//	}
//
	public int updateParyMember(PartyMember partyMember) {
		return this.getSqlSession().update("PartyDao.updateParyMember", partyMember);
	}
	
	public void insertParyMember(PartyMember partyMember) {
		this.getSqlSession().insert("PartyDao.insertParyMember", partyMember);
	}
	
	public int insertFullPartyMember(PartyMember partyMember) {
		return this.getSqlSession().insert("PartyDao.insertFullPartyMember", partyMember);
	}

    public List<PartyMember> selectPartyMemberFilterSmallId(){
        return this.getSqlSession().selectList("PartyDao.selectPartyMemberFilterSmallId");
    }

    public int updatePartyLegatusName(){
        return this.getSqlSession().update("PartyDao.updatePartyLegatusName");
    }

    public int clearPartyDataWithMerge(){
        return this.getSqlSession().update("PartyDao.clearPartyDataWithMerge");
    }
}
