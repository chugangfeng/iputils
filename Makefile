#
# Configuration
#

# CC
CC=gcc
#指定gcc 程序
# Path to parent kernel include files directory
#指向包括文件库的父内核路径
LIBC_INCLUDE=/usr/include
# Libraries
#加载库
ADDLIB=
# Linker flags
#Wl选项告诉编译器将后面的参数传递给链接器
#-Wl,-Bstatic告诉链接器使用-Bstatic选项，该选项是告诉链接器，对接下来的-l选项使用静态链接
#-Wl,-Bdynamic就是告诉链接器对接下来的-l选项使用动态链接
LDFLAG_STATIC=-Wl,-Bstatic
LDFLAG_DYNAMIC=-Wl,-Bdynamic
#指定加载库
LDFLAG_CAP=-lcap
LDFLAG_GNUTLS=-lgnutls-openssl
LDFLAG_CRYPTO=-lcrypto
LDFLAG_IDN=-lidn
LDFLAG_RESOLV=-lresolv
LDFLAG_SYSFS=-lsysfs

#
# Options
#选项
#

#定义变量，设置开关
# Capability support (with libcap) [yes|static|no]
#功能支持
USE_CAP=yes
# sysfs support (with libsysfs - deprecated) [no|yes|static]
#sysfs支持
USE_SYSFS=no
# IDN support (experimental) [no|yes|static]
#IDN支持
USE_IDN=no

# Do not use getifaddrs [no|yes|static]
#不要使用getifaddrs
WITHOUT_IFADDRS=no
# arping default device (e.g. eth0) []
#arping的默认设备
ARPING_DEFAULT_DEVICE=

# GNU TLS library for ping6 [yes|no|static]
#ping6的GUN TLS 库
USE_GNUTLS=yes
# Crypto library for ping6 [shared|static]
#ping6的密码库
USE_CRYPTO=shared
# Resolv library for ping6 [yes|static]
#ping6的resolv库
USE_RESOLV=yes
# ping6 source routing (deprecated by RFC5095) [no|yes|RFC3542]
#ping6的源路由
ENABLE_PING6_RTHDR=no

# rdisc server (-r option) support [no|yes]
ENABLE_RDISC_SERVER=no

# -------------------------------------
# What a pity, all new gccs are buggy and -Werror does not work. Sigh.
#但是，gcc和werror都不起作用
# CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -Werror -g
#-Wstrict-prototypes: 如果函数的声明或定义没有指出参数类型，编译器就发出警告
CCOPT=-fno-strict-aliasing -Wstrict-prototypes -Wall -g
CCOPTOPT=-O3
GLIBCFIX=-D_GNU_SOURCE
DEFINES=
LDLIB=

FUNC_LIB = $(if $(filter static,$(1)),$(LDFLAG_STATIC) $(2) $(LDFLAG_DYNAMIC),$(2))

# USE_GNUTLS: DEF_GNUTLS, LIB_GNUTLS
# USE_CRYPTO: LIB_CRYPTO
ifneq ($(USE_GNUTLS),no)
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_GNUTLS),$(LDFLAG_GNUTLS))
	DEF_CRYPTO = -DUSE_GNUTLS
else
	LIB_CRYPTO = $(call FUNC_LIB,$(USE_CRYPTO),$(LDFLAG_CRYPTO))
endif

# USE_RESOLV: LIB_RESOLV
LIB_RESOLV = $(call FUNC_LIB,$(USE_RESOLV),$(LDFLAG_RESOLV))

# USE_CAP:  DEF_CAP, LIB_CAP
ifneq ($(USE_CAP),no)
	DEF_CAP = -DCAPABILITIES
	LIB_CAP = $(call FUNC_LIB,$(USE_CAP),$(LDFLAG_CAP))
endif

# USE_SYSFS: DEF_SYSFS, LIB_SYSFS
ifneq ($(USE_SYSFS),no)
	DEF_SYSFS = -DUSE_SYSFS
	LIB_SYSFS = $(call FUNC_LIB,$(USE_SYSFS),$(LDFLAG_SYSFS))
endif

# USE_IDN: DEF_IDN, LIB_IDN
ifneq ($(USE_IDN),no)
	DEF_IDN = -DUSE_IDN
	LIB_IDN = $(call FUNC_LIB,$(USE_IDN),$(LDFLAG_IDN))
endif

