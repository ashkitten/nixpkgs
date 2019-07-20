{ nodejs-slim, mkYarnPackage, fetchFromGitHub, bundlerEnv,
  stdenv, yarn, lib, ... }:

let
  version = "94ddb8d1f50bdbd92b5ec9490c8471df234e5e04";

  src = stdenv.mkDerivation {
    name = "mastodon-src";
    src = fetchFromGitHub {
      owner = "ashkitten";
      repo = "mastodon";
      rev = version;
      sha256 = "0jgsk3gmshyqmhahfvncqx6f4anqdfw568494ji9k9sk546yr4cz";
    };
    patches = [ ./mastodon-nix.patch ];
    dontConfigure = true;
    dontBuild = true;
    installPhase = ''
      mkdir -p $out
      cp -r * $out/
    '';
  };

  mastodon-gems = bundlerEnv {
    name = "mastodon-gems";
    inherit version;
    gemdir = src;
    gemset = ./gemset.nix;
  };

  mastodon-js-modules = mkYarnPackage {
    name = "mastodon-modules";
    yarnNix = ./yarn.nix;
    yarnLock = ./yarn.lock;
    packageJSON = ./package.json;
    inherit src;
  };

  mastodon-assets = stdenv.mkDerivation {
    name = "mastodon-assets";
    inherit src version;

    buildInputs = [
      mastodon-gems nodejs-slim yarn
    ];

    buildPhase = ''
      cp -r "${mastodon-js-modules}/libexec/mastodon/node_modules" "node_modules"
      chmod -R u+w node_modules
      rake assets:precompile
    '';

    installPhase = ''
      mkdir -p $out/public
      cp -r public/assets $out/public
      cp -r public/packs $out/public
    '';
  };

in stdenv.mkDerivation {
  name = "mastodon";
  inherit src version;

  buildPhase = ''
    ln -s ${mastodon-js-modules}/libexec/mastodon/node_modules node_modules
    ln -s ${mastodon-assets}/public/assets public/assets
    ln -s ${mastodon-assets}/public/packs public/packs

    for b in $(ls ${mastodon-gems}/bin/)
    do
      rm -f bin/$b
      ln -s ${mastodon-gems}/bin/$b bin/$b
    done

    rm -rf log
    ln -s /var/log/mastodon log
    ln -s /tmp tmp
  '';

  installPhase = ''
    mkdir -p $out
    cp -r * $out/
  '';

  meta = {
    description = "Self-hosted, globally interconnected microblogging software based on ActivityPub";
    homepage = https://joinmastodon.org;
    license = lib.licenses.agpl3;
    maintainers = [ lib.maintainers.petabyteboy ];
  };
}
