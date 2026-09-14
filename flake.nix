{
  description = "Ansible dev shell with the synthesio.ovh collection";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfreePredicate = pkg:
            builtins.elem (nixpkgs.lib.getName pkg) [ "terraform" ];
        };
        inherit (pkgs) lib;

        tf = pkgs.terraform.withPlugins (p: [ p.hetznercloud_hcloud p.carlpett_sops ]);

        # ansible-core + the Python libs the synthesio.ovh modules import at runtime.
        ansibleEnv = pkgs.python3.withPackages (ps: with ps; [
          ansible-core
          ovh          # python-ovh: required by every synthesio.ovh module
          requests
          jmespath     # json_query filter
          netaddr
        ]);

        # The collection is not published on Galaxy, only on GitHub.
        synthesio-ovh = pkgs.stdenvNoCC.mkDerivation (finalAttrs: {
          pname = "ansible-collection-synthesio-ovh";
          version = "5.11.1";

          src = pkgs.fetchFromGitHub {
            owner = "synthesio";
            repo = "infra-ovh-ansible-module";
            rev = finalAttrs.version;
            hash = "sha256-EpzprFCivFkf7E2zSH8R0p5sD17WI4V1wUGHe8L5Es4=";
          };

          nativeBuildInputs = [ ansibleEnv ];

          buildPhase = ''
            runHook preBuild
            export HOME=$(mktemp -d)
            ansible-galaxy collection build --output-path build .
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            export HOME=$(mktemp -d)
            mkdir -p $out
            ansible-galaxy collection install build/synthesio-ovh-*.tar.gz \
              --no-deps -p $out
            runHook postInstall
          '';

          meta = with lib; {
            description = "Ansible collection to talk to the OVH API";
            homepage = "https://github.com/synthesio/infra-ovh-ansible-module";
            license = licenses.mit;
          };
        });
      in
      {
        packages = {
          inherit synthesio-ovh;
          ansible = ansibleEnv;
          default = ansibleEnv;
        };

        devShells.default = pkgs.mkShell {
          packages = [
            tf
            ansibleEnv
            pkgs.ansible-lint
            pkgs.yamllint
            pkgs.openssh
            pkgs.sops
            pkgs.age-plugin-yubikey
            pkgs.git
            pkgs.hcloud
          ];

          shellHook = ''
            export ANSIBLE_COLLECTIONS_PATH="${synthesio-ovh}:$HOME/.ansible/collections"
            export ANSIBLE_COLLECTIONS_PATHS="$ANSIBLE_COLLECTIONS_PATH"  # pre-2.10 name
            export ANSIBLE_HOST_KEY_CHECKING=False
            echo "ansible $(ansible --version | head -n1 | cut -d' ' -f2) + synthesio.ovh ${synthesio-ovh.version}"
          '';
        };
      });
}
