# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

K_NOUSENAME="yes"
K_NOSETEXTRAVERSION="1"
K_DEBLOB_AVAILABLE="0"
K_SECURITY_UNSUPPORTED="1"

CKV="${PVR/-r/-git}"
# only use this if it's not an _rc/_pre release
[ "${PV/_pre}" == "${PV}" ] && [ "${PV/_rc}" == "${PV}" ] && OKV="${PV}"
#CKV="3.2.1"

ETYPE="sources"

inherit kernel-2 eutils
detect_version
detect_arch

DESCRIPTION="Fedora Core Linux patchset for the ${KV_MAJOR}.${KV_MINOR} linux kernel tree"
RESTRICT="nomirror"
IUSE="backports"
DEPEND="!net-wireless/athload" # compat-wireless
UNIPATCH_STRICTORDER="yes"
KEYWORDS="~amd64 ~x86"
HOMEPAGE="http://fedoraproject.org/ http://download.fedora.redhat.com/pub/fedora/ http://pkgs.fedoraproject.org/gitweb/?p=kernel.git;a=summary http://wireless.kernel.org/en/users/Download/stable"
cwversion="3.2-1" # The compat-wireless version
SRC_URI="${KERNEL_URI} ${ARCH_URI} http://www.orbit-lab.org/kernel/compat-wireless-3-stable/v3.2/compat-wireless-${cwversion}.tar.bz2 http://www.orbit-lab.org/kernel/compat-wireless-2.6/2012/01/compat-wireless-${cwversion}.tar.bz2"

KV_FULL="${PVR}-fc"
EXTRAVERSION="${RELEASE}-fc"
SLOT="${PV}"
S="${WORKDIR}/linux-${KV_FULL}"

