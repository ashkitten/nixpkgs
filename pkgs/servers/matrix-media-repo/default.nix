{ lib, buildGoModule, fetchFromGitHub }:

buildGoModule rec {
  pname = "matrix-media-repo";
  version = "1.2.8";

  src = fetchFromGitHub {
    owner = "turt2live";
    repo = "matrix-media-repo";
    rev = "v${version}";
    sha256 = "1mkcknanl660skbfi6r01njk9gwigbhihpgymmpvs82m6yv4q7by";
  };

  vendorSha256 = "0nlyx21k793dsgl5h69nlcyachfi8w8i4iw6x5s2rzahj81p6761";

  preBuild = ''
    GOBIN=$PWD/bin go install -v ./cmd/compile_assets
    $PWD/bin/compile_assets
  '';

  buildFlagsArray = [ "-ldflags=-s -w -X github.com/turt2live/matrix-media-repo/common/version.GitCommit=${version} -X github.com/turt2live/matrix-media-repo/common/version.Version=${version}" ];

  meta = {
    description = "Matrix media repository with multi-domain in mind";
    homepage = "https://github.com/turt2live/matrix-media-repo";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ ashkitten ];
  };
}
