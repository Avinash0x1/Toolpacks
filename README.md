<!-- This can be changed -->
<p align="center">
    <a href="https://github.com/Azathothas/Toolpacks">
        <img src="https://github.com/Azathothas/Toolpacks/assets/58171889/d226c553-1835-464c-8908-fe293d3aac3c" width="100"></a>
    <br>
    <b><strong> <a href="https://github.com/Azathothas/Toolpacks">Statically Compiled Binaries</a></code></strong></b>
    <br>
  <img src="https://github.com/Azathothas/Toolpacks/assets/58171889/dbb447ce-19f9-4a3a-8b56-b21eeba470d7" width="200" />
</p>

#### Contents
> - [**🔽 Download 🔽**](https://github.com/Azathothas/Toolpacks/tree/main#-download-)
> > - [**`📦Linux x86_64📦`**](https://github.com/Azathothas/Toolpacks/tree/main#linux-amd-x86_64) 
> > - [**`📦Linux aarch64📦`**](https://github.com/Azathothas/Toolpacks/tree/main#linux-aarch64_arm64)
> > - [**`📦Android arm64-v8a📦`**](https://github.com/Azathothas/Toolpacks/tree/main#android-arm64-v8a)
> - [**📦 Status 🔖**](https://github.com/Azathothas/Toolpacks/tree/main#-status-)
> - [**🚧 Security ⚙️**](https://github.com/Azathothas/Toolpacks#-security-%EF%B8%8F)
---
<!-- DO NOT CHANGE -->
- #### 📦 Status 🔖
| 🧰 Architecture 🧰 | 📦 Total Binaries 📦 | 🇨🇭 WorkFlows 🇨🇭 |
|---------------------|-----------------------|-----------------|
|[ **Android `arm64-v8a`**](https://github.com/Azathothas/Toolpacks/tree/main/aarch64_arm64_v8a_Android)|0| [![📱 Android Package 📦🗄️](https://github.com/Azathothas/Toolpacks/actions/workflows/build_fetch_weekly_toolpack_aarch64_arm64_v8a_Android.yaml/badge.svg)](https://github.com/Azathothas/Toolpacks/actions/workflows/build_fetch_weekly_toolpack_aarch64_arm64_v8a_Android.yaml)|
|[ **Linux `amd // x86_64`**](https://github.com/Azathothas/Toolpacks/tree/main/x86_64)|0| [![🛍️ Build ⚙️ Weekly (toolpack_x86_64) Binaries 📦🗄️](https://github.com/Azathothas/Toolpacks/actions/workflows/build_weekly_toolpack_x86_64.yaml/badge.svg)](https://github.com/Azathothas/Toolpacks/actions/workflows/build_weekly_toolpack_x86_64.yaml)|
|[ **Linux `aarch64 // arm64`**](https://github.com/Azathothas/Toolpacks/tree/main/aarch64_arm64)|0| [![🛍️ Build ⚙️ Weekly (toolpack_aarch64_arm64) Binaries 📦🗄️](https://github.com/Azathothas/Toolpacks/actions/workflows/build_weekly_toolpack_aarch64_arm64.yaml/badge.svg)](https://github.com/Azathothas/Toolpacks/actions/workflows/build_weekly_toolpack_aarch64_arm64.yaml)|

> - Raw **`metadata`** containing info for _all packages_ is available as [**`json`**](https://github.com/metis-os/hysp-pkgs/blob/main/data/metadata.json) & [**`toml`**](https://github.com/metis-os/hysp-pkgs/blob/main/data/metadata.toml) --> [metis-os/hysp-pkgs](https://github.com/metis-os/hysp-pkgs/tree/main/data)
---
#### 🔽 Download 🔽
> ℹ️ Recommended ℹ️ : Use [**`Hysp`**](https://github.com/pwnwriter/hysp) if you want to skip everything below, since hysp already [uses this repo as it's source.](https://github.com/metis-os/hysp-pkgs)
> 1. Install [**`eget`**](https://github.com/zyedidia/eget)
> > ```bash
> > #--------------------------------------------------------------------------------------------#
> > ❯ amd || x86_64 (Linux) 
> > 
> > !# As $USER
> > mkdir -p "$HOME/bin" ; export PATH="$HOME/bin:$PATH"
> > curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/eget" -o "$HOME/bin/eget" && chmod +xwr "$HOME/bin/eget"
> > wget -q "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/eget" -O "$HOME/bin/eget" && chmod +xwr "$HOME/bin/eget"
> > 
> > !# As ROOT
> > sudo curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/eget" -o "/usr/local/bin/eget" && sudo chmod +xwr "/usr/local/bin/eget"
> > sudo wget -q "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/eget" -O "/usr/local/bin/eget" && sudo chmod +xwr "/usr/local/bin/eget"
> > #--------------------------------------------------------------------------------------------#
> > 
> > #--------------------------------------------------------------------------------------------#
> > ❯ arm64 || aarch64 (Linux) 
> > 
> > !# As $USER
> > mkdir -p "$HOME/bin" ; export PATH="$HOME/bin:$PATH"
> > curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/eget" -o "$HOME/bin/eget" && chmod +xwr "$HOME/bin/eget"
> > wget -q "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/eget" -O "$HOME/bin/eget" && chmod +xwr "$HOME/bin/eget"
> > 
> > !# As ROOT
> > sudo curl -qfsSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/eget" -o "/usr/local/bin/eget" && sudo chmod +xwr "/usr/local/bin/eget"
> > sudo wget -q "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/eget" -O "/usr/local/bin/eget" && sudo chmod +xwr "/usr/local/bin/eget"
> > #--------------------------------------------------------------------------------------------#
> >
> > #--------------------------------------------------------------------------------------------#
> > ❯ arm64-v8a (Android) 
> > 
> > !# As $USER (TERMUX)
> > # $PREFIX:/data/data/com.termux/files/usr
> > curl -qfSL "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64_v8a_Android/eget" -o "$PREFIX/bin/eget" && chmod +xwr "$PREFIX/bin/eget"
> > wget -q "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64_v8a_Android/eget" -O "$PREFIX/bin/eget" && chmod +xwr "$PREFIX/bin/eget"
> > !# Root requires remounting /system/bin as RWR (NOT RECOMMENDED)
> > #--------------------------------------------------------------------------------------------#
> > ```
> 2. Install **`7z`**
> > ```bash
> > #--------------------------------------------------------------------------------------------#
> > ❯ amd || x86_64 (Linux) 
> > 
> > !# As $USER
> > eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/7z" --to "$HOME/bin/7z"
> > 
> > !# As ROOT
> > sudo eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/7z" --to "/usr/local/bin/7z"
> > #--------------------------------------------------------------------------------------------#
> > 
> > #--------------------------------------------------------------------------------------------#
> > ❯ arm64 || aarch64 (Linux) 
> > 
> > !# As $USER
> > eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/7z" --to "$HOME/bin/7z"
> > 
> > !# As ROOT
> > sudo eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/7z" --to "/usr/local/bin/7z"
> > ```
> ---
> - #### [**Linux `amd x86_64`**](https://github.com/Azathothas/Toolpacks/tree/main/x86_64)
> ```bash
> #--------------------------------------------------------------------------------------------#
> ❯ Single/Individual Binaries
> 
> !# $USER
> eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/$BINARY_NAME" --to "$HOME/bin"
>
> !# ROOT
> sudo eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/x86_64/$BINARY_NAME" --to "/usr/local/bin"
> 
> #--------------------------------------------------------------------------------------------#
> ❯ Everything All at once
> !# $USER
> !#Download .7z archive
>  wget "$(curl -qfsSL "https://api.github.com/repos/Azathothas/Toolpacks/releases" | jq -r '.[] | select(.assets[].name | contains("x86_64")) | .assets[].browser_download_url' | grep -i '.7z$' | sort -u | tail -n 1)" -O "./toolpack_x86_64.7z"
> 
> !# $USER
>  mkdir -p "$HOME/bin" ; 7z e "./toolpack_x86_64.7z" -o"$HOME/bin" -y && rm -rf "$HOME/bin/toolpack_x86_64" 2>/dev/null && rm -rf "./toolpack_x86_64.7z" ; chmod +xwr $HOME/bin/*
> 
> !# ROOT
>  sudo 7z e "./toolpack_x86_64.7z" -o"/usr/local/bin" -y && sudo rm -rf "/usr/local/bin/toolpack_x86_64" 2>/dev/null && rm -rf "./toolpack_x86_64.7z" ; sudo chmod +xwr /usr/local/bin/* 2>/dev/null
> #--------------------------------------------------------------------------------------------#
> ```
> ---
> - #### [**Linux `aarch64_arm64`**](https://github.com/Azathothas/Toolpacks/tree/main/aarch64_arm64)
> ```bash
> #--------------------------------------------------------------------------------------------#
> ❯ Single/Individual Binaries
> 
> !# $USER
> eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/$BINARY_NAME" --to "$HOME/bin"
>
> !# ROOT
> sudo eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64/$BINARY_NAME" --to "/usr/local/bin"
> 
> #--------------------------------------------------------------------------------------------#
> ❯ Everything All at once
> !# $USER
> !#Download .7z archive
>  wget "$(curl -qfsSL "https://api.github.com/repos/Azathothas/Toolpacks/releases" | jq -r '.[] | select(.assets[].name | contains("aarch64_arm64")) | .assets[].browser_download_url' | grep -i '.7z$' | sort -u | tail -n 1)" -O "./toolpack_aarch64_arm64.7z"
> 
> !# $USER
>  mkdir -p "$HOME/bin" ; 7z e "./toolpack_aarch64_arm64.7z" -o"$HOME/bin" -y && rm -rf "$HOME/bin/toolpack_aarch64_arm64" 2>/dev/null && rm -rf "./toolpack_aarch64_arm64.7z" ; chmod +xwr $HOME/bin/*
> 
> !# ROOT
>  sudo 7z e "./toolpack_aarch64_arm64.7z" -o"/usr/local/bin" -y && sudo rm -rf "/usr/local/bin/toolpack_aarch64_arm64" 2>/dev/null && rm -rf "./toolpack_aarch64_arm64.7z" ; sudo chmod +xwr /usr/local/bin/* 2>/dev/null
> #--------------------------------------------------------------------------------------------#
> ```
> ---
> - #### [**Android `arm64-v8a`**](https://github.com/Azathothas/Toolpacks/tree/main/aarch64_arm64_v8a_Android)
> ```bash
> #--------------------------------------------------------------------------------------------#
> ❯ Single/Individual Binaries
>
> eget "https://raw.githubusercontent.com/Azathothas/Toolpacks/main/aarch64_arm64_v8a_Android/$BINARY_NAME" --to "$PREFIX/bin/$BINARY_NAME"
> 
> #--------------------------------------------------------------------------------------------#
> ❯ Everything All at once
>
> !# Create tmp dir
> pushd "$(mktemp -d)"
> !# Download all bins
> for url in $(curl -qfsSL "https://api.github.com/repos/Azathothas/Toolpacks/contents/aarch64_arm64_v8a_Android" -H "Accept: application/vnd.github.v3+json" | jq -r '.[].download_url'); do echo -e "\n[+] $url\n" && curl -qfLJO "$url"; done
> !# Move all to "$PREFIX/bin"
> # $PREFIX=/data/data/com.termux/files/usr
> find . -maxdepth 1 -type f ! -name '*.md' -exec mv {} "$PREFIX/bin/" \; 2>/dev/null
> #chmod
> chmod +xwr $PREFIX/bin/*
> #list
> ls "$PREFIX/bin" | column -t ; popd
> #--------------------------------------------------------------------------------------------#
> ```
---
- #### 🚧 Security ⚙️
It is _never a good idea_ to **install random binaries** from **random sources**. 
- Check these `HackerNews Discussions`
> - [A cautionary tale from the decline of SourceForge](https://news.ycombinator.com/item?id=31110206)
> - [Downloading PuTTY Safely Is Nearly Impossible (2014)](https://news.ycombinator.com/item?id=9577861)
- Reasons to **Trust this Repo**
> - All the [Build Scripts](https://github.com/Azathothas/Toolpacks/tree/main/.github/scripts) & [workflows](https://github.com/Azathothas/Toolpacks/tree/main/.github/workflows) are completely open-source. You are free to audit & scrutinize everything.
> ```bash
> # Everything is automated via Github Actions & Build Scripts
> WorkFlows --> https://github.com/Azathothas/Toolpacks/tree/main/.github/workflows
> Build Scripts --> https://github.com/Azathothas/Toolpacks/tree/main/.github/scripts
> ```
> - Both `SHA256SUM` & `BLAKE3SUM` are automatically generated right after build script finishes.
- Reasons **NOT to trust this Repo**
> - Repos that already publish pre-compiled static binaries, nothing is changed. You can compare checksums.
> - However, for repos that don't publish releases or at least not statically linked binaries, there is ***no way for you to end up with the same binary even when you use the same build scripts***. In this case, `checksums` are meaningless as **each build will produce different checksums**. Your only option is to `trust me bro` or:
> > - [Fork this repo](https://github.com/Azathothas/Toolpacks/fork) : https://github.com/Azathothas/Toolpacks/fork
> > - Read & Verify everything : [Scripts](https://github.com/Azathothas/Toolpacks/tree/main/.github/scripts) & [Workflows](https://github.com/Azathothas/Toolpacks/tree/main/.github/workflows)
> > - Add `TOOLPACKS` as Actions Secret & Run the workflows.
> > > ```yaml
> > > env:
> > >  GITHUB_TOKEN: ${{ secrets.TOOLPACKS }}
> > > ```
---
