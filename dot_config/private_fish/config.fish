if status is-interactive
    # ローカルの対話シェル起動時は Herdr に自動で入る（Herdr内/tmux内/SSH先では無効）
    if type -q herdr; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY
        herdr
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
        # fzf が背景色検出で OSC 11 応答を残すことがあるため、配色を明示する。
        if not string match -q '*--color=*' -- $FZF_DEFAULT_OPTS; and not string match -q '*--no-color*' -- $FZF_DEFAULT_OPTS
            set -gx FZF_DEFAULT_OPTS "--color=dark $FZF_DEFAULT_OPTS"
        end

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
    if type -q hermes
        abbr -a h hermes
    end
    abbr -a c opencode
    abbr -a d docker
    abbr -a y yazi
    abbr -a lg lazygit

    # Git
    abbr -a g git
    abbr -a gp git pull

    function gf --description "Fetch origin and prune stale git refs/worktrees"
        git fetch --prune origin
        git worktree prune --verbose
    end

    # ghq でリポジトリを選んで移動
    if type -q ghq; and type -q fzf
        function gq --description "Select ghq repo with fzf"
            set -l selected (ghq list -p | fzf --height=40% --reverse --prompt "ghq> " --query "$argv")
            if test -n "$selected"
                cd "$selected"
            end
        end
    end

    # git worktree を選んで移動
    if type -q fzf
        function gw --description "Select git worktree with fzf"
            set -l selected (git worktree list 2>/dev/null | fzf --height=40% --reverse --prompt "worktree> " --query "$argv")
            if test -n "$selected"
                cd (string split -f1 ' ' -- "$selected")
            end
        end
    end

    # git branch + fzf でブランチを選んで切り替え
    if type -q fzf
        function gs --description "Select git branch with fzf"
            set -l selected (git branch -a 2>/dev/null \
                 | string trim \
                 | string replace -r '^\* ' '' \
                 | string replace -r '^remotes/origin/' '' \
                 | string match -v 'HEAD' \
                 | sort -u \
                 | fzf --height=40% --reverse --prompt "branch> " --query "$argv")
            if test -n "$selected"
                git switch "$selected"
            end
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

    function __confirm_block_device_erase --argument-names device
        if not test -b "$device"
            echo "Error: $device is not a block device." >&2
            return 1
        end

        set -l mounted (lsblk -nrpo MOUNTPOINT "$device" 2>/dev/null | string match -r '\S+')
        if test (count $mounted) -gt 0
            echo "Error: $device or one of its partitions is mounted." >&2
            return 1
        end

        lsblk -d -o NAME,SIZE,MODEL,TRAN "$device"
        set -l expected "ERASE $device"
        read -l -P "Type '$expected' to continue: " confirm
        test "$confirm" = "$expected"
    end

    # ISO をブロックデバイスへ書き込む
    function iso2sd
        if test (count $argv) -ne 2
            echo "Usage: iso2sd <input_file> <output_device>"
            echo "Example: iso2sd ~/Downloads/ubuntu.iso /dev/sda"
            return 2
        end

        set -l input (path resolve -- "$argv[1]")
        set -l device (path resolve -- "$argv[2]")
        if not test -f "$input"
            echo "Error: $input is not a regular file." >&2
            return 1
        end
        __confirm_block_device_erase "$device"; or return

        sudo dd bs=4M status=progress oflag=sync if="$input" of="$device"; or return
        sudo eject "$device"
    end

    # ドライブを exFAT で 1 パーティションに初期化
    function format-drive
        if test (count $argv) -ne 2
            echo "Usage: format-drive <device> <name>"
            echo "Example: format-drive /dev/sda 'My Stuff'"
            return 2
        end

        set -l device (path resolve -- "$argv[1]")
        set -l label "$argv[2]"
        if test (string length -- "$label") -gt 15
            echo "Error: exFAT labels are limited to 15 characters." >&2
            return 1
        end
        __confirm_block_device_erase "$device"; or return

        sudo wipefs -a "$device"; or return
        sudo parted -s "$device" mklabel gpt; or return
        sudo parted -s "$device" mkpart primary 1MiB 100%; or return

        if string match -qr '/(nvme\d+n\d+|mmcblk\d+|loop\d+)$' -- "$device"
            set -l partition "$device"p1
        else
            set -l partition "$device"1
        end

        sudo partprobe "$device"; or return
        sudo udevadm settle; or return
        for attempt in (seq 1 20)
            test -b "$partition"; and break
            sleep 0.1
        end
        if not test -b "$partition"
            echo "Error: partition $partition did not appear." >&2
            return 1
        end

        sudo mkfs.exfat -n "$label" "$partition"; or return
        echo "Drive $device formatted as exFAT and labeled '$label'."
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

# >>> splashboard >>>
# Added by `splashboard install`. Safe to remove.
if type -q splashboard
    splashboard init fish | source
end
# <<< splashboard <<<
