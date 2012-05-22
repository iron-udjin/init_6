# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"
ETYPE="sources"
K_SECURITY_UNSUPPORTED="1"
K_DEBLOB_AVAILABLE="1"

inherit kernel-2 versionator
detect_version
detect_arch

#------------------------------------------------------------------------

# Budget Fair Queueing Budget I/O Scheduler
bfq_url="http://algo.ing.unimo.it/people/paolo/disk_sched/"

# Con Kolivas' Brain Fuck CPU Scheduler
bfs_url="http://ck-hack.blogspot.com"
#bfs_ver="3.3"
bfs_src="http://ck.kolivas.org/patches/bfs/3.3.0/3.3-sched-bfs-420.patch"

# Alternate CPU load distribution technique for Linux kernel scheduler
bld_url="http://code.google.com/p/bld"
bld_ver="3.3-rc3" # 3.4-rc4 available but failed to install - 20.05.12
bld_src="http://bld.googlecode.com/files/bld-${bld_ver}.tar.bz2"

# Con Kolivas' high performance patchset
ck_url="http://users.on.net/~ckolivas/kernel"
ck_ver="3.3"
ck_src="http://ck.kolivas.org/patches/3.0/3.3/3.3-ck1/patch-${ck_ver}-ck1.bz2"

# Spock's fbsplash patch
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/3.4/4200_fbcondecor-0.9.6.patch"

# Fedora
fedora_url="http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary"

# grsecurity security patches
grsecurity_url="http://grsecurity.net"
grsecurity_ver="2.9-${OKV}-201205191125"
grsecurity_src="http://grsecurity.net/test/grsecurity-${grsecurity_ver}.patch"

# Gentoo hardened patchset
hardened_url="http://git.overlays.gentoo.org/gitweb/?p=proj/hardened-patchset.git;a=summary"

# TuxOnIce
ice_url="http://tuxonice.net"

# Intermediate Queueing Device patches
imq_url="http://www.linuximq.net"
imq_ver="3.3"
imq_src="http://www.linuximq.net/patches/patch-imqmq-${imq_ver}.diff.xz"

# Mandriva/Mageia
mageia_url="http://svnweb.mageia.org/packages/cauldron/kernel"

# Moblin/Meego
meego_url="https://meego.gitorious.org/meego-os-base/kernel-source" # http://git.yoctoproject.org/

# Pardus
pardus_url="https://svn.pardus.org.tr/pardus/playground/kaan.aksit/2011/kernel/default/kernel"

# Reiser4
reiser4_url="http://sourceforge.net/projects/reiser4"
#reiser4_ver="${OKV}"
#reiser4_src="mirror://kernel/linux/kernel/people/edward/reiser4/reiser4-for-2.6/reiser4-for-${REISER4_OKV}${REISER4_VER}.patch.bz2"

# Ingo Molnar's realtime preempt patches
rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"
#rt_ver="3.4-rc5-rt6"
#rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/3.4/patch-${rt_ver}.patch.xz"

# OpenSuSe
suse_url="http://kernel.opensuse.org/cgit/kernel-source"

# Ubuntu
ubuntu_url="https://launchpad.net/ubuntu/+source/linux"

# todo: add Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
# Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
#xenomai_url="http://www.xenomai.org"
#xenomai_ver="2.6.0"
#xenomai_src="http://download.gna.org/xenomai/stable/xenomai-${xenomai_ver}.tar.bz2"

#------------------------------------------------------------------------

KEYWORDS="~amd64 ~x86"
use reiser4 && die "No reiser4 support yet for this version."
use rt && die "No rt support yet for this version."

IUSE="bfq bfs bld branding ck deblob fbcondecor fedora grsecurity ice imq mageia pardus reiser4 rt suse ubuntu"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"

HOMEPAGE="http://www.kernel.org ${bfq_url} ${bfs_url} ${bld_url} ${ck_url} ${fbcondecor_url} ${fedora_url} ${grsecurity_url} ${ice_url} ${imq_url} ${mageia_url} ${pardus_url} ${reiser4_url} ${rt_url} ${suse_url}"

SRC_URI="${KERNEL_URI} ${ARCH_URI}
	bfs?		( ${bfs_src} )
	bld?		( ${bld_src} )
	ck?		( ${ck_src} )
	fbcondecor?	( ${fbcondecor_src} )
	grsecurity?	( ${grsecurity_src} )
	imq?		( ${imq_src} )"

