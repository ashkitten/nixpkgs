{ stdenv, fetchFromGitHub, pythonPackages, mopidy, gobject-introspection }:

pythonPackages.buildPythonApplication rec {
  pname = "Mopidy-Local";
  version = "3.1.1";

  src = pythonPackages.fetchPypi {
    inherit pname version;
    sha256 = "13m0iz14lyplnpm96gfpisqvv4n89ls30kmkg21z7v238lm0h19j";
  };

  buildInputs = [ gobject-introspection ];

  checkInputs = [
    pythonPackages.pytest
  ];

  propagatedBuildInputs = [
    mopidy
    pythonPackages.pykka
    pythonPackages.uritools
  ];

  meta = with stdenv.lib; {
    homepage = "https://github.com/mopidy/mopidy-local";
    description = "Mopidy extension for playing music from your local music archive";
    license = licenses.asl20;
    maintainers = [ maintainers.ashkitten ];
  };
}