# WITHOUT_IFADDRS: DEF_WITHOUT_IFADDRS
ifneq ($(WITHOUT_IFADDRS),no)
	DEF_WITHOUT_IFADDRS = -DWITHOUT_IFADDRS
endif

# ENABLE_RDISC_SERVER: DEF_ENABLE_RDISC_SERVER
ifneq ($(ENABLE_RDISC_SERVER),no)
	DEF_ENABLE_RDISC_SERVER = -DRDISC_SERVER
endif

# ENABLE_PING6_RTHDR: DEF_ENABLE_PING6_RTHDR
ifneq ($(ENABLE_PING6_RTHDR),no)
	DEF_ENABLE_PING6_RTHDR = -DPING6_ENABLE_RTHDR
ifeq ($(ENABLE_PING6_RTHDR),RFC3542)
	DEF_ENABLE_PING6_RTHDR += -DPINR6_ENABLE_RTHDR_RFC3542
endif
endif

# -------------------------------------
IPV4_TARGETS=tracepath ping clockdiff rdisc arping tftpd rarpd
IPV6_TARGETS=tracepath6 traceroute6 ping6
#赋值TARGETS
TARGETS=$(IPV4_TARGETS) $(IPV6_TARGETS)
#定义变量
CFLAGS=$(CCOPTOPT) $(CCOPT) $(GLIBCFIX) $(DEFINES)
LDLIBS=$(LDLIB) $(ADDLIB)

#用shell取值
UNAME_N:=$(shell uname -n)
LASTTAG:=$(shell git describe HEAD | sed -e 's/-.*//')
TODAY=$(shell date +%Y/%m/%d)
DATE=$(shell date --date $(TODAY) +%Y%m%d)
TAG:=$(shell date --date=$(TODAY) +s%Y%m%d)
#当我们定义了一个变量之后，就可以在Makefile的很多地方使用这个变量。变量的引用方式是：使用“$（VARIABLE_NAME）”或者“${ VARIABLE_NAME }”来引用一个变量的定义。例 如：“$(foo) ”或者“${foo}”就是取变量“foo”的值。美元符号“$”在Makefile中有特殊的含义，所有在命令或者文件名中使用“$”时需要用两个美元 符号“$$”来表示。对一个变量的引用可以在Makefile的任何上下文中，目标、依赖、命令、绝大多数指示符和新变量的赋值中。这里有一个例子，其中 变量保存了所有.o文件的列表：

#objects = program.o foo.o utils.o
#program : $(objects)
#       cc -o program $(objects)

#$(objects) : defs.h

#变量引用的展开过程是严格的文本替换过程，就是说变量值的字符串被精确的展开在此变量被引用的地方。因此规则：

#foo = c
#prog.o : prog.$(foo)
#       $(foo) $(foo) -$(foo) prog.$(foo)
#被展开后就是：

#prog.c : prog.c
#       cc -c prog.c


# -------------------------------------
#makefile
.PHONY: all ninfod clean distclean man html check-kernel modules snapshot

all: $(TARGETS)

%.s: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -S -o $@
%.o: %.c
	$(COMPILE.c) $< $(DEF_$(patsubst %.o,%,$@)) -o $@
$(TARGETS): %: %.o
	$(LINK.o) $^ $(LIB_$@) $(LDLIBS) -o $@
# COMPILE.c=$(CC) $(CFLAGS) $(CPPFLAGS) -c
# $< 依赖目标中的第一个目标名字 
# $@ 表示目标
# $^ 所有的依赖目标的集合 
# 在$(patsubst %.o,%,$@ )中，patsubst把目标中的变量符合后缀是.o的全部删除,  DEF_ping
# LINK.o把.o文件链接在一起的命令行,缺省值是$(CC) $(LDFLAGS) $(TARGET_ARCH)
#以ping为例，翻译为：
# gcc -O3 -fno-strict-aliasing -Wstrict-prototypes -Wall -g -D_GNU_SOURCE    -c ping.c -DCAPABILITIES   -o ping.o
#gcc   ping.o ping_common.o -lcap    -o ping
# -------------------------------------
# arping
#设置arping
DEF_arping = $(DEF_SYSFS) $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_arping = $(LIB_SYSFS) $(LIB_CAP) $(LIB_IDN)

ifneq ($(ARPING_DEFAULT_DEVICE),)
DEF_arping += -DDEFAULT_DEVICE=\"$(ARPING_DEFAULT_DEVICE)\"
endif

