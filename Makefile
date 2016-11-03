disk=/dev/disk2
remote=
image?=rpi

gcc=.bin/gcc
buildchain=${SRCROOT}/${ARCH}${VARIANT}${DEBUG}/tools/bin/

all: img

$(buildchain): | $(gcc)
	make -C third-party tools

img: | $(buildchain)
	make -C os

$(gcc): | $(shell brew --prefix)/bin/gcc-6
	mkdir -p .bin
	ln -s $(shell brew --prefix)/bin/gcc-6 $@

$(brew --prefix)/bin/gcc-6:
	brew install gcc

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

clean:
	make -C os clean

mrproper: clean
	make -C os wipe
	make -C third-party clean
	rm -fr armv6rel armv6dbg x86rel x86dbg
