#!/usr/bin/env bash

#-------------------------------------------------------#
#Sanity Checks
if [ "${BUILD}" != "YES" ] || \
   [ -z "${BINDIR}" ] || \
   [ -z "${EGET_EXCLUDE}" ] || \
   [ -z "${EGET_TIMEOUT}" ] || \
   [ -z "${GIT_TERMINAL_PROMPT}" ] || \
   [ -z "${GIT_ASKPASS}" ] || \
   [ -z "${GITHUB_TOKEN}" ] || \
   [ -z "${SYSTMP}" ] || \
   [ -z "${TMPDIRS}" ]; then
 #exit
  echo -e "\n[+]Skipping Builds...\n"
  exit 1
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Main
SKIP_BUILD="NO" #YES, in case of deleted repos, broken builds etc
if [ "${SKIP_BUILD}" == "NO" ]; then
    #firejail : Linux namespaces and seccomp-bpf sandbox Tools
     export BIN="firejail"
     export SOURCE_URL="https://github.com/netblue30/firejail"
     echo -e "\n\n [+] (Building | Fetching) ${BIN} :: ${SOURCE_URL} [$(TZ='UTC' date +'%A, %Y-%m-%d (%I:%M:%S %p)') UTC]\n"
      ##Build (alpine-musl)
       pushd "$($TMPDIRS)" >/dev/null 2>&1
       docker stop "alpine-builder" 2>/dev/null ; docker rm "alpine-builder" 2>/dev/null
       docker run --privileged --net="host" --name "alpine-builder" --pull="always" "azathothas/alpine-builder:latest" \
        bash -l -c '
        #Setup ENV
         mkdir -p "/build-bins" && pushd "$(mktemp -d)" >/dev/null 2>&1
        #Deps 
         apk update && apk upgrade --no-interactive
         apk add libapparmor --latest --upgrade --no-interactive
         apk add libapparmor-dev --latest --upgrade --no-interactive
         apk add libselinux --latest --upgrade --no-interactive
         apk add libselinux-dev --latest --upgrade --no-interactive
         apk add libselinux-static --latest --upgrade --no-interactive
        #Build
         git clone --filter "blob:none" --quiet "https://github.com/netblue30/firejail" && cd "./firejail"
         export CFLAGS="-O2 -flto=auto -static -w -pipe -D_FILE_OFFSET_BITS=64"
         export LDFLAGS="-static -s -Wl,-S -Wl,--build-id=none"
         "./configure" --disable-shared --disable-Werror --enable-static --enable-apparmor --enable-busybox-workaround --enable-gcov --enable-ids --enable-landlock --disable-selinux --disable-suid
         make --jobs="$(($(nproc)+1))" --keep-going
        #Copy
         find "./src" -type f -exec file -i "{}" \; | grep "application/.*executable" | cut -d":" -f1 | xargs realpath | xargs -I {} rsync -achvL "{}" "/build-bins/"
        #strip & info 
         find "/build-bins/" -type f -exec objcopy --remove-section=".comment" --remove-section=".note.*" "{}" \;
         find "/build-bins/" -type f ! -name "*.no_strip" -exec strip --strip-debug --strip-dwo --strip-unneeded --preserve-dates "{}" \; 2>/dev/null
         file "/build-bins/"* && du -sh "/build-bins/"*
         popd >/dev/null 2>&1
        '
      #Copy & Meta
       docker cp "alpine-builder:/build-bins/." "$(pwd)/"
       find "." -maxdepth 1 -type f -exec file -i "{}" \; | grep "application/.*executable" | cut -d":" -f1 | xargs realpath
       #Meta
       find "." -maxdepth 1 -type f -print | xargs -I {} sh -c 'file {}; b3sum {}; sha256sum {}; du -sh {}'
       [ "$(find ./ -mindepth 1 -maxdepth 1)" ] && sudo rsync -av --copy-links "./." "${BASEUTILSDIR}/firejail"
       sudo chown -R "$(whoami):$(whoami)" "${BASEUTILSDIR}/firejail/" && chmod -R 755 "${BASEUTILSDIR}/firejail/"
      #-------------------------------------------------------#
      if [ -s "$HOME/.config/rclone/rclone.conf" ] && [ "$(find "${BASEUTILSDIR}/firejail" -mindepth 1 -print -quit 2>/dev/null)" ]; then
      ##Meta
       file "${BASEUTILSDIR}/firejail/"*
       #Archive [${BASEUTILSDIR}/firejail]
       7z a -t7z -mx="9" -mmt="$(($(nproc)+1))" -bt "${BASEUTILSDIR}/firejail/_firejail.7z" "${BASEUTILSDIR}/firejail" 2>/dev/null
       7z a -ttar -mx="9" -mmt="$(($(nproc)+1))" -bt "${BASEUTILSDIR}/firejail/_firejail.tar" "${BASEUTILSDIR}/firejail" 2>/dev/null
       #Generate METADATA
       cd "${BASEUTILSDIR}/firejail" && find "./" -maxdepth 1 -type f | grep -v -E '\.jq$|\.log$|\.md$|\.png$|\.txt$|\.upx$' | sort | xargs file > "${BASEUTILSDIR}/firejail/FILE.txt"
       cd "${BASEUTILSDIR}/firejail" && find "./" -maxdepth 1 -type f | grep -v -E '\.jq$|\.log$|\.md$|\.png$|\.txt$|\.upx$' | sort | xargs b3sum > "${BASEUTILSDIR}/firejail/BLAKE3SUM.txt"
       cd "${BASEUTILSDIR}/firejail" && find "./" -maxdepth 1 -type f | grep -v -E '\.jq$|\.log$|\.md$|\.png$|\.txt$|\.upx$' | sort | xargs sha256sum > "${BASEUTILSDIR}/firejail/SHA256SUM.txt"
       dust --depth 1 --only-file --no-percent-bars --no-colors --ignore_hidden --reverse --number-of-lines 99999999 --invert-filter "\.7z$|\.gz$|\.jq$|\.json$|\.md$|\.rar$|\.tar$|\.tgz$|\.tmp$|\.txt$|\.upx$|\.yaml$|\.zip$" "${BASEUTILSDIR}/firejail" | tee "${BASEUTILSDIR}/firejail/SIZE.txt"
       #rClone
       TMP_METADIR="$(mktemp -d)" && export TMP_METADIR="$TMP_METADIR"
       cd "${BASEUTILSDIR}/firejail" && rclone sync "." "r2:/bin/x86_64_Linux/Baseutils/firejail/" --exclude="*.jq" --user-agent="$USER_AGENT" --s3-upload-concurrency="500" --s3-chunk-size="100M" --multi-thread-streams="500" --checkers="2000" --transfers="1000" --retries="10" --check-first --checksum --copy-links --fast-list --progress
       curl -qfsSL "https://pub.ajam.dev/utils/devscripts/jq/to_human_bytes.jq" -o "./to_human_bytes.jq"
       #List
       BUILD_URL="https://pub.ajam.dev/repos/Azathothas/Toolpacks/.github/scripts/x86_64_Linux/bins/firejail.yaml" && export BUILD_URL="$BUILD_URL"
       curl -qfsSL "$BUILD_URL" -o "$TMP_METADIR/temp.yaml"
       yq -r '.bins[]' "$TMP_METADIR/temp.yaml" | sort -u -o "$TMP_METADIR/BINS.txt"
       BUILD_SCRIPT="$(echo "$BUILD_URL" | sed 's|https://pub.ajam.dev/repos|https://github.com|; s|/Toolpacks|/Toolpacks/tree/main|; s|\.yaml$|.sh|')" && export BUILD_SCRIPT="$BUILD_SCRIPT"
       BUILD_LOG="$(echo "$BUILD_SCRIPT" | sed 's|https://github.com/Azathothas/Toolpacks/tree/main/.github/scripts/x86_64_Linux/bins|https://bin.ajam.dev/x86_64_Linux|; s|\.sh$|.log.txt|')" && export BUILD_LOG="$BUILD_LOG"
       DESCRIPTION="$(yq -r '.description' $TMP_METADIR/temp.yaml)" && export DESCRIPTION="$DESCRIPTION"
       NOTE="$(yq -r '.note' $TMP_METADIR/temp.yaml)" && export NOTE="$NOTE"
       EXTRA_BINS="$(awk -v bin="$BIN" '$0 != bin' "$TMP_METADIR/BINS.txt" | paste -sd ',' -)" && export EXTRA_BINS="${EXTRA_BINS}"
       REPO_URL="$(yq -r '.repo_url' $TMP_METADIR/temp.yaml)" && export REPO_URL="$REPO_URL"
       WEB_URL="$(yq -r '.web_url' $TMP_METADIR/temp.yaml)" && export WEB_URL="$WEB_URL"
       rclone lsjson --fast-list "r2:/bin/x86_64_Linux/Baseutils/firejail/" --exclude="*.7z" --exclude="*.no_strip" --exclude="*.gz" --exclude="*.jq" --exclude="*.json" --exclude="*.log" --exclude="*.md" --exclude="*.tar" --exclude="*.tgz" --exclude="*.tmp" --exclude="*.txt" --exclude="*.upx" --exclude="*.zip" | \
       jq --arg BUILD_LOG "$BUILD_LOG" --arg BUILD_SCRIPT "$BUILD_SCRIPT" --arg DESCRIPTION "$DESCRIPTION" --arg EXTRA_BINS "$EXTRA_BINS" --arg NOTE "$NOTE" --arg WEB_URL "$WEB_URL" --arg REPO_URL "$REPO_URL" -r 'include "./to_human_bytes" ; .[] | select(.Size != 0 and .Size != -1 and (.Name | test("\\.(7z|bz2|gz|json|md|rar|tar|tgz|tmp|txt|zip)$") | not)) | {name: (.Name), description: $DESCRIPTION, note: $NOTE, download_url: "https://bin.ajam.dev/x86_64_Linux/Baseutils/firejail/\(.Path)", size: (.Size | tonumber | bytes), build_date: (.ModTime | split(".")[0]), repo_url: $REPO_URL, web_url: $WEB_URL, build_log: $BUILD_LOG, build_script: $BUILD_SCRIPT, extra_bins: $EXTRA_BINS}' | jq -s 'sort_by(.name)' > "$TMP_METADIR/INFO.json"
       for BIN in $(cat "$TMP_METADIR/BINS.txt" | sed 's/"//g'); do
         #Description
          jq --arg BIN "$BIN" --arg DESCRIPTION "$DESCRIPTION" '.[] |= if .name == $BIN then . + {description: $DESCRIPTION} else . end' "$TMP_METADIR/INFO.json" > "$TMP_METADIR/INFO.tmp" && mv "$TMP_METADIR/INFO.tmp" "$TMP_METADIR/INFO.json"
         #Extras (All Bins)
          EXTRA_BINS="$(awk -v bin="$BIN" '$0 != bin' "$TMP_METADIR/BINS.txt" | paste -sd ',' -)" && export EXTRA_BINS="${EXTRA_BINS}"  
          jq --arg BIN "$BIN" --arg EXTRA_BINS "$EXTRA_BINS" '.[] |= if .name == $BIN then . + {extra_bins: $EXTRA_BINS} else . end' "$TMP_METADIR/INFO.json" > "$TMP_METADIR/INFO.tmp" && mv "$TMP_METADIR/INFO.tmp" "$TMP_METADIR/INFO.json"
         #BSUM
          B3SUM="$(cat "${BASEUTILSDIR}/firejail/BLAKE3SUM.txt" | grep -E "^[a-f0-9]+[[:space:]]+(\./)?${BIN}$" | awk '{print $1}' | sort  -u | head -n 1 | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/`//g' | sed 's/|//g' | tr -d '[:space:]')" && export B3SUM="$B3SUM"
          jq --arg BIN "$BIN" --arg B3SUM "$B3SUM" '.[] |= if .name == $BIN then . + {b3sum: $B3SUM} else . end' "$TMP_METADIR/INFO.json" > "$TMP_METADIR/INFO.tmp" && mv "$TMP_METADIR/INFO.tmp" "$TMP_METADIR/INFO.json"
         #SHA256SUM
          SHA256="$(cat "${BASEUTILSDIR}/firejail/SHA256SUM.txt" | grep -E "^[a-f0-9]+[[:space:]]+(\./)?${BIN}$" | awk '{print $1}' | sort  -u | head -n 1 | sed 's/"//g' | sed 's/^[ \t]*//;s/[ \t]*$//' | sed 's/["'\'']//g' | sed 's/`//g' | sed 's/|//g' | tr -d '[:space:]')" && export SHA256="$SHA256"
          jq --arg BIN "$BIN" --arg SHA256 "$SHA256" '.[] |= if .name == $BIN then . + {sha256: $SHA256} else . end' "$TMP_METADIR/INFO.json" > "$TMP_METADIR/INFO.tmp" && mv "$TMP_METADIR/INFO.tmp" "$TMP_METADIR/INFO.json"
         #Web URLs
          jq --arg BIN "$BIN" --arg WEB_URL "$WEB_URL" '.[] |= if .name == $BIN then . + {web_url: $WEB_URL} else . end' "$TMP_METADIR/INFO.json" > "$TMP_METADIR/INFO.tmp" && mv "$TMP_METADIR/INFO.tmp" "$TMP_METADIR/INFO.json"
       done
       #Upload 
       if jq --exit-status . "$TMP_METADIR/INFO.json" >/dev/null 2>&1; then
          rclone copyto --checksum "$TMP_METADIR/INFO.json" "r2:/bin/x86_64_Linux/Baseutils/firejail/INFO.json" --check-first --checkers 2000 --transfers 1000 --user-agent="$USER_AGENT"
       fi
       unset TMP_METADIR BUILD_LOG BUILD_SCRIPT B3SUM DESCRIPTION NOTE EXTRA_BINS REPO_URL SHA256 WEB_URL
      fi
       docker stop "alpine-builder" 2>/dev/null ; docker rm "alpine-builder"
       find "${BASEUTILSDIR}" -type f -size -3c -delete ; popd >/dev/null 2>&1       
fi
#-------------------------------------------------------#

#-------------------------------------------------------#
##Cleanup
unset SKIP_BUILD ; export BUILT="YES"
#In case of zig polluted env
unset AR CC CFLAGS CXX CPPFLAGS CXXFLAGS DLLTOOL HOST_CC HOST_CXX LDFLAGS LIBS OBJCOPY RANLIB
#In case of go polluted env
unset GOARCH GOOS CGO_ENABLED CGO_CFLAGS
#PKG Config
unset PKG_CONFIG_PATH PKG_CONFIG_LIBDIR PKG_CONFIG_SYSROOT_DIR PKG_CONFIG_SYSTEM_INCLUDE_PATH PKG_CONFIG_SYSTEM_LIBRARY_PATH
#-------------------------------------------------------#