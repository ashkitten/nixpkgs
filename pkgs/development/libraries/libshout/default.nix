{ stdenv, fetchurl, pkgconfig, fetchpatch
, libvorbis, libtheora, speex }:

# need pkgconfig so that libshout installs ${out}/lib/pkgconfig/shout.pc

stdenv.mkDerivation rec {
  name = "libshout-2.4.3";

  src = fetchurl {
    url = "http://downloads.xiph.org/releases/libshout/${name}.tar.gz";
    sha256 = "1zhdshas539cs8fsz8022ljxnnncr5lafhfd1dqr1gs125fzb2hd";
  };

  patches = [
    # these 2 fix https://gitlab.xiph.org/xiph/icecast-libshout/-/issues/2308, can be removed on next release
    (fetchpatch {
      url = "https://gitlab.xiph.org/xiph/icecast-libshout/-/commit/0ac7ed9e84c3871d4427acc1ce59dca5e4af21ef.diff";
      sha256 = "14ha9zajhpdzfgzhj8hl5rhdrczrmmm9klwp239hs0drxj674r43";
    })
    (fetchpatch {
      url = "https://gitlab.xiph.org/xiph/icecast-libshout/-/commit/b807c1e2550718bdc73d65ac1b05255d18f45c54.diff";
      sha256 = "0cps64396cnml66kg7czfd2vas04nn5nhj4l0qll9jdx5q078ypa";
    })
  ];

  outputs = [ "out" "dev" "doc" ];

  nativeBuildInputs = [ pkgconfig ];
  propagatedBuildInputs = [ libvorbis libtheora speex ];

  meta = {
    description = "icecast 'c' language bindings";

    longDescription = ''
      Libshout is a library for communicating with and sending data to an icecast
      server.  It handles the socket connection, the timing of the data, and prevents
      bad data from getting to the icecast server.
    '';

    homepage = "http://www.icecast.org";
    license = stdenv.lib.licenses.gpl2;
    maintainers = with stdenv.lib.maintainers; [ jcumming ];
    platforms = with stdenv.lib.platforms; unix;
  };
}
