## cplt sandbox

OpenCode runs inside the cplt sandbox, which restricts access to the file
system, the network, system services and certain commands or operations. Errors
such as missing access, read-only paths, blocked connections or failed system
changes may therefore be caused by the sandbox.

Always consider sandbox restrictions as a possible cause before assuming a fault
in the host machine's configuration, ownership, permissions or installation. Do
not propose system changes to work around a likely sandbox restriction. State
instead what the user has to run outside the sandbox.

When running `npx skills` inside the cplt sandbox, always use
`NPM_CONFIG_CACHE="$TMPDIR/npm-cache" npx skills ...`, so that the downloaded
CLI can be executed from cplt's approved scratch directory.

`.git/config` is read-only in cplt. When publishing a feature branch, use
`git push origin HEAD`, not `git push -u`. Later `git push` calls work without
an upstream because the global Git configuration sets `push.default = current`.
