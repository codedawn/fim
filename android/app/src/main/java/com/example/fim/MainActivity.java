package com.example.fim;

import android.os.Handler;
import android.os.Looper;
import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import com.codedawn.vital.client.VitalC;
import com.codedawn.vital.server.callback.MessageCallBack;
import com.codedawn.vital.server.callback.RequestSendCallBack;
import com.codedawn.vital.server.callback.SendCallBack;
import com.codedawn.vital.server.context.MessageContext;
import com.codedawn.vital.server.processor.Processor;
import com.codedawn.vital.server.proto.MessageWrapper;
import com.codedawn.vital.server.proto.VitalPB;
import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;
import io.flutter.embedding.engine.plugins.util.GeneratedPluginRegister;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;

import java.util.HashMap;
import java.util.concurrent.ExecutorService;

public class MainActivity extends FlutterActivity {
    private VitalC vitalC;
    private MethodChannel mc;
    private Handler uiThreadHandler = new Handler(Looper.getMainLooper());


    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        GeneratedPluginRegister.registerGeneratedPlugins(flutterEngine);
        mc = new MethodChannel(flutterEngine.getDartExecutor(), "com.codedawn.flutter.native");//此处名称应与Flutter端保持一致
        init();
        //接收Flutter消息
        HashMap<Object, Object> map = new HashMap<>();
        mc.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
            @Override
            public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
                System.out.println("MethodChannel call.method:" + call.method + "  call arguments:" + call.arguments);
                switch (call.method) {
                    case AndroidMethod.LOGIN:
                        map.clear();
                        vitalC.start(call.argument("id"), call.argument("token"), new RequestSendCallBack() {
                            @Override
                            public void onResponse(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", true);
                                        System.out.println("AndroidMethod.LOGIN success");
                                        result.success(map);
                                    }
                                });
                            }

                            @Override
                            public void onAck(MessageWrapper messageWrapper) {

                            }

