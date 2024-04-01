#!/bin/bash -e

install -v -m 644 files/fstab "${ROOTFS_DIR}/etc/fstab"

if [ "${FILE_SYSTEM_TYPE}" == "ext4" ]; then
	echo "ROOTDEV  /               ext4    defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
elif [ "${FILE_SYSTEM_TYPE}" == "btrfs" ]; then
	echo "ROOTDEV  /               btrfs   subvol=@,compress=zstd,defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
	echo "ROOTDEV  /home           btrfs   subvol=@home,compress=zstd,defaults,noatime  0       1" >> "${ROOTFS_DIR}/etc/fstab"
else
	echo "Unsupported root file system type '${FILE_SYSTEM_TYPE}'. Only ext4 and btrfs are supported."
	exit 1
fi

on_chroot << EOF
if ! id -u ${FIRST_USER_NAME} >/dev/null 2>&1; then
	adduser --disabled-password --gecos "" ${FIRST_USER_NAME}
fi

if [ -n "${FIRST_USER_PASS}" ]; then
	echo "${FIRST_USER_NAME}:${FIRST_USER_PASS}" | chpasswd
fi
echo "root:root" | chpasswd
EOF


