/**
 * @Title: ITimerEvent.java
 * @Package com.game.server.timer
 * @Description:
 * @author ZhangJun
 * @date 2015年8月11日 下午5:52:17
 * @version V1.0
 */
package com.game.server.timer;

import com.game.server.ICommand;

/**
 * @author ZhangJun
 * @ClassName: ITimerEvent
 * @Description: 定时任务接口 除了继承ICommand的action方法以外 定义remain方法来控制任务执行频率
 * @date 2015年8月11日 下午5:52:17
 */
public interface ITimerEvent extends ICommand {
    long remain();
}
