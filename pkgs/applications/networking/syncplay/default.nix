{ lib, fetchFromGitHub, buildPythonApplication, pyside2, shiboken2, twisted, certifi, youtube-dl, qt5 }:

buildPythonApplication rec {
  pname = "syncplay";
  version = "1.6.8";

  format = "other";

  src = fetchFromGitHub {
    owner = "Syncplay";
    repo = "syncplay";
    rev = "v${version}";
    sha256 = "17rmyv6v7zx1brvzhpkqq5rz5lyhi34yl68qw2sjymnxws40hq4w";
  };

  propagatedBuildInputs = [ pyside2 shiboken2 twisted certifi youtube-dl ] ++ twisted.extras.tls;
  nativeBuildInputs = [ qt5.wrapQtAppsHook ];

  makeFlags = [ "DESTDIR=" "PREFIX=$(out)" ];

  postFixup = ''
    wrapQtApp $out/bin/syncplay --prefix PYTHONPATH : "$PYTHONPATH"
  '';

  meta = with lib; {
    homepage = "https://syncplay.pl/";
    description = "Free software that synchronises media players";
    license = licenses.asl20;
    platforms = platforms.linux;
    maintainers = with maintainers; [ enzime ];
  };
}