RDEPEND="${RDEPEND}
	grsecurity?	( >=sys-apps/gradm-2.2.2 )
	ice?		( >=sys-apps/tuxonice-userui-1.0
			( || ( >=sys-power/hibernate-script-2.0 sys-power/pm-utils ) ) )"

KV_FULL="${PVR}-geek"
S="${WORKDIR}"/linux-"${KV_FULL}"
SLOT="${PV}"

patch_command='patch -p1 -F1 -s'
ExtractApply() {
	local patch=$1
	shift
	case "$patch" in
	*.bz2) bunzip2 < "$patch" | $patch_command ${1+"$@"} ;;
	*.gz)  gunzip  < "$patch" | $patch_command ${1+"$@"} ;;
	*.xz)  unxz    < "$patch" | $patch_command ${1+"$@"} ;;
	*) $patch_command ${1+"$@"} < "$patch" ;;
	esac
}

Handler() {
	local patch=$1
	shift
	if [ ! -f $patch ]; then
		ewarn "Patch $patch does not exist."
		exit 1
	fi
	# don't apply patch if it's empty
	local C=$(wc -l $patch | awk '{print $1}')
	if [ "$C" -gt 9 ]; then
		patch_command='patch -p1 --dry-run'
		if ExtractApply "$patch" &>/dev/null; then
			patch_command='patch -p1 -F1 -s'
			ExtractApply "$patch" &>/dev/null
		else
			ewarn "Skipping patch --> $(basename $patch)"
		fi
	fi
}

ApplyPatch() {
	local patch=$1
	shift
	case `basename "$patch"` in
	patch_list)
		while read -r line
		do
			# skip comments
			[[ $line =~ ^\ {0,}# ]] && continue
			# skip empty lines
			[[ -z "$line" ]] && continue
				ebegin "Applying $line"
					dir=`dirname "$patch"`
					Handler "$dir/$line"
				eend $?
		done < "$patch"
	;;
	*)
		ebegin "Applying $(basename $patch)"
			Handler "$patch"
		eend $?
	;;
	esac
}

