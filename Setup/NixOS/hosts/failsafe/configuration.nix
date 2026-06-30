{ pkgs, ... }:

let
  tphNixosSync = pkgs.writeShellApplication {
    name = "tph-nixos-sync";
    runtimeInputs = with pkgs; [
      git
      nix
      nixos-rebuild
    ];
    text = ''
      set -euo pipefail

      repo="''${1:-/workspace/ThePaleHeart}"
      message="''${2:-Update Failsafe NixOS configuration}"

      cd "$repo"

      if [ ! -d .git ]; then
        echo "$repo is not a Git checkout" >&2
        exit 1
      fi

      branch="$(git rev-parse --abbrev-ref HEAD)"
      if [ "$branch" = "HEAD" ]; then
        echo "Refusing to sync from a detached HEAD" >&2
        exit 1
      fi

      git fetch --prune origin
      git pull --ff-only origin "$branch"

      nix flake check ./Setup/NixOS \
        --extra-experimental-features "nix-command flakes" \
        --show-trace

      /run/wrappers/bin/sudo ${pkgs.nixos-rebuild}/bin/nixos-rebuild switch \
        --flake ./Setup/NixOS#failsafe

      git add Setup/NixOS
      if git diff --cached --quiet; then
        echo "No NixOS configuration changes to commit."
      else
        git commit -m "$message"
      fi

      git push origin "$branch"
    '';
  };
in
{
  imports = [
    ./hardware-configuration.nix
  ];

  networking.hostName = "failsafe";

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "prohibit-password";
    };
  };

  virtualisation.docker.enable = true;

  services.hermes-agent = {
    enable = true;
    container.enable = false;
    addToSystemPackages = true;
    environmentFiles = [
      "/var/lib/hermes/env"
      "/var/lib/hermes/hcloud.env"
    ];
    extraDependencyGroups = [
      "messaging"
    ];
    extraPackages = with pkgs; [
      ansible
      docker
      git
      jq
      kubectl
      kubernetes-helm
      nodejs_22
      opentofu
      pnpm
      ripgrep
    ];
    settings = {
      model.default = "anthropic/claude-sonnet-4";
      toolsets = [ "all" ];
      terminal = {
        backend = "local";
        cwd = "/workspace/ThePaleHeart";
        timeout = 180;
      };
    };
  };

  systemd.services.hermes-agent.environment = {
    KUBECONFIG = "/var/lib/hermes/kube/config";
  };

  environment.systemPackages = with pkgs; [
    ansible
    bun
    curl
    direnv
    docker-compose
    fd
    git
    jq
    k9s
    kubectl
    kubernetes-helm
    nodejs_22
    opentofu
    pnpm
    ripgrep
    tphNixosSync
    tmux
    vim
    yarn
  ];

  programs.git = {
    enable = true;
    config = {
      init.defaultBranch = "main";
      pull.ff = "only";
      safe.directory = [
        "/workspace/ThePaleHeart"
      ];
      user.name = "Failsafe Hermes";
      user.email = "failsafe-hermes@users.noreply.github.com";
    };
  };

  security.sudo.enable = true;
  security.sudo.extraRules = [
    {
      users = [ "hermes" ];
      commands = [
        {
          command = "${pkgs.nixos-rebuild}/bin/nixos-rebuild";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /workspace 0750 hermes hermes -"
    "d /var/lib/hermes 0750 hermes hermes -"
    "d /var/lib/hermes/kube 0700 hermes hermes -"
    "f /var/lib/hermes/env 0600 hermes hermes -"
    "f /var/lib/hermes/hcloud.env 0600 hermes hermes -"
  ];

  networking.firewall.allowedTCPPorts = [
    22
  ];

  system.stateVersion = "25.05";
}
