# SafeSwiftDemo（iOS安全加固）

## 一、防止App被别人动态调试

### 1、Ptrace

>为了方便应用软件的开发和调试，从Unix的早期版本开始就提供了一种对运行中的进程进行跟踪和控制的手段，那就是系统调用ptrace()。通过ptrace可以对另一个进程实现调试跟踪，同时ptrace还提供了一个非常有用的参数那就是PT_DENY_ATTACH，这个参数用来告诉系统，阻止调试器依附。

```
#include <stdio.h>
#import <string.h>
#import <dlfcn.h>
#import <sys/types.h>
#define A(c)            (c) - 0x19
#define UNHIDE_STR(str) do { char *p = str;  while (*p) *p++ += 0x19; } while (0)
#define HIDE_STR(str)   do { char *p = str;  while (*p) *p++ -= 0x19; } while (0)
typedef int (*ptrace_ptr_t)(int _request, pid_t _pid, caddr_t _addr, int _data);
#if !defined(PT_DENY_ATTACH)
#define PT_DENY_ATTACH 31
#endif

void disable_gdb() {
    void* handle = dlopen(0, RTLD_GLOBAL | RTLD_NOW);
    char str[  ] = {
        A('p'), A('t'), A('r'), A('a'), A('c'),
        A('e'), 0
    };
    UNHIDE_STR(str);
    char string[6];
    int i;
    for(i=0;i<6;i++){
        string[i]=str[i];
    }
    string[i]='\0';
    ptrace_ptr_t ptrace_ptr = dlsym(handle, string);
    ptrace_ptr(PT_DENY_ATTACH, 0, 0, 0);
    dlclose(handle);
}
```

>代码示例：MyPtrace.h，MyPtrace.c，main.swift

### 2、Sysctl

>当一个进程被调试的时候，该进程会有一个标记来标记自己正在被调试，所以可以通过sysctl去查看当前进程的信息，看有没有这个标记位即可检查当前调试状态。

```
class func isDebugger() -> Bool {
    var name = [Int32]()
    name.append(CTL_KERN)
    name.append(KERN_PROC)
    name.append(KERN_PROC_PID)
    name.append(getpid())

    var info = kinfo_proc()
    info.kp_proc.p_flag = 0
    var infoSize = MemoryLayout.size(ofValue: info) as size_t
    if sysctl(&name, 4, &info, &infoSize, nil, 0) == -1 {
        return false
    }
    return (info.kp_proc.p_flag & P_TRACED) != 0
}
```

>RefuseDebug.swift，ViewController.swift

## 二、防止文件被篡改

>对需要保护的重要文件做MD5hash校验，通过对比原始文件的hash和当前的hash来做判断。

```
/// 获取指定路径下不是目录的所有文件的MD5Hash
class func getFileHash(withPath: String) -> [String: String] {
    var dicHash: [String: String] = [:]
    let fileArr = self.getAllFiles(atPath: withPath)
    for fileName in fileArr {
        let hashString = FileHash.md5HashOfFile(atPath: Bundle.main.resourcePath?.appending("/\(fileName)"))
        if let hashString = hashString {
            dicHash[fileName] = hashString
        }
    }
    return dicHash
}
    
/// 获取指定路径下不是目录的所有文件
class func getAllFiles(atPath: String) -> [String] {
    var fileArr: [String] = []
    let manager = FileManager.default
    let tempFileArr = try? manager.contentsOfDirectory(atPath: atPath)
    if let tempFileArr = tempFileArr {
        for fileName in tempFileArr {
            var flag: ObjCBool = false
            let fullpath = atPath.appending("/\(fileName)")
            if manager.fileExists(atPath: fullpath, isDirectory: &flag) {
                if !flag.boolValue {
                    fileArr.append(fileName)
                }
            }

        }
    }
    return fileArr
}
```

>代码示例：CheckFileMD5Hash.swift，ViewController.swift

## 三、越狱检测

>一般能拿到自己ipa包都需要有一台越狱的手机

### 1、判断设备是否安装了越狱常用工具

>一般安装了越狱工具的设备都会存在以下文件：  
/Applications/Cydia.app  
/Library/MobileSubstrate/MobileSubstrate.dylib  
/bin/bash  
/usr/sbin/sshd  
/etc/apt  

### 2、判断设备上是否存在cydia应用

### 3、是否有权限读取系统应用列表

>没有越狱的设备是没有读取所有应用名称的权限

### 4、检测当前程序运行的环境变量 DYLD_INSERT_LIBRARIES

>非越狱手机DYLD_INSERT_LIBRARIES获取到的环境变量为NULL

