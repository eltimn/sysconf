# Reorganize nix/home and nix/system into nix/modules Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Consolidate `nix/home/` and `nix/system/` directories into `nix/modules/home/` and `nix/modules/system/` to improve repository organization.

**Architecture:** This is a pure refactoring with no functional changes. We move two directories and update ~50 import paths across the codebase. Git will track moves properly using `git mv`. All module contents remain identical.

**Tech Stack:** NixOS, Nix Flakes, Home Manager

---

## Task 1: Move home directory to modules/home

**Files:**
- Move: `nix/home/` → `nix/modules/home/`

**Step 1: Move the home directory**

```bash
git mv nix/home nix/modules/home
```

Expected: Directory moved, git tracks as rename

**Step 2: Verify the move**

```bash
git status
```

Expected: Shows renamed files from `nix/home/*` → `nix/modules/home/*`

**Step 3: Commit the move**

```bash
git commit -m "refactor: move nix/home to nix/modules/home"
```

---

## Task 2: Move system directory to modules/system

**Files:**
- Move: `nix/system/` → `nix/modules/system/`

**Step 1: Move the system directory**

```bash
git mv nix/system nix/modules/system
```

Expected: Directory moved, git tracks as rename

**Step 2: Verify the move**

```bash
git status
```

Expected: Shows renamed files from `nix/system/*` → `nix/modules/system/*`

**Step 3: Commit the move**

```bash
git commit -m "refactor: move nix/system to nix/modules/system"
```

---

## Task 3: Update flake.nix reference

**Files:**
- Modify: `flake.nix:132`

**Step 1: Update the import path**

In `flake.nix` line 132, change:
```nix
./nix/system/default.nix # system modules
```

To:
```nix
./nix/modules/system/default.nix # system modules
```

**Step 2: Verify the change**

```bash
git diff flake.nix
```

Expected: Shows change from `./nix/system/default.nix` to `./nix/modules/system/default.nix`

**Step 3: Commit the change**

```bash
git add flake.nix
git commit -m "refactor: update flake.nix to reference modules/system"
```

---

## Task 4: Update ruca machine configs

**Files:**
- Modify: `nix/machines/ruca/home.nix:15-25`
- Modify: `nix/machines/ruca/system.nix:10-12`

**Step 1: Update ruca/home.nix imports**

In `nix/machines/ruca/home.nix` lines 15-25, change all `../../home/` to `../../modules/home/`:

```nix
  imports = [
    ../../modules/home/common
    ../../modules/home/containers
    ../../modules/home/desktop
    ../../modules/home/cosmic
    ../../modules/home/programs
    ../../modules/home/programs/git
    ../../modules/home/programs/vscode
    ../../modules/home/programs/zsh
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/firefox.nix
    ../../modules/home/programs/tmux.nix
  ];
```

**Step 2: Update ruca/system.nix imports**

In `nix/machines/ruca/system.nix` lines 10-12, change `../../system/` to `../../modules/system/`:

```nix
  imports = [
    ../../modules/system
    # ../../modules/system/de/gnome.nix
    ../../modules/system/de/cosmic.nix
  ];
```

**Step 3: Commit the changes**

```bash
git add nix/machines/ruca/home.nix nix/machines/ruca/system.nix
git commit -m "refactor: update ruca configs to use modules paths"
```

---

## Task 5: Update cbox machine configs

**Files:**
- Modify: `nix/machines/cbox/home.nix:8-13`
- Modify: `nix/machines/cbox/system.nix:13`

**Step 1: Update cbox/home.nix imports**

In `nix/machines/cbox/home.nix` lines 8-13, change all `../../home/` to `../../modules/home/`:

```nix
  imports = [
    ../../modules/home/common
    ../../modules/home/programs
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/git
    ../../modules/home/programs/tmux.nix
    ../../modules/home/programs/zsh
  ];
```

**Step 2: Update cbox/system.nix imports**

In `nix/machines/cbox/system.nix` line 13, change `../../system/` to `../../modules/system/`:

```nix
    ../../modules/system/sysconf-user.nix
```

**Step 3: Commit the changes**

```bash
git add nix/machines/cbox/home.nix nix/machines/cbox/system.nix
git commit -m "refactor: update cbox configs to use modules paths"
```

