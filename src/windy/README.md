# 一个 MPQ 的转发接口

## 许可协议

下文指明了本程序使用 GPL 3 或后续版本发布，但在程序中引用闭源的 MyPCQQ 库是允许的。

Copyright (C) 2017-2018 ThisTusooa

This program is free software; you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation; either version 3 of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program; if not, see <http://www.gnu.org/licenses>.

Additional permission under GNU GPL version 3 section 7

If you modify this Program, or any covered work, by linking or combining it with MyPCQQ (or a modified version of that library), containing parts covered by the terms that can be accessed [here](https://f.mypcqq.cc/thread-4274-1-1.html), the licensors of this Program grant you additional permission to convey the resulting work.

### 附注



MyPCQQ **不是**自由软件，其许可协议可能会对您使用或分发 MyPCQQ 造成限制。并且，我无法保证它能够正确工作且不损害您的计算机。

在您考虑修改或重新发布本程序时，希望您能先考虑实现一个自由的 MyPCQQ 替代品。

## 安装

仅在 Visual Studio 2017 下测试过。

依赖 Boost 和 LibIconv。`link=static runtime-link=static`。


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

### 关于编码

对于不能在 GBK 下表示的字符，仍然需要手动用 \uXXXXXX 的形式表示。

### 调用 API

本机的 `recvPort` 端口在 `apiCallAddr` 处接受 `POST` 请求。内容为 JSON 格式。示例如下:

```
{ "seq": [{"func":"OutPut", "args": ["mewww"]},
  {"func":"OutPut", "args": ["喵"]}
]}
```

其中 `func` 对应的值为函数名称，不包括 `Api_`。`加密` 和 `解密` 分别替换为 `Encrypt` 和 `Decrypt`。

`args` 对应的值是一个列表，如果传入的参数是字串，则是 UTF-8 编码。如果传入的参数不是字符串，则将其字符串化。

返回值形如

```
{ "seq": ["0", "0"] }
```

如果返回值是字符串，则是 UTF-8 编码。如果不是字符串，会被转化为字符串。

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
"msg": "",
"rawmsg": ""}
```

上例中顺序和 `EventFun` 参数顺序一致。`msg` 和 `rawmsg` 是 UTF-8 编码的。

目标应该返回一个 JSON，内容形如

```
{ "ret": 0,
"msg": ""}
```

`ret` 是返回值。遵循 MPQ 的定义。

`msg` 是要写入 `EventFun` 最后一个参数的字符串，是 UTF-8 编码。目前，这个功能还没有进行测试，但是应该可以用吧。
