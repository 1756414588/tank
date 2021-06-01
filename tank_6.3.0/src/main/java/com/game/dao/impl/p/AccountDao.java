package com.game.dao.impl.p;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import com.game.dao.BaseDao;
import com.game.domain.p.Account;
import com.game.domain.p.CountAccount;
/**
* @ClassName: AccountDao 
* @Description: 账号表
* @author
 */
public class AccountDao extends BaseDao {

    public List<CountAccount> countAccountGroupByPlatAndServerId(){
        return this.getSqlSession().selectList("AccountDao.countAccountGroupByPlatAndServerId");
    }

	public Account selectAccount(int accountKey, int serverId) {
		Map<String, Object> param = paramsMap();
		param.put("accountKey", accountKey);
		param.put("serverId", serverId);
		return this.getSqlSession().selectOne("AccountDao.selectAccount", param);
	}

	public Account selectAccountByLordId(long lordId) {
		 return this.getSqlSession().selectOne("AccountDao.selectAccountByLordId",lordId);
	}

	public Account selectAccountByKeyId(int keyId) {
		return this.getSqlSession().selectOne("AccountDao.selectAccountByKeyId", keyId);
	}

	public Map<Long, Account> selectAccountMapByLords(List<Long> lordIds) {
		return this.getSqlSession().selectMap("AccountDao.selectAccountMapByLords", lordIds, "lordId");
	}

	public void updateCreateRole(Account account) {
		this.getSqlSession().update("AccountDao.updateCreateRole", account);
	}

	// public void updateNick(Long lordId, String nick) {
	// Map<String, Object> param = paramsMap();
	// param.put("lordId", lordId);
	// param.put("nick", nick);
	// this.getSqlSession().update("AccountDao.updateNick", param);
	// }

	public void insertAccount(Account account) {
		this.getSqlSession().insert("AccountDao.insertAccount", account);
	}
	
	public int insertFullAccount(Account account) {
		return this.getSqlSession().insert("AccountDao.insertFullAccount", account);
	}

	public void recordLoginTime(Account account) {
		this.getSqlSession().update("AccountDao.recordLoginTime", account);
	}

	/**   
	* Method: updateIord    
	* @Description:     
	* @param account    
	* @return void    
	*/
	public void updateIordId(Account account) {
		this.getSqlSession().update("AccountDao.updateIordId", account);
	}
	
    public void updatePlatNo(Account account) {
        this.getSqlSession().update("AccountDao.updatePlatNo", account);
    }	
	
	// public int sameNameCount(String nick) {
	// return this.getSqlSession().selectOne("AccountDao.sameNameCount", nick);
	// }

	public List<Account> load() {
		List<Account> list = new ArrayList<>();
		long curIndex = 0L;
		int count = 1000;
		int pageSize = 0;
		while (true) {
			List<Account> page = load(curIndex, count);
			pageSize = page.size();
			if (pageSize > 0) {
				list.addAll(page);
				curIndex = page.get(pageSize - 1).getKeyId();
			} else {
				break;
			}

			if (pageSize < count) {
				break;
			}
		}
		return list;
	}

	private List<Account> load(long curIndex, int count) {
		Map<String, Object> params = paramsMap();
		params.put("curIndex", curIndex);
		params.put("count", count);
		return this.getSqlSession().selectList("AccountDao.load", params);
	}

	public List<Account> selectAll() {
		return this.getSqlSession().selectList("AccountDao.selectAll");
	}

	public List<Account> selectAccountByAccountKeyAndServerId(List<Account> oldSlaveAccounts) {
		return this.getSqlSession().selectList("AccountDao.selectAccountByAccountKeyAndServerId",oldSlaveAccounts);
	}
}
