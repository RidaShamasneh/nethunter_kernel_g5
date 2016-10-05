export ARCH=arm
export SUBARCH=arm
export CROSS_COMPILE=arm-eabi-
export PATH=../platform/prebuilts/gcc/linux-x86/arm/arm-eabi-4.8/bin:$PATH

##export CROSS_COMPILE=arm-linux-androideabi-
##export PATH=../platform/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin:$PATH

make goldfish_armv7_defconfig
make -j4
