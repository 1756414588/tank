/**
 * @Title: ITimerEvent.java @Package com.game.server.timer @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月11日 下午5:52:17
 * @version V1.0
 */
package com.game.server.timer;

import com.game.server.ICommand;

/**
 * @ClassName: ITimerEvent @Description: TODO
 *
 * @author ZhangJun
 * @date 2015年8月11日 下午5:52:17
 */
public interface ITimerEvent extends ICommand {
  long remain();
}
