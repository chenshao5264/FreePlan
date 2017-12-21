#!/bin/bash


workdir=$(cd $(dirname $0); pwd)

# 平台android ios
target=android
# 远程文件地址
romate_url=http://192.168.0.203:3000
# 包名
package_name=bfmj
# 工程路径
proj_root=$workdir/../
# 当前脚本执行路径
scripts_root=$workdir
# 小版本号
verion_text=$workdir/version_android_$package_name.text
# 大版本号
pre_verion_text=1.0.
# lua加密路径
luacompile_root=F:\\cocos2d-x-3.16\\tools\\cocos2d-console\\bin\\cocos
# lua是否需求加密 0 不加密 1 加密
is_need_luacompile=0

echo "----------------  android -------------"
./update_lua.sh $target $romate_url $package_name $proj_root $verion_text $scripts_root $luacompile_root $pre_verion_text $is_need_luacompile
echo "----------------  android 完毕-------------"
