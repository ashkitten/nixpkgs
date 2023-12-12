{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.services.matrix-media-repo;

  format = pkgs.formats.yaml { };
  configFile = format.generate "config.yaml" cfg.settings;
in
  {
    options.services.matrix-media-repo = {
      enable = lib.mkEnableOption "matrix-media-repo";
      environmentFile = lib.mkOption {
        type = lib.types.nullOr lib.types.path;
        example = "/var/lib/matrix-media-repo/environment";
        default = null;
        description = ''
          Environment file as defined in <citerefentry>
          <refentrytitle>systemd.exec</refentrytitle><manvolnum>5</manvolnum></citerefentry>.
          Secrets may be passed to the service without adding them to the world-readable
          Nix store, by specifying placeholder variables as the option value in Nix and
          setting these variables accordingly in the environment file.
          <programlisting>
            \# example snippet of matrix-media-repo config
            services.matrix-media-repo.settings.datastores = [
              {
                type = "s3";
                opts = {
                  accessSecret = "$ACCESS_SECRET";
                  \# [...]
                };
              }
            ];
          </programlisting>
          <programlisting>
            \# content of the environment file
            ACCESS_SECRET=yoursecretgoeshere
          </programlisting>
          Note that this file needs to be available on the host on which
          <literal>matrix-media-repo</literal> is running.
        '';
      };
      settings = mkOption {
        default = {};
        description = lib.mdDoc ''
          Configuration for matrix-media-repo. Refer to
          <https://github.com/turt2live/matrix-media-repo/blob/master/config.sample.yaml>
          for available options.
        '';
        type = types.submodule {
          freeformType = format.type;
          options = {
            repo.bindAddress = mkOption {
              type = types.str;
              default = "127.0.0.1";
              description = lib.mdDoc "Address to listen for HTTP requests on.";
            };
            repo.port = mkOption {
              type = types.port;
              default = 8000;
              description = lib.mdDoc "Port to listen for HTTP requests on.";
            };
            database.postgres = mkOption {
              type = types.str;
              example = "postgres://your_username:your_password@localhost/database_name?sslmode=require";
              description = lib.mdDoc "Postgresql connection string. This is *not* the same as your homeserver's database.";
            };
            homeservers = mkOption {
              description = lib.mdDoc ''
                List of homeservers this media repository is known to control.
                Servers not listed here will not be able to upload media.
              '';
              type = types.listOf (types.submodule {
                freeformType = format.type;
                options = {
                  name = mkOption {
                    type = types.str;
                    example = "example.org";
                    description = lib.mdDoc "This should match the server_name of your homeserver.";
                  };
                  csApi = mkOption {
                    type = types.str;
                    example = "https://example.org/";
                    description = lib.mdDoc "The base URL to where the homeserver can actually be reached.";
                  };
                };
              });
            };
            admins = mkOption {
              type = types.listOf types.str;
              default = [];
              example = literalExpression ''[ "@your_username:example.org" ]'';
              description = lib.mdDoc "Users that have full access to the administrative functions of the media repository.";
            };
            datastores = mkOption {
              default = [
                {
                  type = "file";
                  opts = {
                    path = "/var/lib/matrix-media-repo";
                  };
                }
              ];
              description = lib.mdDoc "List of stores where media should be persisted.";
              type = types.listOf (types.submodule {
                options = {
                  type = mkOption {
                    type = types.str;
                    example = "file";
                    description = lib.mdDoc "Datastore type";
                  };
                  id = mkOption {
                    type = types.str;
                    example = "e9ce13bbb062383ce1bcee76414058668877f2d51635810652335374336";
                    description = lib.mdDoc "Datastore ID";
                  };
                  forKinds = mkOption {
                    type = types.listOf types.str;
                    default = [ "all" ];
                    example = literalExpression ''
                      [ "thumbnails" "remote_media" "local_media" "archives" ]
                    '';
                    description = lib.mdDoc "What kinds of media to use this datastore for.";
                  };
                  opts = mkOption {
                    type = types.submodule { freeformType = format.type; };
                    default = {};
                    example = literalExpression ''
                      { path = "/var/lib/matrix-media-repo"; }
                    '';
                    description = "Extra datastore-type-specific options.";
                  };
                };
              });
            };
          };
        };
      };
    };

    config = lib.mkIf cfg.enable {
      systemd.services.matrix-media-repo = {
        description = "matrix-media-repo media repository";
        documentation = [ "https://github.com/turt2live/matrix-media-repo" ];
        wantedBy = [ "multi-user.target" ];
        serviceConfig = {
          DynamicUser = true;
          User = "matrix-media-repo";
          StateDirectory = "matrix-media-repo";
          WorkingDirectory = "/var/lib/matrix-media-repo";
          RuntimeDirectory = "matrix-media-repo";
          RuntimeDirectoryMode = "0700";
          EnvironmentFile = lib.mkIf (cfg.environmentFile != null) cfg.environmentFile;
          ExecStartPre = ''
            ${pkgs.envsubst}/bin/envsubst \
              -i ${configFile} \
              -o /run/matrix-media-repo/config.yaml
          '';
          ExecStart = "${pkgs.matrix-media-repo}/bin/media_repo --config /run/matrix-media-repo/config.yaml";
          Restart = "on-failure";
        };
      };
    };
    meta.maintainers = teams.matrix.members;
  }
