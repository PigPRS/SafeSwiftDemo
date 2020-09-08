#!/bin/bash

# 这是Shell脚本，如果不懂shell，自行修炼：http://www.runoob.com/linux/linux-shell.html

# 以下使用sqlite3进行增加数据，如果不了解sqlite3命令，自行修炼：http://www.runoob.com/sqlite/sqlite-tutorial.html

#数据表名
TABLENAME="CodeObClassOC"

#数据库名
SYMBOL_DB_FILE="CodeObClassOC.db"

#要被替换的方法列表文件
STRING_SYMBOL_FILE="$PROJECT_DIR/$PROJECT_NAME/confuseOC/class.list"

#被替换后的宏定义在此文件里
HEAD_FILE="$PROJECT_DIR/$PROJECT_NAME/confuseOC/CodeObClassOC.h"

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
echo "#ifndef CodeObClassOC_h
#define CodeObClassOC_h" >> $HEAD_FILE
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
echo "#ifndef $line" >> $HEAD_FILE
echo "#define $line $random" >> $HEAD_FILE
echo "#endif" >> $HEAD_FILE
echo "" >> $HEAD_FILE
fi
done
echo "" >> $HEAD_FILE
echo "#endif" >> $HEAD_FILE
sqlite3 $SYMBOL_DB_FILE .dump
