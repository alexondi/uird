#!/bin/bash
rm -rf /usr/lib/dracut/modules.d/97uird /usr/lib/dracut/modules.d/98uird-soft /usr/lib/dracut/modules.d/90ntfs
cp -pRf modules.d/* /usr/lib/dracut/modules.d

#dracut -N  -f -m "base busybox uird magos-soft network ntfs url-lib ifcfg"  \
dracut -N  -f -m "base busybox uird ntfs uird-soft"  \
	-d "loop cryptoloop aes-generic aes-i586 pata_acpi ata_generic ahci xhci-hcd" \
        --filesystems "aufs squashfs vfat msdos iso9660 isofs xfs ext3 ext4 fuse nfs cifs" \
        --confdir "dracut.conf.d" \
        -i initrd / \
        --kernel-cmdline "uird.from=/MagOS uird.ro=*.xzm uird.load=/base/ uird.changes=xzm uird.machines=/MagOS-Data/machines" \
        -c dracut.conf -v -M uird.soft.cpio.xz $(uname -r) >dracut.log 2>&1

