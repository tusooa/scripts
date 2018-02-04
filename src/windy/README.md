# 一个 MPQ 的转发接口

## 安装

仅在 Visual Studio 2017 下测试过。

```
mkdir build
cd build
cmake ..
cmake --build . --config Release
copy Release\windy.xx.dll path\to\mypcqq\Plugin\
```

## 配置

配置文件位于 `path\to\mypcqq\windy.xx.conf`，格式为 `INI`。

默认配置如下:

```
[windy]
recvPort = 7456
apiCallAddr = /api/call
sendServer = localhost:7457
testAddr = /
sendAddr = /recv
testSleepTime = 5
```

`recvPort`: MPQ 方面的监听端口，用于接收 API 调用。

`apiCallAddr`: API 调用的地址。

`sendServer`: 消息发送到哪个服务器。

`testAddr`: 用于测试服务器是否可用，相对于 `sendServer` 的地址。

`sendAddr`: 用于转发消息，相对于 `sendServer` 的地址。

`testSleepTime`: 测试间隔。

尽管格式不完全一样，可以用 `config.perl` 修改配置。

```
cd path\to\mypcqq
config.perl -a windy.xx.conf windy recvPort -s 3000
```

## 用法

### 调用 API

本机的 `recvPort` 端口在 `apiCallAddr` 处接受 `POST` 请求。内容为 JSON 格式。示例如下:

```
{ "seq": [{"func":"OutPut", "args": ["bWV3dw=="]},
  {"func":"OutPut", "args": ["3/c="]}
]}
```

其中 `func` 对应的值为函数名称，不包括 `Api_`。`加密` 和 `解密` 分别替换为 `Encrypt` 和 `Decrypt`。

`args` 对应的值是一个列表，如果传入的参数是字串，则是 GBK 编码，并将其 `base64` 化(因为 JSON 库无法处理非 UTF-8 编码)。如果传入的参数不是字符串，则将其字符串化，不需要 `base64`。

返回值形如

```
{ "seq": ["0", "0"] }
```

如果返回值是字符串，它会被 `base64` 化。如果不是字符串，不会被 `base64` 化。

### 消息转发

收到新消息时，用 `POST` 方法提交到 `sendServer/sendAddr` 处。

提交内容是一个 JSON。

```
{"tencent": "",
"type": 0,
"subtype": 0,
"source": "",
"subject": "",
"object": "",
"msg": "(base64)",
"rawmsg": "(base64)"}
```

上例中顺序和 `EventFun` 参数顺序一致。只有 `msg` 和 `rawmsg` 是经过 `base64` 化的。

目标应该返回一个 JSON，内容形如

```
{ "ret": 0,
"msg": ""}
```

`ret` 是返回值。遵循 MPQ 的定义。

`msg` 是要写入 `EventFun` 最后一个参数的。目前，这个功能还没有进行测试。
