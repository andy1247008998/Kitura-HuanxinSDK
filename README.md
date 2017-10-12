# Kitura-HuanxinSDK

## 前言

* Swift是Apple为iOS和Mac OS X开发的编程语言，但不止于此。随着Swift的开源，它开始被Apple官方支持在Ubuntu等GNU/Linux平台上运行，并且理论上可以移植到其他任何操作系统上(只要有人为它开发合适的工具链)。进一步的，它不再限制于用来开发本地/移动App，有人为它开发了Web框架和Web服务器。
* Kitura是上述Web框架和Web服务器之一。它是由IBM公司开发的，使用Swift语言。不过IBM只是基于Swift.org提供的编译工具链和Swift Package Manager(SPM)开发了一个第三方库，并没有单独开发一个完整的IDE，因此在Linux平台上的开发过程会略显不便。
* 环信是一个即时通信(IM)服务提供商。如果你的App需要好友私聊、群聊、客服等功能，你就需要一个IM服务。环信已经提供了iOS、Android等平台的SDK，用于客户端直接与环信服务器的交互。除此之外，注册、注销用户等高权限操作不适合从客户端直接发起请求，而应该让客户端先和[你的服务器]交互，再由[你的服务器]去和[环信服务器]交互。由此，服务器端集成是需要开发者自己去完成的。
* Kitura-HuanxinSDK是用于Swift+Kitura+环信解决方案的服务器端集成。它是对环信服务器端API的简单封装。开发者可以专注于App功能的开发，不用再去逐个研究环信服务器API的细节。

![0_1507774177862_kitura_huanxinsdk_arch.png](http://pics-mustu-cn.oss-cn-shenzhen.aliyuncs.com/assets/89e3bc67-c0be-48ac-a10f-de5cdb2e9c31.png) 

## 使用方法

1. Swift Package Manager

```
import PackageDescription
let package = Package(
        name: "YourProjectName",
        dependencies: [
            .Package(url: "https://github.com/andy1247008998/Kitura-HuanxinSDK.git", majorVersion: 0)
        ]
)
```

2. 环信账户信息
```
import KituraHuanxinSDK

//拼接环信URL基址
let huanxinDomain = "https://a1.easemob.com"
let huanxinOrgName = "1111222233334444"
let huanxinAppName = "yourappname"
let huanxinBaseURL = "\(huanxinDomain)/\(huanxinOrgName)/\(huanxinAppName)"
//准备好ID和Secret
let huanxinClientID = "AAAABBBBCCCCDDDDEEEEFFFF"
let huanxinClientSecret = "AAAABBBBCCCCDDDDEEEEFFFFGGGG"
```

3.  获取一个Huanxin实例
```
let huanxin = Huanxin(domain:huanxinDomain, orgName:huanxinOrgName, appName:huanxinAppName, client_id:huanxinClientID, client_secret:huanxinClientSecret)
```

4. 注册用户

```
huanxin.registerUser(username:username, password:password, nickname:nickname, withToken:true){ registerUserResponse, error in
    print("registerUserResponse is \(registerUserResponse)")
}
```


