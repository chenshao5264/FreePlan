#!/bin/bash

target=$1
romate_url=$2
package_name=$3
proj_root=$4
verion_text=$5
scripts_root=$6
luacompile_root=$7
pre_verion_text=$8
is_need_luacompile=$9

cd $proj_root

mkdir hotupdate
rm -rf hotupdate/$package_name

mkdir hotupdate/manifests
mkdir hotupdate/$package_name

cp -r ./src/$package_name ./hotupdate

if [ "$is_need_luacompile" = 1 ]; then
	echo "---------------- 开始加密 -------------"
	$luacompile_root luacompile -s ./src/$package_name -d ./hotupdate/$package_name -e -k key-zjzy2016.. -b sign-zjzy2016.. --disable-compile
	find ./hotupdate/$package_name -name *.lua|xargs rm -rf
	echo "---------------- 完成加密 -------------"
fi

#删除.DS_Store
find ./hotupdate -name *.DS_Store|xargs rm -rf

echo "---------------- 开始生成 配置文件-------------"
#每次运行版本号最后一位自+1
#文件格式必须保证正确，此脚本不做任何检测
pre_verion=$pre_verion_text

##读取文件第一行作为版本号的最后一位
build=`head -1 $verion_text` 
version=$pre_verion$build

echo version=$version

##自+1
newVersion=$(($build+1))
echo $newVersion > $verion_text
#
export URL=$romate_url/scripts/$target/
export VERSION=$version
export WALKDIR=$proj_root/hotupdate
export OUT_DIR=$proj_root/hotupdate/manifests
export TARGET=$target
export PACKAGENAME=$package_name

echo $scripts_root
node $scripts_root/lfsHelper
echo "---------------- 完成生成 配置文件-------------"

cp -r ./hotupdate/manifests $proj_root/src


read -p "Press any key to continue." var