#!/usr/bin/env bash

# This should be able to be executed completely in userspace mode only & shouldn't require root access
# Only Dependency is 'curl' or 'wget' 
# Get wget: https://github.com/Azathothas/Static-Binaries/tree/main/wget
# Get Curl: https://github.com/Azathothas/Static-Binaries/tree/main/curl
# Once requirement is satisfied, simply:
# bash <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/.github/scripts/eget_binaries_amd_x86_64.sh")
#-------------------------------------------------------#
#Get ENV:PATH
if [[ ":$PATH:" != *":$HOME/bin:"* ]]; then
  if ! [ -d "$HOME/bin" ] ; then
    mkdir -p "$HOME/bin" 
  fi  
    export PATH="$HOME/bin:$PATH"
fi
#Get Dir Ready
if ! [ -d "$HOME/bin" ] ; then
    mkdir -p "$HOME/bin" 
fi
# If On Github Actions, remove bloat to get space (~ 30 GB)
if [ "$USER" = "runner" ] || [ "$(whoami)" = "runner" ]; then
     #12.0 GB
     sudo rm /usr/local/lib/android -rf 2>/dev/null
     #8.2 GB
     sudo rm /opt/hostedtoolcache/CodeQL -rf 2>/dev/null
     #5.0 GB
     sudo rm /usr/local/.ghcup -rf 2>/dev/null
     #2.0 GB
     sudo rm /usr/share/dotnet -rf 2>/dev/null
     #1.7 GB
     sudo rm /usr/share/swift -rf 2>/dev/null
     #1.1 GB
     #sudo rm /usr/local/lib/node_modules -rf 2>/dev/null
     #1.0 GB
     sudo rm /usr/local/share/powershell -rf 2>/dev/null
     #500 MB
     sudo rm /usr/local/lib/heroku -rf 2>/dev/null
fi 
#Download eget
if ! command -v eget &> /dev/null; then
   curl -qfsSL "https://zyedidia.github.io/eget.sh" | bash
   if [ -f "./eget" ]; then
       mv "./eget" "$HOME/bin" && chmod +xwr "$HOME/bin/eget"
   else
      pushd $(mktemp -d)
      curl -qfLJO $(curl -qfsSL "https://api.github.com/repos/zyedidia/eget/releases/latest" | jq -r '.assets[].browser_download_url' | grep -i 'linux.*amd64')
      find . -type f -name '*.tar.gz' -exec tar -xzvf {} \;
      find . -type f -name 'eget*' -exec strip {} \; >/dev/null 2>&1
      find . -type f -name 'eget' -exec mv {} "$HOME/bin/eget" \;
      chmod +xwr "$HOME/bin/eget"
      popd
   fi
else
  cp "$(which eget)" "$HOME/bin/eget"
fi   
#-------------------------------------------------------#
#Sanity Checks
if [[ -n "$GITHUB_TOKEN" ]]; then
   # 5000 req/minute (80 req/minute) 
   echo "GITHUB_TOKEN is Exported"
   eget --rate
else
   # 60 req/hr
   echo "GITHUB_TOKEN is NOT Exported"
   echo -e "Export it to avoid ratelimits"
   eget --rate 
   exit 1
