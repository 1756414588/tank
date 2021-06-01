/**
 * 由于服务器处理消息是单线程处理 应尽可能保证效率 比如一些记日志的代码 不适合放在消息处理线程中做  所以张大虎加入了actor
 */
package com.game.server.Actor;