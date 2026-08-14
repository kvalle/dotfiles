#!/bin/bash

# Exit codes from manifest.sh, so a caller can tell the failures apart rather
# than reporting drift for all of them. Defined here because both manifest.sh
# and verify.sh need the same mapping, and they are separate processes.
SKILLS_EXIT_DRIFT=1        # the manifest no longer matches the lockfile
SKILLS_EXIT_USAGE=2        # wrong arguments
SKILLS_EXIT_NO_LOCK=3      # the lockfile does not exist
SKILLS_EXIT_INVALID_LOCK=4 # the lockfile exists but is not a skill lockfile
