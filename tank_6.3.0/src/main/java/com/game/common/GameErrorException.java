/**
 * 
 */
package com.game.common;

import com.game.constant.GameError;

/**
 * 
* @ClassName: GameErrorException 
* @Description: 提供一个可以封装GameError错误枚举的异常 用于捕获游戏逻辑异常  比如参数错误  可以在里层方法处理逻辑时抛出   最外层方法捕获这个异常  来讲错误码发送给客户端
* @author 丁文渊
 */
public class GameErrorException extends TankException {
  
    private static final long serialVersionUID = 1L;
    private GameError gameError;
    
    /**
     * 
    * Title: 
    * Description: 
    * @param gameError 错误码枚举
     */
    public GameErrorException(GameError gameError) {
        super();
        this.gameError = gameError;
    }
    /**
     * @return the gameError
     */
    public GameError getGameError() {
        return gameError;
    }
    /**
     * @param gameError the gameError to set
     */
    public void setGameError(GameError gameError) {
        this.gameError = gameError;
    }

}
