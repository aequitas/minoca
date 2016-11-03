img=${SRCROOT}/${ARCH}${VARIANT}${DEBUG}/bin/pc.img
buildchain=${SRCROOT}/${ARCH}${VARIANT}${DEBUG}/tools/bin/

all: $(img)

$(buildchain):
	make -C third-party tools

img: | $(buildchain)
	make -C os

clean:
	make -C os clean

mrproper: clean
	make -C os wipe
	make -C third-party clean
	rm -fr armv6rel armv6dbg x86rel x86dbg
