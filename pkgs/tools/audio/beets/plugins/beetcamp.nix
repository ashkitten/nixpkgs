{ lib,
  fetchFromGitHub,
  python3Packages,
  beets,

  propagateBeets ? false
}:

python3Packages.buildPythonApplication rec {
  pname = "beets-beetcamp";
  version = "0.20.0";

  src = fetchFromGitHub {
    repo = "beetcamp";
    owner = "snejus";
    rev = version;
    sha256 = "sha256-k8IbzD59PU7iSUUe4USu45fFyob8mWe0EGreWt2x6xI=";
  };

  format = "pyproject";

  propagatedBuildInputs = with python3Packages; [ setuptools poetry-core requests cached-property pycountry dateutil ordered-set httpx ]
                                                ++ (lib.optional propagateBeets [ beets ]);

  checkInputs = with python3Packages; [
    # pytestCheckHook
    pytest-cov
    pytest-randomly
    pytest-lazy-fixture
    rich
    tox
    types-setuptools
    types-requests
  ] ++ [
    beets
  ];

  meta = {
    homepage = "https://github.com/snejus/beetcamp";
    description = "Bandcamp autotagger plugin for beets.";
    license = lib.licenses.gpl2;
    inherit (beets.meta) platforms;
    maintainers = with lib.maintainers; [ rrix ];
  };
}
