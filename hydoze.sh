#
# Custom build script for Shadow kernel
#
# Copyright 2016 Umang Leekha (Umang96@xda)
#
# This software is licensed under the terms of the GNU General Public
# License version 2, as published by the Free Software Foundation, and
# may be copied, distributed, and modified under those terms.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# Please maintain this if you use this script or any part of it.
#
VERSION="Pie"
DEVICE="Beryllium"
yellow='\033[0;33m'
white='\033[0m'
red='\033[0;31m'
gre='\e[0;32m'
echo -e ""
echo -e "$gre ====================================\n\n Welcome to Shadow building program !\n\n ===================================="
echo -e "$gre \n 1.Build Shadow\n\n 2.Make Menu Config\n\n 3.Clean Source\n\n 4.Exit\n"
echo -n " Enter your choice:"
read qc
echo -e "$white"
KERNEL_DIR=$PWD
export ARCH=arm64
export CROSS_COMPILE="/home/ubuntu/android/toolchain/bin/aarch64-linux-gnu-"
if [ $qc == 1 ]; then
echo -e "$yellow Building Kernel \n $white"
Start=$(date +"%s")
echo -e "$yellow Running make clean before compiling \n$white"
make clean && make mrproper
make O=out clean
make O=out mrproper
make O=out beryllium_defconfig

export KBUILD_BUILD_HOST="gcp"
export KBUILD_BUILD_USER="incmak"
make O=out -j$(nproc --all)
time=$(date +"%d-%m-%y-%T")
date=$(date +"%d-%m-%y")

zimage=$KERNEL_DIR/out/arch/arm64/boot/Image
if ! [ -a $zimage ];
then
echo -e "$red << Failed to compile zImage, fix the errors first >>$white"
else
cd $KERNEL_DIR/build/
rm *.zip > /dev/null 2>&1
echo -e "$yellow\n Build successful, generating flashable zip now \n $white"
End=$(date +"%s")
Diff=$(($End - $Start))
rm -rf dtbs
mv $KERNEL_DIR/out/arch/arm64/boot/dts/qcom/ $KERNEL_DIR/build/
mv $KERNEL_DIR/build/qcom $KERNEL_DIR/build/dtbs
cd $KERNEL_DIR/build/dtbs/
rm modules.order
cp $KERNEL_DIR/out/arch/arm64/boot/Image.gz $KERNEL_DIR/build/kernel/
cd $KERNEL_DIR/build/
echo -n " Enter release version:"
read rv
zip -r HyDoze-$DEVICE-$VERSION-$rv-$date.zip * > /dev/null
echo -n "Upload zip to gdrive ? Y/N:"
read gd
if [ $gd == Y ]; then
gdrive upload HyDoze-$DEVICE-$VERSION-$rv-$date.zip
fi
echo -e "$gre << Build completed in $(($Diff / 60)) minutes and $(($Diff % 60)) seconds >> \n $white"
fi
elif [ $qc == 2 ]; then
make O=out clean
make O=out franco_defconfig
make O=out menuconfig
./hydoze.sh
elif [ $qc == 3 ]; then
echo -e "$yellow Cleaning... \n$white"
make clean && make mrproper
make O=out clean
make O=out mrproper
./hydoze.sh
elif [ $qc == 4 ]; then
echo -e "$yellow good bye ! \n$white"
fi
