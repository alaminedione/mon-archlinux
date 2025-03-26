#!/usr/bin/env bash

# Configuration de base
OUTPUT_FORMAT="mkv"
MAX_RESOLUTION=1080
DEFAULT_FORMAT="bestvideo[height<=${MAX_RESOLUTION}]+bestaudio/best[height<=${MAX_RESOLUTION}]"
ARIA2_ARGS=("--downloader" "aria2c" "--external-downloader-args" "aria2c:-x 3 -s 3 -k 1M")

# Variables d'options
VIDEO_OPT=0
PLAYLIST_OPT=0
AUDIO_OPT=0
SUBS_OPT=0
PATH_OPT=0
RAPIDE_OPT=0

# Parser les options
while getopts "vrpasc" opt; do
  case $opt in
    v) VIDEO_OPT=1 ;;
    r) RAPIDE_OPT=1 ;;
    p) PLAYLIST_OPT=1 ;;
    a) AUDIO_OPT=1 ;;
    s) SUBS_OPT=1 ;;
    c) PATH_OPT=1 ;;
    *) echo "Usage: $0 [-v] [-r] [-p] [-a] [-s] [-c] URL" >&2
       exit 1 ;;
  esac
done
shift $((OPTIND-1))

# Vérifier URL
if [ -z "$1" ]; then
  echo "Erreur: URL manquante"
  exit 1
fi

# Construction de la commande avec tableau pour éviter les problèmes de guillemets
CMD=("yt-dlp")

# Options rapides (aria2c)
if [ $RAPIDE_OPT -eq 1 ]; then
  CMD+=("${ARIA2_ARGS[@]}")
fi

# Gestion playlist
if [ $PLAYLIST_OPT -eq 1 ]; then
  CMD+=("--yes-playlist" "--download-archive" "archive.txt")
else
  CMD+=("--no-playlist")
fi

# Gestion audio/video
if [ $AUDIO_OPT -eq 1 ]; then
  CMD+=("--extract-audio" "--audio-format" "best" "--audio-quality" "0")
  OUTPUT_FORMAT="best"
else
  CMD+=("--format" "${DEFAULT_FORMAT}" "--merge-output-format" "${OUTPUT_FORMAT}")
fi

# Sous-titres
if [ $SUBS_OPT -eq 1 ]; then
  CMD+=("--write-subs" "--sub-langs" "all,-live_chat" "--convert-subs" "srt" "--embed-subs")
fi

# Chemin personnalisé
if [ $PATH_OPT -eq 1 ]; then
  CMD+=("-o" "~/Videos/%(uploader)s/%(playlist_title)s/%(title)s.%(ext)s")
else
  CMD+=("-o" "%(title)s.%(ext)s")
fi

# Ajout de l'URL et execution
CMD+=("$1")

# Exécution avec affichage debug
echo "Exécution:" "${CMD[@]}"
exec "${CMD[@]}"
