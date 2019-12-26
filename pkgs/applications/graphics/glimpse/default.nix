{
  stdenv, lib, fetchFromGitHub, substituteAll,

  python2Packages,

  autoconf, automake, gettext, intltool, libtool, pkgconfig,

  aalib, babl, cairo, fontconfig, freetype, gdk-pixbuf, gegl, gexiv2,
  ghostscript, glib, glib-networking, gtk-doc, gtk2, harfbuzz, isocodes, lcms,
  libexif, libjpeg, libmng, libmypaint, libpng, librsvg, libtiff, libwmf,
  libxslt, libzip, mypaint-brushes, pango, poppler, poppler_data,
  shared-mime-info, xorg, zlib, libwebp, libheif, openexr,

  AppKit, Cocoa, gtk-mac-integration-gtk2,

  libgudev
}:

let
  inherit (python2Packages) pygtk wrapPython python;
in stdenv.mkDerivation rec {
  pname = "glimpse";
  version = "0.1.0";

  outputs = [ "out" "dev" ];

  src = fetchFromGitHub {
    owner = "glimpse-editor";
    repo = "Glimpse";
    rev = "glimpse-0-1";
    sha256 = "0kw06k6fvcf11mpasxn1y55vsbg10d8j1f15pc5bgkq7ch6nx79k";
  };

  nativeBuildInputs = [
    autoconf automake gettext intltool libtool pkgconfig wrapPython
  ];

  buildInputs = [
    aalib babl cairo fontconfig freetype gdk-pixbuf gegl gexiv2 ghostscript
    glib glib-networking gtk-doc gtk2 harfbuzz isocodes lcms libexif libheif
    libjpeg libmng libmypaint libpng librsvg libtiff libwebp libwmf libxslt
    libzip mypaint-brushes openexr pango poppler poppler_data pygtk python
    shared-mime-info xorg.libXpm zlib
  ] ++ lib.optionals stdenv.isDarwin [
    AppKit Cocoa gtk-mac-integration-gtk2
  ] ++ lib.optionals stdenv.isLinux [
    libgudev
  ];

  # needed by gimp-2.0.pc
  propagatedBuildInputs = [ gegl ];

  pythonPath = [ pygtk ];

  # Check if librsvg was built with --disable-pixbuf-loader.
  PKG_CONFIG_GDK_PIXBUF_2_0_GDK_PIXBUF_MODULEDIR = "${librsvg}/${gdk-pixbuf.moduleDir}";

  preConfigure = ''
    # The check runs before glib-networking is registered
    export GIO_EXTRA_MODULES="${glib-networking}/lib/gio/modules:$GIO_EXTRA_MODULES"

    ./autogen.sh
  '';

  patches = [
    # to remove compiler from the runtime closure, reference was retained via
    # glimpse --version --verbose output
    (substituteAll {
      src = ./remove-cc-reference.patch;
      cc_version = stdenv.cc.cc.name;
    })
  ];

  postFixup = ''
    wrapPythonProgramsIn $out/lib/glimpse/${passthru.majorVersion}/plug-ins/
    wrapProgram $out/bin/glimpse-${lib.versions.majorMinor version} \
      --prefix PYTHONPATH : "$PYTHONPATH" \
      --set GDK_PIXBUF_MODULE_FILE "$GDK_PIXBUF_MODULE_FILE"
  '';

  passthru = rec {
    # The declarations for `glimpse-with-plugins` wrapper,
    # used for determining plug-in installation paths
    majorVersion = "${lib.versions.major version}.0";
    # normally we'd use the major version for the directories but glimpse uses
    # 2.0 as its major version for plugin and data dirs
    targetPluginDir = "lib/glimpse/2.0/plug-ins";
    targetScriptDir = "share/glimpse/2.0/scripts";

    # probably its a good idea to use the same gtk in plugins ?
    gtk = gtk2;
  };

  configureFlags = [
    "--without-webkit" # old version is required
    "--with-bug-report-url=https://github.com/NixOS/nixpkgs/issues/new"
    "--with-icc-directory=/run/current-system/sw/share/color/icc"
    # fix libdir in pc files (${exec_prefix} needs to be passed verbatim)
    "--libdir=\${exec_prefix}/lib"
  ];

  # on Darwin,
  # test-eevl.c:64:36: error: initializer element is not a compile-time constant
  doCheck = !stdenv.isDarwin;

  enableParallelBuilding = true;

  meta = with lib; {
    description = "Fork of the GNU Image Manipulation Program";
    homepage = "https://glimpse-editor.org";
    maintainers = with maintainers; [ ashkitten ];
    license = licenses.gpl3Plus;
    platforms = platforms.unix;
  };
}
