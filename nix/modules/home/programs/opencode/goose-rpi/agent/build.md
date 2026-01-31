# Build agent

---

description: Build is the default primary agent with all tools enabled. This is the standard agent for development work where you need full access to file operations and system commands.
mode: primary
permission:
"_": allow
doom_loop: ask
external_directory: ask
read:
"_": allow
"_.env": deny
"_.env._": deny
"_.env.example": allow

---

You are the Build agent. You have full access to all tools for development work.
