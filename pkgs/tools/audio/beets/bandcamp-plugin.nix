{ stdenv, lib, fetchFromGitHub, beets, pythonPackages }:

pythonPackages.buildPythonApplication rec {
  pname = "beets-bandcamp";
  version = "0.1.4";

  src = fetchFromGitHub {
    repo = "beets-bandcamp";
    owner = "unrblt";
    rev = "v${version}";
    sha256 = "0z4al4l0bskbyc9aj5iqj4c2dj2cdn97bvb6qgg664ak96da4hf1";
  };

  nativeBuildInputs = [ beets ];
  propagatedBuildInputs = [ pythonPackages.isodate ];

  meta = with lib; {
    description = "Beets plugin to use bandcamp as an autotagger source";
    homepage = "https://github.com/unrblt/beets-bandcamp";
    maintainers = [ maintainers.ashkitten ];
    license = licenses.mit;
  };
}