```
class func isJailbroken() -> Bool {
    // 检查是否存在越狱常用文件
    let jailFilePaths = ["/Applications/Cydia.app",
                         "/Library/MobileSubstrate/MobileSubstrate.dylib",
                         "/bin/bash",
                         "/usr/sbin/sshd",
                         "/etc/apt"]
    for filePath in jailFilePaths {
        if FileManager.default.fileExists(atPath: filePath) {
            return true
        }
    }

    // 检查是否安装了越狱工具Cydia
    if UIApplication.shared.canOpenURL(URL(string: "cydia://package/com.example.package")!) {
        return true
    }

    // 检查是否有权限读取系统应用列表
    if FileManager.default.fileExists(atPath: "/User/Applications/") {
        if let applist = try? FileManager.default.contentsOfDirectory(atPath: "/User/Applications/") {
            debugPrint(applist)
            return true
        }
    }

    // 检测当前程序运行的环境变量
    let env = getenv("DYLD_INSERT_LIBRARIES")
    if env != nil {
        return true
    }

    return false
}
```

>代码示例：CheckPhoneEnvironment.swift，ViewController.swift

## 四、OC代码混淆（使用脚本动态生成宏定义实现

>这里生成混淆代码的方法我们通过shell脚本来实现，同时我们需要一个文档来写入我们需要进行混淆的方法名或是变量名。

### 1、打开终端，cd到文件所在目录，使用

>touch confuseFuncOC.sh  
touch func.list

### 2、写入shell脚本

>在项目中找到刚刚拖进来的.sh文件，在confuseFuncOC.sh中写入脚本

```
#!/bin/bash

# 这是Shell脚本，如果不懂shell，自行修炼：http://www.runoob.com/linux/linux-shell.html

# 以下使用sqlite3进行增加数据，如果不了解sqlite3命令，自行修炼：http://www.runoob.com/sqlite/sqlite-tutorial.html

#数据表名
TABLENAME="CodeObFuncOC"

#数据库名
SYMBOL_DB_FILE="CodeObFuncOC.db"

#要被替换的方法列表文件
STRING_SYMBOL_FILE="$PROJECT_DIR/$PROJECT_NAME/confuseOC/func.list"

#被替换后的宏定义在此文件里
HEAD_FILE="$PROJECT_DIR/$PROJECT_NAME/confuseOC/CodeObFuncOC.h"

#维护数据库方便日后做bug排查
createTable()
{
echo "create table $TABLENAME(src text,des text);" | sqlite3 $SYMBOL_DB_FILE
}

insertValue()
{
echo "insert into $TABLENAME values('$1','$2');" | sqlite3 $SYMBOL_DB_FILE
}

query()
{
echo "select * from $TABLENAME where src='$1';" | sqlite3 $SYMBOL_DB_FILE
}

#生成随机16位名称
randomString()
{
openssl rand -base64 64 | tr -cd 'a-zA-Z' | head -c 16
}

#删除旧数据库文件
rm -f $SYMBOL_DB_FILE

#删除就宏定义文件
rm -f $HEAD_FILE

#创建数据表
createTable

#touch命令创建空文件，根据指定的路径
touch $HEAD_FILE
echo "#ifndef CodeObFuncOC_h
#define CodeObFuncOC_h" >> $HEAD_FILE
echo "" >> $HEAD_FILE
echo "//confuse string at `date`" >> $HEAD_FILE

#使用cat将方法列表文件里的内容全部读取出来，形成数组，然后逐行读取，并进行替换
cat "$STRING_SYMBOL_FILE" | while read -ra line;
do
if [[ ! -z "$line" ]]
then
random=`randomString`
echo $line $random

#将生成的随机字符串插入到表格中
insertValue $line $random

#将生成的字符串写入到宏定义文件中，变量是$HEAD_FILE
echo "#define $line $random" >> $HEAD_FILE
fi
done
echo "" >> $HEAD_FILE
echo "#endif" >> $HEAD_FILE
sqlite3 $SYMBOL_DB_FILE .dump
```

### 3、添加run script命令

>然后添加$PROJECT_DIR/$PROJECT_NAME/confuseOC/confuseFuncOC.sh

### 4、给脚本授权

>接下来还是在我们项目的文件夹下，通过终端给我们的脚本赋予最高权限  
chmod 777 confuse.sh

### 5、添加预编译文件PCH

>然后配置PCH文件

>添加$PROJECT_DIR/$PROJECT_NAME/confuseOC/PrefixHeader.pch

### 6、生成CodeObFuncOC.h文件

>这时候我们编译一下代码，会发现项目中多出了一个CodeObfuscation.h文件(如果没有，可到项目文件夹中找，我的就是在文件夹里找到的- -，然后拖进项目)。这个文件就是替换方法名的文件，我们在PCH文件中引入他。

### 7、在func.list中添加准备替换的方法名

>在项目中点开之前拖进来的func.list文件，然后在里面加入自己想要混淆的方法名

```
AMDecodeCString
AMDecodeOCString
AMEncodedString

BHJSafeCKey
BHJSafeEncodedCKey
BHJSafeOCKey
BHJSafeEncodedOCKey

viewControllerTestMethodA
```

