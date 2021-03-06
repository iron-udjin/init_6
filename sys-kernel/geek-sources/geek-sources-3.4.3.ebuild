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

# Latest version checker:
# # curl -s http://www.kernel.org/kdist/finger_banner

aufs_url="http://aufs.sourceforge.net/"
# git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git, read README
# Patch creation:
# git clone git://aufs.git.sourceforge.net/gitroot/aufs/aufs3-standalone.git
# cd aufs3-standalone
# git checkout -b aufs3.4 origin/aufs3.4
# cat aufs3-kbuild.patch aufs3-base.patch aufs3-standalone.patch > ~/rpm/packages/kernel/kernel-aufs3.patch
# mkdir linux
# cp -a Documentation fs include linux
# diff -urN /usr/share/empty linux >> ~/rpm/packages/kernel/kernel-aufs3.patch
# drop hunk at the end of patch (hunk is patching include/linux/Kbuild with single line change)

# apparmor
# http://git.kernel.org/?p=linux/kernel/git/jj/linux-apparmor.git;a=shortlog;h=refs/heads/v3.4-aa2.8

# Budget Fair Queueing Budget I/O Scheduler
bfq_url="http://algo.ing.unimo.it/people/paolo/disk_sched/"

# Alternate CPU load distribution technique for Linux kernel scheduler
bld_url="http://code.google.com/p/bld"
bld_ver="3.4-rc4"
bld_src="http://bld.googlecode.com/files/bld-${bld_ver}.tar.bz2"

# Con Kolivas' high performance patchset
ck_url="http://users.on.net/~ckolivas/kernel"
ck_ver="3.4"
ck_src="http://ck.kolivas.org/patches/3.0/3.4/3.4-ck2/patch-${ck_ver}-ck2.bz2"

# Spock's fbsplash patch
fbcondecor_url="http://dev.gentoo.org/~spock/projects/fbcondecor"
fbcondecor_src="http://sources.gentoo.org/cgi-bin/viewvc.cgi/linux-patches/genpatches-2.6/trunk/3.4/4200_fbcondecor-0.9.6.patch"

# Fedora
fedora_url="http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary"

# grsecurity security patches
# NOTE: mirror of old grsecurity patches:
# https://github.com/slashbeast/grsecurity-scrape/tree/master/test
grsecurity_url="http://grsecurity.net"
# Gentoo hardened patchset
# http://git.overlays.gentoo.org/gitweb/?p=proj/hardened-patchset.git;a=summary
grsecurity_ver="2.9.1-${OKV}-201206171836"
grsecurity_src="http://grsecurity.net/test/grsecurity-${grsecurity_ver}.patch"

# TuxOnIce
ice_url="http://tuxonice.net"

# Intermediate Queueing Device patches
imq_url="http://www.linuximq.net"
imq_ver="3.3"
imq_src="http://www.linuximq.net/patches/patch-imqmq-${imq_ver}.diff.xz"

# Mandriva/Mageia
mageia_url="http://svnweb.mageia.org/packages/cauldron/kernel/current"

# Pardus
pardus_url="https://svn.pardus.org.tr/pardus/playground/kaan.aksit/2011/kernel/default/kernel"

# pld
pld_url="http://cvs.pld-linux.org/cgi-bin/viewvc.cgi/cvs/packages/kernel/?pathrev=MAIN"

# Reiser4
reiser4_url="http://sourceforge.net/projects/reiser4"
#reiser4_ver="${OKV}"
#reiser4_src="mirror://kernel/linux/kernel/people/edward/reiser4/reiser4-for-2.6/reiser4-for-${REISER4_OKV}${REISER4_VER}.patch.bz2"

# Ingo Molnar's realtime preempt patches
rt_url="http://www.kernel.org/pub/linux/kernel/projects/rt"
rt_ver="3.4.3-rt11"
rt_src="http://www.kernel.org/pub/linux/kernel/projects/rt/3.4/patch-${rt_ver}.patch.xz"

# OpenSuSE
suse_url="http://kernel.opensuse.org/cgit/kernel-source"

uksm_url="http://kerneldedup.org"

# unionfs
# http://download.filesystems.org/unionfs/unionfs-2.x/unionfs-2.5.11_for_3.3.0-rc3.diff.gz

# todo: add Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
# Xenomai: Real-Time Framework for Linux http://www.xenomai.org/
#xenomai_url="http://www.xenomai.org"
#xenomai_ver="2.6.0"
#xenomai_src="http://download.gna.org/xenomai/stable/xenomai-${xenomai_ver}.tar.bz2"

#------------------------------------------------------------------------

KEYWORDS="~amd64 ~x86"
use reiser4 && die "No reiser4 support yet for this version."

IUSE="aufs bfq bld branding ck deblob fbcondecor fedora grsecurity ice imq mageia pardus -pld reiser4 rt suse uksm"

DESCRIPTION="Full sources for the Linux kernel including: fedora, grsecurity, mageia and other patches"

HOMEPAGE="http://www.kernel.org ${aufs_url} ${bfq_url} ${bld_url} ${ck_url} ${fbcondecor_url} ${fedora_url} ${grsecurity_url} ${ice_url} ${imq_url} ${mageia_url} ${pardus_url} ${pld_url} ${reiser4_url} ${rt_url} ${suse_url} ${uksm_url}"

SRC_URI="${KERNEL_URI} ${ARCH_URI}
	bld?		( ${bld_src} )
	ck?		( ${ck_src} )
	fbcondecor?	( ${fbcondecor_src} )
	grsecurity?	( ${grsecurity_src} )
	imq?		( ${imq_src} )
	rt?		( ${rt_src} )"

