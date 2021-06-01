package com.game.grpc.proto.rpc;

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
    comments = "Source: rpc.proto")
public final class HeartbeatGrpc {

  private HeartbeatGrpc() {}

  public static final String SERVICE_NAME = "Heartbeat";

  // Static method descriptors that strictly reflect the proto.
  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  @java.lang.Deprecated // Use {@link #getValidateChannelMethod()} instead. 
  public static final io.grpc.MethodDescriptor<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest,
      com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> METHOD_VALIDATE_CHANNEL = getValidateChannelMethodHelper();

  private static volatile io.grpc.MethodDescriptor<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest,
      com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> getValidateChannelMethod;

  @io.grpc.ExperimentalApi("https://github.com/grpc/grpc-java/issues/1901")
  public static io.grpc.MethodDescriptor<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest,
      com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> getValidateChannelMethod() {
    return getValidateChannelMethodHelper();
  }

  private static io.grpc.MethodDescriptor<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest,
      com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> getValidateChannelMethodHelper() {
    io.grpc.MethodDescriptor<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest, com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> getValidateChannelMethod;
    if ((getValidateChannelMethod = HeartbeatGrpc.getValidateChannelMethod) == null) {
      synchronized (HeartbeatGrpc.class) {
        if ((getValidateChannelMethod = HeartbeatGrpc.getValidateChannelMethod) == null) {
          HeartbeatGrpc.getValidateChannelMethod = getValidateChannelMethod = 
              io.grpc.MethodDescriptor.<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest, com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse>newBuilder()
              .setType(io.grpc.MethodDescriptor.MethodType.UNARY)
              .setFullMethodName(generateFullMethodName(
                  "Heartbeat", "validateChannel"))
              .setSampledToLocalTracing(true)
              .setRequestMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest.getDefaultInstance()))
              .setResponseMarshaller(io.grpc.protobuf.ProtoUtils.marshaller(
                  com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse.getDefaultInstance()))
                  .setSchemaDescriptor(new HeartbeatMethodDescriptorSupplier("validateChannel"))
                  .build();
          }
        }
     }
     return getValidateChannelMethod;
  }

  /**
   * Creates a new async stub that supports all call types for the service
   */
  public static HeartbeatStub newStub(io.grpc.Channel channel) {
    return new HeartbeatStub(channel);
  }

  /**
   * Creates a new blocking-style stub that supports unary and streaming output calls on the service
   */
  public static HeartbeatBlockingStub newBlockingStub(
      io.grpc.Channel channel) {
    return new HeartbeatBlockingStub(channel);
  }

  /**
   * Creates a new ListenableFuture-style stub that supports unary calls on the service
   */
  public static HeartbeatFutureStub newFutureStub(
      io.grpc.Channel channel) {
    return new HeartbeatFutureStub(channel);
  }

  /**
   */
  public static abstract class HeartbeatImplBase implements io.grpc.BindableService {

    /**
     */
    public void validateChannel(com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> responseObserver) {
      asyncUnimplementedUnaryCall(getValidateChannelMethodHelper(), responseObserver);
    }

    @java.lang.Override public final io.grpc.ServerServiceDefinition bindService() {
      return io.grpc.ServerServiceDefinition.builder(getServiceDescriptor())
          .addMethod(
            getValidateChannelMethodHelper(),
            asyncUnaryCall(
              new MethodHandlers<
                com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest,
                com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse>(
                  this, METHODID_VALIDATE_CHANNEL)))
          .build();
    }
  }

  /**
   */
  public static final class HeartbeatStub extends io.grpc.stub.AbstractStub<HeartbeatStub> {
    private HeartbeatStub(io.grpc.Channel channel) {
      super(channel);
    }

    private HeartbeatStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected HeartbeatStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new HeartbeatStub(channel, callOptions);
    }

    /**
     */
    public void validateChannel(com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest request,
        io.grpc.stub.StreamObserver<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> responseObserver) {
      asyncUnaryCall(
          getChannel().newCall(getValidateChannelMethodHelper(), getCallOptions()), request, responseObserver);
    }
  }

  /**
   */
  public static final class HeartbeatBlockingStub extends io.grpc.stub.AbstractStub<HeartbeatBlockingStub> {
    private HeartbeatBlockingStub(io.grpc.Channel channel) {
      super(channel);
    }

    private HeartbeatBlockingStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected HeartbeatBlockingStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new HeartbeatBlockingStub(channel, callOptions);
    }

    /**
     */
    public com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse validateChannel(com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest request) {
      return blockingUnaryCall(
          getChannel(), getValidateChannelMethodHelper(), getCallOptions(), request);
    }
  }

  /**
   */
  public static final class HeartbeatFutureStub extends io.grpc.stub.AbstractStub<HeartbeatFutureStub> {
    private HeartbeatFutureStub(io.grpc.Channel channel) {
      super(channel);
    }

    private HeartbeatFutureStub(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      super(channel, callOptions);
    }

    @java.lang.Override
    protected HeartbeatFutureStub build(io.grpc.Channel channel,
        io.grpc.CallOptions callOptions) {
      return new HeartbeatFutureStub(channel, callOptions);
    }

    /**
     */
    public com.google.common.util.concurrent.ListenableFuture<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse> validateChannel(
        com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest request) {
      return futureUnaryCall(
          getChannel().newCall(getValidateChannelMethodHelper(), getCallOptions()), request);
    }
  }

  private static final int METHODID_VALIDATE_CHANNEL = 0;

  private static final class MethodHandlers<Req, Resp> implements
      io.grpc.stub.ServerCalls.UnaryMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ServerStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.ClientStreamingMethod<Req, Resp>,
      io.grpc.stub.ServerCalls.BidiStreamingMethod<Req, Resp> {
    private final HeartbeatImplBase serviceImpl;
    private final int methodId;

    MethodHandlers(HeartbeatImplBase serviceImpl, int methodId) {
      this.serviceImpl = serviceImpl;
      this.methodId = methodId;
    }

    @java.lang.Override
    @java.lang.SuppressWarnings("unchecked")
    public void invoke(Req request, io.grpc.stub.StreamObserver<Resp> responseObserver) {
      switch (methodId) {
        case METHODID_VALIDATE_CHANNEL:
          serviceImpl.validateChannel((com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatRequest) request,
              (io.grpc.stub.StreamObserver<com.game.grpc.proto.rpc.HeartbeatProto.HeartbeatResponse>) responseObserver);
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

  private static abstract class HeartbeatBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoFileDescriptorSupplier, io.grpc.protobuf.ProtoServiceDescriptorSupplier {
    HeartbeatBaseDescriptorSupplier() {}

    @java.lang.Override
    public com.google.protobuf.Descriptors.FileDescriptor getFileDescriptor() {
      return com.game.grpc.proto.rpc.HeartbeatProto.getDescriptor();
    }

    @java.lang.Override
    public com.google.protobuf.Descriptors.ServiceDescriptor getServiceDescriptor() {
      return getFileDescriptor().findServiceByName("Heartbeat");
    }
  }

  private static final class HeartbeatFileDescriptorSupplier
      extends HeartbeatBaseDescriptorSupplier {
    HeartbeatFileDescriptorSupplier() {}
  }

  private static final class HeartbeatMethodDescriptorSupplier
      extends HeartbeatBaseDescriptorSupplier
      implements io.grpc.protobuf.ProtoMethodDescriptorSupplier {
    private final String methodName;

    HeartbeatMethodDescriptorSupplier(String methodName) {
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
      synchronized (HeartbeatGrpc.class) {
        result = serviceDescriptor;
        if (result == null) {
          serviceDescriptor = result = io.grpc.ServiceDescriptor.newBuilder(SERVICE_NAME)
              .setSchemaDescriptor(new HeartbeatFileDescriptorSupplier())
              .addMethod(getValidateChannelMethodHelper())
              .build();
        }
      }
    }
    return result;
  }
}
