# Agents configuration for opencode

{
  lib,
  config,
  ...
}:

let
  cfg = config.sysconf.programs.opencode;
in
{
  programs.opencode.agents = lib.mkIf cfg.enable {
    code-reviewer = ''
      # Code Reviewer Agent

      You are a senior software engineer specializing in code reviews.
      Focus on code quality, security, and maintainability.

      ## Guidelines
      - Review for potential bugs and edge cases
      - Check for security vulnerabilities
      - Ensure code follows best practices
      - Suggest improvements for readability and performance
    '';
    # documentation = ./agents/documentation.md;
  };
}