### 8、结果

```
#ifndef CodeObFuncOC_h
#define CodeObFuncOC_h

//confuse string at Tue May 19 15:25:43 CST 2020
#define AMDecodeCString hXwuKZVGVazRQyrh
#define AMDecodeOCString UmeCDMlDYkikOONs
#define AMEncodedString cWUVwCfyjinoUfTH
#define BHJSafeCKey XuSfejJyEFdQJpnU
#define BHJSafeEncodedCKey dEsukIbZghFmCbaO
#define BHJSafeOCKey cOMBwiEXgTCSfmmg
#define BHJSafeEncodedOCKey rGvynrfresuEwpbx
#define viewControllerTestMethodA lPeIInAzbPoUXKOg

#endif
```

### 9、需要注意的几点

>不可以混淆iOS中的系统方法；  
不可以混淆iOS中init等初始化方法；  
不可以混淆xib的文件，会导致找不到对应文件；  
不可以混淆storyboard中用到的类名；  
混淆有风险，有可能会被App Store以2.1大礼包拒掉。

>代码示例：PrefixHeader.pch，confuseFuncOC.sh，CodeObFuncOC.h，func.list

## 五、字符串加密

>将明文字符串的每一个字符通过移位等操作转成16进制字符集，避免明文保存秘钥等重要信息。

### 1、加密

```
- (void)testGetHexString{
    int seed = 0x64;
    NSString *string = @"local char str";
//    int seed = 0xD7;
//    NSString *string = @"return c string";
    NSData *myD = [string dataUsingEncoding:NSUTF8StringEncoding];
    Byte *bytes = (Byte *)[myD bytes];
    //下面是Byte 转换为16进制。
    NSMutableString *hexStr = [NSMutableString string];
    for (int i = 0; i < [myD length]; i++) {
        NSString *newHexStr = [NSString stringWithFormat:@"%x",(bytes[i] & 0xff) ^ seed];///16进制数
        [hexStr appendString:[self formateHexString:newHexStr]];
    }
    [hexStr appendString:[self formateHexString:[NSString stringWithFormat:@"%x",seed]]];
    [hexStr deleteCharactersInRange:NSMakeRange(0, 1)];
    NSLog(@"\n%@",hexStr);
}

- (NSString *)formateHexString:(NSString *)hexStr {
    NSString *newHexStr = [hexStr uppercaseString];
    if ([newHexStr length] == 1) {
        return [NSString stringWithFormat:@", 0x0%@",newHexStr];
    } else {
        return [NSString stringWithFormat:@", 0x%@",newHexStr];
    }
}
```

### 2、解密

```
#ifdef __cplusplus
extern "C" {
#endif
    
#import <pthread.h>
    
    typedef struct AMEncodedString {
        char *origstr;
        int size;
        pthread_mutex_t mutex;
    } AMEncodedString;
    
    static inline char *AMDecodeCString(AMEncodedString *str) {
        pthread_mutex_lock(&str->mutex);
        char seed = str->origstr[str->size-1];
        int j = 0;
        do {
            str->origstr[j] ^= seed;
            j++;
        } while (j < str->size);
        pthread_mutex_unlock(&str->mutex);
        return str->origstr;
    }
    
#ifdef __OBJC__
#import <Foundation/Foundation.h>
    
    static inline NSString *AMDecodeOCString(AMEncodedString *str) {
        pthread_mutex_lock(&str->mutex);
        char seed = str->origstr[str->size-1];
        int j = 0;
        do {
            str->origstr[j] ^= seed;
            j++;
        } while (j < str->size);
        pthread_mutex_unlock(&str->mutex);
        return [[NSString alloc] initWithBytesNoCopy:str->origstr length:str->size-1 encoding:NSUTF8StringEncoding freeWhenDone:0];
    }
    
#endif
    
#ifdef __cplusplus
}
#endif

static unsigned char BHJSafeOCKey[] = { 0xA5, 0xB2, 0xA3, 0xA2, 0xA5, 0xB9, 0xF7, 0xB4, 0xF7, 0xA4, 0xA3, 0xA5, 0xBE, 0xB9, 0xB0, 0xD7 };
static AMEncodedString BHJSafeEncodedOCKey = { (char *)BHJSafeOCKey, sizeof(BHJSafeOCKey) };

static unsigned char BHJSafeCKey[] = { 0x08, 0x0B, 0x07, 0x05, 0x08, 0x44, 0x07, 0x0C, 0x05, 0x16, 0x44, 0x17, 0x10, 0x16, 0x64 };
static AMEncodedString BHJSafeEncodedCKey = { (char *)BHJSafeCKey, sizeof(BHJSafeCKey) };
```

>代码示例：PrefixHeader.pch，SafeSwiftDemoTests.m, ViewController2.m