---

## Task 6: Update illmatic machine configs

**Files:**
- Modify: `nix/machines/illmatic/home.nix:7-13`
- Modify: `nix/machines/illmatic/system.nix:9-11`

**Step 1: Update illmatic/home.nix imports**

In `nix/machines/illmatic/home.nix` lines 7-13, change all `../../home/` to `../../modules/home/`:

```nix
  imports = [
    ../../modules/home/common
    ../../modules/home/containers
    ../../modules/home/programs
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/git
    ../../modules/home/programs/tmux.nix
    ../../modules/home/programs/zsh
  ];
```

**Step 2: Update illmatic/system.nix imports**

In `nix/machines/illmatic/system.nix` lines 9-11, change `../../system/` to `../../modules/system/`:

```nix
  imports = [
    ../../modules/system/containers
    ../../modules/system/services
    ../../modules/system/sysconf-user.nix
  ];
```

**Step 3: Commit the changes**

```bash
git add nix/machines/illmatic/home.nix nix/machines/illmatic/system.nix
git commit -m "refactor: update illmatic configs to use modules paths"
```

---

## Task 7: Update lappy machine configs

**Files:**
- Modify: `nix/machines/lappy/home.nix:9-17`
- Modify: `nix/machines/lappy/system.nix:10`

**Step 1: Update lappy/home.nix imports**

In `nix/machines/lappy/home.nix` lines 9-17, change all `../../home/` to `../../modules/home/`:

```nix
  imports = [
    ../../modules/home/common
    ../../modules/home/desktop
    ../../modules/home/gnome.nix
    ../../modules/home/programs
    ../../modules/home/programs/git
    ../../modules/home/programs/vscode
    ../../modules/home/programs/zsh
    ../../modules/home/programs/direnv.nix
    ../../modules/home/programs/tmux.nix
  ];
```

**Step 2: Update lappy/system.nix imports**

In `nix/machines/lappy/system.nix` line 10, change `../../system/` to `../../modules/system/`:

```nix
    ../../modules/system/de/gnome.nix
```

**Step 3: Commit the changes**

```bash
git add nix/machines/lappy/home.nix nix/machines/lappy/system.nix
git commit -m "refactor: update lappy configs to use modules paths"
```

---

## Task 8: Update nixos-test machine configs

**Files:**
- Modify: `nix/machines/nixos-test/home-nelly.nix:5-9`
- Modify: `nix/machines/nixos-test/configuration.nix:11-14`

**Step 1: Update nixos-test/home-nelly.nix imports**

In `nix/machines/nixos-test/home-nelly.nix` lines 5-9, change all `../../home/` to `../../modules/home/`:

```nix
  imports = [
    ../../modules/home/programs
    ../../modules/home/programs/direnv.nix
    # ../../modules/home/programs/git # requires sops
    ../../modules/home/programs/tmux.nix
    ../../modules/home/programs/zsh
  ];
```

**Step 2: Update nixos-test/configuration.nix imports**

In `nix/machines/nixos-test/configuration.nix` lines 11-14, change `../../system/` to `../../modules/system/`:

```nix
    # ../../modules/system/default.nix
    ../../modules/system/sysconf-user.nix
    ../../modules/system/containers/rootless.nix
    ../../modules/system/containers/nginx.nix
```

**Step 3: Commit the changes**

```bash
git add nix/machines/nixos-test/home-nelly.nix nix/machines/nixos-test/configuration.nix
git commit -m "refactor: update nixos-test configs to use modules paths"
```

---

## Task 9: Test the build

**Step 1: Test build for ruca**

```bash
task build -- #ruca
```

Expected: Build succeeds without errors

**Step 2: Clean up build artifacts**

```bash
task clean
```

Expected: Artifacts removed

**Step 3: (Optional) Test other hosts**

If you want to be thorough:
```bash
task build -- #cbox
task build -- #illmatic
task build -- #lappy
task clean
```

Expected: All builds succeed

---

## Summary

This refactoring moves two directories and updates ~49 import paths across 10 configuration files. Each task is atomic and committed separately for easy rollback if needed. The functional behavior remains identical - only paths change.

**Total commits: 8**
- 2 directory moves
- 1 flake.nix update
- 5 machine config updates