src_prepare() {
	# Budget Fair Queueing Budget I/O Scheduler
	use bfq && ApplyPatch "${FILESDIR}/${OKV}/bfq/patch_list"

	# Con Kolivas Brain Fuck CPU Scheduler
	use bfs && ApplyPatch "${DISTDIR}/3.3-sched-bfs-420.patch"

	# Con Kolivas high performance patchset
	use ck && ApplyPatch "$DISTDIR/patch-$ck_ver-ck1.bz2"

	# Spock's fbsplash patch
	use fbcondecor && ApplyPatch "${DISTDIR}/4200_fbcondecor-0.9.6.patch"

	# grsecurity security patches
	use grsecurity && ApplyPatch "${DISTDIR}/grsecurity-${grsecurity_ver}.patch"

	# TuxOnIce
	use ice && ApplyPatch "${FILESDIR}/tuxonice-kernel-${PV}.patch.xz"

	# Intermediate Queueing Device patches
	use imq && ApplyPatch "${DISTDIR}/patch-imqmq-${imq_ver}.diff.xz"

	# Reiser4
	use reiser4 && ApplyPatch "${DISTDIR}/reiser4-for-${OKV}.patch.bz2"

	# Ingo Molnar's realtime preempt patches
	use rt && ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz"

	# Alternate CPU load distribution technique for Linux kernel scheduler
	if use bld; then
		cd "${T}"
		unpack "bld-${bld_ver}.tar.bz2"
		cp "${T}/bld-${bld_ver}/BLD_${bld_ver}-feb12.patch" "${S}/BLD_${bld_ver}-feb12.patch"
		cd "${S}"
		ApplyPatch "${S}/BLD_${bld_ver}-feb12.patch"
		rm -f "${S}/BLD_${bld_ver}-feb12.patch"
		rm -r "${T}/bld-${bld_ver}" # Clean temp
	fi

#	if use xenomai; then
#		# Portage's ``unpack'' macro unpacks to the current directory.
#		# Unpack to the work directory.  Afterwards, ``work'' contains:
#		#   linux-2.6.29-xenomai-r5
#		#   xenomai-2.4.9
#		cd ${WORKDIR}
#		unpack ${XENO_TAR} || die "unpack failed"
#		cd ${WORKDIR}/${XENO_SRC}
#		ApplyPatch ${FILESDIR}/prepare-kernel.patch || die "patch failed"
#		scripts/prepare-kernel.sh --linux=${S} || die "prepare kernel failed"
#	fi

### BRANCH APPLY ###

	# Mandriva/Mageia
	use mageia && ApplyPatch "$FILESDIR/$OKV/mageia/patch_list"

	# Ubuntu
	use ubuntu && ApplyPatch "$FILESDIR/$OKV/ubuntu/patch_list"

	# Fedora
	use fedora && ApplyPatch "$FILESDIR/$OKV/fedora/patch_list"

	# OpenSuSE
	use suse && ApplyPatch "$FILESDIR/$OKV/suse/patch_list"

	# Pardus
	use pardus && ApplyPatch "$FILESDIR/$OKV/pardus/patch_list"

	# Oops: ACPI: EC: input buffer is not empty, aborting transaction - 2.6.32 regression
	# https://bugzilla.kernel.org/show_bug.cgi?id=14733#c41
	ApplyPatch "${FILESDIR}/acpi-ec-add-delay-before-write.patch"

	# USE branding
	if use branding; then
		ApplyPatch "${FILESDIR}/font-8x16-iso-latin-1-v2.patch"
		ApplyPatch "${FILESDIR}/gentoo-larry-logo-v2.patch"
	fi

### END OF PATCH APPLICATIONS ###

	einfo "Make kernel default configs"
	cp "$FILESDIR/$PVR"/fedora/config-* . || die "cannot copy kernel config";
	cp "$FILESDIR/$PVR"/fedora/merge.pl "$FILESDIR/$PVR"/fedora/Makefile.config . &>/dev/null || die "cannot copy kernel files";
	make -f Makefile.config VERSION=${PVR} configs &>/dev/null || die "cannot generate kernel .config files from config-* files"

	einfo "Copy current config from /proc"
	if [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then
		ewarn "Kernel config file already exist."
		ewarn "I will NOT overwrite that."
	else
		einfo "Copying kernel config file."
		zcat /proc/config > .config || ewarn "Can't copy /proc/config"
	fi

# Install the docs
	nonfatal dodoc "${FILESDIR}/${PVR}"/fedora/{README.txt,TODO}

	echo
	einfo "Live long and prosper."
	echo

	einfo "Set extraversion" # manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	einfo "Delete temp files"
	for cfg in {config-*,temp-*,merge.pl}; do
		rm -f $cfg
	done;
}

src_install() {
	local version_h_name="usr/src/linux-${KV_FULL}/include/linux"
	local version_h="${ROOT}${version_h_name}"

	if [ -f "${version_h}" ]; then
		einfo "Discarding previously installed version.h to avoid collisions"
		addwrite "/${version_h_name}"
		rm -f "${version_h}"
	fi

	kernel-2_src_install
}

pkg_postinst() {
# ToDo fix that
#	if [ ! -e ${ROOT}usr/src/linux ]
#	then
#		rm -rf "${ROOT}usr/src/linux"
#		ln -sf "${ROOT}usr/src/linux" "${ROOT}usr/src/linux-${KV_FULL}"
#	fi
	einfo "Now is the time to configure and build the kernel."
	use bfq && einfo "bfq enable Budget Fair Queueing Budget I/O Scheduler patches - ${bfq_url}"
	use bfs && einfo "bfs enable Con Kolivas Brain Fuck CPU Scheduler patches - ${bfs_url}"
	use bld && einfo "bld enable Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}"
	if use branding; then
		einfo "branding enable:"
		einfo "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		einfo "logo - CONFIG_LOGO_LARRY_CLUT224 http://www.gentoo.org/proj/en/desktop/artwork/artwork.xml"
	fi
	use ck && einfo "ck enable Con Kolivas' high performance patchset - ${ck_url}"
	use fedora && einfo "fedora enable fedora patches - ${fedora_url}"
	use fbcondecor && einfo "fbcondecor enable Spock's fbsplash patch - ${fbcondecor_url}"
	use grsecurity && einfo "grsecurity enable grsecurity security patches - ${grsecurity_url}"
	use ice && einfo "ice enable TuxOnIce patches - ${ice_url}"
	use imq && einfo "imq enable Intermediate Queueing Device patches - ${imq_url}"
	use mageia && einfo "mageia enable mageia patches - ${mageia_url}"
	use pardus && einfo "pardus enable pardus patches - ${pardus_url}"
	use reiser4 && einfo "reiser4 enable Reiser4 FS patches - ${reiser4_url}"
	use rt && einfo "rt enable Ingo Molnar's realtime preempt patches - ${rt_url}"
	use suse && einfo "suse enable suse patches - ${suse_url}"
	use ubuntu && einfo "ubuntu enable ubuntu patches - ${ubuntu_url}"
}