                            @Override
                            public void onException(MessageWrapper messageWrapper) {

                            }
                        });
                        break;
                    case AndroidMethod.SEND_DIS_AUTH:
                        map.clear();
                        vitalC.sendDisAuth(new SendCallBack() {
                            @Override
                            public void onAck(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", true);
                                        System.out.println("AndroidMethod.SEND_DIS_AUTH success");
                                        result.success(map);

                                    }
                                });
                            }

                            @Override
                            public void onException(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", false);
                                        System.out.println("AndroidMethod.SEND_DIS_AUTH fail");
                                        result.success(map);

                                    }
                                });
                            }


                        });
                        break;
                    case AndroidMethod.SEND_TEXT_MESSAGE: {
                        String msg = call.argument("message");
                        String toId = call.argument("toId");
                        String fromId = call.argument("fromId");
                        boolean isGroup = call.argument("isGroup");
                        map.clear();
                        SendCallBack sendCallBack = new SendCallBack() {
                            @Override
                            public void onAck(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", true);
                                        map.put("timestamp", messageWrapper.getTimestamp());
                                        map.put("perId", messageWrapper.getPerId());
                                        System.out.println("AndroidMethod.SEND_TEXT_MESSAGE success");
                                        result.success(map);


                                    }
                                });
                            }

                            @Override
                            public void onException(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", false);
                                        System.out.println("AndroidMethod.SEND_TEXT_MESSAGE fail");
                                        result.success(map);

                                    }
                                });
                            }
                        };
                        if (!isGroup) {
                            vitalC.send(fromId, toId, msg, sendCallBack);
                        } else {
                            vitalC.sendGroup(fromId, toId, msg, sendCallBack);
                        }
                        break;
                    }
                    case AndroidMethod.SEND_IMAGE_MESSAGE: {
                        String url = call.argument("url");
                        String toId = call.argument("toId");
                        String fromId = call.argument("fromId");
                        boolean isGroup = call.argument("isGroup");
                        map.clear();
                        SendCallBack sendCallBack = new SendCallBack() {
                            @Override
                            public void onAck(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", true);
                                        map.put("timestamp", messageWrapper.getTimestamp());
                                        map.put("perId", messageWrapper.getPerId());
                                        System.out.println("AndroidMethod.SEND_TEXT_MESSAGE success");
                                        result.success(map);


                                    }
                                });
                            }

                            @Override
                            public void onException(MessageWrapper messageWrapper) {
                                uiThreadHandler.post(new Runnable() {
                                    @Override
                                    public void run() {
                                        map.put("success", false);
                                        System.out.println("AndroidMethod.SEND_TEXT_MESSAGE fail");
                                        result.success(map);

                                    }
                                });
                            }
                        };
                        if (!isGroup) {
                            vitalC.sendImage(fromId, toId, url, sendCallBack);
                        } else {
                            vitalC.sendGroupImage(fromId, toId, url, sendCallBack);
                        }
                        break;
                    }
                    default:
                        System.out.println("default 404");
                        result.error("404", "未匹配到对应的方法" + call.method, null);
                }
            }
        });
    }

    private void init() {
        vitalC = new VitalC()
                .serverIp("127.0.0.1")
                .serverPort(8000);

        //text
        vitalC.registerUserProcessor(VitalPB.MessageType.TextMessageType.name(), new Processor() {
            @Override
            public void process(MessageContext messageContext, MessageWrapper messageWrapper) {
                HashMap<String, Object> map = new HashMap<>();
                VitalPB.TextMessage textMessage = messageWrapper.getMessage();
                map.put("fromId", Long.parseLong(messageWrapper.getFromId()));
                map.put("content", textMessage.getContent());
                map.put("isGroup", messageWrapper.getIsGroup());
                map.put("toId", Long.parseLong(messageWrapper.getToId()));
                map.put("timestamp", messageWrapper.getTimestamp());
                map.put("mid", Long.parseLong(messageWrapper.getPerId()));
                map.put("messageType", "textMessage");

//                System.out.println(map);
                uiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mc.invokeMethod(FlutterMethod.MESSAGE, map, new MethodChannel.Result() {
                            @Override
                            public void success(@Nullable Object result) {
                                System.out.println("调用" + FlutterMethod.MESSAGE + "成功");
                            }

                            @Override
                            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {

                            }

                            @Override
                            public void notImplemented() {

                            }
                        });
                    }
                });

            }


            @Override
            public ExecutorService getExecutor() {
                return null;
            }
        });
        //image
        vitalC.registerUserProcessor(VitalPB.MessageType.ImageMessageType.name(), new Processor() {
            @Override
            public void process(MessageContext messageContext, MessageWrapper messageWrapper) {
                HashMap<String, Object> map = new HashMap<>();
                VitalPB.ImageMessage imageMessage = messageWrapper.getMessage();
                map.put("fromId", Long.parseLong(messageWrapper.getFromId()));
                map.put("url", imageMessage.getUrl());
                map.put("isGroup", messageWrapper.getIsGroup());
                map.put("toId", Long.parseLong(messageWrapper.getToId()));
                map.put("timestamp", messageWrapper.getTimestamp());
                map.put("mid", Long.parseLong(messageWrapper.getPerId()));
                map.put("messageType", "imageMessage");

//                System.out.println(map);
                uiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mc.invokeMethod(FlutterMethod.MESSAGE, map, new MethodChannel.Result() {
                            @Override
                            public void success(@Nullable Object result) {
                                System.out.println("调用" + FlutterMethod.MESSAGE + "成功");
                            }

                            @Override
                            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {

                            }

                            @Override
                            public void notImplemented() {

                            }
                        });
                    }
                });

            }


            @Override
            public ExecutorService getExecutor() {
                return null;
            }
        });
        vitalC.registerUserProcessor(VitalPB.MessageType.KickoutMessageType.name(), new Processor() {
            @Override
            public void process(MessageContext messageContext, MessageWrapper messageWrapper) {
                HashMap<String, Object> map = new HashMap<>();
                uiThreadHandler.post(new Runnable() {
                    @Override
                    public void run() {
                        mc.invokeMethod(FlutterMethod.KICKOUT_MESSAGE, map, new MethodChannel.Result() {
                            @Override
                            public void success(@Nullable Object result) {
                                System.out.println("调用" + FlutterMethod.KICKOUT_MESSAGE + "成功");
                            }

                            @Override
                            public void error(String errorCode, @Nullable String errorMessage, @Nullable Object errorDetails) {

                            }

                            @Override
                            public void notImplemented() {

                            }
                        });
                    }
                });
            }

            @Override
            public ExecutorService getExecutor() {
                return null;
            }
        });
        vitalC.setMessageCallBack(new MessageCallBack() {
            @Override
            public void onMessage(MessageWrapper messageWrapper) {

            }
        });


    }
}
