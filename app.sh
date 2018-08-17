### READLINE ###
_build_readline() {
local VERSION="7.0"
local FOLDER="readline-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://ftp.gnu.org/gnu/readline/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --host=${HOST} --prefix="${DEPS}" --libdir="${DEST}/lib"
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### ZLIB ###
_build_zlib() {
local VERSION="1.2.11"
local FOLDER="zlib-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="http://zlib.net/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"
./configure --prefix="${DEPS}" --libdir="${DEST}/lib"
make
make install
rm -v "${DEST}/lib"/*.a
popd
}

### OPENSSL ###
_build_openssl() {
local VERSION="1.0.2e"
local FOLDER="openssl-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://www.openssl.org/source/old/1.0.2/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
cp -vf "src/${FOLDER}-parallel-build.patch" "target/${FOLDER}/"
pushd "target/${FOLDER}"
patch -p1 -i "${FOLDER}-parallel-build.patch"
./Configure --prefix="${DEPS}" --openssldir="${DEST}/etc/ssl" \
  zlib-dynamic --with-zlib-include="${DEPS}/include" --with-zlib-lib="${DEPS}/lib" \
  shared threads linux-armv4 -DL_ENDIAN ${CFLAGS} ${LDFLAGS} \
  -Wa,--noexecstack -Wl,-z,noexecstack \
  no-asm
sed -i -e "s/-O3//g" Makefile
make
make install_sw
mkdir -p "${DEST}/libexec"
cp -vfa "${DEPS}/bin/openssl" "${DEST}/libexec/"
cp -vfa "${DEPS}/lib/libssl.so"* "${DEST}/lib/"
cp -vfa "${DEPS}/lib/libcrypto.so"* "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/engines" "${DEST}/lib/"
cp -vfaR "${DEPS}/lib/pkgconfig" "${DEST}/lib/"
rm -vf "${DEPS}/lib/libcrypto.a" "${DEPS}/lib/libssl.a"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libcrypto.pc"
sed -e "s|^libdir=.*|libdir=${DEST}/lib|g" -i "${DEST}/lib/pkgconfig/libssl.pc"
popd
}

### Bacula ###
_build_postgresql() {

local VERSION="10.5"
local FOLDER="postgresql-${VERSION}"
local FILE="${FOLDER}.tar.gz"
local URL="https://ftp.postgresql.org/pub/source/v${VERSION}/${FILE}"

_download_tgz "${FILE}" "${URL}" "${FOLDER}"
pushd "target/${FOLDER}"

./configure \
  --host=${HOST} \
  --prefix="${DEST}" \
  --exec-prefix="${DEST}" \
  --disable-strong-random \
  --disable-spinlocks \
  --with-lib="${DEST}/lib" \
  --without-readline

make
make install
popd
}

_build() {
  _build_readline
  _build_zlib
  _build_openssl
  _build_postgresql
#  _package
}
