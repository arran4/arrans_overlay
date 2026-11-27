#!/bin/sh
# Portage manages launcher updates; do not mutate installed files in place.
export EGL_DISABLE_SELF_UPDATE="${EGL_DISABLE_SELF_UPDATE:-1}"
exec /usr/lib/epic-games-launcher/bin/EpicGamesLauncher "$@"
