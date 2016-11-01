disk=/dev/disk2
remote=
image?=rpi

flash: ${image}.img umount_disk2
	sudo dd if=$< of=${disk}
	diskutil umountDisk /dev/disk2

$(patsubst %.zip,%.img,$(wildcard *.zip)): %.img: %.zip
	unzip $<
	test -f $@ && touch $@

$(patsubst %.tar.gz,%.img,$(wildcard *.tar.gz)): %.img: %.tar.gz
	tar zxvpf $<
	test -f $@ && touch $@

umount_disk2:
	diskutil umountDisk ${disk}

sshkey:
	test ! -z ${remote}
	-ssh-copy-id root@${remote}
	stty -echo; ssh root@${remote} passwd; stty echo

bootstrap:
	test ! -z ${remote}
	scp bootstrap.sh root@${remote}:/boot/bootstrap.sh
	ssh root@${remote} /bin/sh -l /boot/bootstrap.sh
