# Maintainer: Eihdran Lego <hadean-eon-dev@proton.me>

pkgname=apc
pkgver='0.0.2'
pkgrel='3'
pkgdesc="Lightweight bash wrapper for Pacman."
arch=('any')
url="https://github.com/h8d13/apc"

license=('0BSD')
depends=('pacman' 'pacman-contrib' 'reflector')
provides=('apc')
conflicts=('apc')
# The release workflow publishes a pre-stamped tarball at the v<pkgver>-<pkgrel>
# tag; consume that. Run `updpkgsums` after a release to pin the checksum.
source=("$url/releases/download/v${pkgver}-${pkgrel}/${pkgname}-${pkgver}-${pkgrel}.tar.gz")
sha256sums=('SKIP')

package() {
	# Tarball extracts to apc-<pkgver>-<pkgrel>/ and its VER_STRING is already
	# stamped by the release workflow, so this just installs.
	cd "${srcdir}/${pkgname}-${pkgver}-${pkgrel}"
	install -Dm755 apc "${pkgdir}/usr/bin/apc"
}