fi
#-------------------------------------------------------# 
#Tools (Binaries Only)
  #---------------#
  #7z : Unarchiver
  pushd "$(mktemp -d)" && curl -qfsSLJO "https://www.7-zip.org/$(curl -qfsSL "https://www.7-zip.org/download.html" | grep -o 'href="[^"]*"' | sed 's/href="//' | grep 'linux-x64.tar.xz' | sed 's/"$//' | sort | tail -n 1)"
  find . -type f -name '*.xz' -exec tar -xf {} \;
  find . -type f -name '7zzs' ! -name '*.xz' -exec cp {} "$HOME/bin/7z" \;
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #airiXSS : xss automater
  #eget "ferreiraklet/airixss" --to "$HOME/bin/airixss"
  pushd "$(mktemp -d)" && git clone "https://github.com/ferreiraklet/airixss" && cd "./airixss"
  go mod init "github.com/ferreiraklet/airixss" ; go mod tidy
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./airixss" "$HOME/bin/airixss" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #aix : AIx is a cli tool to interact with Large Language Models (LLM) APIs. 
  eget "projectdiscovery/aix" --asset "amd64" --asset "linux" --to "$HOME/bin/aix"
  #---------------#
  #albafetch : system-info-fetcher
  eget "alba4k/albafetch" --asset "linux" --asset "static" --asset "x64" --to "$HOME/bin/albafetch"
  #---------------#
  #alist : A file list/WebDAV program that supports multiple storages
  eget "alist-org/alist" --asset "amd64" --asset "linux" --asset "musl" --to "$HOME/bin/alist"
  #---------------#
  #alterx : Fast and customizable subdomain wordlist generator using DSL 
  eget "projectdiscovery/alterx" --asset "amd64" --asset "linux" --to "$HOME/bin/alterx"
  #---------------#
  #amass : In-depth attack surface mapping and asset discovery 
  #eget "owasp-amass/amass" --asset "amd64" --asset "zip" --to "$HOME/bin/amass" && mkdir -p "$HOME/.config/amass"
  pushd "$(mktemp -d)" && git clone "https://github.com/owasp-amass/amass" && cd "./amass"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/amass" ; mv "./amass" "$HOME/bin/amass" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #analyticsrelationships : Get related domains / subdomains by looking at Google Analytics IDs 
  pushd "$(mktemp -d)" && git clone "https://github.com/Josue87/AnalyticsRelationships" && cd "./AnalyticsRelationships"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./analyticsrelationships" "$HOME/bin/analyticsrelationships" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #anew : A tool for adding new lines to files, skipping duplicates 
  eget "tomnomnom/anew" --asset "amd64" --asset "linux" --to "$HOME/bin/anew"
  #---------------#
  #angle-grinder: Slice and dice logs on the command line 
  eget "rcoh/angle-grinder" --asset "linux" --asset "musl" --asset "x86_64" --to "$HOME/bin/agrind"
  #---------------#
  #aria2c : aria2 is a multi-protocol (HTTP/HTTPS, FTP, SFTP, BitTorrent & Metalink) & multi-source command-line download utility
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/aria2/aria2c_amd_x86_64_libressl_musl_latest_Linux" --to "$HOME/bin/aria2c"
  #---------------#
  #assetfinder : Find domains and subdomains related to a given domain 
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/assetfinder" && cd "./assetfinder"
  go mod init "github.com/tomnomnom/assetfinder" ; go mod tidy
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./assetfinder" "$HOME/bin/assetfinder" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #asn : ASN / RPKI validity / BGP stats / IPv4v6 / Prefix / URL / ASPath / Organization / IP reputation / IP geolocation / IP fingerprinting / Network recon / lookup API server / Web traceroute server
  eget "https://raw.githubusercontent.com/nitefood/asn/master/asn" --to "$HOME/bin/asn"
  #---------------#
  #asnmap : Mapping organization network ranges using ASN information
  #eget "projectdiscovery/asnmap" --asset "amd64" --asset "linux" --to "$HOME/bin/asnmap"
  pushd "$(mktemp -d)" && git clone "https://github.com/projectdiscovery/asnmap" && cd "./asnmap"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/asnmap" ; mv "./asnmap" "$HOME/bin/asnmap" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #atuin: Sync Shell History
  eget "atuinsh/atuin" --asset "unknown-linux-musl" --to "$HOME/bin/atuin"
  #---------------#
  #batcat: cat with colors & syntax highlights 
  eget "sharkdp/bat" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/bat" && ln -s "$HOME/bin/bat" "$HOME/bin/batcat"
  #---------------#
  #binfetch : neofetch for binaries   
  pushd "$(mktemp -d)" && git clone "https://github.com/Im-0xea/binfetch" && cd "./binfetch"
  #Install Deps
  sudo apt-get install libconfuse-common libconfuse-dev libelf-dev meson -y
  #https://mesonbuild.com/Builtin-options.html
  meson setup --buildtype="release" --default-library="static" --prefer-static -Ddebug="false" -Db_lto="true" -Db_pie="true" -Db_staticpic="true" --strip --reconfigure --wipe --clearcache "./build" "./"
  ninja -C "./build"
  file "./build/binfetch" && ldd "./build/binfetch" ; mv "./build/binfetch" "$HOME/bin/binfetch"
  #Requires cfg
  curl -qfsSL "https://raw.githubusercontent.com/Im-0xea/binfetch/main/cfg/binfetch.cfg" -o "$HOME/bin/binfetch.cfg"
  #mkdir -p "$HOME/.config/binfetch" && curl -qfsSL "https://raw.githubusercontent.com/Im-0xea/binfetch/main/cfg/binfetch.cfg" -o "$HOME/.config/binfetch/binfetch.cfg"
  #mkdir -p "$HOME/.config/binfetch" && curl -qfsSL "https://raw.githubusercontent.com/Im-0xea/binfetch/main/cfg/emby.cfg" -o "$HOME/.config/binfetch/binfetch.cfg"
  #mkdir -p "$HOME/.config/binfetch" && curl -qfsSL "https://raw.githubusercontent.com/Im-0xea/binfetch/main/cfg/rainbow.cfg" -o "$HOME/.config/binfetch/binfetch.cfg"
  #---------------#
  #binocle : a graphical tool to visualize binary data 
  eget "sharkdp/binocle" --asset "linux" --asset "musl" --asset "x86_64" --to "$HOME/bin/binocle"
  #---------------#
  #bore : ngrok alternative for making tunnels to localhost 
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/bore/bore_amd_x86_64_musl_Linux" --to "$HOME/bin/bore"
  #---------------#
  #bottom : htop clone | graphical process/system monitor
  eget "ClementTsang/bottom" --asset "bottom_x86_64-unknown-linux-musl.tar.gz" --file "btm" --to "$HOME/bin/bottom"
  #"$HOME/bin/eget" "ClementTsang/bottom" --asset "bottom_x86_64-unknown-linux-musl.tar.gz" --file "btm" --to "$HOME/bin/bottom" && ln -s "$HOME/bin/bottom" "$HOME/bin/btm"
 #---------------#
  #btop : htop clone | A monitor of resources 
  pushd "$(mktemp -d)" && curl -qfsSL $(curl -s "https://api.github.com/repos/aristocratos/btop/actions/artifacts" | jq -r '[.artifacts[] | select(.name == "btop-x86_64-linux-musl")] | sort_by(.created_at) | .[].archive_download_url') -H "Authorization: Bearer $GITHUB_TOKEN" -o "btop.zip" && unzip "./btop.zip" && find . -type f -name '*btop*' ! -name '*.zip*' -exec mv {} "$HOME/bin/btop" \; && popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #BucketLoot : Automated S3-compatible bucket inspector
  pushd "$(mktemp -d)" && git clone "https://github.com/redhuntlabs/BucketLoot" && cd "./BucketLoot"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./bucketloot" "$HOME/bin/bucketloot" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #busybox : several Unix utilities in a single executable file
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/busybox/busybox_amd_x86_64_musl_Linux" --to "$HOME/bin/busybox"
  #---------------#
  #byp4xx : 40X/HTTP bypasser in Go. Features: Verb tampering, headers, #bugbountytips, User-Agents, extensions, default credentials
  pushd "$(mktemp -d)" && git clone "https://github.com/lobuhi/byp4xx" && cd "./byp4xx"
  go mod init "github.com/lobuhi/byp4xx" ; go mod tidy
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./byp4xx" "$HOME/bin/byp4xx" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #cdncheck : A utility to detect various technology for a given IP address. 
  eget "projectdiscovery/cdncheck" --asset "amd64" --asset "linux" --to "$HOME/bin/cdncheck"
  #---------------#
  #cent : Fetch & Organize all Nuclei Templates
  eget "xm1k3/cent" --asset "amd64" --asset "linux" --to "$HOME/bin/cent"
  #---------------#
  #certstream :  Cli for calidog's certstream
  pushd $(mktemp -d) && mkdir certstream && cd certstream
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/certstream/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/certstream/go.mod"
  go get github.com/Azathothas/Arsenal/certstream
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./certstream" ; mv "./certstream" "$HOME/bin/certstream" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Chameleon : Content Discovery using wappalyzer's set of technology fingerprints alongside custom wordlists tailored to each detected technologies.
  eget "iustin24/chameleon" --asset "linux" --to "$HOME/bin/chameleon"
  #---------------#
  #cherrybomb : Validating and Testing APIs using an OpenAPI file
  pushd "$(mktemp -d)" && git clone "https://github.com/blst-security/cherrybomb" && cd "./cherrybomb"
  export TARGET="x86_64-unknown-linux-gnu" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/cherrybomb" "$HOMR/bin/cherrybomb"
  #---------------#
  #chaos
  eget "projectdiscovery/chaos-client" --asset "amd64" --asset "linux" --to "$HOME/bin/chaos-client"
  #---------------#
  #Cloudfox
  #eget "BishopFox/cloudfox" --asset "amd64" --asset "linux" --to "$HOME/bin/cloudfox"
  pushd $(mktemp -d) && git clone "https://github.com/BishopFox/cloudfox" && cd cloudfox
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./cloudfox" "$HOME/bin/cloudfox" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #cloudlist
  eget "projectdiscovery/cloudlist" --asset "amd64" --asset "linux" --to "$HOME/bin/cloudlist"
  #---------------#
  #cloudreve
  eget "cloudreve/Cloudreve" --asset "amd64" --asset "linux" --file "cloudreve" --to "$HOME/bin/cloudreve"
  #---------------#
  #comb
  pushd $(mktemp -d) && mkdir comb && cd comb
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/comb/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/comb/go.mod"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./comb" ; mv "./comb" "$HOME/bin/comb" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #https://github.com/containerd/containerd
  eget "containerd/containerd" --asset "linux" --asset "static" --asset "amd" --asset "64" --asset "^sha256sum" --to "$HOME/bin/containerd"
  #---------------#
  #cpufetch : fetch for cpu
  eget "Dr-Noob/cpufetch" --asset "linux" --asset "x86" --asset "64" --to "$HOME/bin/cpufetch"
  #---------------#
  #https://github.com/kubernetes-sigs/cri-tools
  eget "kubernetes-sigs/cri-tools" --asset "crictl" --asset "linux" --asset "amd" --asset "^sha" --to "$HOME/bin/crictl"
  #---------------#
  #crlfuzz
  pushd $(mktemp -d) && git clone "https://github.com/dwisiswant0/crlfuzz" && cd crlfuzz
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/crlfuzz" ; mv "./crlfuzz" "$HOME/bin/crlfuzz" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #croc
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/croc/croc_amd_x86_64_Linux" --to "$HOME/bin/croc"
  #---------------#
  #crt
  #eget "cemulus/crt" --asset "x86_64" --to "$HOME/bin/crt"
  pushd $(mktemp -d) && git clone "https://github.com/cemulus/crt" && cd crt
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./crt" "$HOME/bin/crt" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #csprecon
  pushd $(mktemp -d) && git clone "https://github.com/edoardottt/csprecon" && cd csprecon
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/csprecon" ; mv "./csprecon" "$HOME/bin/csprecon" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #curl
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/curl/curl_amd_x86_64_Linux" --to "$HOME/bin/curl"
  #---------------#
  #curlie
  eget "rs/curlie" --asset "linux_amd64.tar.gz" --to "$HOME/bin/curlie"
  #---------------#
  #cut-cdn
  pushd $(mktemp -d) && git clone "https://github.com/ImAyrix/cut-cdn" && cd cut-cdn
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./cut-cdn" "$HOME/bin/cut-cdn" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #dalfox
  eget "hahwul/dalfox" --asset "amd64" --to "$HOME/bin/dalfox"
  #---------------#
  #dirstat-rs
  pushd $(mktemp -d) && git clone https://github.com/scullionw/dirstat-rs && cd dirstat-rs
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/ds" "$HOMR/bin/ds" ; popd
  #---------------#
  #dns-doctor
  pushd $(mktemp -d) && git clone "https://github.com/jvns/dns-doctor" && cd "./dns-doctor"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./dns-doctor" "$HOME/bin/dns-doctor" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #dnstake
  pushd $(mktemp -d) && git clone "https://github.com/pwnesia/dnstake" && cd dnstake
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/dnstake" ; mv "./dnstake" "$HOME/bin/dnstake" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #dnsx
  eget "projectdiscovery/dnsx" --asset "amd64" --asset "linux" --to "$HOME/bin/dnsx"
  #---------------#
  #doggo
  eget "mr-karan/doggo" --asset "linux" --asset "amd64" --to "$HOME/bin/doggo"
  #---------------#
  #dsieve
  eget "trickest/dsieve" --asset "amd64" --to "$HOME/bin/dsieve"
  #---------------#
  #duf
  eget "muesli/duf" --asset "linux_x86_64.tar.gz" --to "$HOME/bin/duf"
  #---------------#
  #dust
  eget "bootandy/dust" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/dust"
  #---------------#
  #dysk
  pushd $(mktemp -d) && curl -qfLJO $(curl -qfsSL "https://api.github.com/repos/Canop/dysk/releases/latest" | jq -r '.assets[].browser_download_url' | grep -i 'dysk' | grep -i 'zip')
  find . -type f -name '*.zip*' -exec unzip -o {} \;
  find . -type f -name '*.md' -exec rm {} \;
  #mv "$(find . -type d -name '*x86_64*' -name '*linux*' ! -name '*musl*')/dysk" "$HOME/bin/dysk_gcc"   
  mv "$(find . -type d -name '*x86_64*' -name '*linux*' -name '*musl*')/dysk" "$HOME/bin/dysk" ; popd
  #---------------#
  #encode
  pushd $(mktemp -d) && git clone "https://github.com/Brum3ns/encode" && cd encode
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/encode" ; mv "./encode" "$HOME/bin/encode" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #enumerepo
  eget "trickest/enumerepo" --asset "amd64" --to "$HOME/bin/enumerepo"
  #---------------#
  #exa
  eget "ogham/exa" --asset "linux" --asset "musl" --asset "x86_64" --to "$HOME/bin/exa"
  #---------------#
  #fastfetch (This is Dynamic)
  eget "fastfetch-cli/fastfetch" --asset "Linux" --asset "tar.gz" --to "$HOME/bin/fastfetch"
  #---------------#
  #fd
  eget "sharkdp/fd" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/fd" && ln -s "$HOME/bin/fd" "$HOME/bin/fd-find"
  #---------------#
  #feroxbuster
  eget "epi052/feroxbuster" --asset "linux" --asset "zip" --to "$HOME/bin/feroxbuster"
  #---------------#
  #fget
  pushd $(mktemp -d) && mkdir fget && cd fget
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/fget/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/fget/go.mod"
  go get github.com/Azathothas/Arsenal/fget
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./fget" ; mv "./fget" "$HOME/bin/fget" ; popd ; go clean -cache -fuzzcache -modcache
  #---------------#
  #Findomain
  eget "Findomain/Findomain" --asset "findomain-linux.zip" --asset "^386" --to "$HOME/bin/findomain"
  #---------------#
  #fingerprintx
  eget "praetorian-inc/fingerprintx" --asset "amd64" --asset "linux" --to "$HOME/bin/fingerprintx"
  #---------------#
  #https://github.com/eugeneware/ffmpeg-static
  eget "eugeneware/ffmpeg-static" --asset "ffmpeg" --asset "linux" --asset "x64" --asset ".gz" --to "$HOME/bin/ffmpeg"
  eget "eugeneware/ffmpeg-static" --asset "ffprobe" --asset "linux" --asset "x64" --asset ".gz" --to "$HOME/bin/ffprobe"
  #---------------#
  #ffuf
  eget "ffuf/ffuf" --asset "amd64" --asset "linux" --to "$HOME/bin/ffuf"
  #---------------#
  #ffufPostprocessing
  pushd $(mktemp -d) && git clone "https://github.com/Damian89/ffufPostprocessing" && cd ffufPostprocessing
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./ffufPostprocessing" "$HOME/bin/ffufPostprocessing" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #filebrowser : https://github.com/filebrowser/filebrowser
  eget "filebrowser/filebrowser" --asset "linux" --asset "amd" --asset "64" --to "$HOME/bin/filebrowser"
  #---------------#
  #fuzzuli
  pushd $(mktemp -d) && git clone "https://github.com/musana/fuzzuli" && cd fuzzuli
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./fuzzuli" "$HOME/bin/fuzzuli" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #fzf
  eget "junegunn/fzf" --asset "linux_amd64.tar.gz" --to "$HOME/bin/fzf"
  #---------------#
  #gau
  #eget "lc/gau" --asset "amd64" --asset "linux" --to "$HOME/bin/gau"
  pushd $(mktemp -d) && git clone "https://github.com/lc/gau" && cd gau
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/gau" ; mv "./gau" "$HOME/bin/gau" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gdu
  eget "dundee/gdu" --asset "gdu_linux_amd64_static.tgz" --to "$HOME/bin/gdu"
  #---------------#
  #getJS
  pushd $(mktemp -d) && mkdir getJS && cd getJS
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/getJS/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/getJS/go.mod"
  go get github.com/Azathothas/Arsenal/getJS
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./getJS" ; mv "./getJS" "$HOME/bin/getJS" ; popd ; go clean -cache -fuzzcache -modcache
  #---------------#
  #gf
  pushd $(mktemp -d) && git clone "https://github.com/tomnomnom/gf" && cd gf
  go mod init github.com/tomnomnom/gf ; go mod tidy
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gf" "$HOME/bin/gf" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gfx --> symlinked to gf
  #eget "dwisiswant0/gfx" --asset "amd64" --asset "linux" --to "$HOME/bin/gfx" && ln -s "$HOME/bin/gfx" "$HOME/bin/gf"
  pushd $(mktemp -d) && git clone "https://github.com/dwisiswant0/gfx" && cd gfx
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gfx" "$HOME/bin/gfx" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gh
  eget "cli/cli" --asset "linux_amd64.tar.gz" --to "$HOME/bin/gh"
  #---------------#
  #git
  # requires additional binaries
  #eget "Azathothas/static-toolbox" --tag "git" --asset "git_amd_x86_64_Linux" --to "$HOME/bin/git"
  #---------------#
  #gitdorks_go
  pushd $(mktemp -d) && git clone "https://github.com/damit5/gitdorks_go" && cd gitdorks_go
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gitdorks_go" "$HOME/bin/gitdorks_go" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #github-endpoints
  pushd $(mktemp -d) && git clone "https://github.com/gwen001/github-endpoints" && cd github-endpoints
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./github-endpoints" "$HOME/bin/github-endpoints" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #github-regexp
  pushd $(mktemp -d) && git clone "https://github.com/gwen001/github-regexp" && cd github-regexp
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./github-regexp" "$HOME/bin/github-regexp" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #github-subdomains
  pushd $(mktemp -d) && git clone "https://github.com/gwen001/github-subdomains" && cd github-subdomains
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./github-subdomains" "$HOME/bin/github-subdomains" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gitlab-subdomains
  pushd $(mktemp -d) && git clone "https://github.com/gwen001/gitlab-subdomains" && cd gitlab-subdomains
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gitlab-subdomains" "$HOME/bin/gitlab-subdomains" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gitleaks
  eget "gitleaks/gitleaks" --asset "linux_x64.tar.gz" --to "$HOME/bin/gitleaks"
  #---------------#
  #gitui
  eget "extrawurst/gitui" --asset "gitui-linux-musl.tar.gz" --to "$HOME/bin/gitui"
  #---------------#
  #https://github.com/charmbracelet/glow
  eget "charmbracelet/glow" --asset "Linux" --asset "x86_64" --asset "^sbom" --to "$HOME/bin/glow"
  #---------------#
  #gobuster
  eget "OJ/gobuster" --asset "Linux_x86_64.tar.gz" --to "$HOME/bin/gobuster"
  #---------------#
  #godns
  eget "TimothyYe/godns" --asset "linux_amd64.tar.gz" --to "$HOME/bin/godns"
  #---------------#
  #gofastld
  pushd $(mktemp -d) && git clone "https://github.com/elliotwutingfeng/go-fasttld" && cd go-fasttld
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./fasttld" "./cmd/main.go" ; mv "./fasttld" "$HOME/bin/fasttld" ; popd
  #---------------#
  #gofireprox
  eget "mr-pmillz/gofireprox" --asset "amd64" --asset "linux" --to "$HOME/bin/gofireprox"
  #---------------#
  #goop
  pushd $(mktemp -d) && git clone "https://github.com/nyancrimew/goop" && cd "./goop"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./goop" "$HOME/bin/goop" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gorilla
  pushd $(mktemp -d) && git clone https://github.com/d4rckh/gorilla && cd gorilla
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/gorilla" "$HOMR/bin/gorilla" ; popd
  #---------------#
  #gost
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/gost/gost_amd_x86_64_Linux" --to "$HOME/bin/gost"
  #---------------#
  #gotator
  pushd $(mktemp -d) && git clone "https://github.com/Josue87/gotator" && cd gotator
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gotator" "$HOME/bin/gotator" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gowitness
  #eget "sensepost/gowitness" --asset "amd64" --asset "linux" --to "$HOME/bin/gowitness"
  pushd $(mktemp -d) && git clone "https://github.com/sensepost/gowitness" && cd gowitness
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gowitness" "$HOME/bin/gowitness" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gping: https://github.com/orf/gping
  eget "orf/gping" --asset "unknown-linux-musl" --asset "linux" --to "$HOME/bin/gping"
  #---------------#
  #GRPCurl
  pushd $(mktemp -d) && git clone "https://github.com/fullstorydev/grpcurl" && cd grpcurl
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/grpcurl" ; mv "./grpcurl" "$HOME/bin/grpcurl" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Gxss
  pushd $(mktemp -d) && git clone "https://github.com/KathanP19/Gxss" && cd Gxss
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./Gxss" "$HOME/bin/Gxss" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hacker-scoper
  pushd $(mktemp -d) && git clone "https://github.com/ItsIgnacioPortal/hacker-scoper" && cd hacker-scoper
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hacker-scoper" "$HOME/bin/hacker-scoper" ; popd
  #---------------#
  #hakip2host
  pushd $(mktemp -d) && git clone "https://github.com/hakluke/hakip2host" && cd hakip2host
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakip2host" "$HOME/bin/hakip2host" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hakoriginfinder
  pushd$(mktemp -d) && git clone https://github.com/hakluke/hakoriginfinder && cd hakoriginfinder 
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakoriginfinder" "$HOME/bin/hakoriginfinder" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hakrawler
  pushd $(mktemp -d) && git clone https://github.com/hakluke/hakrawler && cd hakrawler
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakrawler" "$HOME/bin/hakrawler" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hakrevdns
  pushd $(mktemp -d) && git clone https://github.com/hakluke/hakrevdns && cd hakrevdns
  go mod init github.com/hakluke/hakrevdns ; go mod tidy
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakrevdns" "$HOME/bin/hakrevdns" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #HEDnsExtractor
  pushd $(mktemp -d) && git clone "https://github.com/HuntDownProject/HEDnsExtractor" && cd HEDnsExtractor
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/hednsextractor" ; mv "./hednsextractor" "$HOME/bin/hednsextractor" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #https://github.com/sharkdp/hexyl
  eget "sharkdp/hexyl" --asset "linux" --asset "musl" --asset "x86_64" --to "$HOME/bin/hexyl"
  #---------------#
  #hrekt: https://github.com/ethicalhackingplayground/hrekt
  #eget "ethicalhackingplayground/hrekt" --asset "^exe" --to "$HOME/bin/hrekt"
  pushd $(mktemp -d) && git clone https://github.com/ethicalhackingplayground/hrekt && cd hrekt
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET"
  export RUSTFLAGS="-C target-feature=+crt-static" ; sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/hrekt" "$HOMR/bin/hrekt" ; popd
  #---------------#
  #hxn
  eget "pwnwriter/haylxon" --asset "linux" --asset "musl" --asset "^.sha512" --to "$HOME/bin/hxn" && ln -s "$HOME/bin/hxn" "$HOME/bin/haylxon"
  #---------------#
  #htmlq
  #eget "mgdm/htmlq" --asset "x86_64-linux.tar.gz" --to "$HOME/bin/htmlq"
  pushd $(mktemp -d) && git clone "https://github.com/mgdm/htmlq" && cd "./htmlq"
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release
  file "./target/$TARGET/release/htmlq" ; ldd "./target/$TARGET/release/htmlq" ; ls "./target/$TARGET/release/htmlq" -lah
  mv "./target/$TARGET/release/htmlq" "$HOMR/bin/htmlq" ; popd
  #---------------#
  #httprobe
  pushd $(mktemp -d) && git clone "https://github.com/tomnomnom/httprobe" && cd httprobe
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./httprobe" "$HOME/bin/httprobe" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #httpx
  eget "projectdiscovery/httpx" --asset "amd64" --asset "linux" --to "$HOME/bin/httpx"
  #---------------#
  #https://github.com/sharkdp/hyperfine
  eget "sharkdp/hyperfine" --asset "linux" --asset "musl" --asset "x86_64" --to "$HOME/bin/hyperfine"
  #---------------#
  #inscope
  pushd $(mktemp -d) && mkdir inscope && cd inscope
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/inscope/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/inscope/go.mod"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./inscope" ; mv "./inscope" "$HOME/bin/inscope" ; popd ; go clean -cache -fuzzcache -modcache -testcache  
  #---------------#
  #iperf3
  eget "userdocs/iperf3-static" --asset "iperf3-amd64" --to "$HOME/bin/iperf3"
  #---------------#
  #interactsh-client
  eget "projectdiscovery/interactsh" --asset "amd64" --asset "linux" --asset "interactsh-client" --to "$HOME/bin/interactsh-client"
  #---------------#
  #jaeles
  #eget "jaeles-project/jaeles" --asset "linux" --to "$HOME/bin/jaeles"
  pushd $(mktemp -d) && git clone "https://github.com/jaeles-project/jaeles" && cd jaeles
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./jaeles" "$HOME/bin/jaeles" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #jc
  eget "kellyjonbrazil/jc" --asset "linux-x86_64.tar.gz" --to "$HOME/bin/jc"
  staticx --loglevel DEBUG "$HOME/bin/jc" --strip "$HOME/bin/jc_staticx"
  #---------------#
  #jless 
  pushd $(mktemp -d) && git clone https://github.com/PaulJuliusMartinez/jless && cd jless
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET"
  # Currenttly can't build static, flags get overidden, instead use staticX
  #export RUSTFLAGS="-C target-feature=+crt-static"  
  #echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  unset RUSTFLAGS ; cargo build --target "$TARGET" --release
  mv "./target/$TARGET/release/jless" "$HOME/bin/jless_dynamic"
  staticx --loglevel DEBUG "$HOME/bin/jless_dynamic" --strip "$HOME/bin/jless_staticx" ; popd
  #---------------#
  #jq
  # this needs to be updated
  eget "jqlang/jq"  --pre-release --tag "jq-1.7rc1" --asset "jq-linux-amd64" --to "$HOME/bin/jq"
  #---------------#
  #jwthack
  pushd $(mktemp -d) && git clone "https://github.com/hahwul/jwt-hack" && cd jwt-hack
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./jwt-hack" "$HOME/bin/jwt-hack" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #kanha
  eget "pwnwriter/kanha" --asset "linux" --asset "musl" --asset "^.sha512" --to "$HOME/bin/kanha"
  #katana
  eget "projectdiscovery/katana" --asset "amd64" --asset "linux" --to "$HOME/bin/katana"
  staticx --loglevel DEBUG "$HOME/bin/katana" --strip "$HOME/bin/katana_staticx"
  #pushd $(mktemp -d) && git clone "https://github.com/projectdiscovery/katana" && cd katana
  #CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./katana" "./cmd/katana" ; mv "./katana" "$HOME/bin/katana" ; popd
  #---------------#
  #ksubdomain
  eget "boy-hack/ksubdomain" --asset "linux.tar" --to "$HOME/bin/ksubdomain"
  staticx --loglevel DEBUG "$HOME/bin/ksubdomain" --strip "$HOME/bin/ksubdomain_staticx"
  #---------------#
  #https://github.com/jesseduffield/lazydocker
  eget "jesseduffield/lazydocker" --asset "Linux" --asset "x86_64" --to "$HOME/bin/lazydocker"
  #---------------#
  #lit-bb-hack-tools
  pushd $(mktemp -d) && git clone https://github.com/edoardottt/lit-bb-hack-tools && cd lit-bb-hack-tools
  find . -type f -name '*.md' -exec rm {} \;
  find . -maxdepth 1 -type d ! -name '.git*' -exec sh -c 'CGO_ENABLED=0 go build -o "$1/$1_amd_x86_64_Linux" -v -a -gcflags=all="-l -B -wb=false" -ldflags="-s -w -extldflags '\''-static'\''" "$1/"*' _ {} \;
  find . -type f -name '*_Linux' -exec mv {} "$HOME/bin/" \;
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #https://github.com/tstack/lnav
  eget "tstack/lnav" --asset "linux" --asset "musl" --asset "x86_64" --to "$HOME/bin/lnav"
  #---------------#
  #logtimer
  eget "Eun/logtimer" --asset "linux" --asset "x86_64.tar.gz" --to "$HOME/bin/logtimer"
  #---------------#
  #machinna : system-info-fetch
  pushd $(mktemp -d) && git clone "https://github.com/Macchina-CLI/macchina" && cd "./macchina"
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/macchina" "$HOME/bin/macchina" ; popd
  #---------------#
  #mantra
  pushd $(mktemp -d) && git clone "https://github.com/MrEmpy/mantra" && cd mantra
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./Mantra" "$HOME/bin/mantra" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #mapcidr
  #eget "projectdiscovery/mapcidr" --asset "amd64" --asset "linux" --to "$HOME/bin/mapcidr"
  pushd $(mktemp -d) && git clone "https://github.com/projectdiscovery/mapcidr" && cd mapcidr
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/mapcidr" ; mv "./mapcidr" "$HOME/bin/mapcidr" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #massdns
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/massdns/massdns_linux_x86_64_gcc" --to "$HOME/bin/massdns"
  #---------------#
  #masscan
  #Doesn't work
  #eget "https://github.com/Azathothas/Static-Binaries/raw/main/masscan/masscan_linux_x86_64_gcc" --to "$HOME/bin/masscan"
  #---------------#
  #mergerfs
  eget "trapexit/mergerfs" --asset "amd64" --asset "static" --to "$HOME/bin/mergerfs"
  #---------------#
  #mgwls
  eget "trickest/mgwls" --asset "amd64" --asset "linux" --to "$HOME/bin/mgwls"
  #---------------#
  #micro : https://github.com/zyedidia/micro/blob/master/runtime/help/keybindings.md
  eget "zyedidia/micro" --asset "linux64-static.tar.gz" --to "$HOME/bin/micro"
  #---------------#
  #miniserve
  eget "svenstaro/miniserve" --asset "x86_64-unknown-linux-musl" --to "$HOME/bin/miniserve"
  #---------------#
  #mksub
  eget "trickest/mksub" --asset "amd64" --asset "linux" --to "$HOME/bin/mksub"
  #---------------#
  #mubeng
  #eget "kitabisa/mubeng" --asset "amd64" --asset "linux" --to "$HOME/bin/mubeng"
  pushd $(mktemp -d) && git clone "https://github.com/kitabisa/mubeng" && cd mubeng
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/mubeng" ; mv "./mubeng" "$HOME/bin/mubeng" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #naabu
  eget "projectdiscovery/naabu" --asset "amd64" --asset "linux" --to "$HOME/bin/naabu"
  staticx --loglevel DEBUG "$HOME/bin/naabu" --strip "$HOME/bin/naabu_staticx"
  #---------------#
  #ncdu
  eget "https://dev.yorhel.nl$(curl -qfsSL https://dev.yorhel.nl/ncdu | awk -F '"' '/x86_64\.tar\.gz/ && /href=/{print $2}' | grep -v 'asc' | sort -u)" --to "$HOME/bin/ncdu"
  #---------------#
  #https://github.com/containerd/nerdctl
  eget "containerd/nerdctl" --asset "linux" --asset "amd" --asset "64" --asset "^full" --asset "nerdctl" --to "$HOME/bin/nerdctl"
  #---------------#
  #ngrok
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/ngrok/ngrok_amd_x86_64_Linux" --to "$HOME/bin/ngrok"
  #---------------#
  #nmap
  eget "Azathothas/static-toolbox" --tag "nmap" --asset "x86_64-portable.tar.gz" --all && mv "./ncat" "./nmap" "./nping" "$HOME/bin"
  #---------------#
  #nmap-formatter
  #eget "vdjagilev/nmap-formatter" --asset "amd64" --asset "linux" --to "$HOME/bin/nmap-formatter"
  pushd $(mktemp -d) && git clone "https://github.com/vdjagilev/nmap-formatter" && cd nmap-formatter
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./nmap-formatter" "$HOME/bin/nmap-formatter" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #neofetch : Updated Fork 
  eget "https://raw.githubusercontent.com/hykilpikonna/hyfetch/master/neofetch" --to "$HOME/bin/neofetch" ; chmod +xwr "$HOME/bin/neofetch"
  #---------------#
  #nnn
  eget "jarun/nnn" --asset "musl-static" --asset "x86_64" --to "$HOME/bin/nnn"
  #---------------#
  #noir
  pushd $(mktemp -d) && git clone "https://github.com/hahwul/noir" && cd noir
  shards build --release --no-debug --production --static ; mv "./bin/noir" "$HOME/bin/noir" ; popd
  #staticx --loglevel DEBUG "$HOME/bin/noir" --strip "$HOME/bin/noir_staticx"
  #---------------#
  #notify
  eget "projectdiscovery/notify" --asset "amd64" --asset "linux" --to "$HOME/bin/notify"
  #---------------#
  #nrich
  eget "https://gitlab.com/api/v4/projects/33695681/packages/generic/nrich/0.4.1/nrich-linux-amd64" --to "$HOME/bin/nrich"
  #---------------#
  #nuclei
  eget "projectdiscovery/nuclei" --asset "amd64" --asset "linux" --to "$HOME/bin/nuclei"
  #---------------#
  #oha: https://github.com/hatoo/oha
  eget "hatoo/oha" --asset "amd64" --asset "linux" --to "$HOME/bin/oha"
  #---------------#
  #openrisk
  #eget "projectdiscovery/openrisk" --asset "amd64" --asset "linux" --to "$HOME/bin/openrisk"
  pushd $(mktemp -d) && git clone "https://github.com/projectdiscovery/openrisk" && cd openrisk
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/openrisk" ; mv "./openrisk" "$HOME/bin/openrisk" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #osmedeus
  #eget "j3ssie/osmedeus" --asset "linux.zip" --to "$HOME/bin/osmedeus"
  pushd $(mktemp -d) && git clone "https://github.com/j3ssie/osmedeus" && cd osmedeus
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./osmedeus" "$HOME/bin/osmedeus" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #pathbuster
  eget "ethicalhackingplayground/pathbuster" --asset "^exe" --to "$HOME/bin/pathbuster"
  # attempt to build a static binary produces dynamic anyway
  # pushd $(mktemp -d) && git clone https://github.com/ethicalhackingplayground/pathbuster && cd pathbuster
  # export TARGET="x86_64-unknown-linux-gnu"
  # rustup target add "$TARGET"
  # export RUSTFLAGS="-C target-feature=+crt-static" 
  # sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  # echo -e '\n\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  # cargo build --target "$TARGET" --release
  # file "./target/$TARGET/release/pathbuster" ; ldd "./target/$TARGET/release/pathbuster" ; ls "./target/$TARGET/release/pathbuster" -lah
  # mv "./target/$TARGET/release/pathbuster" "$HOMR/bin/pathbuster"
  # popd
  #---------------#
  #ppfuzz
  pushd $(mktemp -d) && git clone https://github.com/dwisiswant0/ppfuzz && cd ppfuzz
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/ppfuzz" "$HOME/bin/ppfuzz" ; popd
  #---------------#
  #pping
  eget "wzv5/pping" --asset "Linux_x86_64.tar.gz" --to "$HOME/bin/pping"
  #---------------#
  #procs
  eget "dalance/procs" --asset "x86_64-linux.zip" --to "$HOME/bin/procs"
  #---------------#
  #proxify
  #eget "projectdiscovery/proxify" --asset "amd64" --asset "linux" --to "$HOME/bin/proxify"
  pushd $(mktemp -d) && git clone "https://github.com/projectdiscovery/proxify" && cd proxify
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/proxify" ; mv "./proxify" "$HOME/bin/proxify" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #https://github.com/Nukesor/pueue
  eget "Nukesor/pueue" --asset "linux" --asset "x86_64" --asset "^pueued" --to "$HOME/bin/pueue"
  eget "Nukesor/pueue" --asset "linux" --asset "x86_64" --asset "pueued" --to "$HOME/bin/pueued"
  #---------------#
  #puredns
  eget "d3mondev/puredns" --asset "amd64" --to "$HOME/bin/puredns"
  #---------------#
  #Qbittorent-nox
  eget "userdocs/qbittorrent-nox-static" --asset "x86_64-qbittorrent-nox" --to "$HOME/bin/qbittorrent-nox"
  #---------------#
  #qsreplace
  pushd $(mktemp -d) && git clone "https://github.com/tomnomnom/qsreplace" && cd qsreplace
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./qsreplace" "$HOME/bin/qsreplace" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #rate-limit-checker
  pushd $(mktemp -d) && mkdir rate-limit-checker && cd rate-limit-checker
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/rate-limit-checker/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/rate-limit-checker/go.mod"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./rate-limit-checker" ; mv "./rate-limit-checker" "$HOME/bin/rate-limit-checker" ; popd ; go clean -cache -fuzzcache -modcache
  #---------------#
  #rclone
  eget "rclone/rclone" --asset "linux-amd64.zip" --to "$HOME/bin/rclone"
  #---------------#
  #recollapse
  pushd $(mktemp -d) && git clone https://github.com/0xacb/recollapse && cd recollapse
  pip install --upgrade -r requirements.txt ; mv "./recollapse" "./recollapse.py"
  pyinstaller --clean "./recollapse.py" --noconfirm ; pyinstaller --strip --onefile "./recollapse.py" --noconfirm
  staticx --loglevel DEBUG "./dist/recollapse" --strip "$HOME/bin/recollapse_staticx" ; popd
  #---------------#
  #reptyr
  pushd $(mktemp -d) && git clone "https://github.com/nelhage/reptyr" && cd reptyr
  make CFLAGS="-MD -Wall -Werror -D_GNU_SOURCE -g -static $CFLAGS" LDFLAGS="-static $LDFLAGS" all
  strip "./reptyr" ; mv "./reptyr" "$HOME/bin/reptyr" ; popd
  #---------------#
  #rescope
  # Installton will require placing a /tmp/rescope/configs/avoid.txt
  # mkdir -p "/tmp/rescope/configs" ; curl -qfsSL "https://raw.githubusercontent.com/root4loot/rescope/master/configs/avoid.txt" -o "/tmp/rescope/configs/avoid.txt"
  cd /tmp && git clone https://github.com/root4loot/rescope && cd rescope
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./rescope" "$HOMR/bin/rescope" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #resDNS
  eget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/resdns/resdns.sh" --to "$HOME/bin/resdns"
  #---------------#
  #revit
  pushd $(mktemp -d) && git clone "https://github.com/devanshbatham/revit" && cd revit
  rm go.mod ; rm go.sum ; go mod init github.com/devanshbatham/revit ; go mod tidy
  go get github.com/devanshbatham/revit/cmd/revit
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/revit" ; mv "./revit" "$HOME/bin/revit" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ripgen
  pushd $(mktemp -d) && git clone https://github.com/resyncgg/ripgen && cd ripgen
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/ripgen" "$HOME/bin/ripgen" ; popd
  #---------------#
  #ripgrep
  eget "BurntSushi/ripgrep" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/ripgrep" && ln -s "$HOME/bin/ripgrep" "$HOME/bin/rg"
  #---------------#
  #https://github.com/phiresky/ripgrep-all
  eget "phiresky/ripgrep-all" --asset "linux" --asset "musl" --asset "x86_64" --file "rga" --to "$HOME/bin/rga"
  #---------------#
  #roboxtractor
  pushd $(mktemp -d) && git clone "https://github.com/Josue87/roboxtractor" && cd roboxtractor
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./roboxtractor" "$HOME/bin/roboxtractor" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #https://github.com/opencontainers/runc
  eget "opencontainers/runc" --asset "amd" --asset "64" --asset "^asc" --to "$HOME/bin/runc"
  #---------------#
  #rush
  eget "shenwei356/rush" --asset "rush_linux_amd64.tar.gz" --to "$HOME/bin/rush"
  #---------------#
  #Rustscan --> GH Releases are outdated
  pushd $(mktemp -d) && git clone https://github.com/RustScan/RustScan && cd RustScan
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/rustscan" "$HOME/bin/rustcan" ; popd
  #---------------#
  #s3scanner
  eget "sa7mon/S3Scanner" --asset "Linux_x86_64.tar.gz" --to "$HOME/bin/s3scanner"
  #---------------#
  #scilla
  pushd $(mktemp -d) && git clone "https://github.com/edoardottt/scilla" && cd scilla
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/scilla" ; mv "./scilla" "$HOME/bin/scilla" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #scopegen
  pushd $(mktemp -d) && mkdir scopegen && cd scopegen
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/scopegen/scopegen.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/scopegen/go.mod"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "scopegen" "./scopegen.go" ; mv "./scopegen" "$HOME/bin/scopegen" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #scopeview
  eget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/scopeview/scopeview.sh" --to "$HOME/bin/scopeview"
  #---------------#
  #scp
  eget "https://files.serverless.industries/bin/scp.amd64" --to "$HOME/bin/scp"
  #---------------#
  #screenfetch
  eget "https://raw.githubusercontent.com/KittyKatt/screenFetch/master/screenfetch-dev" --to "$HOME/bin/screenfetch" ; chmod +xwr "$HOME/bin/screenfetch"
  #---------------#
  #sftp
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/openssh/sftp_server_amd_x86_64_Linux" --to "$HOME/bin/sftp"
  #---------------#
  #shfmt
  eget "mvdan/sh" --asset "linux_amd64" --to "$HOME/bin/shfmt"
  #---------------#
  #shuffledns
  eget "projectdiscovery/shuffledns" --asset "amd64" --asset "linux" --to "$HOME/bin/shuffledns"
  #---------------#
  #shortscan
  pushd $(mktemp -d) && git clone "https://github.com/bitquark/shortscan" && cd shortscan
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/shortscan" ; mv "./shortscan" "$HOME/bin/shortscan" 
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/shortutil" ; mv "./shortutil" "$HOME/bin/shortutil"
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #go-simplehttpserver
  pushd $(mktemp -d) && git clone "https://github.com/projectdiscovery/simplehttpserver" && cd simplehttpserver
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/simplehttpserver" ; mv "./simplehttpserver" "$HOME/bin/go-simplehttpserver" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #smap
  pushd $(mktemp -d) && git clone "https://github.com/s0md3v/Smap" && cd Smap
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/smap" ; mv "./smap" "$HOME/bin/smap" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #sns
  pushd $(mktemp -d) && git clone "https://github.com/sw33tLie/sns" && cd sns
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./sns" "$HOME/bin/sns" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #socat
  eget "Azathothas/static-toolbox" --tag "socat" --asset "x86_64" --to "$HOME/bin/socat"
  #---------------#
  #speedtest-go
  eget "showwin/speedtest-go" --asset "Linux_x86_64.tar.gz" --to "$HOME/bin/speedtest-go"
  #---------------#
  #spk
  pushd $(mktemp -d) && git clone https://github.com/dhn/spk && cd spk
  CGO_ENABLED=0 go build -o "spk_amd_x86_64_Linux" -v -ldflags="-s -w -extldflags '-static'"
  find . -type f -name '*_Linux' -exec mv {} "$HOME/bin/spk" \;
  go clean -cache -fuzzcache -modcache -testcache ; popd
  #---------------#
  #ssh
  eget "https://files.serverless.industries/bin/ssh.amd64" --to "$HOME/bin/ssh"
  #---------------#
  #sshd
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/openssh/sshd_amd_x86_64_Linux" --to "$HOME/bin/sshd"
  #---------------#
  #sshd_config
  eget "https://raw.githubusercontent.com/Azathothas/Static-Binaries/main/openssh/sshd_config_amd_x86_64_Linux" --to "$HOME/bin/sshd_config"
  #---------------#
  #ssh-keygen
  eget "https://files.serverless.industries/bin/ssh-keygen.amd64" --to "$HOME/bin/ssh-keygen"
  #---------------#
  #ssh-keyscan
  eget "https://files.serverless.industries/bin/ssh-keyscan.amd64" --to "$HOME/bin/ssh-keyscan"
  #---------------#
  #sshkeys
  eget "Eun/sshkeys" --asset "linux_amd64.tar.gz" --to "$HOME/bin/sshkeys"
  #---------------#
  #starship
  eget "starship/starship" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/starship"
  #---------------#
  #https://github.com/abhimanyu003/sttr
  eget "abhimanyu003/sttr" --asset "amd" --asset "64" --asset "tar.gz" --to "$HOME/bin/sttr"
  #---------------#
  #strace
  eget "Azathothas/static-toolbox" --tag "strace" --asset "x86_64" --to "$HOME/bin/strace"
  #---------------#
  #subfinder
  eget "projectdiscovery/subfinder" --asset "amd64" --asset "linux" --to "$HOME/bin/subfinder"
  #---------------#
  #subjs
  pushd $(mktemp -d) && git clone "https://github.com/lc/subjs" && cd subjs
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./subjs" "$HOME/bin/subjs" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #subxtract
  eget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/subxtract/subxtract.sh" --to "$HOME/bin/subxtract"
  #---------------#
  #surf
  pushd $(mktemp -d) && git clone "https://github.com/assetnote/surf" && cd surf
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/surf" ; mv "./surf" "$HOME/bin/surf" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #tailscale
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/tailscale/tailscale_amd_x86_64_Linux" --to "$HOME/bin/tailscale"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/tailscale/tailscale_merged_amd_x86_64_Linux" --to "$HOME/bin/tailscale_merged"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/tailscale/tailscaled_amd_x86_64_Linux" --to "$HOME/bin/tailscaled"
  #---------------#
  #tailspin
  pushd $(mktemp -d) && git clone "https://github.com/bensadeh/tailspin" && cd "./tailspin"
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/spin" "$HOME/bin/tailspin" ; popd
  #---------------#
  #tcpdump
  eget "Azathothas/static-toolbox" --tag "tcpdump" --asset "x86_64" --to "$HOME/bin/tcpdump"
  #---------------#
  #tere (Terminal Dir Navigator)
  eget "mgunyho/tere" --asset "x86_64-unknown-linux-musl.zip" --to "$HOME/bin/tere"
  #---------------#
  #tlsx
  eget "projectdiscovery/tlsx" --asset "amd64" --asset "linux" --to "$HOME/bin/tlsx"
  #---------------#
  #https://github.com/tmate-io/tmate
  eget "tmate-io/tmate" --asset "linux" --asset "amd" --asset "64" --asset "^symbol" --to "$HOME/bin/tmate"
  #---------------#
  #tmux
  eget "Azathothas/static-toolbox" --tag "tmux" --asset "tmux_amd_x86_64_Linux" --asset "^gz" --asset "^bz2" --to "$HOME/bin/tmux"
  #---------------#
  #tok
  pushd $(mktemp -d) && mkdir tok && cd tok
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/tok/main.go" ; curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/tok/go.mod"
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./tok" ; mv "./tok" "$HOME/bin/tok" ; popd ; go clean -cache -fuzzcache -modcache -testcache 
  #---------------#
  #tokei
  eget "XAMPPRocky/tokei" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/tokei"
  #---------------#
  #toybox
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/toybox/toybox_amd_x86_64_Linux" --to "$HOME/bin/toybox"
  #---------------#
  #trufflehog
  eget "trufflesecurity/trufflehog" --asset "amd64" --asset "linux" --to "$HOME/bin/trufflehog"
  #---------------#
  #twingate
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_client_amd_x86_64_staticx_Linux" --to "$HOME/bin/twingate-client"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_connector_amd_x86_64_dynamic_Linux" --to "$HOME/bin/twingate-connector"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_connector_amd_x86_64_staticx_Linux" --to "$HOME/bin/twingate-connector-staticx"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_connectorctl_amd_x86_64_staticx_Linux" --to "$HOME/bin/twingate-connectorctl"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_notifier_amd_x86_64_staticx_Linux" --to "$HOME/bin/twingate-notifier"
  #---------------#
  #udpx
  pushd $(mktemp -d) && git clone "https://github.com/nullt3r/udpx" && cd udpx
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/udpx" ; mv "./udpx" "$HOME/bin/udpx" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #uncover
  eget "projectdiscovery/uncover" --asset "amd64" --asset "linux" --to "$HOME/bin/uncover"
  #---------------#
  #unfurl
  #eget "tomnomnom/unfurl" --asset "amd64" --asset "linux" --to "$HOME/bin/unfurl"
  pushd $(mktemp -d) && git clone "https://github.com/tomnomnom/unfurl" && cd unfurl
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./unfurl" "$HOME/bin/unfurl" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #upx
  eget "https://github.com/borestad/static-binaries/raw/main/x86_64/upx" --to "$HOME/bin/upx"
  #---------------#
  #vhs: https://github.com/charmbracelet/vhs
  eget "charmbracelet/vhs" --asset "Linux" --asset "x86_64" --asset "^sbom" --asset "vhs" --to "$HOME/bin/vhs"
  #---------------#
  #viewgen
  pushd $(mktemp -d) && git clone https://github.com/0xacb/viewgen && cd viewgen
  pip install --upgrade -r requirements.txt ; mv "./viewgen" "./viewgen.py"
  pyinstaller --clean "./viewgen.py" --noconfirm ; pyinstaller --strip --onefile "./viewgen.py" --noconfirm
  staticx --loglevel DEBUG "./dist/viewgen" --strip "$HOME/bin/viewgen_staticx" ; popd
  #---------------#
  #https://github.com/sachaos/viddy
  eget "sachaos/viddy" --asset "Linux" --asset "x86_64" --to "$HOME/bin/viddy"
  #---------------#
  #wadl-dumper
  pushd $(mktemp -d) && git clone "https://github.com/dwisiswant0/wadl-dumper" && cd wadl-dumper
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./wadl-dumper" "$HOME/bin/wadl-dumper" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #wappalyzergo (Just a library not cli)
  #eget "projectdiscovery/wappalyzergo" --asset "amd64" --asset "linux" --to "$HOME/bin/wappalyzergo"
  #---------------#
  #watchexec
  eget "https://github.com/borestad/static-binaries/raw/main/x86_64/watchexec" --to "$HOME/bin/watchexec"
  #---------------#
  #waybackrobots
  pushd $(mktemp -d) && git clone "https://github.com/mhmdiaa/waybackrobots" && cd waybackrobots
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./waybackrobots" "$HOME/bin/waybackrobots" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #waybackurls
  # pre made is static
  #eget "tomnomnom/waybackurls" --asset "amd64" --asset "linux" --to "$HOME/bin/waybackurls"
  pushd $(mktemp -d) && git clone "https://github.com/tomnomnom/waybackurls" && cd waybackurls
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./waybackurls" "$HOME/bin/waybackurls"
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Web-Cache-Vulnerability-Scanner
  pushd $(mktemp -d) && git clone "https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner" && cd Web-Cache-Vulnerability-Scanner
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./Web-Cache-Vulnerability-Scanner" "$HOME/bin/Web-Cache-Vulnerability-Scanner" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #WebSocat
  eget "vi/websocat" --asset "x86_64-unknown-linux-musl" --asset "max" --to "$HOME/bin/websocat"
  #---------------#
  #wormhole-rs
  pushd "$(mktemp -d)" && git clone "https://github.com/magic-wormhole/magic-wormhole.rs" && cd "./magic-wormhole.rs"
  export TARGET="x86_64-unknown-linux-gnu" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cargo build --target "$TARGET" --release ; mv "./target/$TARGET/release/wormhole-rs" "$HOMR/bin/wormhole-rs" ; popd
  #---------------#
  #x8
  eget "Sh1Yo/x8" --asset "linux" --to "$HOME/bin/x8"
  # attempt to build a static binary produces dynamic anyway  
  # pushd $(mktemp -d) && git clone https://github.com/Sh1Yo/x8 && cd x8
  # export TARGET="x86_64-unknown-linux-gnu"
  # rustup target add "$TARGET"
  # export RUSTFLAGS="-C target-feature=+crt-static" 
  # sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  # echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  # cargo build --target "$TARGET" --release
  # file "./target/$TARGET/release/x8" ; ldd "./target/$TARGET/release/x8" ; ls "./target/$TARGET/release/x8" -lah
  # mv "./target/$TARGET/release/x8" "$HOMR/bin/x8"
  # popd
  #---------------#
  #xurls
  eget "mvdan/xurls" --asset "linux_amd64" --to "$HOME/bin/xurls"
  #---------------#
  #yalis
  pushd $(mktemp -d) && git clone "https://github.com/EatonChips/yalis" && cd yalis
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./yalis" "$HOME/bin/yalis" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #yataf
  pushd $(mktemp -d) && git clone https://github.com/Damian89/yataf && cd yataf
  CGO_ENABLED=0 go build -o "yataf_amd_x86_64_Linux" -v -ldflags="-s -w -extldflags '-static'"
  find . -type f -name '*_Linux' -exec mv {} "$HOME/bin/yataf" \;
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #yq
  eget "mikefarah/yq" --asset "yq_linux_amd64" --asset "^.tar.gz" --to "$HOME/bin/yq"
  #---------------#
  #zdns
  pushd $(mktemp -d) && git clone "https://github.com/zmap/zdns" && cd zdns
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./zdns" "$HOME/bin/zdns" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #https://github.com/zellij-org/zellij
  eget "zellij-org/zellij" --asset "linux" --asset "musl" --asset "x86_64" --asset "^sha256sum" --to "$HOME/bin/zellij"
  #---------------#
  #https://github.com/bvaisvil/zenith
  eget "bvaisvil/zenith" --asset "linux" --asset "musl" --asset "^sha256" --to "$HOME/bin/zenith"
  #---------------#
  #zgrab2
  pushd $(mktemp -d) && git clone "https://github.com/zmap/zgrab2" && cd zgrab2
  CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/zgrab2" ; mv "./zgrab2" "$HOME/bin/zgrab2" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #zoxide
  eget "ajeetdsouza/zoxide" --asset "x86_64-unknown-linux-musl.tar.gz" --to "$HOME/bin/zoxide" && ln -s "$HOME/bin/zoxide" "$HOME/bin/z"
  #---------------#
  #zsh (best to install using conda)
  #eget "romkatv/zsh-bin" --asset "linux-x86_64.tar.gz" --asset "^.asc" --all
#-------------------------------------------------------#  
#EOF