src_unpack() {

	kernel-2_src_unpack
	cd "${S}"

	einfo "Set extraversion"
	# manually set extraversion
	sed -i -e "s:^\(EXTRAVERSION =\).*:\1 ${EXTRAVERSION}:" Makefile

	einfo "Copy kernel scripts"
	cp ${FILESDIR}/${PVR}/scripts/* "${S}"/scripts || die "cannot copy kernel scripts";

	einfo "Make kernel default configs"
	cp ${FILESDIR}/${PVR}/config-* . || die "cannot copy kernel config";
	cp ${FILESDIR}/${PVR}/merge.pl ${FILESDIR}/${PVR}/Makefile.config . &>/dev/null || die "cannot copy kernel files";
	make -f Makefile.config VERSION=${PVR}-fc configs &>/dev/null || die "cannot generate kernel .config files from config-* files"

	einfo "Delete temp files"
	for cfg in {config-*,temp-*,merge.pl,*.orig,*~,.gitignore}; do
		rm -f $cfg \; >/dev/null
	done;

	echo
	einfo "A long time ago in a galaxy far, far away...."
	echo

### BRANCH APPLY ###

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-makefile-after_link.patch

# Architecture patches
# x86(-64)

#
# ARM
#
	epatch "${FILESDIR}"/"${PVR}"/arm-omap-dt-compat.patch
	epatch "${FILESDIR}"/"${PVR}"/arm-smsc-support-reading-mac-address-from-device-tree.patch

	epatch "${FILESDIR}"/"${PVR}"/taint-vbox.patch
#
# NX Emulation
#
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-32bit-mmap-exec-randomization.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-i386-nx-emulation.patch

#
# bugfixes to drivers and filesystems
#

# ext4
#rhbz 753346
	epatch "${FILESDIR}"/"${PVR}"/jbd-jbd2-validate-sb-s_first-in-journal_get_superblo.patch

# xfs

# btrfs


# eCryptfs

# NFSv4

# USB

# WMI

# ACPI
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-acpi-video.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-video-dos.patch
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-acpi-debug-infinite-loop.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi-ensure-thermal-limits-match-cpu-freq.patch
	epatch "${FILESDIR}"/"${PVR}"/acpi-sony-nonvs-blacklist.patch

#
# PCI
#
# enable ASPM by default on hardware we expect to work
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-defaults-aspm.patch

#
# SCSI Bits.
#

# ACPI

# ALSA

# Networking


# Misc fixes
# The input layer spews crap no-one cares about.
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-input-kill-stupid-messages.patch

# stop floppy.ko from autoloading during udev...
	epatch "${FILESDIR}"/"${PVR}"/die-floppy-die.patch
	epatch "${FILESDIR}"/"${PVR}"/floppy-drop-disable_hlt-warning.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6.30-no-pcspkr-modalias.patch

# Allow to use 480600 baud on 16C950 UARTs
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-serial-460800.patch

# Silence some useless messages that still get printed with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-noise.patch

# Make fbcon not show the penguins with 'quiet'
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-fbcon-logo.patch

# Changes to upstream defaults.


# /dev/crash driver.
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-crash-driver.patch

# Hack e1000e to work on Montevina SDV
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-e1000-ich9-montevina.patch

# crypto/

# Assorted Virt Fixes
	epatch "${FILESDIR}"/"${PVR}"/fix_xen_guest_on_old_EC2.patch

# DRM core
#	epatch "${FILESDIR}"/"${PVR}"/drm-edid-try-harder-to-fix-up-broken-headers.patch

# Intel DRM
	epatch "${FILESDIR}"/"${PVR}"/drm-i915-fbc-stfu.patch

	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-intel-iommu-igfx.patch

# silence the ACPI blacklist code
	epatch "${FILESDIR}"/"${PVR}"/linux-2.6-silence-acpi-blacklist.patch
	epatch "${FILESDIR}"/"${PVR}"/quite-apm.patch

# Patches headed upstream

	epatch "${FILESDIR}"/"${PVR}"/disable-i8042-check-on-apple-mac.patch

	epatch "${FILESDIR}"/"${PVR}"/epoll-limit-paths.patch
	epatch "${FILESDIR}"/"${PVR}"/block-stray-block-put-after-teardown.patch

# rhbz#605888
	epatch "${FILESDIR}"/"${PVR}"/dmar-disable-when-ricoh-multifunction.patch

	epatch "${FILESDIR}"/"${PVR}"/revert-efi-rtclock.patch
	epatch "${FILESDIR}"/"${PVR}"/efi-dont-map-boot-services-on-32bit.patch

# utrace.
#	epatch "${FILESDIR}"/"${PVR}"/utrace.patch # Failed

#rhbz 752176
	epatch "${FILESDIR}"/"${PVR}"/sysfs-msi-irq-per-device.patch

# rhbz 754907
	epatch "${FILESDIR}"/"${PVR}"/hpsa-add-irqf-shared.patch

#rhbz 731365
	epatch "${FILESDIR}"/"${PVR}"/mac80211_offchannel_rework_revert.patch

	epatch "${FILESDIR}"/"${PVR}"/pci-Rework-ASPM-disable-code.patch

#	epatch "${FILESDIR}"/"${PVR}"/pci-crs-blacklist.patch

#rhbz 717735
#	epatch "${FILESDIR}"/"${PVR}"/nfs-client-freezer.patch # Failed

#rhbz 590880
#	epatch "${FILESDIR}"/"${PVR}"/alps.patch # Failed

#rhbz 746097
	epatch "${FILESDIR}"/"${PVR}"/tpm_tis-delay-after-aborting-cmd.patch

#rhbz 771058
	epatch "${FILESDIR}"/"${PVR}"/msi-irq-sysfs-warning.patch

	epatch "${FILESDIR}"/"${PVR}"/ext4-Support-check-none-nocheck-mount-options.patch

	epatch "${FILESDIR}"/"${PVR}"/ext4-Fix-error-handling-on-inode-bitmap-corruption.patch

#rhbz 773392
	epatch "${FILESDIR}"/"${PVR}"/KVM-x86-extend-struct-x86_emulate_ops-with-get_cpuid.patch
	epatch "${FILESDIR}"/"${PVR}"/KVM-x86-fix-missing-checks-in-syscall-emulation.patch

#rhbz 728740
	epatch "${FILESDIR}"/"${PVR}"/rtl8192cu-Fix-WARNING-on-suspend-resume.patch

#rhbz 782686
	epatch "${FILESDIR}"/"${PVR}"/procfs-parse-mount-options.patch
	epatch "${FILESDIR}"/"${PVR}"/procfs-add-hidepid-and-gid-mount-options.patch
	epatch "${FILESDIR}"/"${PVR}"/proc-fix-null-pointer-deref-in-proc_pid_permission.patch

#rhbz 782681
	epatch "${FILESDIR}"/"${PVR}"/proc-clean-up-and-fix-proc-pid-mem-handling.patch

	epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-work-removal-on-deauth-request.patch

# END OF PATCH APPLICATIONS

	if use backports; then
		echo
		einfo "Apply compat-wireless patches"
		echo
		unpack compat-wireless-${cwversion}.tar.bz2
		cd compat-wireless-${cwversion}

		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-config-fixups.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-change-CONFIG_IWLAGN-CONFIG_IWLWIFI.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-pr_fmt-warning-avoidance.patch
		epatch "${FILESDIR}"/"${PVR}"/compat-wireless-rtl8192cu-Fix-WARNING-on-suspend-resume.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-rx-key-NULL-ptr-deref-in-promiscuous-mode.patch
		epatch "${FILESDIR}"/"${PVR}"/mac80211-fix-work-removal-on-deauth-request.patch

	#rhbz 731365, 773271
		epatch "${FILESDIR}"/"${PVR}"/mac80211_offchannel_rework_revert.patch

	# Remove overlap between bcma/b43 and brcmsmac and reenable bcm4331
		epatch "${FILESDIR}"/"${PVR}"/bcma-brcmsmac-compat.patch

		cd ..
	fi
	echo
	einfo "Apply extra patches" # my
	echo
	epatch "${FILESDIR}"/acpi-ec-add-delay-before-write.patch
	epatch "${FILESDIR}"/font-8x16-iso-latin-1.patch
	epatch "${FILESDIR}"/gentoo-larry-logo.patch
	echo

# Unfortunately, it has yet not been ported into 3.0 kernel.
# Check out here for the progress: http://www.kernel.org/pub/linux/kernel/people/edward/reiser4/
# http://sourceforge.net/projects/reiser4/
#	use reiser4 && epatch ${DISTDIR}/reiser4-for-${PV}.patch.bz2

# Install the docs
	dodoc "${FILESDIR}"/"${PVR}"/{README.txt,TODO}

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