# clockdiff
#设置clochdiff
DEF_clockdiff = $(DEF_CAP)
LIB_clockdiff = $(LIB_CAP)

# ping / ping6
#设置ping以及ping6
DEF_ping_common = $(DEF_CAP) $(DEF_IDN)
DEF_ping  = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS)
LIB_ping  = $(LIB_CAP) $(LIB_IDN)
DEF_ping6 = $(DEF_CAP) $(DEF_IDN) $(DEF_WITHOUT_IFADDRS) $(DEF_ENABLE_PING6_RTHDR) $(DEF_CRYPTO)
LIB_ping6 = $(LIB_CAP) $(LIB_IDN) $(LIB_RESOLV) $(LIB_CRYPTO)

ping: ping_common.o
ping6: ping_common.o
ping.o ping_common.o: ping_common.h
ping6.o: ping_common.h in6_flowlabel.h

# rarpd
#设置rarpd
DEF_rarpd =
LIB_rarpd =

# rdisc
#设置rdisc
DEF_rdisc = $(DEF_ENABLE_RDISC_SERVER)
LIB_rdisc =

# tracepath
#设置tracepath
DEF_tracepath = $(DEF_IDN)
LIB_tracepath = $(LIB_IDN)

# tracepath6
#设置tracepath6
DEF_tracepath6 = $(DEF_IDN)
LIB_tracepath6 =

# traceroute6
#设置traceroute6
DEF_traceroute6 = $(DEF_CAP) $(DEF_IDN)
LIB_traceroute6 = $(LIB_CAP) $(LIB_IDN)

# tftpd
#设置tftpd
DEF_tftpd =
DEF_tftpsubs =
LIB_tftpd =

tftpd: tftpsubs.o
tftpd.o tftpsubs.o: tftp.h

# -------------------------------------
# ninfod
#编译ninfod
ninfod:
	@set -e; \
		if [ ! -f ninfod/Makefile ]; then \
			cd ninfod; \
			./configure; \
			cd ..; \
		fi; \
		$(MAKE) -C ninfod

# -------------------------------------
# modules / check-kernel are only for ancient kernels; obsolete
#模块和检查内核只针对之前的内核（什么意思。。。）
check-kernel:
ifeq ($(KERNEL_INCLUDE),)
	@echo "Please, set correct KERNEL_INCLUDE"; false
else
	@set -e; \
	if [ ! -r $(KERNEL_INCLUDE)/linux/autoconf.h ]; then \
		echo "Please, set correct KERNEL_INCLUDE"; false; fi
endif

modules: check-kernel
	$(MAKE) KERNEL_INCLUDE=$(KERNEL_INCLUDE) -C Modules

# -------------------------------------
man:
	$(MAKE) -C doc man

html:
	$(MAKE) -C doc html

clean:
	@rm -f *.o $(TARGETS)
	@$(MAKE) -C Modules clean
	@$(MAKE) -C doc clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod clean; \
		fi

distclean: clean
	@set -e; \
		if [ -f ninfod/Makefile ]; then \
			$(MAKE) -C ninfod distclean; \
		fi

# -------------------------------------
snapshot:
#输出
	@if [ x"$(UNAME_N)" != x"pleiades" ]; then echo "Not authorized to advance snapshot"; exit 1; fi
	@echo "[$(TAG)]" > RELNOTES.NEW
	@echo >>RELNOTES.NEW
	@git log --no-merges $(LASTTAG).. | git shortlog >> RELNOTES.NEW
	@echo >> RELNOTES.NEW
	@cat RELNOTES >> RELNOTES.NEW
	@mv RELNOTES.NEW RELNOTES
	@sed -e "s/^%define ssdate .*/%define ssdate $(DATE)/" iputils.spec > iputils.spec.tmp
	@mv iputils.spec.tmp iputils.spec
	@echo "static char SNAPSHOT[] = \"$(TAG)\";" > SNAPSHOT.h
	@$(MAKE) -C doc snapshot
	@$(MAKE) man
	@git commit -a -m "iputils-$(TAG)"
	@git tag -s -m "iputils-$(TAG)" $(TAG)
	@git archive --format=tar --prefix=iputils-$(TAG)/ $(TAG) | bzip2 -9 > ../iputils-$(TAG).tar.bz2

