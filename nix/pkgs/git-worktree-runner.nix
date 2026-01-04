{
  lib,
  stdenv,
  fetchFromGitHub,
  installShellFiles,
}:

stdenv.mkDerivation rec {
  pname = "git-worktree-runner";
  version = "2.0.0";

  src = fetchFromGitHub {
    owner = "coderabbitai";
    repo = "git-worktree-runner";
    rev = "v${version}";
    hash = "sha256-TPd+5WtEZsR6x4/OPVkrIpW7SSDJpbZbvjYR8rzdZAs=";
  };

  nativeBuildInputs = [ installShellFiles ];

  buildPhase = ":";

  installPhase = ''
    runHook preInstall

    # Install both scripts to bin
    install -Dm755 bin/git-gtr $out/bin/git-gtr
    install -Dm755 bin/gtr $out/bin/gtr

    # Install lib directory to same level as bin
    cp -r lib $out/

    # Install adapters directory if it exists
    if [ -d adapters ]; then
      cp -r adapters $out/
    fi

    # Install completions manually
    install -Dm644 completions/gtr.bash $out/share/bash-completion/completions/git-gtr
    install -Dm644 completions/gtr.fish $out/share/fish/vendor_completions.d/git-gtr.fish
    install -Dm644 completions/_git-gtr $out/share/zsh/vendor-completions/_git-gtr

    runHook postInstall
  '';

  meta = with lib; {
    description = "Bash-based Git worktree manager with editor and AI tool integration";
    homepage = "https://github.com/coderabbitai/git-worktree-runner";
    license = licenses.asl20;
    maintainers = [ ];
    platforms = platforms.unix;
    mainProgram = "git-gtr";
  };
}
