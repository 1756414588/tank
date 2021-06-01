package com.game.grpc.proto.team;

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
 */
@javax.annotation.Generated(
    value = "by gRPC proto compiler (version 1.10.0)",
    comments = "Source: team.proto")
public final class TeamHandlerGrpc {

  private TeamHandlerGrpc() {}

  public static final String SERVICE_NAME = "TeamHandler";

  // Static method descriptors that strictly reflect the proto.
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getSynPlayerMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_SYN_PLAYER = getSynPlayerMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynPlayerMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynPlayerMethod() {
    return getSynPlayerMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynPlayerMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynPlayerMethod;
    if ((getSynPlayerMethod = TeamHandlerGrpc.getSynPlayerMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getSynPlayerMethod = TeamHandlerGrpc.getSynPlayerMethod) == null) {
          TeamHandlerGrpc.getSynPlayerMethod = getSynPlayerMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "synPlayer"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("synPlayer"))
                  .build();
          }
        }
     }
     return getSynPlayerMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getCreateTeamMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> METHOD_CREATE_TEAM = getCreateTeamMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> getCreateTeamMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> getCreateTeamMethod() {
    return getCreateTeamMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> getCreateTeamMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> getCreateTeamMethod;
    if ((getCreateTeamMethod = TeamHandlerGrpc.getCreateTeamMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getCreateTeamMethod = TeamHandlerGrpc.getCreateTeamMethod) == null) {
          TeamHandlerGrpc.getCreateTeamMethod = getCreateTeamMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "createTeam"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("createTeam"))
                  .build();
          }
        }
     }
     return getCreateTeamMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getDismissTeamMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_DISMISS_TEAM = getDismissTeamMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getDismissTeamMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getDismissTeamMethod() {
    return getDismissTeamMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getDismissTeamMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getDismissTeamMethod;
    if ((getDismissTeamMethod = TeamHandlerGrpc.getDismissTeamMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getDismissTeamMethod = TeamHandlerGrpc.getDismissTeamMethod) == null) {
          TeamHandlerGrpc.getDismissTeamMethod = getDismissTeamMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "dismissTeam"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("dismissTeam"))
                  .build();
          }
        }
     }
     return getDismissTeamMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getFindTeamMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_FIND_TEAM = getFindTeamMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFindTeamMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFindTeamMethod() {
    return getFindTeamMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFindTeamMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFindTeamMethod;
    if ((getFindTeamMethod = TeamHandlerGrpc.getFindTeamMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getFindTeamMethod = TeamHandlerGrpc.getFindTeamMethod) == null) {
          TeamHandlerGrpc.getFindTeamMethod = getFindTeamMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "findTeam"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("findTeam"))
                  .build();
          }
        }
     }
     return getFindTeamMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getLeaveTeamMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_LEAVE_TEAM = getLeaveTeamMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLeaveTeamMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLeaveTeamMethod() {
    return getLeaveTeamMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLeaveTeamMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLeaveTeamMethod;
    if ((getLeaveTeamMethod = TeamHandlerGrpc.getLeaveTeamMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getLeaveTeamMethod = TeamHandlerGrpc.getLeaveTeamMethod) == null) {
          TeamHandlerGrpc.getLeaveTeamMethod = getLeaveTeamMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "leaveTeam"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("leaveTeam"))
                  .build();
          }
        }
     }
     return getLeaveTeamMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getKickTeamMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_KICK_TEAM = getKickTeamMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getKickTeamMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getKickTeamMethod() {
    return getKickTeamMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getKickTeamMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getKickTeamMethod;
    if ((getKickTeamMethod = TeamHandlerGrpc.getKickTeamMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getKickTeamMethod = TeamHandlerGrpc.getKickTeamMethod) == null) {
          TeamHandlerGrpc.getKickTeamMethod = getKickTeamMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "kickTeam"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("kickTeam"))
                  .build();
          }
        }
     }
     return getKickTeamMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getJoinTeamMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_JOIN_TEAM = getJoinTeamMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getJoinTeamMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getJoinTeamMethod() {
    return getJoinTeamMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getJoinTeamMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getJoinTeamMethod;
    if ((getJoinTeamMethod = TeamHandlerGrpc.getJoinTeamMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getJoinTeamMethod = TeamHandlerGrpc.getJoinTeamMethod) == null) {
          TeamHandlerGrpc.getJoinTeamMethod = getJoinTeamMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "joinTeam"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("joinTeam"))
                  .build();
          }
        }
     }
     return getJoinTeamMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getChangeTeamOrderMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_CHANGE_TEAM_ORDER = getChangeTeamOrderMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeTeamOrderMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeTeamOrderMethod() {
    return getChangeTeamOrderMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeTeamOrderMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeTeamOrderMethod;
    if ((getChangeTeamOrderMethod = TeamHandlerGrpc.getChangeTeamOrderMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getChangeTeamOrderMethod = TeamHandlerGrpc.getChangeTeamOrderMethod) == null) {
          TeamHandlerGrpc.getChangeTeamOrderMethod = getChangeTeamOrderMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "changeTeamOrder"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("changeTeamOrder"))
                  .build();
          }
        }
     }
     return getChangeTeamOrderMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getChangeMemberStatusMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_CHANGE_MEMBER_STATUS = getChangeMemberStatusMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeMemberStatusMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeMemberStatusMethod() {
    return getChangeMemberStatusMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeMemberStatusMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getChangeMemberStatusMethod;
    if ((getChangeMemberStatusMethod = TeamHandlerGrpc.getChangeMemberStatusMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getChangeMemberStatusMethod = TeamHandlerGrpc.getChangeMemberStatusMethod) == null) {
          TeamHandlerGrpc.getChangeMemberStatusMethod = getChangeMemberStatusMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "changeMemberStatus"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("changeMemberStatus"))
                  .build();
          }
        }
     }
     return getChangeMemberStatusMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getTeamChatMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> METHOD_TEAM_CHAT = getTeamChatMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> getTeamChatMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> getTeamChatMethod() {
    return getTeamChatMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> getTeamChatMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest, com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> getTeamChatMethod;
    if ((getTeamChatMethod = TeamHandlerGrpc.getTeamChatMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getTeamChatMethod = TeamHandlerGrpc.getTeamChatMethod) == null) {
          TeamHandlerGrpc.getTeamChatMethod = getTeamChatMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest, com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "teamChat"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("teamChat"))
                  .build();
          }
        }
     }
     return getTeamChatMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getLookFormMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> METHOD_LOOK_FORM = getLookFormMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> getLookFormMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> getLookFormMethod() {
    return getLookFormMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> getLookFormMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest, com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> getLookFormMethod;
    if ((getLookFormMethod = TeamHandlerGrpc.getLookFormMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getLookFormMethod = TeamHandlerGrpc.getLookFormMethod) == null) {
          TeamHandlerGrpc.getLookFormMethod = getLookFormMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest, com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "lookForm"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("lookForm"))
                  .build();
          }
        }
     }
     return getLookFormMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getTeamInviteMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_TEAM_INVITE = getTeamInviteMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getTeamInviteMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getTeamInviteMethod() {
    return getTeamInviteMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getTeamInviteMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getTeamInviteMethod;
    if ((getTeamInviteMethod = TeamHandlerGrpc.getTeamInviteMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getTeamInviteMethod = TeamHandlerGrpc.getTeamInviteMethod) == null) {
          TeamHandlerGrpc.getTeamInviteMethod = getTeamInviteMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "teamInvite"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("teamInvite"))
                  .build();
          }
        }
     }
     return getTeamInviteMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getFightMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_FIGHT = getFightMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFightMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFightMethod() {
    return getFightMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFightMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getFightMethod;
    if ((getFightMethod = TeamHandlerGrpc.getFightMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getFightMethod = TeamHandlerGrpc.getFightMethod) == null) {
          TeamHandlerGrpc.getFightMethod = getFightMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "fight"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("fight"))
                  .build();
          }
        }
     }
     return getFightMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getSynFormMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_SYN_FORM = getSynFormMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynFormMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynFormMethod() {
    return getSynFormMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynFormMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getSynFormMethod;
    if ((getSynFormMethod = TeamHandlerGrpc.getSynFormMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getSynFormMethod = TeamHandlerGrpc.getSynFormMethod) == null) {
          TeamHandlerGrpc.getSynFormMethod = getSynFormMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "synForm"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("synForm"))
                  .build();
          }
        }
     }
     return getSynFormMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getLogOutMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_LOG_OUT = getLogOutMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLogOutMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLogOutMethod() {
    return getLogOutMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLogOutMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getLogOutMethod;
    if ((getLogOutMethod = TeamHandlerGrpc.getLogOutMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getLogOutMethod = TeamHandlerGrpc.getLogOutMethod) == null) {
          TeamHandlerGrpc.getLogOutMethod = getLogOutMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "logOut"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("logOut"))
                  .build();
          }
        }
     }
     return getLogOutMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getWorldChatMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> METHOD_WORLD_CHAT = getWorldChatMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getWorldChatMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getWorldChatMethod() {
    return getWorldChatMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest,
      com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getWorldChatMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> getWorldChatMethod;
    if ((getWorldChatMethod = TeamHandlerGrpc.getWorldChatMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getWorldChatMethod = TeamHandlerGrpc.getWorldChatMethod) == null) {
          TeamHandlerGrpc.getWorldChatMethod = getWorldChatMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest, com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "worldChat"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("worldChat"))
                  .build();
          }
        }
     }
     return getWorldChatMethod;
  }
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getQueryServerListMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> METHOD_QUERY_SERVER_LIST = getQueryServerListMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> getQueryServerListMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> getQueryServerListMethod() {
    return getQueryServerListMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest,
      com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> getQueryServerListMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest, com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> getQueryServerListMethod;
    if ((getQueryServerListMethod = TeamHandlerGrpc.getQueryServerListMethod) == null) {
      synchronized (TeamHandlerGrpc.class) {
        if ((getQueryServerListMethod = TeamHandlerGrpc.getQueryServerListMethod) == null) {
          TeamHandlerGrpc.getQueryServerListMethod = getQueryServerListMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest, com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "TeamHandler", "queryServerList"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new TeamHandlerMethodDescriptorSupplier("queryServerList"))
                  .build();
          }
        }
     }
     return getQueryServerListMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static TeamHandlerStub newStub(io.grpc.Channel channel) {
    return new TeamHandlerStub(channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static TeamHandlerBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    return new TeamHandlerBlockingStub(channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static TeamHandlerFutureStub newFutureStub(
      io.grpc.Channel channel) {
    return new TeamHandlerFutureStub(channel);
  }

  /**
   */
  public static abstract class TeamHandlerImplBase implements io.grpc.BindableService {

    /**
     * <pre>
     *同步信息
     * </pre>
     */
    public void synPlayer(com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getSynPlayerMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *创建组队
     * </pre>
     */
    public void createTeam(com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getCreateTeamMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *解散队伍
     * </pre>
     */
    public void dismissTeam(com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getDismissTeamMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *寻找队伍
     * </pre>
     */
    public void findTeam(com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getFindTeamMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *退出队伍
     * </pre>
     */
    public void leaveTeam(com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getLeaveTeamMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *踢出队伍
     * </pre>
     */
    public void kickTeam(com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getKickTeamMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *加入队伍
     * </pre>
     */
    public void joinTeam(com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getJoinTeamMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *交换队伍出站顺序
     * </pre>
     */
    public void changeTeamOrder(com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getChangeTeamOrderMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *更改队员准备状态
     * </pre>
     */
    public void changeMemberStatus(com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getChangeMemberStatusMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *队伍聊天
     * </pre>
     */
    public void teamChat(com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getTeamChatMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *查看阵型
     * </pre>
     */
    public void lookForm(com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getLookFormMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *世界频道发送聊天
     * </pre>
     */
    public void teamInvite(com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getTeamInviteMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *战斗
     * </pre>
     */
    public void fight(com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getFightMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *同步阵型
     * </pre>
     */
    public void synForm(com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getSynFormMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *退出
     * </pre>
     */
    public void logOut(com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getLogOutMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     *跨服世界频道聊天
     * </pre>
     */
    public void worldChat(com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getWorldChatMethodHelper(), responseObserver);
    }

    /**
     * <pre>
     * 获取服务器列表
     * </pre>
     */
    public void queryServerList(com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getQueryServerListMethodHelper(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getSynPlayerMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_SYN_PLAYER)))
          .addMethod(
            getCreateTeamMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse>(
                  this, METHODID_CREATE_TEAM)))
          .addMethod(
            getDismissTeamMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_DISMISS_TEAM)))
          .addMethod(
            getFindTeamMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_FIND_TEAM)))
          .addMethod(
            getLeaveTeamMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_LEAVE_TEAM)))
          .addMethod(
            getKickTeamMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_KICK_TEAM)))
          .addMethod(
            getJoinTeamMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_JOIN_TEAM)))
          .addMethod(
            getChangeTeamOrderMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_CHANGE_TEAM_ORDER)))
          .addMethod(
            getChangeMemberStatusMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_CHANGE_MEMBER_STATUS)))
          .addMethod(
            getTeamChatMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest,
                com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse>(
                  this, METHODID_TEAM_CHAT)))
          .addMethod(
            getLookFormMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest,
                com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse>(
                  this, METHODID_LOOK_FORM)))
          .addMethod(
            getTeamInviteMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_TEAM_INVITE)))
          .addMethod(
            getFightMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_FIGHT)))
          .addMethod(
            getSynFormMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_SYN_FORM)))
          .addMethod(
            getLogOutMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_LOG_OUT)))
          .addMethod(
            getWorldChatMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest,
                com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>(
                  this, METHODID_WORLD_CHAT)))
          .addMethod(
            getQueryServerListMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest,
                com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse>(
                  this, METHODID_QUERY_SERVER_LIST)))
          .build();
    }
  }

  /**
   */
  public static final class TeamHandlerStub extends io.grpc.stub.AbstractStub<TeamHandlerStub> {
    private TeamHandlerStub(io.grpc.Channel channel) {
      super(channel);
    }

    private TeamHandlerStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected TeamHandlerStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new TeamHandlerStub(channel, callOptions);
    }

    /**
     * <pre>
     *同步信息
     * </pre>
     */
    public void synPlayer(com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getSynPlayerMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *创建组队
     * </pre>
     */
    public void createTeam(com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getCreateTeamMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *解散队伍
     * </pre>
     */
    public void dismissTeam(com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getDismissTeamMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *寻找队伍
     * </pre>
     */
    public void findTeam(com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getFindTeamMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *退出队伍
     * </pre>
     */
    public void leaveTeam(com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getLeaveTeamMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *踢出队伍
     * </pre>
     */
    public void kickTeam(com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getKickTeamMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *加入队伍
     * </pre>
     */
    public void joinTeam(com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getJoinTeamMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *交换队伍出站顺序
     * </pre>
     */
    public void changeTeamOrder(com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getChangeTeamOrderMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *更改队员准备状态
     * </pre>
     */
    public void changeMemberStatus(com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getChangeMemberStatusMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *队伍聊天
     * </pre>
     */
    public void teamChat(com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getTeamChatMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *查看阵型
     * </pre>
     */
    public void lookForm(com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getLookFormMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *世界频道发送聊天
     * </pre>
     */
    public void teamInvite(com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getTeamInviteMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *战斗
     * </pre>
     */
    public void fight(com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getFightMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *同步阵型
     * </pre>
     */
    public void synForm(com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getSynFormMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *退出
     * </pre>
     */
    public void logOut(com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getLogOutMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     *跨服世界频道聊天
     * </pre>
     */
    public void worldChat(com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getWorldChatMethodHelper(), getCallOptions()), request, responseObserver);
    }

    /**
     * <pre>
     * 获取服务器列表
     * </pre>
     */
    public void queryServerList(com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getQueryServerListMethodHelper(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   */
  public static final class TeamHandlerBlockingStub extends io.grpc.stub.AbstractStub<TeamHandlerBlockingStub> {
    private TeamHandlerBlockingStub(io.grpc.Channel channel) {
      super(channel);
    }

    private TeamHandlerBlockingStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected TeamHandlerBlockingStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new TeamHandlerBlockingStub(channel, callOptions);
    }

    /**
     * <pre>
     *同步信息
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse synPlayer(com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest request) {
      return blockingUnaryCall(
          getChannel(), getSynPlayerMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *创建组队
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse createTeam(com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest request) {
      return blockingUnaryCall(
          getChannel(), getCreateTeamMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *解散队伍
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse dismissTeam(com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest request) {
      return blockingUnaryCall(
          getChannel(), getDismissTeamMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *寻找队伍
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse findTeam(com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest request) {
      return blockingUnaryCall(
          getChannel(), getFindTeamMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *退出队伍
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse leaveTeam(com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest request) {
      return blockingUnaryCall(
          getChannel(), getLeaveTeamMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *踢出队伍
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse kickTeam(com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest request) {
      return blockingUnaryCall(
          getChannel(), getKickTeamMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *加入队伍
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse joinTeam(com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest request) {
      return blockingUnaryCall(
          getChannel(), getJoinTeamMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *交换队伍出站顺序
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse changeTeamOrder(com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest request) {
      return blockingUnaryCall(
          getChannel(), getChangeTeamOrderMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *更改队员准备状态
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse changeMemberStatus(com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest request) {
      return blockingUnaryCall(
          getChannel(), getChangeMemberStatusMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *队伍聊天
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse teamChat(com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest request) {
      return blockingUnaryCall(
          getChannel(), getTeamChatMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *查看阵型
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse lookForm(com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest request) {
      return blockingUnaryCall(
          getChannel(), getLookFormMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *世界频道发送聊天
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse teamInvite(com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest request) {
      return blockingUnaryCall(
          getChannel(), getTeamInviteMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *战斗
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse fight(com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest request) {
      return blockingUnaryCall(
          getChannel(), getFightMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *同步阵型
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse synForm(com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest request) {
      return blockingUnaryCall(
          getChannel(), getSynFormMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *退出
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse logOut(com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest request) {
      return blockingUnaryCall(
          getChannel(), getLogOutMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     *跨服世界频道聊天
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse worldChat(com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest request) {
      return blockingUnaryCall(
          getChannel(), getWorldChatMethodHelper(), getCallOptions(), request);
    }

    /**
     * <pre>
     * 获取服务器列表
     * </pre>
     */
    public com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse queryServerList(com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest request) {
      return blockingUnaryCall(
          getChannel(), getQueryServerListMethodHelper(), getCallOptions(), request);
    }
  }

  /**
   */
  public static final class TeamHandlerFutureStub extends io.grpc.stub.AbstractStub<TeamHandlerFutureStub> {
    private TeamHandlerFutureStub(io.grpc.Channel channel) {
      super(channel);
    }

    private TeamHandlerFutureStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected TeamHandlerFutureStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new TeamHandlerFutureStub(channel, callOptions);
    }

    /**
     * <pre>
     *同步信息
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> synPlayer(
        com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getSynPlayerMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *创建组队
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse> createTeam(
        com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getCreateTeamMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *解散队伍
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> dismissTeam(
        com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getDismissTeamMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *寻找队伍
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> findTeam(
        com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getFindTeamMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *退出队伍
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> leaveTeam(
        com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getLeaveTeamMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *踢出队伍
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> kickTeam(
        com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getKickTeamMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *加入队伍
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> joinTeam(
        com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getJoinTeamMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *交换队伍出站顺序
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> changeTeamOrder(
        com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getChangeTeamOrderMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *更改队员准备状态
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> changeMemberStatus(
        com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getChangeMemberStatusMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *队伍聊天
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse> teamChat(
        com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getTeamChatMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *查看阵型
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse> lookForm(
        com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getLookFormMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *世界频道发送聊天
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> teamInvite(
        com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getTeamInviteMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *战斗
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> fight(
        com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getFightMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *同步阵型
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> synForm(
        com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getSynFormMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *退出
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> logOut(
        com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getLogOutMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     *跨服世界频道聊天
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse> worldChat(
        com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getWorldChatMethodHelper(), getCallOptions()), request);
    }

    /**
     * <pre>
     * 获取服务器列表
     * </pre>
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse> queryServerList(
        com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getQueryServerListMethodHelper(), getCallOptions()), request);
    }
  }

  private static final int METHODID_SYN_PLAYER = 0;
  private static final int METHODID_CREATE_TEAM = 1;
  private static final int METHODID_DISMISS_TEAM = 2;
  private static final int METHODID_FIND_TEAM = 3;
  private static final int METHODID_LEAVE_TEAM = 4;
  private static final int METHODID_KICK_TEAM = 5;
  private static final int METHODID_JOIN_TEAM = 6;
  private static final int METHODID_CHANGE_TEAM_ORDER = 7;
  private static final int METHODID_CHANGE_MEMBER_STATUS = 8;
  private static final int METHODID_TEAM_CHAT = 9;
  private static final int METHODID_LOOK_FORM = 10;
  private static final int METHODID_TEAM_INVITE = 11;
  private static final int METHODID_FIGHT = 12;
  private static final int METHODID_SYN_FORM = 13;
  private static final int METHODID_LOG_OUT = 14;
  private static final int METHODID_WORLD_CHAT = 15;
  private static final int METHODID_QUERY_SERVER_LIST = 16;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final TeamHandlerImplBase serviceImpl;
    private final int methodId;

    MethodHandlers(TeamHandlerImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_SYN_PLAYER:
          serviceImpl.synPlayer((com.game.grpc.proto.team.CrossTeamProto.RpcSynPlayerRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_CREATE_TEAM:
          serviceImpl.createTeam((com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCreateTeamResponse>) responseObserver);
          break;
        case METHODID_DISMISS_TEAM:
          serviceImpl.dismissTeam((com.game.grpc.proto.team.CrossTeamProto.RpcDisMissTeamRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_FIND_TEAM:
          serviceImpl.findTeam((com.game.grpc.proto.team.CrossTeamProto.RpcFindTeamRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_LEAVE_TEAM:
          serviceImpl.leaveTeam((com.game.grpc.proto.team.CrossTeamProto.RpcLeaveTeamRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_KICK_TEAM:
          serviceImpl.kickTeam((com.game.grpc.proto.team.CrossTeamProto.RpcKickTeamRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_JOIN_TEAM:
          serviceImpl.joinTeam((com.game.grpc.proto.team.CrossTeamProto.RpcJoinTeamRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_CHANGE_TEAM_ORDER:
          serviceImpl.changeTeamOrder((com.game.grpc.proto.team.CrossTeamProto.CrossExchangeOrderRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_CHANGE_MEMBER_STATUS:
          serviceImpl.changeMemberStatus((com.game.grpc.proto.team.CrossTeamProto.RpcChangeMemberStatusRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_TEAM_CHAT:
          serviceImpl.teamChat((com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossTeamChatResponse>) responseObserver);
          break;
        case METHODID_LOOK_FORM:
          serviceImpl.lookForm((com.game.grpc.proto.team.CrossTeamProto.CrossLookFormRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossLookFormResponse>) responseObserver);
          break;
        case METHODID_TEAM_INVITE:
          serviceImpl.teamInvite((com.game.grpc.proto.team.CrossTeamProto.CrossInviteRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_FIGHT:
          serviceImpl.fight((com.game.grpc.proto.team.CrossTeamProto.CrossTeamFightRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_SYN_FORM:
          serviceImpl.synForm((com.game.grpc.proto.team.CrossTeamProto.CrossSynFormRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_LOG_OUT:
          serviceImpl.logOut((com.game.grpc.proto.team.CrossTeamProto.CrossLogOutRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_WORLD_CHAT:
          serviceImpl.worldChat((com.game.grpc.proto.team.CrossTeamProto.CrossWorldChatRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.RpcCodeTeamResponse>) responseObserver);
          break;
        case METHODID_QUERY_SERVER_LIST:
          serviceImpl.queryServerList((com.game.grpc.proto.team.CrossTeamProto.CrossServerListRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.team.CrossTeamProto.CrossServerListResponse>) responseObserver);
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

  private static abstract class TeamHandlerBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    TeamHandlerBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.game.grpc.proto.team.CrossTeamProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("TeamHandler");
    }
  }

  private static final class TeamHandlerFileDescriptorSupplier
      extends TeamHandlerBaseDescriptorSupplier {
    TeamHandlerFileDescriptorSupplier() {}
  }

  private static final class TeamHandlerMethodDescriptorSupplier
      extends TeamHandlerBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final String methodName;

    TeamHandlerMethodDescriptorSupplier(String methodName) {
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
      synchronized (TeamHandlerGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new TeamHandlerFileDescriptorSupplier())
              .addMethod(getSynPlayerMethodHelper())
              .addMethod(getCreateTeamMethodHelper())
              .addMethod(getDismissTeamMethodHelper())
              .addMethod(getFindTeamMethodHelper())
              .addMethod(getLeaveTeamMethodHelper())
              .addMethod(getKickTeamMethodHelper())
              .addMethod(getJoinTeamMethodHelper())
              .addMethod(getChangeTeamOrderMethodHelper())
              .addMethod(getChangeMemberStatusMethodHelper())
              .addMethod(getTeamChatMethodHelper())
              .addMethod(getLookFormMethodHelper())
              .addMethod(getTeamInviteMethodHelper())
              .addMethod(getFightMethodHelper())
              .addMethod(getSynFormMethodHelper())
              .addMethod(getLogOutMethodHelper())
              .addMethod(getWorldChatMethodHelper())
              .addMethod(getQueryServerListMethodHelper())
              .build();
        }
      }
    }
    return result;
  }
}
