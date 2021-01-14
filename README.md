# XY.OpenSource

## iOS 
* WebViewJavaScriptBridge
* libdispatch
* objc4
* runloop
* SDWebImage
* MJRefresh
* AFNetwork
* FishHook 


### WebViewJavaScriptBridge

**主要源码目录** 

WebViewJavascriptBridge_JS    JavascriptBase,针对JS，JS调用OC

WebViewJavascriptBridge         针对WebView，依赖WebViewJavascriptBridgeBase

WKWebViewJavascriptBridge   针对WKWebView，依赖WebViewJavascriptBridgeBase

WebViewJavascriptBridgeBase  OC调用JS,JS调用OC基础方法


**主要数据结构以及方法**

registerHandler   -> MessageHandler

callHandler  -> MessageQueue 

responseCallback (key=callbackId) 回调哈希

http://__bridge_load__  (注入JS)

http://__wvjb_queue_message__ (处理消息队列)

flushMessageQueue (Objc)

dispatchMessageFromObjc (JS)

JS:callbackId= cb+ ++uniqueId + timestamp

OC:callbackId= objc_cb_++uniqueId

**Objc:**

message[data], JSON数据

message[callbackId]，oc调用js,回调名称

message[handleName]，函数名

message[responseId]，oc调用js，js处理完毕后，根据callbackId,写入responseId

message[responsedata]，oc调用js，js处理完毕后，根据callbackId,写入返回数据


**JS: (基本原理同上)**

message[data]

message[callbackId]

message[handleName]

message[responseId]

message[responsedata]


**初始化流程**

通过网页端创建iFrame指向http://bridge_load,通过OC拦截(ShouldStartLoadWithRequest or DecidePolicyForNavigationAction)进行初始化工作,其实就是初始化WebViewBridgeJS；
OC有一个startupMessageQueue,如果还没有初始化InjectJavascriptFile的话，则缓存在这里，如果初始化完成后，才从startupMessageQueue取出消息处理。

**基础原理**

OC调用JS通过evaluateJavascript->handleMessageFromObjc
JS调用OC通过 WKWebView-> decidePolicyForNavigationAction),UIWebView->ShouldStartLoadWithRequest

**JS调用OC**

JS端维护一个MessageQueue，然后OC通过fetchQueue方式，获取消息队列，解析消息(函数名，函数参数，函数回调)，分发消息通过messageHandler匹配函数名处理，OC处理完毕后将结果，调用JS的handleMessageFromObjc，解析消息，并回调。

**OC调用JS**

通过HandleMessageFromObjc，处理完成后，数据以及回调通过messageQueue的方式 (JS调用OC)



### 卡顿检测

**原理**

因为kCFRunLoopBeforeSources-> kCFRunLoopBeforeWaiting 这期间处理用户交互，还有就是kCFRunLoopAfterWaiting 出现两次也可以认为卡顿；
通过创建子线程，监听主线程状态变更判断是否卡顿；

**步骤**

1. 注册ObserverCallback

2. 创建一个信号量，当状态改变的时候，Signal信号量

3. 创建一个子线程，设置信号量等待超时（50ms)，如果超时了（代表主线程状态保持一段长时间不变），然后判断当前是否是kCFRunLoopBeforeSources或者kCFRunLoopAfterWaiting，连续5次代表卡断