RESTRICT="mirror"

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
	local msg=$2
	shift
	echo
	einfo "${msg}"
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
	use bfq && ApplyPatch "${FILESDIR}/${OKV}/bfq/patch_list" "Budget Fair Queueing Budget I/O Scheduler - ${bfq_url}"

	use ck && ApplyPatch "$DISTDIR/patch-$ck_ver-ck2.bz2" "Con Kolivas high performance patchset - ${ck_url}"

	use fbcondecor && ApplyPatch "${DISTDIR}/4200_fbcondecor-0.9.6.patch" "Spock's fbsplash patch - ${fbcondecor_url}"

	use grsecurity && ApplyPatch "${DISTDIR}/grsecurity-${grsecurity_ver}.patch" "GrSecurity patches - ${grsecurity_url}"

	use ice && ApplyPatch "${FILESDIR}/tuxonice-kernel-${PV}.patch.xz" "TuxOnIce - ${ice_url}"

	use imq && ApplyPatch "${DISTDIR}/patch-imqmq-${imq_ver}.diff.xz" "Intermediate Queueing Device patches - ${imq_url}"
#	use imq && ApplyPatch "$FILESDIR/$OKV/pld/kernel-imq.patch" "Intermediate Queueing Device patches - ${imq_url} ${pld_url}"

	use reiser4 && ApplyPatch "${DISTDIR}/reiser4-for-${OKV}.patch.bz2" "Reiser4 - ${reiser4_url}"
#	use reiser4 && ApplyPatch "$FILESDIR/$OKV/pld/kernel-reiser4.patch" "Reiser4 - ${reiser4_url} ${pld_url}"

	use rt && ApplyPatch "${DISTDIR}/patch-${rt_ver}.patch.xz" "Ingo Molnar's realtime preempt patches - ${rt_url}"

	if use bld; then
		cd "${T}"
		unpack "bld-${bld_ver}.tar.bz2"
		cp "${T}/bld-${bld_ver}/BLD-${bld_ver}.patch" "${S}/BLD-${bld_ver}.patch"
		cd "${S}"
		ApplyPatch "BLD-${bld_ver}.patch" "Alternate CPU load distribution technique for Linux kernel scheduler - ${bld_url}"
		rm -f "BLD-${bld_ver}.patch"
		rm -r "${T}/bld-${bld_ver}" # Clean temp
	fi

	use uksm && ApplyPatch "${FILESDIR}/${OKV}/uksm/patch_list" "Ultra Kernel Samepage Merging - ${uksm_url}"

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

	use aufs && ApplyPatch "$FILESDIR/$OKV/aufs/patch_list" "aufs3 - ${aufs_url}"

	use mageia && ApplyPatch "$FILESDIR/$OKV/mageia/patch_list" "Mandriva/Mageia - ${mageia_url}"

	use fedora && ApplyPatch "$FILESDIR/$OKV/fedora/patch_list" "Fedora - ${fedora_url}"

	use suse && ApplyPatch "$FILESDIR/$OKV/suse/patch_list" "OpenSuSE - ${suse_url}"

	use pardus && ApplyPatch "$FILESDIR/$OKV/pardus/patch_list" "Pardus - ${pardus_url}"

	use pld && ApplyPatch "$FILESDIR/$OKV/pld/patch_list" "PLD - ${pld_url}"

	ApplyPatch "${FILESDIR}/acpi-ec-add-delay-before-write.patch" "Oops: ACPI: EC: input buffer is not empty, aborting transaction - 2.6.32 regression https://bugzilla.kernel.org/show_bug.cgi?id=14733#c41"

	# USE branding
	if use branding; then
		ApplyPatch "${FILESDIR}/font-8x16-iso-latin-1-v2.patch" "font - CONFIG_FONT_ISO_LATIN_1_8x16 http://sudormrf.wordpress.com/2010/10/23/ka-ping-yee-iso-latin-1%c2%a0font-in-linux-kernel/"
		ApplyPatch "${FILESDIR}/gentoo-larry-logo-v2.patch" "logo - CONFIG_LOGO_LARRY_CLUT224 https://github.com/init6/init_6/raw/master/sys-kernel/geek-sources/files/larry.png"
	fi

### END OF PATCH APPLICATIONS ###

	einfo "Copy current config from /proc"
	if [ -e "/usr/src/linux-${KV_FULL}/.config" ]; then
		ewarn "Kernel config file already exist."
		ewarn "I will NOT overwrite that."
	else
		einfo "Copying kernel config file."
		zcat /proc/config > .config || ewarn "Can't copy /proc/config"
	fi

# Install the docs (why not all?) <-- ToDo
#	nonfatal dodoc "${FILESDIR}/${PVR}"/fedora/{README.txt,TODO}

	echo
	einfo "Live long and prosper."
	echo

	# Comment out EXTRAVERSION added by CK patch:
	use ck && sed -i -e 's/\(^EXTRAVERSION :=.*$\)/# \1/' "${S}/Makefile"

	einfo "Cleanup backups after patching"
	find '(' -name '*~' -o -name '*.orig' -o -name '.gitignore' ')' -print0 | xargs -0 -r -l512 rm -f
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
	einfo "Now is the time to configure and build the kernel."
	use uksm && einfo "Do not forget to disable the remote bug reporting feature by echo 0 > /sys/kernel/mm/uksm/usr_spt_enabled
	more http://kerneldedup.org/en/projects/uksm/uksmdoc/usage/"
}
