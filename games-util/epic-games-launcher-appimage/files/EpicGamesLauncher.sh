#!/bin/sh
# Portage owns the AppImage version; preserve the vendor archive.
export EGL_DISABLE_SELF_UPDATE="${EGL_DISABLE_SELF_UPDATE:-1}"
exec /opt/epic-games-launcher/EpicGamesLauncher.AppImage "$@"
