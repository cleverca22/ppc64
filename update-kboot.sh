#! @crossShell@

ln -svf $1/init /init

cp -vL $1/initrd /boot/initrd

cp @kbootTemplate@ /boot/kboot.tmp

echo 'nixos_latest="uda0:/zImage.xenon initrd=uda0:/initrd console=tty0 console=ttyS0,115200 video=xenonfb loglevel=16 coherent_pool=16M nokaslr init=/init"' >> /boot/kboot.tmp
echo 'default=nixos_latest' >> /boot/kboot.tmp

mv /boot/kboot.tmp /boot/kboot.conf
