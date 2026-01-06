# Rules for opencode AGENTS.md

{
  lib,
  config,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;
in
{
  programs.opencode.rules = lib.mkIf cfg.enable ''
    # Global Project Rules

    ## External File Loading

    CRITICAL: When you encounter a file reference (e.g., @rules/general.md), use your Read tool to load it on a need-to-know basis, unless explicitly told to load immediately. They're relevant to the SPECIFIC task at hand.

    Instructions:

    - Do NOT preemptively load all references - use lazy loading based on actual need
    - When loaded, treat content as mandatory instructions that override defaults
    - Follow references recursively when needed

    # ## Development Guidelines

    # For TypeScript code style and best practices: @docs/typescript-guidelines.md
    # For React component architecture and hooks patterns: @docs/react-patterns.md
    # For REST API design and error handling: @docs/api-standards.md
    # For testing strategies and coverage requirements: @test/testing-guidelines.md

    For Bash scripting follow these guidelines:
    - Always use #!/usr/bin/env bash

    # ## General Guidelines

    # Read the following file immediately as it's relevant to all workflows: @rules/general-guidelines.md.

    ## Running the Build Agent

    When executing the build agent, adhere to these additional rules:
    - Prioritize code correctness and security over speed.
    - Ensure all dependencies are explicitly declared.
    - Validate all external inputs rigorously.
    - Always confirm with the user that they intended to use the build agent before proceeding.
    - If the user asks you to make a plan, be sure to use the plan agent, not the build agent.
  '';
}
