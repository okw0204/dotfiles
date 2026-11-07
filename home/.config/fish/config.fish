set -gx EDITOR nvim

if status is-interactive
    if type -q mise
        mise activate fish | source
    end

    # ローカルの対話シェル起動時は Herdr に自動で入る（Herdr内/tmux内/SSH先では無効）
    if type -q herdr; and not set -q HERDR_ENV; and not set -q TMUX; and not set -q SSH_TTY
        herdr
    end

    # fish は履歴/補完を標準で管理するため、bash の HIST* や inputrc は不要

    # 環境変数 (.bashrc envs 相当)
    set -gx SUDO_EDITOR $EDITOR
    set -gx BAT_THEME ansi
    # fish のテーマ(プロンプト)を上書きしないよう無効化
    # if type -q starship
    #     starship init fish | source
    # end
    if type -q zoxide
        zoxide init fish | source
    end
    if type -q fzf
        # fzf が背景色検出で OSC 11 応答を残すことがあるため、配色を明示する。
        if not string match -q '*--color=*' -- $FZF_DEFAULT_OPTS; and not string match -q '*--no-color*' -- $FZF_DEFAULT_OPTS
            set -gx FZF_DEFAULT_OPTS "--color=dark $FZF_DEFAULT_OPTS"
        end
        # ディストリビューションが配置する fzf の補完/キーバインドは local.fish 側で読み込む。
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
        # WSL2 では wslview、通常 Linux では xdg-open を使う
        if type -q wslview
            wslview $argv >/dev/null 2>&1 &
        else if type -q xdg-open
            xdg-open $argv >/dev/null 2>&1 &
        end
    end

    # ディレクトリ移動
    alias ..="cd .."
    alias ...="cd ../.."
    alias ....="cd ../../.."

    # ツール
    abbr -a n nvim
    abbr -a c omp --allow-home
    abbr -a d docker
    abbr -a y yazi
    abbr -a lg lazygit

    # Git
    abbr -a g git
    abbr -a gp git pull
    alias gcm="git commit -m"
    alias gcam="git commit -a -m"
    alias gcad="git commit -a --amend"

    function gf --description "Fetch origin and prune stale git refs/worktrees"
        git fetch --prune origin
        git worktree prune --verbose
    end

    # ghq + fzf でリポジトリを選んで移動
    function gq --description "Select ghq repo with fzf"
        if not type -q ghq; or not type -q fzf
            return 1
        end

        set -l selected (ghq list -p | fzf --height=40% --reverse --prompt "ghq> " --query "$argv")
        if test -n "$selected"
            cd "$selected"
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

    # ブロックデバイス操作（iso2sd / format-drive）は環境固有の local.fish 側で linux-disk.fish を読み込む。

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

# 非対話シェルでは表示用コマンドを起動しない。
if status is-interactive; and type -q splashboard
    splashboard init fish | source
end

# 環境固有の追加設定。ファイルがある環境だけが読み込む（無くてもエラーにならない）。
if test -f $__fish_config_dir/local.fish
    source $__fish_config_dir/local.fish
end
