if status is-interactive
    # ローカルの対話シェル起動時は tmux に自動で入る（tmux内/SSH先では無効）
    if not set -q TMUX; and not set -q SSH_TTY
        tmux new-session # 新しいセッションを毎回作成して接続
    end

    # fish は履歴/補完を標準で管理するため、bash の HIST* や inputrc は不要

    # 環境変数 (.bashrc envs 相当)
    set -gx SUDO_EDITOR $EDITOR
    set -gx BAT_THEME ansi
    # Obsidian Vault パスの正本。Hermes 側でも ~/.hermes/.env に同じ値をミラーしている。
    set -gx OBSIDIAN_VAULT_PATH "$HOME/ghq/github.com/okw0204/Obsidian"

    # 初期化 (.bashrc init 相当)
    if type -q mise
        mise activate fish | source
    end
    # fish のテーマ(プロンプト)を上書きしないよう無効化
    # if type -q starship
    #     starship init fish | source
    # end
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q try
        # try が fish 出力に対応している前提
        try init ~/Work/tries | source
    end
    if type -q fzf
        if test -f /usr/share/fzf/completion.fish
            source /usr/share/fzf/completion.fish
        end
        if test -f /usr/share/fzf/key-bindings.fish
            source /usr/share/fzf/key-bindings.fish
        end
    end

    # ファイル操作系 alias (.bashrc aliases 相当)
    if type -q eza
        alias ls="eza -lh --group-directories-first --icons=auto"
        alias lsa="ls -a"
        alias lt="eza --tree --level=2 --long --icons --git"
        alias lta="lt -a"
    end

    alias ff="fzf --preview 'bat --style=numbers --color=always {}'"

    function open
        # xdg-open をバックグラウンドで実行
        xdg-open $argv >/dev/null 2>&1 &
    end

    # ディレクトリ移動
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # ツール
    abbr -a n nvim
    abbr -a h hermes
    abbr -a c opencode
    abbr -a d docker
    abbr -a y yazi
    abbr -a lg lazygit

    # Git
    abbr -a g git
    alias gcm="git commit -m"
    alias gcam="git commit -a -m"
    alias gcad="git commit -a --amend"

    # ghq + fzf でリポジトリを選んで移動
    function gq --description "Select ghq repo with fzf"
        set -l selected (ghq list -p | fzf --height=40% --reverse --prompt "ghq> " --query "$argv")
        if test -n "$selected"
            cd "$selected"
        end
    end

    # Brave の言語を日本語に設定
    function brave
        env LANG=ja_JP.UTF-8 LC_ALL=ja_JP.UTF-8 command brave $argv
    end

    # 圧縮/展開
    function compress
        set -l base (string replace -r '/$' '' -- $argv[1])
        tar -czf "$base.tar.gz" "$base"
    end
    alias decompress="tar -xzf"

    # ISO を SD カードへ書き込み
    function iso2sd
        if test (count $argv) -ne 2
            echo "Usage: iso2sd <input_file> <output_device>"
            echo "Example: iso2sd ~/Downloads/ubuntu-25.04-desktop-amd64.iso /dev/sda"
            printf "\nAvailable SD cards:\n"
            lsblk -d -o NAME | grep -E '^sd[a-z]' | awk '{print "/dev/"$1}'
        else
            sudo dd bs=4M status=progress oflag=sync if="$argv[1]" of="$argv[2]"
            sudo eject "$argv[2]"
        end
    end

    # ドライブを exFAT で 1 パーティションに初期化
    function format-drive
        if test (count $argv) -ne 2
            echo "Usage: format-drive <device> <name>"
            echo "Example: format-drive /dev/sda 'My Stuff'"
            printf "\nAvailable drives:\n"
            lsblk -d -o NAME -n | awk '{print "/dev/"$1}'
        else
            echo "WARNING: This will completely erase all data on $argv[1] and label it '$argv[2]'."
            read -l -P "Are you sure you want to continue? (y/N): " confirm

            if string match -qr '^[Yy]$' -- $confirm
                sudo wipefs -a "$argv[1]"
                sudo dd if=/dev/zero of="$argv[1]" bs=1M count=100 status=progress
                sudo parted -s "$argv[1]" mklabel gpt
                sudo parted -s "$argv[1]" mkpart primary 1MiB 100%

                if string match -q '*nvme*' -- $argv[1]
                    set -l partition "$argv[1]p1"
                else
                    set -l partition "$argv[1]1"
                end

                sudo partprobe "$argv[1]"; or true
                sudo udevadm settle; or true

                sudo mkfs.exfat -n "$argv[2]" "$partition"
                echo "Drive $argv[1] formatted as exFAT and labeled '$argv[2]'."
            end
        end
    end

    # 共有向け 1080p へトランスコード
    function transcode-video-1080p
        set -l base (path change-extension '' -- $argv[1])
        ffmpeg -i $argv[1] -vf scale=1920:1080 -c:v libx264 -preset fast -crf 23 -c:a copy "$base-1080p.mp4"
    end

    # 共有向け 4K へトランスコード
    function transcode-video-4K
        set -l base (path change-extension '' -- $argv[1])
        ffmpeg -i $argv[1] -c:v libx265 -preset slow -crf 24 -c:a aac -b:a 192k "$base-optimized.mp4"
    end

    # 画像を JPG に変換（壁紙向け）
    function img2jpg
        set -l img $argv[1]
        set -e argv[1]
        magick "$img" $argv -quality 95 -strip (path change-extension '' -- $img)-optimized.jpg
    end

    # 画像を JPG に変換（共有向けに縮小）
    function img2jpg-small
        set -l img $argv[1]
        set -e argv[1]
        magick "$img" $argv -resize '1080x>' -quality 95 -strip (path change-extension '' -- $img)-optimized.jpg
    end

    # 画像をロスレス圧縮 PNG に変換
    function img2png
        set -l img $argv[1]
        set -e argv[1]
        set -l base (path change-extension '' -- $img)
        magick "$img" $argv -strip -define png:compression-filter=5 \
            -define png:compression-level=9 \
            -define png:compression-strategy=1 \
            -define png:exclude-chunk=all \
            "$base-optimized.png"
    end
end

# opencode
fish_add_path /home/okw/.opencode/bin
