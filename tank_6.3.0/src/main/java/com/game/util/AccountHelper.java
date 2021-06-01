package com.game.util;

import com.game.domain.p.Account;

import java.util.Date;


/**
 * 账号相关帮助类
* @ClassName: AccountHelper 
* @Description: TODO
* @author
 */
public class AccountHelper {
    /**
     * 
    * 账号是否被禁了
    * @param account
    * @return  
    * boolean
     */
	public static boolean isForbid(Account account) {
//		return account.getForbid() == 1;
		int Forbid=account.getForbid();
		if (Forbid > 0) {
			int currentTime=Integer.parseInt(String.valueOf( new Date().getTime()/1000 ));
			if(Forbid==1){
				return true;
			}else if(Forbid > currentTime )
			{
				LogUtil.silence(account.getLordId()+" Silence account time:" + (Forbid-currentTime)+"("+Forbid+"-"+currentTime+")");
				return true;
			}
		}
		return false;
	}
}
