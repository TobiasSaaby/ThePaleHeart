{ lib, pkgs, ... }:

let
  tphNixosSync = pkgs.writeShellApplication {
    name = "tph-nixos-sync";
    runtimeInputs = with pkgs; [
      git
      gh
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

  tphFailsafeAuth = pkgs.writeShellApplication {
    name = "tph-failsafe-auth";
    runtimeInputs = with pkgs; [
      gh
      git
    ];
    text = ''
      set -euo pipefail

      export HERMES_HOME=/var/lib/hermes/.hermes
      repo="''${1:-/workspace/ThePaleHeart}"

      cd "$repo"

      echo "Authenticating GitHub for the failsafe user..."
      if ! gh auth status --hostname github.com >/dev/null 2>&1; then
        gh auth login --hostname github.com --git-protocol https --skip-ssh-key --web
      fi
      gh auth setup-git --hostname github.com

      git remote set-url origin https://github.com/TobiasSaaby/ThePaleHeart.git
      git remote set-url --push origin https://github.com/TobiasSaaby/ThePaleHeart.git

      echo
      echo "Starting Hermes interactive setup. Use the ChatGPT/portal option when prompted."
      echo "Hermes state will be written to $HERMES_HOME and reused by the systemd service."
      hermes setup

      echo
      echo "Restarting hermes-agent..."
      /run/wrappers/bin/sudo ${pkgs.systemd}/bin/systemctl restart hermes-agent
      ${pkgs.systemd}/bin/systemctl --no-pager --full status hermes-agent || true
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
    user = "failsafe";
    group = "failsafe";
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
      gh
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
      model.default = "openai-codex/gpt-5.5";
      toolsets = [ "all" ];
      terminal = {
        backend = "local";
        cwd = "/workspace/ThePaleHeart";
        timeout = 180;
      };
    };
  };

  systemd.services.hermes-agent = {
    environment = {
      KUBECONFIG = "/var/lib/hermes/kube/config";
    };

    serviceConfig = {
      # The Hermes service uses ProtectSystem=strict, which remounts most of
      # the host filesystem read-only inside the service sandbox. The project
      # checkout intentionally lives under /workspace, so explicitly allow the
      # agent to write there while keeping the rest of the sandbox intact.
      ReadWritePaths = lib.mkAfter [
        "/workspace"
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    ansible
    bun
    curl
    direnv
    docker-compose
    fd
    gh
    git
    jq
    k9s
    kubectl
    kubernetes-helm
    nodejs_22
    opentofu
    pnpm
    ripgrep
    tphFailsafeAuth
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
      user.name = "Failsafe";
      user.email = "failsafe@users.noreply.github.com";
    };
  };

  security.sudo.enable = true;
  security.sudo.extraRules = [
    {
      users = [ "failsafe" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  systemd.tmpfiles.rules = [
    "d /workspace 0750 failsafe failsafe -"
    "d /var/lib/hermes 0750 failsafe failsafe -"
    "d /var/lib/hermes/kube 0700 failsafe failsafe -"
    "f /var/lib/hermes/env 0600 failsafe failsafe -"
    "f /var/lib/hermes/hcloud.env 0600 failsafe failsafe -"
  ];

  networking.firewall.allowedTCPPorts = [
    22
  ];

  system.stateVersion = "25.05";
}
