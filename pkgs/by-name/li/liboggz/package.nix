{
  lib,
  stdenv,
  fetchurl,
  libogg,
  pkg-config,
}:

stdenv.mkDerivation rec {
  pname = "liboggz";
  version = "1.1.3";

  src = fetchurl {
    url = "https://downloads.xiph.org/releases/liboggz/${pname}-${version}.tar.gz";
    sha256 = "sha256-JGbQO2fvC8ug4Q+zUtGp/9n5aRFlerzjy7a6Qpxlbi8=";
  };

  propagatedBuildInputs = [ libogg ];

  nativeBuildInputs = [ pkg-config ];

  meta = with lib; {
    homepage = "https://xiph.org/oggz/";
    description = "C library and tools for manipulating with Ogg files and streams";
    longDescription = ''
      Oggz comprises liboggz and the tool oggz, which provides commands to
      inspect, edit and validate Ogg files. The oggz-chop tool can also be used
      to serve time ranges of Ogg media over HTTP by any web server that
      supports CGI.

      liboggz is a C library for reading and writing Ogg files and streams.  It
      offers various improvements over the reference libogg, including support
      for seeking, validation and timestamp interpretation. Ogg is an
      interleaving data container developed by Monty at Xiph.Org, originally to
      support the Ogg Vorbis audio format but now used for many free codecs
      including Dirac, FLAC, Speex and Theora.'';
    platforms = platforms.unix;
    license = licenses.bsd3;
  };
}
