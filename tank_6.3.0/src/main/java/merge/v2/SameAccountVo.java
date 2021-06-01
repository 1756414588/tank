package merge.v2;

import com.game.domain.p.Account;
import merge.MServer;

import java.util.List;

/**
 * @author ：Liu Gui Jie
 * @date ：Created in 2019/5/27 17:31
 * @description：
 */
public class SameAccountVo {

    private int accountKey;

    private int serverId;

    public String getKey() {
        return accountKey + "-" + serverId;
    }

    private List<SameAccount> sameAccount;

    public int getAccountKey() {
        return accountKey;
    }

    public void setAccountKey(int accountKey) {
        this.accountKey = accountKey;
    }

    public int getServerId() {
        return serverId;
    }

    public void setServerId(int serverId) {
        this.serverId = serverId;
    }

    public List<SameAccount> getSameAccount() {
        return sameAccount;
    }

    public void setSameAccount(List<SameAccount> sameAccount) {
        this.sameAccount = sameAccount;
    }
}

class SameAccount {

    private long roleId;
    private String name;
    private int level;


    private Account account;

    private MServer slave;

    public Account getAccount() {
        return account;
    }

    public void setAccount(Account account) {
        this.account = account;
    }

    public MServer getSlave() {
        return slave;
    }

    public void setSlave(MServer slave) {
        this.slave = slave;
    }

    public int getLevel() {
        return level;
    }

    public void setLevel(int level) {
        this.level = level;
    }

    public long getRoleId() {
        return roleId;
    }

    public void setRoleId(long roleId) {
        this.roleId = roleId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

}