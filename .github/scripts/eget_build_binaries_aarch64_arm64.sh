#!/usr/bin/env bash

# This should be able to be executed completely in userspace mode only & shouldn't require root access
# Only Dependency is 'curl' or 'wget' 
# Get wget: https://github.com/Azathothas/Static-Binaries/tree/main/wget
# Get Curl: https://github.com/Azathothas/Static-Binaries/tree/main/curl
# Once requirement is satisfied, simply:
# bash <(curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/.github/scripts/eget_binaries_aarch64_arm64.sh")
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
#Download eget
if ! command -v eget &> /dev/null; then
   curl -qfsSL "https://zyedidia.github.io/eget.sh" | bash
   if [ -f "./eget" ]; then
       mv "./eget" "$HOME/bin" && chmod +xwr "$HOME/bin/eget"
   else
      pushd "$(mktemp -d)"
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
  pushd "$(mktemp -d)" && curl -qfsSLJO "https://www.7-zip.org/$(curl -qfsSL "https://www.7-zip.org/download.html" | grep -o 'href="[^"]*"' | sed 's/href="//' | grep 'linux-arm64.tar.xz' | sed 's/"$//' | sort | tail -n 1)"
  find . -type f -name '*.xz' -exec tar -xf {} \;
  find . -type f -name '7zzs' ! -name '*.xz' -exec cp {} "$HOME/bin/7z" \;
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #airiXSS : xss automater
  #eget "ferreiraklet/airixss" --to "$HOME/bin/airixss"
  pushd "$(mktemp -d)" && git clone "https://github.com/ferreiraklet/airixss" && cd "./airixss"
  go mod init "github.com/ferreiraklet/airixss" ; go mod tidy
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./airixss" "$HOME/bin/airixss" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #aix : AIx is a cli tool to interact with Large Language Models (LLM) APIs.  
  eget "projectdiscovery/aix" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/aix"
  #---------------#
  #alist : A file list/WebDAV program that supports multiple storages
  eget "alist-org/alist" --asset "arm" --asset "64" --asset "linux" --asset "musl" --to "$HOME/bin/alist"
  #---------------#
  #alterx : Fast and customizable subdomain wordlist generator using DSL 
  eget "projectdiscovery/alterx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/alterx"
  #---------------#
  #amass : In-depth attack surface mapping and asset discovery 
  #eget "owasp-amass/amass" --asset "arm" --asset "64" --asset "zip" --to "$HOME/bin/amass" && mkdir -p "$HOME/.config/amass"
  pushd "$(mktemp -d)" && git clone "https://github.com/owasp-amass/amass" && cd "./amass"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/amass" ; mv "./amass" "$HOME/bin/amass" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #analyticsrelationships : Get related domains / subdomains by looking at Google Analytics IDs 
  pushd "$(mktemp -d)" && git clone "https://github.com/Josue87/AnalyticsRelationships" && cd "./AnalyticsRelationships"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./analyticsrelationships" "$HOME/bin/analyticsrelationships" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #anew : A tool for adding new lines to files, skipping duplicates 
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/anew" && cd "./anew"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./anew" "$HOME/bin/anew" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #angle-grinder: Slice and dice logs on the command line 
  pushd "$(mktemp -d)" && git clone "https://github.com/rcoh/angle-grinder" && cd "./angle-grinder"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/agrind" "$HOME/bin/agrind" 
  #---------------#
  #aria2c : aria2 is a multi-protocol (HTTP/HTTPS, FTP, SFTP, BitTorrent & Metalink) & multi-source command-line download utility
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/aria2/aria2c_aarch64_arm64_libressl_musl_latest_Linux" --to "$HOME/bin/aria2c"
  #---------------#
  #assetfinder : Find domains and subdomains related to a given domain 
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/assetfinder" && cd "./assetfinder"
  go mod init "github.com/tomnomnom/assetfinder" ; go mod tidy
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./assetfinder" "$HOME/bin/assetfinder" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #assh : 💻 make your ssh client smarter 
  pushd "$(mktemp -d)" && git clone "https://github.com/moul/assh" && cd "./assh"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'"
  mv "./assh" "$HOME/bin/assh" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #asn : ASN / RPKI validity / BGP stats / IPv4v6 / Prefix / URL / ASPath / Organization / IP reputation / IP geolocation / IP fingerprinting / Network recon / lookup API server / Web traceroute server
  eget "https://raw.githubusercontent.com/nitefood/asn/master/asn" --to "$HOME/bin/asn"
  #---------------#
  #asnmap : Mapping organization network ranges using ASN information
  #eget "projectdiscovery/asnmap" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/asnmap"
  pushd "$(mktemp -d)" && git clone "https://github.com/projectdiscovery/asnmap" && cd "./asnmap"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/asnmap" ; mv "./asnmap" "$HOME/bin/asnmap" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #atuin: Sync Shell History
  eget "atuinsh/atuin" --asset "linux" --asset "aarch64" --asset "musl" --to "$HOME/bin/atuin"
  #---------------#
  #b3sum : the official Rust and C implementations of the BLAKE3 cryptographic hash function
  pushd "$(mktemp -d)" && git clone "https://github.com/BLAKE3-team/BLAKE3" && cd "./BLAKE3"
  cd "./b3sum"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/b3sum" "$HOME/bin/b3sum" 
  #---------------#
  #batcat: cat with colors & syntax highlights 
  eget "sharkdp/bat" --asset "aarch" --asset "64" --asset "^amd" --to "$HOME/bin/bat" && ln -s "$HOME/bin/bat" "$HOME/bin/batcat"
  #---------------#
  #Berty : Secure peer-to-peer messaging app that works with or without internet access, cellular data or trust in the network
  pushd "$(mktemp -d)" && git clone "https://github.com/berty/berty" && cd "./berty"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=1 go build -v -ldflags="-s -w -extldflags '-static'" "./go/cmd/berty"
  mv "./berty" "$HOME/bin/berty" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Bandwhich : Terminal bandwidth utilization tool
  pushd "$(mktemp -d)" && git clone "https://github.com/imsnif/bandwhich" && cd "./bandwhich"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/bandwhich" "$HOME/bin/bandwhich"
  #---------------#
  #BinGrep :  like ~~grep~~ UBER, but for binaries 
  pushd "$(mktemp -d)" && git clone "https://github.com/m4b/bingrep" && cd "./bingrep"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/bingrep" "$HOME/bin/bingrep" 
  #---------------#
  #binocle : a graphical tool to visualize binary data 
  pushd "$(mktemp -d)" && git clone "https://github.com/sharkdp/binocle" && cd "./binocle"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/binocle" "$HOME/bin/binocle" 
  #---------------#
  #BoltConn : Transparent and flexible L4/L7 networking manager, supporting WireGuard, firewall and scripted MitM
  pushd "$(mktemp -d)" && git clone "https://github.com/XOR-op/BoltConn" && cd "./BoltConn"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/boltconn" "$HOME/bin/boltconn"
  #---------------#
  #bore : ngrok alternative for making tunnels to localhost 
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/bore/bore_aarch64_arm64_musl_Linux" --to "$HOME/bin/bore"
  #---------------#
  #bottom : htop clone | graphical process/system monitor
  eget "ClementTsang/bottom" --asset "aarch" --asset "64" --asset "musl" --asset "^amd" --asset "^x86" --file "btm" --to "$HOME/bin/bottom"
  #---------------#
  #boringtun-cli : Userspace WireGuard® Implementation in Rust
  pushd "$(mktemp -d)" && git clone "https://github.com/cloudflare/boringtun" && cd "./boringtun"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --bin "boringtun-cli" --target "$TARGET" --release ; mv "./target/$TARGET/release/boringtun-cli" "$HOME/bin/boringtun-cli"
  #---------------#
  #btop : htop clone | A monitor of resources 
  pushd "$(mktemp -d)" && curl -qfsSL $(curl -qfsSL "https://api.github.com/repos/aristocratos/btop/actions/artifacts?per_page=100" -H "Authorization: Bearer $GITHUB_TOKEN" | jq -r '[.artifacts[] | select(.name =="btop-aarch64-linux-musl")] | sort_by(.created_at) | .[].archive_download_url') -H "Authorization: Bearer $GITHUB_TOKEN" -o "btop.zip"  
  unzip "./btop.zip" && find . -type f -name '*btop*' ! -name '*.zip*' -exec mv {} "$HOME/bin/btop" \; && popd
  #---------------#
  #BucketLoot : Automated S3-compatible bucket inspector
  pushd "$(mktemp -d)" && git clone "https://github.com/redhuntlabs/BucketLoot" && cd "./BucketLoot"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./bucketloot" "$HOME/bin/bucketloot" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #busybox : several Unix utilities in a single executable file
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/busybox/busybox_aarch64_arm64_musl_Linux" --to "$HOME/bin/busybox"
  #---------------#
  #byp4xx : 40X/HTTP bypasser in Go. Features: Verb tampering, headers, #bugbountytips, User-Agents, extensions, default credentials
  pushd "$(mktemp -d)" && git clone "https://github.com/lobuhi/byp4xx" && cd "./byp4xx"
  go mod init "github.com/lobuhi/byp4xx" ; go mod tidy
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./byp4xx" "$HOME/bin/byp4xx" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #caddy : Fast and extensible multi-platform HTTP/1-2-3 web server with automatic HTTPS
  eget "caddyserver/caddy" --asset "linux" --asset "arm" --asset "64" --asset "tar.gz" --asset "^amd" --asset "^sig" --to "$HOME/bin/caddy"
  #---------------#
  #cdncheck : A utility to detect various technology for a given IP address. 
  eget "projectdiscovery/cdncheck" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/cdncheck"
  #---------------#
  #cent : Fetch & Organize all Nuclei Templates
  eget "xm1k3/cent" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/cent"
  #---------------#
  #certstream :  Cli for calidog's certstream
  pushd "$(mktemp -d)" && mkdir certstream && cd certstream
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/certstream/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/certstream/go.mod"
  go get github.com/Azathothas/Arsenal/certstream
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./certstream" ; mv "./certstream" "$HOME/bin/certstream" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #cherrybomb : Validating and Testing APIs using an OpenAPI file
  pushd "$(mktemp -d)" && git clone "https://github.com/blst-security/cherrybomb" && cd "./cherrybomb"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/cherrybomb" "$HOME/bin/cherrybomb"
  #---------------#
  #chaos : cli for Chaos DB API
  eget "projectdiscovery/chaos-client" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/chaos-client"
  #---------------#
  #Cloudfox : Automating situational awareness for cloud penetration tests
  #eget "BishopFox/cloudfox" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/cloudfox"
  pushd "$(mktemp -d)" && git clone "https://github.com/BishopFox/cloudfox" && cd "./cloudfox"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./cloudfox" "$HOME/bin/cloudfox" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #cloudlist : Cloudlist is a tool for listing Assets from multiple Cloud Providers.
  eget "projectdiscovery/cloudlist" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/cloudlist"
  #---------------#
  #cloudreve : Self-hosted file management and sharing system, supports multiple storage providers
  eget "cloudreve/Cloudreve" --asset "arm" --asset "64" --asset "linux" --file "cloudreve" --to "$HOME/bin/cloudreve"
  #---------------#
  #comb : Combine the lines from two files in every combination.
  pushd "$(mktemp -d)" && mkdir comb && cd "./comb"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/comb/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/comb/go.mod"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./comb" ; mv "./comb" "$HOME/bin/comb" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #containerd : An open and reliable container runtime
  eget "containerd/containerd" --asset "linux" --asset "static" --asset "arm" --asset "64" --asset "^sha256sum" --to "$HOME/bin/containerd"
  #---------------#
  # Cross-platform Rust rewrite of the GNU coreutils 
  pushd "$(mktemp -d)" && git clone "https://github.com/uutils/coreutils" && cd "./coreutils"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --features unix --release ; mv "./target/$TARGET/release/coreutils" "$HOME/bin/coreutils"
  #---------------#
  #cowtiness : mimic an HTTP server and a DNS server, providing complete responses
  pushd "$(mktemp -d)" && git clone "https://github.com/stolenusername/cowitness" && cd "./cowitness"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'"
  mv "./cowitness" "$HOME/bin/cowitness" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #cpufetch : fetch for cpu
  eget "Dr-Noob/cpufetch" --asset "linux" --asset "arm" --asset "^x86" --asset "64" --to "$HOME/bin/cpufetch"
  #---------------#
  #cri-tools : CLI and validation tools for Kubelet Container Runtime Interface (CRI)
  eget "kubernetes-sigs/cri-tools" --asset "crictl" --asset "linux" --asset "arm" --asset "64" --asset "^sha" --to "$HOME/bin/crictl"
  #---------------#
  #crlfuzz : A fast tool to scan CRLF vulnerability written in Go
  pushd "$(mktemp -d)" && git clone "https://github.com/dwisiswant0/crlfuzz" && cd "./crlfuzz"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/crlfuzz" ; mv "./crlfuzz" "$HOME/bin/crlfuzz" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #croc : Easily and securely send things from one computer to another
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/croc/croc_aarch64_arm64_Linux" --to "$HOME/bin/croc"
  #---------------#
  #crt : A CLI tool to check Certificate Transparency logs of a domain name
  #eget "cemulus/crt" --asset "arm" --asset "64" --to "$HOME/bin/crt"
  pushd "$(mktemp -d)" && git clone "https://github.com/cemulus/crt" && cd "./crt"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./crt" "$HOME/bin/crt" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #csprecon : Discover new target domains using Content Security Policy 
  pushd "$(mktemp -d)" && git clone "https://github.com/edoardottt/csprecon" && cd csprecon
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/csprecon" ; mv "./csprecon" "$HOME/bin/csprecon" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #curl
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/curl/curl_aarch64_arm64_Linux" --to "$HOME/bin/curl"
  #---------------#
  #curlie : The power of curl, the ease of use of httpie. 
  eget "rs/curlie" --asset "linux" --asset "arm" --asset "64" --asset "tar.gz" --to "$HOME/bin/curlie"
  #---------------#
  #cut-cdn : ✂️ Removing CDN IPs from the list of IP addresses
  pushd "$(mktemp -d)" && git clone "https://github.com/ImAyrix/cut-cdn" && cd "./cut-cdn"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./cut-cdn" "$HOME/bin/cut-cdn" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #daktilo : Turn your keyboard into a typewriter! 📇 
    #Errors out :/usr/bin/ld: cannot find -lasound: No such file or directory
    pushd "$(mktemp -d)" && git clone "https://github.com/orhun/daktilo" && cd "./daktilo"
    sudo apt-get install libasound2-dev libxi-dev libxtst-dev -y 
    export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
    sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
    echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
    cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/daktilo" "$HOME/bin/daktilo"
  #---------------#
  #dalfox : 🌙🦊 Dalfox is a powerful open-source XSS scanner and utility focused on automation. 
  eget "hahwul/dalfox" --asset "arm" --asset "64" --to "$HOME/bin/dalfox"
  #---------------#
  #DevBox : Instant, easy, and predictable development environments
  # Requires Nix : curl -qfsSL "https://nixos.org/nix/install" | bash -s -- --daemon
  #   Recommended: curl -qfsSL "https://install.determinate.systems/nix" | bash -s -- install
  eget "jetpack-io/devbox" --asset "linux" --asset "arm" --asset "64" --asset "^amd" --asset "tar.gz" --to "$HOME/bin/devbox"
  #---------------#
  #dirstat-rs : (fastest?) disk usage cli, similar to windirstat. 
  pushd "$(mktemp -d)" && git clone "https://github.com/scullionw/dirstat-rs" && cd "./dirstat-rs"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/ds" "$HOME/bin/ds" ; popd
  #---------------#
  #dns-doctor : Runs dig +trace and dig +norecurse , parses the output, and tries to diagnose some problems
  pushd "$(mktemp -d)" && git clone "https://github.com/jvns/dns-doctor" && cd "./dns-doctor"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./dns-doctor" "$HOME/bin/dns-doctor" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #dnstake : Check missing hosted DNS zones that can lead to subdomain takeover 
  pushd "$(mktemp -d)" && git clone "https://github.com/pwnesia/dnstake" && cd "./dnstake"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/dnstake" ; mv "./dnstake" "$HOME/bin/dnstake" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #dnsx : Multi-purpose DNS toolkit allow to run multiple DNS queries
  eget "projectdiscovery/dnsx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/dnsx"
  #---------------#
  #Dropbear : A smallish SSH server and client
  eget "Azathothas/static-toolbox" --tag "dropbear" --asset "dbclient_aarch64_arm64_Linux" --to "$HOME/bin/dbclient"
  eget "Azathothas/static-toolbox" --tag "dropbear" --asset "dropbear_aarch64_arm64_Linux" --to "$HOME/bin/dropbear"
  eget "Azathothas/static-toolbox" --tag "dropbear" --asset "dropbearconvert_aarch64_arm64_Linux" --to "$HOME/bin/dropbearconvert"
  eget "Azathothas/static-toolbox" --tag "dropbear" --asset "dropbearkey_aarch64_arm64_Linux" --to "$HOME/bin/dropbearkey"
  eget "Azathothas/static-toolbox" --tag "dropbear" --asset "dropbearmulti_aarch64_arm64_Linux" --to "$HOME/bin/dropbearmulti"
  eget "Azathothas/static-toolbox" --tag "dropbear" --asset "dropbearscp_aarch64_arm64_Linux" --to "$HOME/bin/dropbearscp"
  #---------------#
  #doggo : 🐶 Command-line DNS Client for Humans
  eget "mr-karan/doggo" --asset "linux" --asset "arm" --asset "64" --to "$HOME/bin/doggo"
  #---------------#
  #dsieve : Filter and enrich a list of subdomains by level  
  eget "trickest/dsieve" --asset "arm" --asset "64" --to "$HOME/bin/dsieve"
  #---------------#
  #duf : Disk Usage/Free Utility - a better 'df' alternative
  eget "muesli/duf" --asset "linux" --asset "arm" --asset "64" --asset "^x86" --asset ".tar.gz" --to "$HOME/bin/duf"
  #---------------#
  #dust : A more intuitive version of du in rust 
  eget "bootandy/dust" --asset "linux" --asset "musl" --asset "aarch" --asset "^x86" --asset "64" --asset "tar.gz" --to "$HOME/bin/dust"
  #---------------#
  #dysk : A linux utility to get information on filesystems, like df but better  
  pushd "$(mktemp -d)" && curl -qfLJO $(curl -qfsSL "https://api.github.com/repos/Canop/dysk/releases/latest" | jq -r '.assets[].browser_download_url' | grep -i 'dysk' | grep -i 'zip')
  find . -type f -name '*.zip*' -exec unzip -o {} \;
  find . -type f -name '*.md' -exec rm {} \;
  mv "$(find . -type d -name '*aarch64*' -name '*linux*' -name '*musl*')/dysk" "$HOME/bin/dysk" ; popd
  #---------------#
  #eget : Easily install prebuilt binaries from GitHub. 
  eget "zyedidia/eget" --asset "linux" --asset "arm" --asset "64" --asset "^amd" --asset "^86" --to "$HOME/bin/eget"
  #---------------#
  #encode : Encode|Decode input from stdin
  pushd "$(mktemp -d)" && git clone "https://github.com/Brum3ns/encode" && cd "./encode"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/encode" ; mv "./encode" "$HOME/bin/encode" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #enumerepo : List all public repositories for (valid) GitHub usernames
  eget "trickest/enumerepo" --asset "arm" --asset "64" --asset "^x86" --to "$HOME/bin/enumerepo"
  #---------------#
  #eza : A modern replacement for ‘ls’. (Fork of exa)
  pushd "$(mktemp -d)" && git clone "https://github.com/eza-community/eza" && cd "./eza"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/eza" "$HOME/bin/eza"
  #---------------#
  #fblog : Small command-line JSON Log viewer
  pushd "$(mktemp -d)" && git clone "https://github.com/brocode/fblog" && cd "./fblog"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/fblog" "$HOME/bin/fblog"
  #---------------#
  #fclones : Efficient Duplicate File Finder 
  pushd "$(mktemp -d)" && git clone "https://github.com/pkolaczk/fclones" && cd "./fclones"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/fclones" "$HOME/bin/fclones"
  #---------------#
  #fd : A simple, fast and user-friendly alternative to 'find'
  pushd "$(mktemp -d)" && git clone "https://github.com/sharkdp/fd" && cd "./fd"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/fd" "$HOME/bin/fd"
  #---------------#
  #feroxbuster : A fast, simple, recursive content discovery tool written in Rust.
  eget "epi052/feroxbuster" --asset "aarch64" --asset "linux" --asset "zip" --to "$HOME/bin/feroxbuster"
  #---------------#
  #fget : Multithread download for a list of files.
  pushd "$(mktemp -d)" && mkdir fget && cd "./fget"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/fget/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/fget/go.mod"
  go get "github.com/Azathothas/Arsenal/fget"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./fget" ; mv "./fget" "$HOME/bin/fget" ; popd ; go clean -cache -fuzzcache -modcache
  #---------------#
  #Findomain : Subdomains Finder
  eget "Findomain/Findomain" --asset "aarch64" --asset "linux.zip" --to "$HOME/bin/findomain"
  #---------------#
  #fingerprintx : Standalone utility for service discovery on open ports! 
  eget "praetorian-inc/fingerprintx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/fingerprintx"
  #---------------#
  #ffmpeg : Static build of ffmpeg
  eget "eugeneware/ffmpeg-static" --asset "ffmpeg" --asset "linux" --asset "arm64" --asset "^x64" --asset ".gz" --to "$HOME/bin/ffmpeg"
  eget "eugeneware/ffmpeg-static" --asset "ffprobe" --asset "linux" --asset "arm64" --asset "^x64" --asset ".gz" --to "$HOME/bin/ffprobe"
  #---------------#
  #ffuf :  Fast web fuzzer written in Go 
  eget "ffuf/ffuf" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/ffuf"
  #---------------#
  #ffufPostprocessing : Filter ffuf results
  pushd "$(mktemp -d)" && git clone "https://github.com/Damian89/ffufPostprocessing" && cd "./ffufPostprocessing"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./ffufPostprocessing" "$HOME/bin/ffufPostprocessing" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #filebrowser : 📂 Web File Browser
  eget "filebrowser/filebrowser" --asset "linux" --asset "arm" --asset "64" --to "$HOME/bin/filebrowser"
  #---------------#
  #findutils : Rust implementation of findutils 
  pushd "$(mktemp -d)" && git clone "https://github.com/uutils/findutils" && cd "./findutils"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release
  mv "./target/$TARGET/release/find" "$HOME/bin/find-rs"
  mv "./target/$TARGET/release/xargs" "$HOME/bin/xargs-rs"
  #---------------#
  #fuzzuli : URL fuzzing tool that aims to find critical backup files by creating a dynamic wordlist based on the domain.
  pushd "$(mktemp -d)" && git clone "https://github.com/musana/fuzzuli" && cd "./fuzzuli"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./fuzzuli" "$HOME/bin/fuzzuli" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #fzf : 🌸 A command-line fuzzy finder 
  eget "junegunn/fzf" --asset "linux_arm64.tar.gz" --to "$HOME/bin/fzf"
  #---------------#
  #gau : Fetch known URLs from AlienVault's Open Threat Exchange, the Wayback Machine, and Common Crawl. 
  #eget "lc/gau" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/gau"
  pushd "$(mktemp -d)" && git clone "https://github.com/lc/gau" && cd "./gau"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/gau" ; mv "./gau" "$HOME/bin/gau" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gdu : Fast disk usage analyzer with console interface written in Go 
  eget "dundee/gdu" --asset "gdu" --asset "linux" --asset "arm64" --asset "static" --asset "gz" --to "$HOME/bin/gdu"
  #---------------#
  #getJS : A tool to fastly get all javascript sources/files 
  pushd "$(mktemp -d)" && mkdir getJS && cd "./getJS"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/getJS/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/getJS/go.mod"
  go get "github.com/Azathothas/Arsenal/getJS"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./getJS" ; mv "./getJS" "$HOME/bin/getJS" ; popd ; go clean -cache -fuzzcache -modcache
  #---------------#
  #gf : A wrapper around grep
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/gf" && cd "./gf"
  go mod init github.com/tomnomnom/gf ; go mod tidy
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gf" "$HOME/bin/gf" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gfx : Updated gf
  #gfx --> symlinked to gf
  #eget "dwisiswant0/gfx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/gfx" && ln -s "$HOME/bin/gfx" "$HOME/bin/gf"
  pushd "$(mktemp -d)" && git clone "https://github.com/dwisiswant0/gfx" && cd "./gfx"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gfx" "$HOME/bin/gfx" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gh : GitHub’s official command line tool
  eget "cli/cli" --asset "linux" --asset "arm64" --asset "gz" --asset "^86" --to "$HOME/bin/gh"
  #---------------#
  #git-cliff : A highly customizable Changelog Generator that follows Conventional Commit specifications ⛰️
  eget "orhun/git-cliff" --asset "linux" --asset "aarch" --asset "musl" --asset "tar.gz" --asset "^amd" --asset "^sha" --asset "^sig" --file "git-cliff" --to "$HOME/bin/git-cliff"
  #---------------#
  #go-git : A highly extensible Git implementation in pure Go. 
  pushd "$(mktemp -d)" && git clone "https://github.com/go-git/go-git" && cd "./go-git"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "git-clone" "./_examples/clone" ; mv "./git-clone" "$HOME/bin/git-clone"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "git-checkout" "./_examples/checkout" ; mv "./git-checkout" "$HOME/bin/git-checkout"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "git-pull" "./_examples/pull" ; mv "./git-pull" "$HOME/bin/git-pull"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "git-log" "./_examples/log" ; mv "./git-log" "$HOME/bin/git-log"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "git-tag" "./_examples/tag" ; mv "./git-tag" "$HOME/bin/git-tag"
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  # git-lfs : Git extension for versioning large files 
  eget "git-lfs/git-lfs" --asset "linux" --asset "arm" --asset "64" --asset "^amd" --file "git-lfs" --to "$HOME/bin/git-lfs"
  #---------------#
  #gitdorks_go : An automated collection tool for discovering sensitive information on GitHub
  pushd "$(mktemp -d)" && git clone "https://github.com/damit5/gitdorks_go" && cd "./gitdorks_go"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gitdorks_go" "$HOME/bin/gitdorks_go" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #github-endpoints : Find endpoints on GitHub
  pushd "$(mktemp -d)" && git clone "https://github.com/gwen001/github-endpoints" && cd "./github-endpoints"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./github-endpoints" "$HOME/bin/github-endpoints" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #github-regexp : Basically a regexp over a GitHub search
  pushd "$(mktemp -d)" && git clone "https://github.com/gwen001/github-regexp" && cd "./github-regexp"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./github-regexp" "$HOME/bin/github-regexp" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #github-subdomains : Find subdomains on GitHub
  pushd "$(mktemp -d)" && git clone "https://github.com/gwen001/github-subdomains" && cd "./github-subdomains"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./github-subdomains" "$HOME/bin/github-subdomains" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gitlab-subdomains : Find subdomains on Gitlab
  pushd "$(mktemp -d)" && git clone "https://github.com/gwen001/gitlab-subdomains" && cd "./gitlab-subdomains"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gitlab-subdomains" "$HOME/bin/gitlab-subdomains" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gitleaks : Protect and discover secrets using Gitleaks 🔑
  eget "gitleaks/gitleaks" --asset "linux" --asset "arm" --asset "64" --asset "tar.gz" --to "$HOME/bin/gitleaks"
  #---------------#
  #gitui : Blazing 💥 fast terminal-ui for git written in rust 🦀
  eget "extrawurst/gitui" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "gz" --to "$HOME/bin/gitui"
  #---------------#
  #gix : An idiomatic, lean, fast & safe pure Rust implementation of Git
  pushd "$(mktemp -d)" && git clone "https://github.com/Byron/gitoxide" && cd "./gitoxide"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release
  mv "./target/$TARGET/release/ein" "$HOME/bin/ein"
  mv "./target/$TARGET/release/gix" "$HOME/bin/gix"
  #---------------#
  #glow : Render markdown on the CLI
  eget "charmbracelet/glow" --asset "Linux" --asset "arm" --asset "64" --asset "^sbom" --to "$HOME/bin/glow"
  #---------------#
  #gobuster : Directory/File, DNS and VHost busting tool written in Go
  eget "OJ/gobuster" --asset "Linux" --asset "arm" --asset "64" --asset "^x86" --asset "gz" --to "$HOME/bin/gobuster"
  #---------------#
  #godns : A dynamic DNS client tool supports AliDNS, Cloudflare, Google Domains, DNSPod, HE.net & DuckDNS & DreamHost, etc
  eget "TimothyYe/godns" --asset "arm" --asset "64" --asset "^x86" --asset "gz" --to "$HOME/bin/godns"
  #---------------#
  #gofastld : go-fasttld is a high performance effective top level domains (eTLD) extraction module
  pushd "$(mktemp -d)" && git clone "https://github.com/elliotwutingfeng/go-fasttld" && cd "./go-fasttld"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./fasttld" "./cmd/main.go" ; mv "./fasttld" "$HOME/bin/fasttld" ; popd
  #---------------#
  #gofireprox : FireProx written in Go 
  eget "mr-pmillz/gofireprox" --asset "arm" --asset "64" --asset "linux" --asset "^x86" --asset "gz" --to "$HOME/bin/gofireprox"
  #---------------#
  #goop : Dump a git repository from a website, focused on as-complete-as-possible dumps and handling weird edge-cases
  pushd "$(mktemp -d)" && git clone "https://github.com/nyancrimew/goop" && cd "./goop"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./goop" "$HOME/bin/goop" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gorilla : Tool for generating wordlists or extending an existing one using mutations
  pushd "$(mktemp -d)" && git clone "https://github.com/d4rckh/gorilla" && cd "./gorilla"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/gorilla" "$HOME/bin/gorilla" ; popd
  #---------------#
  #gost : GO Simple Tunnel - a simple tunnel written in golang
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/gost/gost_aarch64_arm64_Linux" --to "$HOME/bin/gost"
  #---------------#
  #gotator : Generate DNS wordlists through permutations
  pushd "$(mktemp -d)" && git clone "https://github.com/Josue87/gotator" && cd "./gotator"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gotator" "$HOME/bin/gotator" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gowitness : 🔍 gowitness - a golang, web screenshot utility using Chrome Headless
  #eget "sensepost/gowitness" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/gowitness"
  pushd "$(mktemp -d)" && git clone "https://github.com/sensepost/gowitness" && cd "./gowitness"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./gowitness" "$HOME/bin/gowitness" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #gping : Ping, but with a graph
  eget "orf/gping" --asset "aarch" --asset "64" --asset "linux" --asset "musl" --asset "^x86" --asset "gz" --to "$HOME/bin/gping"
  #---------------#
  #gpg-tui : Manage your GnuPG keys with ease! 🔐
  pushd "$(mktemp -d)" && git clone "https://github.com/orhun/gpg-tui" && cd "./gpg-tui"
  sudo apt-get install libgpgme-dev libx11-dev libxcb-shape0-dev libxcb-xfixes0-dev libxkbcommon-dev -y
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/gpg-tui" "$HOME/bin/gpg-tui"
  #---------------#
  #GRPCurl : Like cURL, but for gRPC: Command-line tool for interacting with gRPC servers 
  pushd "$(mktemp -d)" && git clone "https://github.com/fullstorydev/grpcurl" && cd "./grpcurl"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/grpcurl" ; mv "./grpcurl" "$HOME/bin/grpcurl" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Gxss : A tool to check a bunch of URLs that contain reflecting params
  pushd "$(mktemp -d)" && git clone "https://github.com/KathanP19/Gxss" && cd Gxss
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./Gxss" "$HOME/bin/gxss" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hacker-scoper : Automagically filter URLs with Bug Bounty program scope rules scraped from the internet
  pushd "$(mktemp -d)" && git clone "https://github.com/ItsIgnacioPortal/hacker-scoper" && cd "./hacker-scoper"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hacker-scoper" "$HOME/bin/hacker-scoper" ; popd
  #---------------#
  #hakip2host : takes a list of IP addresses via stdin, then does a series of checks to return associated domain names
  pushd "$(mktemp -d)" && git clone "https://github.com/hakluke/hakip2host" && cd "./hakip2host"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakip2host" "$HOME/bin/hakip2host" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hakoriginfinder : Tool for discovering the origin host behind a reverse proxy
  pushd "$(mktemp -d)" && git clone "https://github.com/hakluke/hakoriginfinder" && cd "./hakoriginfinder" 
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakoriginfinder" "$HOME/bin/hakoriginfinder" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hakrawler : Simple, fast web crawler designed for easy, quick discovery of endpoints and assets within a web application
  pushd "$(mktemp -d)" && git clone "https://github.com/hakluke/hakrawler" && cd "hakrawler"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakrawler" "$HOME/bin/hakrawler" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hakrevdns : Small, fast tool for performing reverse DNS lookups en masse.
  pushd "$(mktemp -d)" && git clone "https://github.com/hakluke/hakrevdns" && cd "./hakrevdns"
  go mod init "github.com/hakluke/hakrevdns" ; go mod tidy
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./hakrevdns" "$HOME/bin/hakrevdns" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #halp : A CLI tool to get help with CLI tools 🐙 
  eget "orhun/halp" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "tar.gz" --asset "^amd" --asset "^sha" --asset "^sig" --file "halp" --to "$HOME/bin/halp"
  #---------------#
  #HEDnsExtractor : Raw html extractor from Hurricane Electric portal
  pushd "$(mktemp -d)" && git clone "https://github.com/HuntDownProject/HEDnsExtractor" && cd HEDnsExtractor
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/hednsextractor" ; mv "./hednsextractor" "$HOME/bin/hednsextractor" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Hexyl: A command-line hex viewer
  pushd "$(mktemp -d)" && git clone "https://github.com/sharkdp/hexyl" && cd "./hexyl"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET"
  export RUSTFLAGS="-C target-feature=+crt-static" ; sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/hexyl" "$HOME/bin/hexyl" ; popd
  #---------------#
  #hrekt: A really fast http prober.
  #eget "ethicalhackingplayground/hrekt" --asset "^exe" --to "$HOME/bin/hrekt"
  pushd "$(mktemp -d)" && git clone "https://github.com/ethicalhackingplayground/hrekt" && cd "./hrekt"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET"
  export RUSTFLAGS="-C target-feature=+crt-static" ; sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/hrekt" "$HOME/bin/hrekt" ; popd
  #---------------#
  #hxn : ⚡ Blazing-fast tool to grab screenshots of your domain list right from terminal
  eget "pwnwriter/haylxon" --asset "aarch" --asset "64" --asset "linux" --asset "musl" --asset "^.sha512" --to "$HOME/bin/hxn"
  #---------------#
  #htmlq : Like jq, but for HTML
  #eget "mgdm/htmlq" --asset "x86_64-linux.tar.gz" --to "$HOME/bin/htmlq"
  pushd "$(mktemp -d)" && git clone "https://github.com/mgdm/htmlq" && cd "./htmlq"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release
  file "./target/$TARGET/release/htmlq" ; ldd "./target/$TARGET/release/htmlq" ; ls "./target/$TARGET/release/htmlq" -lah
  mv "./target/$TARGET/release/htmlq" "$HOME/bin/htmlq" ; popd
  #---------------#
  #httprobe : Take a list of domains and probe for working HTTP and HTTPS servers
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/httprobe" && cd "./httprobe"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./httprobe" "$HOME/bin/httprobe" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #httpx : httpx is a fast and multi-purpose HTTP toolkit that allows running multiple probes
  eget "projectdiscovery/httpx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/httpx"
  #---------------#
  #Hub : A command-line tool that makes git easier to use with GitHub.
  pushd "$(mktemp -d)" && git clone "https://github.com/mislav/hub" && cd "./hub"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'"
  mv "./hub" "$HOME/bin/hub" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #hyperfine : A command-line benchmarking tool
  pushd "$(mktemp -d)" && git clone "https://github.com/sharkdp/hyperfine" && cd "./hyperfine"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release
  file "./target/$TARGET/release/hyperfine" ; ldd "./target/$TARGET/release/hyperfine" ; ls "./target/$TARGET/release/hyperfine" -lah
  mv "./target/$TARGET/release/hyperfine" "$HOME/bin/hyperfine" ; popd
  #---------------#
  #hysp : 📦 An independent package manager that every hacker deserves.
  eget "pwnwriter/hysp" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "tar.gz" --asset "^amd" --asset "^sha" --asset "^sig" --file "hysp" --to "$HOME/bin/hysp"
  #---------------#
  #inscope : filtering URLs and domains supplied on stdin to make sure they meet one of a set of regular expressions
  pushd "$(mktemp -d)" && mkdir inscope && cd "./inscope"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/inscope/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/inscope/go.mod"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./inscope" ; mv "./inscope" "$HOME/bin/inscope" ; popd ; go clean -cache -fuzzcache -modcache -testcache 
  #---------------#
  #iperf3 : A tool for network performance measurement and tuning
  eget "userdocs/iperf3-static" --asset "iperf3" --asset "arm" --asset "64" --asset "^86" --to "$HOME/bin/iperf3"
  #---------------#
  #interactsh-client : An OOB interaction gathering server and client library 
  eget "projectdiscovery/interactsh" --asset "arm" --asset "64" --asset "linux" --asset "interactsh-client" --to "$HOME/bin/interactsh-client"
  #---------------#
  #jaeles : The Swiss Army knife for automated Web Application Testing
  #eget "jaeles-project/jaeles" --asset "linux" --to "$HOME/bin/jaeles"
  pushd "$(mktemp -d)" && git clone "https://github.com/jaeles-project/jaeles" && cd "./jaeles"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./jaeles" "$HOME/bin/jaeles" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #jq : Command-line JSON processor 
  eget "jqlang/jq" --asset "linux" --asset "arm" --asset "64" --to "$HOME/bin/jq"
  #eget "jqlang/jq" --pre-release --tag "jq-1.7rc1" --asset "jq-linux-amd64" --to "$HOME/bin/jq"
  #---------------#
  #just : A handy way to save and run project-specific commands.
  eget "casey/just" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "^amd" --asset "^sha" --to "$HOME/bin/just"
  #---------------#
  #jwthack : 🔩 jwt-hack is tool for hacking / security testing to JWT
  pushd "$(mktemp -d)" && git clone "https://github.com/hahwul/jwt-hack" && cd "./jwt-hack"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./jwt-hack" "$HOME/bin/jwt-hack" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #kanha : 🦚 A web-app pentesting suite written in rust
  eget "pwnwriter/kanha" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "^.sha512" --to "$HOME/bin/kanha"
  #---------------#
  #katana : A next-generation crawling and spidering framework
  #This is dynamic
  eget "projectdiscovery/katana" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/katana"
  #---------------#
  #kondo : Cleans dependencies and build artifacts from your projects.
  pushd "$(mktemp -d)" && git clone "https://github.com/tbillington/kondo" && cd "./kondo"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/kondo" "$HOME/bin/kondo" ; popd
  #---------------#
  #kmon : Linux Kernel Manager and Activity Monitor 🐧💻 
  pushd "$(mktemp -d)" && git clone "https://github.com/orhun/kmon" && cd "./kmon"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/kmon" "$HOME/bin/kmon" ; popd
  #---------------#
  #lazydocker : The lazier way to manage everything docker 
  eget "jesseduffield/lazydocker" --asset "Linux" --asset "arm" --asset "64" --to "$HOME/bin/lazydocker"
  #---------------#
  # lazygit : simple terminal UI for git commands
  eget "jesseduffield/lazygit" --asset "Linux" --asset "arm" --asset "64" --asset "^amd" --file "lazygit" --to "$HOME/bin/lazygit"
  #---------------#
  #linuxwave : Generate music from the entropy of Linux 🐧🎵
  eget "orhun/linuxwave" --asset "linux" --asset "aarch" --asset "64" --asset "tar.gz" --asset "^amd" --asset "^sha" --asset "^sig" --asset "^mac" --file "linuxwave" --to "$HOME/bin/linuxwave"
  #---------------#
  #lit-bb-hack-tools : misc bb tools
  pushd "$(mktemp -d)" && git clone https://github.com/edoardottt/lit-bb-hack-tools && cd "./lit-bb-hack-tools"
  find . -type f -name '*.md' -exec rm {} \;
  find . -maxdepth 1 -type d ! -name '.git*' -exec sh -c 'export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -o "$1/$1_aarch64_arm64_Linux" -v -a -gcflags=all="-l -B -wb=false" -ldflags="-s -w -extldflags '\''-static'\''" "$1/"*' _ {} \;
  find . -type f -name '*_Linux' -exec mv {} "$HOME/bin/" \;
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #logtimer : Enhance your output with a timer / date 
  eget "Eun/logtimer" --asset "linux" --asset "64" --asset "arm" --asset "^x86" --asset "gz" --to "$HOME/bin/logtimer"
  #---------------#
  #machinna : system-info-fetch
  pushd "$(mktemp -d)" && git clone "https://github.com/Macchina-CLI/macchina" && cd "./macchina"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/macchina" "$HOME/bin/macchina" ; popd
  #---------------#
  #mani : CLI tool that helps you manage multiple repositories
  eget "alajmo/mani" --asset "linux" --asset "arm" --asset "64" --asset "^86" --asset "tar.gz" --asset "^amd" --to "$HOME/bin/mani"
  #---------------#
  #mantra :「🔑」A tool used to hunt down API key leaks in JS files and pages 
  pushd "$(mktemp -d)" && git clone "https://github.com/MrEmpy/mantra" && cd "./mantra"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./Mantra" "$HOME/bin/mantra" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #mapcidr : Utility program to perform multiple operations for a given subnet/CIDR ranges
  #eget "projectdiscovery/mapcidr" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/mapcidr"
  pushd "$(mktemp -d)" && git clone "https://github.com/projectdiscovery/mapcidr" && cd "./mapcidr"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/mapcidr" ; mv "./mapcidr" "$HOME/bin/mapcidr" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #massdns : A high-performance DNS stub resolver for bulk lookups and reconnaissance (subdomain enumeration) 
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/massdns/massdns_linux_arm64_aarch64_musl" --to "$HOME/bin/massdns"
  #---------------#
  #mergerfs : A featureful union filesystem 
  eget "trapexit/mergerfs" --asset "arm" --asset "64" --asset "static" --to "$HOME/bin/mergerfs"
  #---------------#
  #mgwls : Combine words from two wordlist files and concatenate them with an optional delimiter
  eget "trickest/mgwls" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/mgwls"
  #---------------#
  #micro : A modern and intuitive terminal-based text editor
  # Learn : https://github.com/zyedidia/micro/blob/master/runtime/help/keybindings.md
  eget "zyedidia/micro" --asset "linux" --asset "arm" --asset "64" --asset "static" --asset "gz" --to "$HOME/bin/micro"
  #---------------#
  #miniserve : CLI tool to serve files and dirs over HTTP
  eget "svenstaro/miniserve" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --to "$HOME/bin/miniserve"
  #---------------#
  #mksub : Generate tens of thousands of subdomain combinations in a matter of seconds 
  eget "trickest/mksub" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/mksub"
  #---------------#
  #mubeng : An incredibly fast proxy checker & IP rotator with ease
  #eget "kitabisa/mubeng" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/mubeng"
  pushd "$(mktemp -d)" && git clone "https://github.com/kitabisa/mubeng" && cd "./mubeng"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/mubeng" ; mv "./mubeng" "$HOME/bin/mubeng" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ncdu : disk usage analyzer
  eget "https://dev.yorhel.nl$(curl -qfsSL https://dev.yorhel.nl/ncdu | awk -F '"' '/aarch64\.tar\.gz/ && /href=/{print $2}' | grep -v 'asc' | sort -u)" --to "$HOME/bin/ncdu"
  #---------------#
  #nerdctl : Docker-compatible CLI for containerd, with support for Compose, Rootless, eStargz, OCIcrypt, IPFS
  eget "containerd/nerdctl" --asset "linux" --asset "arm" --asset "64" --asset "^full" --asset "nerdctl" --to "$HOME/bin/nerdctl"
  #---------------#
  #NetBird : Connects Devices into a single secure private WireGuard®-based mesh network with SSO/MFA and simple access controls
  eget "netbirdio/netbird" --asset "linux" --asset "arm" --asset "64" --asset "tar.gz" --asset "^ui" --file "netbird" --to "$HOME/bin/netbird"
  #---------------#
  #NetMaker : makes networks with WireGuard
  pushd "$(mktemp -d)" && git clone "https://github.com/gravitl/netmaker" && cd "./netmaker"
  #Requires CGO for sqlite
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=1 go build -v -ldflags="-s -w -extldflags '-static'" ; echo -e "\n" && file "./netmaker" && echo -e "\n"
  mv "./netmaker" "$HOME/bin/netmaker"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=1 go build -v -ldflags="-s -w -extldflags '-static'" -o "./nmctl" "./cli" ; echo -e "\n" && file "./nmctl" && echo -e "\n"
  mv "./nmctl" "$HOME/bin/nmctl" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ngrok : External Tunnel to Internal Assets
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/ngrok/ngrok_aarch64_arm64_Linux" --to "$HOME/bin/ngrok"
  #---------------#
  #nmap : port scanner
  eget "Azathothas/static-toolbox" --tag "nmap" --asset "aarch64-portable.tar.gz" --all && mv "./ncat" "./nmap" "./nping" "$HOME/bin"
  #---------------#
  #nmap-formatter : A tool to convert NMAP results to html, csv, json, markdown, graphviz (dot) or sqlite
  #eget "vdjagilev/nmap-formatter" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/nmap-formatter"
  pushd "$(mktemp -d)" && git clone "https://github.com/vdjagilev/nmap-formatter" && cd "./nmap-formatter"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./nmap-formatter" "$HOME/bin/nmap-formatter" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #neofetch : Updated Fork
  eget "https://raw.githubusercontent.com/hykilpikonna/hyfetch/master/neofetch" --to "$HOME/bin/neofetch" ; chmod +xwr "$HOME/bin/neofetch"
  #---------------#
  #notify : stream the output of several tools (or read from a file) and send notifications
  eget "projectdiscovery/notify" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/notify"
  #---------------#
  #nuclei : Fast and customizable vulnerability scanner based on simple YAML based DSL
  eget "projectdiscovery/nuclei" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/nuclei"
  #---------------#
  #oha: HTTP load generator
  eget "hatoo/oha" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/oha"
  #---------------#
  #OneTun: User space WireGuard proxy in Rust
  pushd "$(mktemp -d)" && git clone "https://github.com/aramperes/onetun" && cd "./onetun"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/onetun" "$HOME/bin/onetun"
  #---------------#
  #openrisk : Generates a risk score based on the results of a Nuclei scan
  #eget "projectdiscovery/openrisk" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/openrisk"
  pushd "$(mktemp -d)" && git clone "https://github.com/projectdiscovery/openrisk" && cd "./openrisk"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/openrisk" ; mv "./openrisk" "$HOME/bin/openrisk" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #osmedeus : A Workflow Engine for Offensive Security
  #eget "j3ssie/osmedeus" --asset "linux.zip" --to "$HOME/bin/osmedeus"
  pushd "$(mktemp -d)" && git clone "https://github.com/j3ssie/osmedeus" && cd osmedeus
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./osmedeus" "$HOME/bin/osmedeus" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ouch : Painless compression and decompression in the terminal
  eget "ouch-org/ouch" --asset "linux" --asset "musl" --asset "aarch" --asset "^x86" --asset "64" --asset "tar.gz" --asset "^amd" --file "ouch" --to "$HOME/bin/ouch"
  #---------------#
  #pkgtop : Interactive package manager and resource monitor designed for the GNU/Linux.
  pushd "$(mktemp -d)" && git clone "https://github.com/orhun/pkgtop" && cd "./pkgtop"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/pkgtop.go"
  mv "./pkgtop" "$HOME/bin/pkgtop" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ppfuzz : A fast tool to scan client-side prototype pollution vulnerability
  pushd "$(mktemp -d)" && git clone "https://github.com/dwisiswant0/ppfuzz" && cd "./ppfuzz"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/ppfuzz" "$HOME/bin/ppfuzz" ; popd
  #---------------#
  #pping : tcp ping, tls ping, http ping, icmp ping, dns ping, quic ping
  eget "wzv5/pping" --asset "Linux" --asset "arm" --asset "^x86" --asset "64" --asset "tar.gz" --to "$HOME/bin/pping"
  #---------------#
  #procs : A modern replacement for ps written in Rust
  pushd "$(mktemp -d)" && git clone "https://github.com/dalance/procs" && cd "./procs"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/procs" "$HOME/bin/procs" ; popd
  #---------------#
  #proxify : A versatile and portable proxy for capturing, manipulating, and replaying HTTP/HTTPS traffic on the go
  #eget "projectdiscovery/proxify" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/proxify"
  pushd "$(mktemp -d)" && git clone "https://github.com/projectdiscovery/proxify" && cd "./proxify"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/proxify" ; mv "./proxify" "$HOME/bin/proxify" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #pueue : task management tool for sequential and parallel execution of long-running tasks
  eget "Nukesor/pueue" --asset "linux" --asset "aarch" --asset "64" --asset "^pueued" --to "$HOME/bin/pueue"
  eget "Nukesor/pueue" --asset "linux" --asset "aarch" --asset "64" --asset "pueued" --to "$HOME/bin/pueued"
  #---------------#
  #puredns : fast domain resolver and subdomain bruteforcing tool that can accurately filter out wildcard subdomains and DNS poisoned entries
  eget "d3mondev/puredns" --asset "arm" --asset "64" --to "$HOME/bin/puredns"
  #---------------#
  #Qbittorent-nox : static Single binary for qbittorent
  eget "userdocs/qbittorrent-nox-static" --asset "64" --asset "aarch" --asset "^x86" --asset "^qt" --to "$HOME/bin/qbittorrent-nox"
  #---------------#
  #qsreplace : Accept URLs on stdin, replace all query string values with a user-supplied value 
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/qsreplace" && cd "./qsreplace"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./qsreplace" "$HOME/bin/qsreplace" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #qsv : CSVs sliced, diced & analyzed.
  eget "jqnatividad/qsv" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "^amd" --asset "^sha" --asset "^sig" --file "qsv" --to "$HOME/bin/qsv"
  #rate-limit-checker : Check whether the domain has a rate limit enabled
  pushd "$(mktemp -d)" && mkdir rate-limit-checker && cd "./rate-limit-checker"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/rate-limit-checker/main.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/rate-limit-checker/go.mod"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./rate-limit-checker" ; mv "./rate-limit-checker" "$HOME/bin/rate-limit-checker" ; popd ; go clean -cache -fuzzcache -modcache
  #---------------#
  #rclone : rsync for cloud storage
  eget "rclone/rclone" --asset "arm" --asset "64" --asset "linux" --asset "^amd" --asset "zip" --to "$HOME/bin/rclone"
  #---------------#
  #rescope : A scope generation tool for Burp Suite & ZAP
  # Installton will require placing a /tmp/rescope/configs/avoid.txt
  # mkdir -p "/tmp/rescope/configs" ; curl -qfsSL "https://raw.githubusercontent.com/root4loot/rescope/master/configs/avoid.txt" -o "/tmp/rescope/configs/avoid.txt"
  cd /tmp && git clone "https://github.com/root4loot/rescope" && cd "./rescope"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./rescope" "$HOME/bin/rescope" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #resDNS : Wrapper around [dnsx + puredns + shuffledns] for Efficient DNS Resolution
  eget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/resdns/resdns.sh" --to "$HOME/bin/resdns"
  #---------------#
  #revit : A command-line utility for performing reverse DNS lookups
  pushd "$(mktemp -d)" && git clone "https://github.com/devanshbatham/revit" && cd "./revit"
  rm go.mod ; rm go.sum ; go mod init github.com/devanshbatham/revit ; go mod tidy
  go get github.com/devanshbatham/revit/cmd/revit
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/revit" ; mv "./revit" "$HOME/bin/revit" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ripgen : Rust-based high performance domain permutation generator
  pushd "$(mktemp -d)" && git clone "https://github.com/resyncgg/ripgen" && cd "./ripgen"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/ripgen" "$HOME/bin/ripgen" ; popd
  #---------------#
  #ripgrep
  eget "BurntSushi/ripgrep" --asset "aarch" --asset "64" --asset "^amd" --to "$HOME/bin/rg"
  #---------------#
  #ripgrep-all : ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, etc
  pushd "$(mktemp -d)" && git clone "https://github.com/phiresky/ripgrep-all" && cd "./ripgrep-all"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/rga" "$HOME/bin/rga" ; popd
  #---------------#
  #roboxtractor : Extract endpoints marked as disallow in robots files to generate wordlists
  pushd "$(mktemp -d)" && git clone "https://github.com/Josue87/roboxtractor" && cd "./roboxtractor"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./roboxtractor" "$HOME/bin/roboxtractor" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #rospo : 🐸 Simple, reliable, persistent ssh tunnels with embedded ssh server
  eget "ferama/rospo" --asset "linux" --asset "arm" --asset "64" --asset "^amd" --asset "^sig" --to "$HOME/bin/rospo"
  #---------------#
  #ruff : An extremely fast Python linter and code formatter, written in Rust.
  eget "astral-sh/ruff" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "^amd" --asset "^sha" --to "$HOME/bin/ruff"
  #---------------#
  #runc : CLI tool for spawning and running containers according to the OCI specification
  eget "opencontainers/runc" --asset "arm" --asset "64" --asset "^asc" --to "$HOME/bin/runc"
  #---------------#
  #rush : A cross-platform command-line tool for executing jobs in parallel
  eget "shenwei356/rush" --asset "rush" --asset "linux" --asset "arm" --asset "64" --asset "gz" --to "$HOME/bin/rush"
  #---------------#
  #rustypaste : A minimal file upload/pastebin service.
  pushd "$(mktemp -d)" && git clone "https://github.com/orhun/rustypaste" && cd "./rustypaste"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/rustypaste" "$HOME/bin/rustypaste" ; popd
  #---------------#
  #rustypaste-cli (rpaste) : A CLI tool for rustypaste
  eget "orhun/rustypaste-cli" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "tar.gz" --asset "^amd" --asset "^sha" --asset "^sig" --to "$HOME/bin/rpaste"
  #---------------#
  #Rustscan : 🤖 The Modern Port Scanner 🤖  
  #GH Releases are outdated
  pushd "$(mktemp -d)" && git clone "https://github.com/RustScan/RustScan" && cd "./RustScan"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/rustscan" "$HOME/bin/rustcan" ; popd
  #---------------#
  #sake : 🤖 Task runner for local and remote hosts via ssh & more
  eget "alajmo/sake" --asset "linux" --asset "arm" --asset "64" --asset "gz" --asset "^amd" --to "$HOME/bin/sake"
  #---------------#
  #s3scanner : Scan for misconfigured S3 buckets across S3-compatible APIs
  eget "sa7mon/S3Scanner" --asset "Linux" --asset "arm" --asset "^x86" --asset "64" --asset "gz" --to "$HOME/bin/s3scanner"
  #---------------#
  #scilla : Information Gathering tool - DNS / Subdomains / Ports / Directories enumeration 
  pushd "$(mktemp -d)" && git clone "https://github.com/edoardottt/scilla" && cd "./scilla"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/scilla" ; mv "./scilla" "$HOME/bin/scilla" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #scopegen : Generates .scope compatible format for ScopeView (based on TomNomNom's Inscope)
  pushd "$(mktemp -d)" && mkdir scopegen && cd "./scopegen"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/scopegen/scopegen.go"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/scopegen/go.mod"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "scopegen" "./scopegen.go" ; mv "./scopegen" "$HOME/bin/scopegen" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #scopeview : Slightly revamped vesion of TomNomNom's Inscope that allows custom .scope to be defined using -s or --scope options
  eget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/scopeview/scopeview.sh" --to "$HOME/bin/scopeview"
  #---------------#
  #scp : copies files between hosts on a network using SFTP protocol over ssh
  eget "https://files.serverless.industries/bin/scp.aarch64" --to "$HOME/bin/scp"
  #eget "Azathothas/static-toolbox" --tag "openssh" --asset "scp_aarch64_arm64_Linux" --to "$HOME/bin/scp"
  #---------------#
  #screenfetch : bash neofetch alt
  eget "https://raw.githubusercontent.com/KittyKatt/screenFetch/master/screenfetch-dev" --to "$HOME/bin/screenfetch" ; chmod +xwr "$HOME/bin/screenfetch"
  #---------------#
  #sftp : Dependency for sshd
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "sftp_aarch64_arm64_Linux" --to "$HOME/bin/sftp"
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "sftp_server_aarch64_arm64_Linux" --to "$HOME/bin/sftp-server"
  #eget "https://github.com/Azathothas/Static-Binaries/raw/main/openssh/sftp_server_aarch64_arm64_Linux" --to "$HOME/bin/sftp"
  #---------------#
  #shfmt : A shell parser, formatter, and interpreter with bash support; includes shfmt 
  eget "mvdan/sh" --asset "linux" --asset "arm64" --to "$HOME/bin/shfmt"
  #---------------#
  #shuffledns : MassDNS wrapper written in go
  eget "projectdiscovery/shuffledns" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/shuffledns"
  #---------------#
  #shortscan : An IIS short filename enumeration tool 
  pushd "$(mktemp -d)" && git clone "https://github.com/bitquark/shortscan" && cd "./shortscan"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/shortscan" ; mv "./shortscan" "$HOME/bin/shortscan" 
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/shortutil" ; mv "./shortutil" "$HOME/bin/shortutil"
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #go-simplehttpserver : Go alternative of python SimpleHTTPServer
  pushd "$(mktemp -d)" && git clone "https://github.com/projectdiscovery/simplehttpserver" && cd "./simplehttpserver"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/simplehttpserver" ; mv "./simplehttpserver" "$HOME/bin/go-simplehttpserver" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #smap : a drop-in replacement for Nmap powered by shodan.io
  pushd "$(mktemp -d)" && git clone "https://github.com/s0md3v/Smap" && cd "./Smap"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/smap" ; mv "./smap" "$HOME/bin/smap" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #sns : IIS shortname scanner written in Go 
  pushd "$(mktemp -d)" && git clone "https://github.com/sw33tLie/sns" && cd "./sns"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./sns" "$HOME/bin/sns" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #speedtest-go : CLI and Go API to Test Internet Speed using multiple-servers
  eget "showwin/speedtest-go" --asset "Linux" --asset "arm" --asset "^x86" --asset "64" --asset "gz" --to "$HOME/bin/speedtest-go"
  #---------------#
  #spk : A small OSINT/Recon tool to find CIDRs that belong to a specific organization
  pushd "$(mktemp -d)" && git clone "https://github.com/dhn/spk" && cd "./spk"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -o "spk_aarch64_arm64_Linux" -v -ldflags="-s -w -extldflags '-static'"
  find . -type f -name '*_Linux' -exec mv {} "$HOME/bin/spk" \;
  go clean -cache -fuzzcache -modcache -testcache ; popd
  #---------------#
  #spoofdpi : A simple and fast anti-censorship tool written in Go
  pushd "$(mktemp -d)" && git clone "https://github.com/xvzc/SpoofDPI" && cd "./SpoofDPI"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/spoof-dpi"
  mv "./spoof-dpi" "$HOME/bin/spoof-dpi" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #ssh
  eget "https://files.serverless.industries/bin/ssh.aarch64" --to "$HOME/bin/ssh"
  #eget "Azathothas/static-toolbox" --tag "openssh" --asset "ssh_aarch64_arm64_Linux" --to "$HOME/bin/ssh"
  #---------------#
  #ssh-add : adds RSA or DSA identities to the authentication agent ssh-agent
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "ssh-add_aarch64_arm64_Linux" --to "$HOME/bin/ssh-add"
  #---------------#
  #ssh-agent : OpenSSH authentication agent
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "ssh-agent_aarch64_arm64_Linux" --to "$HOME/bin/ssh-agent"
  #---------------#
  #ssh-keygen : OpenSSH authentication key utility
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "ssh-keygen_aarch64_arm64_Linux" --to "$HOME/bin/ssh-keygen"
  #---------------#
  #ssh-keyscan : gather SSH public keys from servers
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "ssh-keyscan_aarch64_arm64_Linux" --to "$HOME/bin/ssh-keyscan"
  #---------------#
  #ssh-keysign : OpenSSH helper for host-based authentication
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "ssh-keysign_aarch64_arm64_Linux" --to "$HOME/bin/ssh-keysign"
  #---------------#
  #sshd
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "sshd_aarch64_arm64_Linux" --to "$HOME/bin/sshd"
  #eget "https://github.com/Azathothas/Static-Binaries/raw/main/openssh/sshd_aarch64_arm64_Linux" --to "$HOME/bin/sshd"
  #---------------#
  #sshd_config
  eget "Azathothas/static-toolbox" --tag "openssh" --asset "sshd_config_aarch64_arm64_Linux" --to "$HOME/bin/sshd_config"
  #eget "https://raw.githubusercontent.com/Azathothas/Static-Binaries/main/openssh/sshd_config_aarch64_arm64_Linux" --to "$HOME/bin/sshd_config"
  #---------------#
  #sshesame : SSH honeypot, a fake SSH server that lets anyone in and logs their activity
  pushd "$(mktemp -d)" && git clone "https://github.com/jaksi/sshesame" && cd "./sshesame"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'"
  mv "./sshesame" "$HOME/bin/sshesame" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #sshkeys : Get all ssh public keys of a ssh server
  eget "Eun/sshkeys" --asset "linux" --asset "arm" --asset "64" --asset "gz" --to "$HOME/bin/sshkeys"
  #---------------#
  #sshportal : Embedded SSH Server & Client meant for temp ssh access using invite codes
  pushd "$(mktemp -d)" && git clone "https://github.com/moul/sshportal" && cd "./sshportal"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'"
  mv "./sshportal" "$HOME/bin/sshportal" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #starship : ☄🌌️ The minimal, blazing-fast, and infinitely customizable prompt for any shell! 
  eget "starship/starship" --asset "aarch" --asset "64" --asset "^amd" --to "$HOME/bin/starship"
  #---------------#
  #sttr : cli app to perform various operations on string
  eget "abhimanyu003/sttr" --asset "arm" --asset "64" --asset "tar.gz" --to "$HOME/bin/sttr"
  #---------------#
  #strace : diagnostic, debugging and instructional userspace utility for Linux 
  eget "Azathothas/static-toolbox" --tag "strace" --asset "aarch" --asset "64" --to "$HOME/bin/strace"
  #---------------#
  #subfinder : Fast passive subdomain enumeration tool
  eget "projectdiscovery/subfinder" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/subfinder"
  #---------------#
  #subjs : Fetches javascript file from a list of URLS or subdomains
  pushd "$(mktemp -d)" && git clone "https://github.com/lc/subjs" && cd "./subjs"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./subjs" "$HOME/bin/subjs" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #subxtract : Public-Suffix based TLDs (Top-Level-Domains) & Root Domain Extractor
  eget "https://raw.githubusercontent.com/Azathothas/Arsenal/main/subxtract/subxtract.sh" --to "$HOME/bin/subxtract"
  #---------------#
  #surf : filter a list of hosts, returning a list of viable SSRF candidates
  pushd "$(mktemp -d)" && git clone "https://github.com/assetnote/surf" && cd "./surf"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/surf" ; mv "./surf" "$HOME/bin/surf" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #systemctl-tui : A fast, simple TUI for interacting with systemd services and their logs
  pushd "$(mktemp -d)" && git clone "https://github.com/rgwood/systemctl-tui" && cd "./systemctl-tui"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/systemctl-tui" "$HOME/bin/systemctl-tui"
  #---------------#
  #systeroid : A more powerful alternative to sysctl(8) with a terminal user interface 🐧 
  eget "orhun/systeroid" --asset "linux" --asset "aarch" --asset "64" --asset "musl" --asset "tar.gz" --asset "^amd" --asset "^sha" --asset "^sig" --file "systeroid" --to "$HOME/bin/systeroid"
  #tailscale : The easiest, most secure way to use WireGuard and 2FA
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/tailscale/tailscale_aarch64_arm64_Linux" --to "$HOME/bin/tailscale"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/tailscale/tailscale_merged_aarch64_arm64_Linux" --to "$HOME/bin/tailscale_merged"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/tailscale/tailscaled_aarch64_arm64_Linux" --to "$HOME/bin/tailscaled"
  #---------------#
  #tailspin : 🌀 A log file highlighter 
  pushd "$(mktemp -d)" && git clone "https://github.com/bensadeh/tailspin" && cd "./tailspin"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ;export RUSTFLAGS="-C target-feature=+crt-static"
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/tspin" "$HOME/bin/tailspin" ; popd
  #---------------#
  #tere : Terminal Dir Navigator
  eget "mgunyho/tere" --asset "^x86" --asset "aarch" --asset "64" --asset "musl" --asset "zip" --to "$HOME/bin/tere"
  #---------------#
  #tlsx : Fast and configurable TLS grabber focused on TLS based data collection
  eget "projectdiscovery/tlsx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/tlsx"
  #---------------#
  #tmate : Instant Terminal Sharing
  eget "tmate-io/tmate" --asset "linux" --asset "arm" --asset "64" --asset "^symbol" --to "$HOME/bin/tmate"
  #---------------#
  #tok : word string splitter
  pushd "$(mktemp -d)" && mkdir tok && cd "./tok"
  curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/tok/main.go" ; curl -qfsSLJO "https://raw.githubusercontent.com/Azathothas/Arsenal/main/tok/go.mod"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./tok" ; mv "./tok" "$HOME/bin/tok" ; popd ; go clean -cache -fuzzcache -modcache -testcache 
  #---------------#
  #tokei : displays statistics & number of files for code files/dirs
  eget "XAMPPRocky/tokei" --asset "aarch" --asset "64" --asset "^amd" --to "$HOME/bin/tokei"
  #---------------#
  #toybox : minimal busybox
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/toybox/toybox_arm64_aarch64_Linux" --to "$HOME/bin/toybox"
  #---------------#
  #trufflehog : Find and verify credentials
  eget "trufflesecurity/trufflehog" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/trufflehog"
  #---------------#
  #twingate : programmatically deploy and maintain a zero trust approach to infrastructures
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_client_aarch64_arm64_dynamic_Linux" --to "$HOME/bin/twingate-client"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_connector_aarch64_arm64_dynamic_Linux" --to "$HOME/bin/twingate-connector"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_connectorctl_aarch64_arm64_dynamic_Linux" --to "$HOME/bin/twingate-connectorctl"
  eget "https://github.com/Azathothas/Static-Binaries/raw/main/twingate/twingate_notifier_aarch64_arm64_dynamic_Linux" --to "$HOME/bin/twingate-notifier"
  #---------------#
  #udpx : a single-packet UDP port scanner
  pushd "$(mktemp -d)" && git clone "https://github.com/nullt3r/udpx" && cd "./udpx"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/udpx" ; mv "./udpx" "$HOME/bin/udpx" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #uncover : Quickly discover exposed hosts on the internet using multiple search engines
  eget "projectdiscovery/uncover" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/uncover"
  #---------------#
  #unfurl : Pull out bits of URLs provided on stdin 
  #eget "tomnomnom/unfurl" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/unfurl"
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/unfurl" && cd "./unfurl"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./unfurl" "$HOME/bin/unfurl" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #upx : Ultimate Packer for eXecutables
  eget "upx/upx" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/upx"
  #---------------#
  #validtoml : simple toml validitor
  pushd "$(mktemp -d)" && git clone "https://github.com/martinlindhe/validtoml" && cd "./validtoml"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'"
  mv "./validtoml" "$HOME/bin/validtoml" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #vegeta : HTTP load testing tool and library
  eget "tsenart/vegeta" --asset "linux" --asset "arm" --asset "64" --asset "tar.gz" --asset "^amd" --to "$HOME/bin/vegeta"
  #---------------#
  #vhs: CLI home video recorder 📼 
  eget "charmbracelet/vhs" --asset "Linux" --asset "arm" --asset "64" --asset "^sbom" --asset "vhs" --to "$HOME/bin/vhs"
  #---------------#
  #viddy : 👀 A modern watch command. Time machine and pager etc. 
  eget "sachaos/viddy" --asset "Linux" --asset "arm" --asset "64" --to "$HOME/bin/viddy"
  #---------------#
  #vopono : Run applications through VPN tunnels with temporary network namespaces
  eget "jamesmcm/vopono" --asset "linux" --asset "aarch" --asset "^x86" --asset "64" --asset "musl" --asset "^deb" --asset "^rpm" --to "$HOME/bin/vopono"
  #wadl-dumper : Dump all available paths and/or endpoints on WADL file
  pushd "$(mktemp -d)" && git clone "https://github.com/dwisiswant0/wadl-dumper" && cd "./wadl-dumper"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./wadl-dumper" "$HOME/bin/wadl-dumper" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #wappalyzergo (Just a library not cli)
  #eget "projectdiscovery/wappalyzergo" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/wappalyzergo"
  #---------------#
  #watchexec : Executes commands in response to file modifications 
  #https://github.com/watchexec/watchexec
  eget "watchexec/watchexec" --asset "aarch64" --asset "linux" --asset "musl" --asset "tar.xz" --asset "^sha" --asset "^sig" --asset "^b3" --to "$HOME/bin/watchexec"
  #---------------#
  #waybackrobots : Enumerate old versions of robots.txt paths using Wayback Machine for content discovery
  pushd "$(mktemp -d)" && git clone "https://github.com/mhmdiaa/waybackrobots" && cd "./waybackrobots"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./waybackrobots" "$HOME/bin/waybackrobots" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #waybackurls : Fetch all the URLs that the Wayback Machine knows about for a domain
  # pre made is static
  #eget "tomnomnom/waybackurls" --asset "arm" --asset "64" --asset "linux" --to "$HOME/bin/waybackurls"
  pushd "$(mktemp -d)" && git clone "https://github.com/tomnomnom/waybackurls" && cd "./waybackurls"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./waybackurls" "$HOME/bin/waybackurls"
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #Web-Cache-Vulnerability-Scanner : CLI tool for testing for web cache poisoning
  pushd "$(mktemp -d)" && git clone "https://github.com/Hackmanit/Web-Cache-Vulnerability-Scanner" && cd "./Web-Cache-Vulnerability-Scanner"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./Web-Cache-Vulnerability-Scanner" "$HOME/bin/web-cache-vulnerability-scanner" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #WebSocat : netcat (or curl) for ws:// with advanced socat-like functions
  eget "vi/websocat" --asset "^86" --asset "64" --asset "linux" --asset "musl" --asset "aarch" --asset "max" --to "$HOME/bin/websocat"
  #---------------#
  #WireGuard-go : Go Implementation of WireGuard
  pushd "$(mktemp -d)" && git clone "https://git.zx2c4.com/wireguard-go" && cd "./wireguard-go"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" -o "./wireguard-go"
  mv "./wireguard-go" "$HOME/bin/wireguard-go" ; popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #WireGuard-rs : Rust Implementation of WireGuard
  pushd "$(mktemp -d)" && git clone "https://git.zx2c4.com/wireguard-rs" && cd "./wireguard-rs"
  export TARGET="aarch64-unknown-linux-musl" ; export RUSTFLAGS="-C target-feature=+crt-static" ; rustup target add "$TARGET" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml"  
  echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/wireguard-rs" "$HOME/bin/wireguard-rs"
  #---------------#
  #WireProxy : Wireguard client that exposes itself as a socks5 proxy
  eget "pufferffish/wireproxy" --asset "linux" --asset "arm" --asset "^amd" --asset "64" --asset "tar.gz" --to "$HOME/bin/wireproxy"
  #---------------#
  #WireTap: ransparent, VPN-like proxy server that tunnels traffic via WireGuard and requires no special privileges to run
  eget "sandialabs/wiretap" --asset "linux" --asset "arm" --asset "64" --asset "tar.gz" --to "$HOME/bin/wiretap"
  #---------------#
  #wormhole-rs : Rust implementation of Magic Wormhole, with new features and enhancements
  pushd "$(mktemp -d)" && git clone "https://github.com/magic-wormhole/magic-wormhole.rs" && cd "./magic-wormhole.rs"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/wormhole-rs" "$HOME/bin/wormhole-rs" ; popd
  #---------------#
  #xurls : Extract urls from text 
  eget "mvdan/xurls" --asset "linux" --asset "arm64" --to "$HOME/bin/xurls"
  #---------------#
  #yalis : Yet Another LinkedIn Scraper 
  pushd "$(mktemp -d)" && git clone "https://github.com/EatonChips/yalis" && cd "./yalis"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./yalis" "$HOME/bin/yalis" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #yataf : yataf extracts secrets and paths from files or urls - its best used against javascript files 
  pushd "$(mktemp -d)" && git clone "https://github.com/Damian89/yataf" && cd "./yataf"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -o "yataf_aarch64_arm64_Linux" -v -ldflags="-s -w -extldflags '-static'"
  find . -type f -name '*_Linux' -exec mv {} "$HOME/bin/yataf" \;
  popd ; go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #yj: Convert between YAML, TOML, JSON, and HCL
  pushd "$(mktemp -d)" && git clone "https://github.com/sclevine/yj" && cd "./yj"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ;  mv "./yj" "$HOME/bin/yj" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #yq : portable command-line YAML, JSON, XML, CSV, TOML and properties processor
  eget "mikefarah/yq" --asset "yq" --asset "linux" --asset "arm64" --asset "^.tar.gz" --to "$HOME/bin/yq"
  #---------------#
  #zdns : Fast CLI DNS Lookup Tool 
  pushd "$(mktemp -d)" && git clone "https://github.com/zmap/zdns" && cd "./zdns"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" ; mv "./zdns" "$HOME/bin/zdns" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #zellij : A terminal workspace with batteries included
  eget "zellij-org/zellij" --asset "linux" --asset "musl" --asset "aarch" --asset "64" --asset "^sha256sum" --to "$HOME/bin/zellij"
  #---------------#
  #zenith : sort of like top or htop but with zoom-able charts, CPU, GPU, network, and disk usage
  pushd "$(mktemp -d)" && git clone "https://github.com/bvaisvil/zenith" && cd "./zenith"
  export TARGET="aarch64-unknown-linux-musl" ; rustup target add "$TARGET" ; export RUSTFLAGS="-C target-feature=+crt-static" 
  sed '/^\[profile\.release\]/,/^$/d' -i "./Cargo.toml" ; echo -e '\n[profile.release]\nstrip = true\nopt-level = "z"\nlto = true' >> "./Cargo.toml"
  cross build --target "$TARGET" --release ; mv "./target/$TARGET/release/zenith" "$HOME/bin/zenith" ; popd
  #---------------#
  #zgrab2 : Fast Go Application Scanner 
  pushd "$(mktemp -d)" && git clone "https://github.com/zmap/zgrab2" && cd "./zgrab2"
  export GOOS=linux ; export GOARCH=arm64 ; CGO_ENABLED=0 go build -v -ldflags="-s -w -extldflags '-static'" "./cmd/zgrab2" ; mv "./zgrab2" "$HOME/bin/zgrab2" ; popd
  go clean -cache -fuzzcache -modcache -testcache
  #---------------#
  #zoxide : A smarter cd command.
  eget "ajeetdsouza/zoxide" --asset "aarch" --asset "64" --asset "^amd" --to "$HOME/bin/zoxide" && ln -s "$HOME/bin/zoxide" "$HOME/bin/z"
  #---------------#
  #zsh (best to install using conda)
  #eget "romkatv/zsh-bin" --asset "linux-x86_64.tar.gz" --asset "^.asc" --all
#-------------------------------------------------------#  
#EOF
