package com.game.grpc.proto.mine;

import static io.grpc.MethodDescriptor.generateFullMethodName;
import static io.grpc.stub.ClientCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ClientCalls.asyncClientStreamingCall;
import static io.grpc.stub.ClientCalls.asyncServerStreamingCall;
import static io.grpc.stub.ClientCalls.asyncUnaryCall;
import static io.grpc.stub.ClientCalls.blockingServerStreamingCall;
import static io.grpc.stub.ClientCalls.blockingUnaryCall;
import static io.grpc.stub.ClientCalls.futureUnaryCall;
import static io.grpc.stub.ServerCalls.asyncBidiStreamingCall;
import static io.grpc.stub.ServerCalls.asyncClientStreamingCall;
import static io.grpc.stub.ServerCalls.asyncServerStreamingCall;
import static io.grpc.stub.ServerCalls.asyncUnaryCall;
import static io.grpc.stub.ServerCalls.asyncUnimplementedStreamingCall;
import static io.grpc.stub.ServerCalls.asyncUnimplementedUnaryCall;

/**
 * <pre>
 *侦查军矿
 * </pre>
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.10.0)",
    comments = "Source: mine.proto")
public final class MineHandlerGrpc {

  private MineHandlerGrpc() {}

  public static final String SERVICE_NAME = "MineHandler";

  // Static method descriptors that strictly reflect the proto.
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getScoutMineMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> METHOD_SCOUT_MINE = getScoutMineMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> getScoutMineMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> getScoutMineMethod() {
    return getScoutMineMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> getScoutMineMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> getScoutMineMethod;
    if ((getScoutMineMethod = MineHandlerGrpc.getScoutMineMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getScoutMineMethod = MineHandlerGrpc.getScoutMineMethod) == null) {
          MineHandlerGrpc.getScoutMineMethod = getScoutMineMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "scoutMine"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("scoutMine"))
                  .build();
          }
        }
     }
     return getScoutMineMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getFindMineMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> METHOD_FIND_MINE = getFindMineMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> getFindMineMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> getFindMineMethod() {
    return getFindMineMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> getFindMineMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> getFindMineMethod;
    if ((getFindMineMethod = MineHandlerGrpc.getFindMineMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getFindMineMethod = MineHandlerGrpc.getFindMineMethod) == null) {
          MineHandlerGrpc.getFindMineMethod = getFindMineMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "findMine"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("findMine"))
                  .build();
          }
        }
     }
     return getFindMineMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getFightMineMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> METHOD_FIGHT_MINE = getFightMineMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> getFightMineMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> getFightMineMethod() {
    return getFightMineMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> getFightMineMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> getFightMineMethod;
    if ((getFightMineMethod = MineHandlerGrpc.getFightMineMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getFightMineMethod = MineHandlerGrpc.getFightMineMethod) == null) {
          MineHandlerGrpc.getFightMineMethod = getFightMineMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "fightMine"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("fightMine"))
                  .build();
          }
        }
     }
     return getFightMineMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getCheckScoreRankMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> METHOD_CHECK_SCORE_RANK = getCheckScoreRankMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> getCheckScoreRankMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> getCheckScoreRankMethod() {
    return getCheckScoreRankMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> getCheckScoreRankMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> getCheckScoreRankMethod;
    if ((getCheckScoreRankMethod = MineHandlerGrpc.getCheckScoreRankMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getCheckScoreRankMethod = MineHandlerGrpc.getCheckScoreRankMethod) == null) {
          MineHandlerGrpc.getCheckScoreRankMethod = getCheckScoreRankMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "checkScoreRank"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("checkScoreRank"))
                  .build();
          }
        }
     }
     return getCheckScoreRankMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getGetScoreRankMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> METHOD_GET_SCORE_RANK = getGetScoreRankMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetScoreRankMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetScoreRankMethod() {
    return getGetScoreRankMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetScoreRankMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetScoreRankMethod;
    if ((getGetScoreRankMethod = MineHandlerGrpc.getGetScoreRankMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getGetScoreRankMethod = MineHandlerGrpc.getGetScoreRankMethod) == null) {
          MineHandlerGrpc.getGetScoreRankMethod = getGetScoreRankMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "getScoreRank"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("getScoreRank"))
                  .build();
          }
        }
     }
     return getGetScoreRankMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getCheckServerScoreRankMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> METHOD_CHECK_SERVER_SCORE_RANK = getCheckServerScoreRankMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> getCheckServerScoreRankMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> getCheckServerScoreRankMethod() {
    return getCheckServerScoreRankMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> getCheckServerScoreRankMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> getCheckServerScoreRankMethod;
    if ((getCheckServerScoreRankMethod = MineHandlerGrpc.getCheckServerScoreRankMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getCheckServerScoreRankMethod = MineHandlerGrpc.getCheckServerScoreRankMethod) == null) {
          MineHandlerGrpc.getCheckServerScoreRankMethod = getCheckServerScoreRankMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "checkServerScoreRank"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("checkServerScoreRank"))
                  .build();
          }
        }
     }
     return getCheckServerScoreRankMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getGetServerScoreRankMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> METHOD_GET_SERVER_SCORE_RANK = getGetServerScoreRankMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetServerScoreRankMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetServerScoreRankMethod() {
    return getGetServerScoreRankMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetServerScoreRankMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getGetServerScoreRankMethod;
    if ((getGetServerScoreRankMethod = MineHandlerGrpc.getGetServerScoreRankMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getGetServerScoreRankMethod = MineHandlerGrpc.getGetServerScoreRankMethod) == null) {
          MineHandlerGrpc.getGetServerScoreRankMethod = getGetServerScoreRankMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "getServerScoreRank"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("getServerScoreRank"))
                  .build();
          }
        }
     }
     return getGetServerScoreRankMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getRetreatArmyMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> METHOD_RETREAT_ARMY = getRetreatArmyMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getRetreatArmyMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getRetreatArmyMethod() {
    return getRetreatArmyMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getRetreatArmyMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getRetreatArmyMethod;
    if ((getRetreatArmyMethod = MineHandlerGrpc.getRetreatArmyMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getRetreatArmyMethod = MineHandlerGrpc.getRetreatArmyMethod) == null) {
          MineHandlerGrpc.getRetreatArmyMethod = getRetreatArmyMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "retreatArmy"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("retreatArmy"))
                  .build();
          }
        }
     }
     return getRetreatArmyMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getCrossMineGmMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> METHOD_CROSS_MINE_GM = getCrossMineGmMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getCrossMineGmMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getCrossMineGmMethod() {
    return getCrossMineGmMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest,
      com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getCrossMineGmMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> getCrossMineGmMethod;
    if ((getCrossMineGmMethod = MineHandlerGrpc.getCrossMineGmMethod) == null) {
      synchronized (MineHandlerGrpc.class) {
        if ((getCrossMineGmMethod = MineHandlerGrpc.getCrossMineGmMethod) == null) {
          MineHandlerGrpc.getCrossMineGmMethod = getCrossMineGmMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest, com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "MineHandler", "crossMineGm"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new MineHandlerMethodDescriptorSupplier("crossMineGm"))
                  .build();
          }
        }
     }
     return getCrossMineGmMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static MineHandlerStub newStub(io.grpc.Channel channel) {
    return new MineHandlerStub(channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static MineHandlerBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    return new MineHandlerBlockingStub(channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static MineHandlerFutureStub newFutureStub(
      io.grpc.Channel channel) {
    return new MineHandlerFutureStub(channel);
  }

  /**
   * <pre>
   *侦查军矿
   * </pre>
   */
  public static abstract class MineHandlerImplBase implements io.grpc.BindableService {

    /**
     * <pre>
     *侦查军矿
     * </pre>
     */
    public void scoutMine(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getScoutMineMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *查看军矿
     * </pre>
     */
    public void findMine(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getFindMineMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *攻打军矿
     * </pre>
     */
    public void fightMine(com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getFightMineMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *查看排名
     * </pre>
     */
    public void checkScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getCheckScoreRankMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *领取排名奖励
     * </pre>
     */
    public void getScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getGetScoreRankMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *查看服务器排名
     * </pre>
     */
    public void checkServerScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getCheckServerScoreRankMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *领取服务器排名奖励
     * </pre>
     */
    public void getServerScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getGetServerScoreRankMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *撤军
     * </pre>
     */
    public void retreatArmy(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getRetreatArmyMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *gm
     * </pre>
     */
    public void crossMineGm(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getCrossMineGmMethodHelper(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getScoutMineMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse>(
                  this, METHODID_SCOUT_MINE)))
          .addMethod(
            getFindMineMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse>(
                  this, METHODID_FIND_MINE)))
          .addMethod(
            getFightMineMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse>(
                  this, METHODID_FIGHT_MINE)))
          .addMethod(
            getCheckScoreRankMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse>(
                  this, METHODID_CHECK_SCORE_RANK)))
          .addMethod(
            getGetScoreRankMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse>(
                  this, METHODID_GET_SCORE_RANK)))
          .addMethod(
            getCheckServerScoreRankMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse>(
                  this, METHODID_CHECK_SERVER_SCORE_RANK)))
          .addMethod(
            getGetServerScoreRankMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse>(
                  this, METHODID_GET_SERVER_SCORE_RANK)))
          .addMethod(
            getRetreatArmyMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse>(
                  this, METHODID_RETREAT_ARMY)))
          .addMethod(
            getCrossMineGmMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest,
                com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse>(
                  this, METHODID_CROSS_MINE_GM)))
          .build();
    }
  }

  /**
   * <pre>
   *侦查军矿
   * </pre>
   */
  public static final class MineHandlerStub extends io.grpc.stub.AbstractStub<MineHandlerStub> {
    private MineHandlerStub(io.grpc.Channel channel) {
      super(channel);
    }

    private MineHandlerStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected MineHandlerStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new MineHandlerStub(channel, callOptions);
    }

    /**
     * <pre>
     *侦查军矿
     * </pre>
     */
    public void scoutMine(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getScoutMineMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *查看军矿
     * </pre>
     */
    public void findMine(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getFindMineMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *攻打军矿
     * </pre>
     */
    public void fightMine(com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getFightMineMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *查看排名
     * </pre>
     */
    public void checkScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getCheckScoreRankMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *领取排名奖励
     * </pre>
     */
    public void getScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getGetScoreRankMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *查看服务器排名
     * </pre>
     */
    public void checkServerScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getCheckServerScoreRankMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *领取服务器排名奖励
     * </pre>
     */
    public void getServerScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getGetServerScoreRankMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *撤军
     * </pre>
     */
    public void retreatArmy(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getRetreatArmyMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *gm
     * </pre>
     */
    public void crossMineGm(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getCrossMineGmMethodHelper(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   * <pre>
   *侦查军矿
   * </pre>
   */
  public static final class MineHandlerBlockingStub extends io.grpc.stub.AbstractStub<MineHandlerBlockingStub> {
    private MineHandlerBlockingStub(io.grpc.Channel channel) {
      super(channel);
    }

    private MineHandlerBlockingStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected MineHandlerBlockingStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new MineHandlerBlockingStub(channel, callOptions);
    }

    /**
     * <pre>
     *侦查军矿
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse scoutMine(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest request) {
      return blockingUnaryCall(
          getChannel(), getScoutMineMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *查看军矿
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse findMine(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest request) {
      return blockingUnaryCall(
          getChannel(), getFindMineMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *攻打军矿
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse fightMine(com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest request) {
      return blockingUnaryCall(
          getChannel(), getFightMineMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *查看排名
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse checkScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest request) {
      return blockingUnaryCall(
          getChannel(), getCheckScoreRankMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *领取排名奖励
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse getScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request) {
      return blockingUnaryCall(
          getChannel(), getGetScoreRankMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *查看服务器排名
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse checkServerScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest request) {
      return blockingUnaryCall(
          getChannel(), getCheckServerScoreRankMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *领取服务器排名奖励
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse getServerScoreRank(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request) {
      return blockingUnaryCall(
          getChannel(), getGetServerScoreRankMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *撤军
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse retreatArmy(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest request) {
      return blockingUnaryCall(
          getChannel(), getRetreatArmyMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *gm
     * </pre>
     */
    public com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse crossMineGm(com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest request) {
      return blockingUnaryCall(
          getChannel(), getCrossMineGmMethodHelper(), getCallOptions(), request);
    }
  }

  /**
   * <pre>
   *侦查军矿
   * </pre>
   */
  public static final class MineHandlerFutureStub extends io.grpc.stub.AbstractStub<MineHandlerFutureStub> {
    private MineHandlerFutureStub(io.grpc.Channel channel) {
      super(channel);
    }

    private MineHandlerFutureStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected MineHandlerFutureStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new MineHandlerFutureStub(channel, callOptions);
    }

    /**
     * <pre>
     *侦查军矿
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse> scoutMine(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getScoutMineMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *查看军矿
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse> findMine(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getFindMineMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *攻打军矿
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse> fightMine(
        com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getFightMineMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *查看排名
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse> checkScoreRank(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getCheckScoreRankMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *领取排名奖励
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getScoreRank(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getGetScoreRankMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *查看服务器排名
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse> checkServerScoreRank(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getCheckServerScoreRankMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *领取服务器排名奖励
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse> getServerScoreRank(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getGetServerScoreRankMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *撤军
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> retreatArmy(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getRetreatArmyMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *gm
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse> crossMineGm(
        com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest request) {
      return futureUnaryCall(
          getChannel().newCall(getCrossMineGmMethodHelper(), getCallOptions()), request);
    }
  }

  private static final int METHODID_SCOUT_MINE = 0;
  private static final int METHODID_FIND_MINE = 1;
  private static final int METHODID_FIGHT_MINE = 2;
  private static final int METHODID_CHECK_SCORE_RANK = 3;
  private static final int METHODID_GET_SCORE_RANK = 4;
  private static final int METHODID_CHECK_SERVER_SCORE_RANK = 5;
  private static final int METHODID_GET_SERVER_SCORE_RANK = 6;
  private static final int METHODID_RETREAT_ARMY = 7;
  private static final int METHODID_CROSS_MINE_GM = 8;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final MineHandlerImplBase serviceImpl;
    private final int methodId;

    MethodHandlers(MineHandlerImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_SCOUT_MINE:
          serviceImpl.scoutMine((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoutMineResponse>) responseObserver);
          break;
        case METHODID_FIND_MINE:
          serviceImpl.findMine((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcFindMineResponse>) responseObserver);
          break;
        case METHODID_FIGHT_MINE:
          serviceImpl.fightMine((com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.FightMineResponse>) responseObserver);
          break;
        case METHODID_CHECK_SCORE_RANK:
          serviceImpl.checkScoreRank((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcScoreRankResponse>) responseObserver);
          break;
        case METHODID_GET_SCORE_RANK:
          serviceImpl.getScoreRank((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse>) responseObserver);
          break;
        case METHODID_CHECK_SERVER_SCORE_RANK:
          serviceImpl.checkServerScoreRank((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcServerScoreRankResponse>) responseObserver);
          break;
        case METHODID_GET_SERVER_SCORE_RANK:
          serviceImpl.getServerScoreRank((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcCoreAwardResponse>) responseObserver);
          break;
        case METHODID_RETREAT_ARMY:
          serviceImpl.retreatArmy((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse>) responseObserver);
          break;
        case METHODID_CROSS_MINE_GM:
          serviceImpl.crossMineGm((com.game.grpc.proto.mine.CrossSeniorMineProto.RpcGmquest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.mine.CrossSeniorMineProto.RpcRetreatArmyResponse>) responseObserver);
          break;
        default:
          throw new AssertionError();
      }
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public io.grpc.stub.StreamObserver<Req> invoke(
        io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        default:
          throw new AssertionError();
      }
    }
  }

  private static abstract class MineHandlerBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    MineHandlerBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.game.grpc.proto.mine.CrossSeniorMineProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("MineHandler");
    }
  }

  private static final class MineHandlerFileDescriptorSupplier
      extends MineHandlerBaseDescriptorSupplier {
    MineHandlerFileDescriptorSupplier() {}
  }

  private static final class MineHandlerMethodDescriptorSupplier
      extends MineHandlerBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final String methodName;

    MineHandlerMethodDescriptorSupplier(String methodName) {
      this.methodName = methodName;
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.MethodDescriptor getMethodDescriptor() {
      return getServiceDescriptor().findMethodByName(methodName);
    }
  }

  private static volatile io.grpc.ServiceDescriptor serviceDescriptor;

  public static io.grpc.ServiceDescriptor getServiceDescriptor() {
    io.grpc.ServiceDescriptor result = serviceDescriptor;
    if (result == null) {
      synchronized (MineHandlerGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new MineHandlerFileDescriptorSupplier())
              .addMethod(getScoutMineMethodHelper())
              .addMethod(getFindMineMethodHelper())
              .addMethod(getFightMineMethodHelper())
              .addMethod(getCheckScoreRankMethodHelper())
              .addMethod(getGetScoreRankMethodHelper())
              .addMethod(getCheckServerScoreRankMethodHelper())
              .addMethod(getGetServerScoreRankMethodHelper())
              .addMethod(getRetreatArmyMethodHelper())
              .addMethod(getCrossMineGmMethodHelper())
              .build();
        }
      }
    }
    return result;
  }
}
