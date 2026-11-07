# dotfiles

OS に依存しない設定を、必要なファイルだけ選んで保存する。Git と明示的なコピーを使い、自動同期・自動適用は行わない。作業時の判断基準は [AGENTS.md](AGENTS.md) を参照する。

Arch Linux／Omarchy 専用の設定は [dotfiles-omarchy](https://github.com/okw0204/dotfiles-omarchy) にあり、そちらだけで chezmoi を継続する。

## 同期対象

`home/` 以下は配置先を表すための構造であり、一括コピーの対象ではない。`~` はコピー先のユーザーのホームを表す。ディレクトリを示す行は、その下の Git 管理対象だけを含む。

| 保存先 | 実環境の配置先 | 内容 |
| --- | --- | --- |
| `home/.omp/agent/AGENTS.md` | `~/.omp/agent/AGENTS.md` | 共通ルールと設定管理先の案内 |
| `home/.omp/agent/PERSONALITY.md` | `~/.omp/agent/PERSONALITY.md` | 応答の口調 |
| `home/.omp/agent/RULES.md` | `~/.omp/agent/RULES.md` | 質問・相談と実施のルール |
| `home/.omp/agent/config.yml` | `~/.omp/agent/config.yml` | モデル・表示・ツール承認の設定 |
| `home/.omp/agent/keybindings.yml` | `~/.omp/agent/keybindings.yml` | 外部エディタのキー操作 |
| `home/.omp/agent/commands/ingest.md` | `~/.omp/agent/commands/ingest.md` | Wiki への取り込みコマンド |
| `home/.omp/agent/commands/lint.md` | `~/.omp/agent/commands/lint.md` | Wiki の点検コマンド |
| `home/.config/herdr/config.toml` | `~/.config/herdr/config.toml` | Herdr のキー操作と表示設定 |
| `home/.agents/skills/herdr/SKILL.md` | `~/.agents/skills/herdr/SKILL.md` | 導入済み Herdr スキルの保存 |
| `home/.config/mise/config.toml`、`mise.lock` | `~/.config/mise/` | 共通ツールと解決済みバージョン |
| `home/.config/lazygit/config.yml` | `~/.config/lazygit/config.yml` | 日本語表示と delta 連携 |
| `home/.config/fish/` | `~/.config/fish/` | 共通の初期化・関数・Fisher／Tide |
| `home/.config/git/config`、`ignore` | `~/.config/git/` | 個人情報を除いた Git 設定 |
| `home/.config/nvim/` | `~/.config/nvim/` | 共通のエディタ設定とプラグイン lock |
| `home/.agents/skills/`、`home/.omp/agent/skills/` | 同じホーム相対パス | 共通スキルの本体と相対リンク |
| `home/.agents/licenses/`、`home/.agents/.skill-lock.json` | 同じホーム相対パス | スキルのライセンスと導入元情報 |
| `home/.claude/skills/`、`home/.codex/skills/`、`home/.config/opencode/skills/` | 同じホーム相対パス | 共通スキルへの相対リンク |

スキルの上流原文と付属ライセンスを保持する。Herdr スキルの出典は [herdrdev/herdr の skills/herdr/SKILL.md](https://github.com/herdrdev/herdr/blob/main/skills/herdr/SKILL.md)。このリポジトリ独自のライセンスとして扱わない。Omarchy 専用スキルと Codex 所有の `.system` は対象外。

### 復元時の前提

- omp の `config.yml` は `approvalMode: yolo` とコマンド拒否パターンを含む。復元先で使うモデル・プロバイダーと承認方針を確認してから適用する。認証情報は別途用意する。
- Wiki コマンドは `managing-llm-wiki`、`japanese-documentation`、`obsidian-cli`、`obsidian-markdown` の各スキルを参照する。コマンドと共通スキルを合わせて復元し、Obsidian 本体や Vault の環境設定は別途用意する。
- Herdr の設定は `fish` と reviewr プラグインの `persiyanov.reviewr.toggle` を参照する。プラグインやエージェント連携は Herdr 側で導入し、生成されたフック・プラグイン本体・セッション状態はここには保存しない。
- mise の共通設定は現在の開発環境を基準とする。Arch 側の Node `25.2.1` は `dotfiles-omarchy` の `mise.local.toml` と `mise.local.lock` に保持し、共通の Node `24.14.1` を上書きする。[mise の設定優先順位](https://mise.jdx.dev/configuration.html)に従うもので、Node の差を OS の制約とは扱わない。
- スキルは参照先の本体とライセンスも合わせて復元する。相対リンクを維持するため `cp -a` を使い、リンクだけを先に復元した状態でエージェントを起動しない。

### 共通設定とローカル設定の分割

| 対象 | 共通設定 | ローカル設定 |
| --- | --- | --- |
| fish | `~/.config/fish/config.fish` と共通関数 | 末尾で `~/.config/fish/local.fish` を読み込む。Arch の Vault パス・略語・ディストリビューション依存の初期化はそちらに置く |
| Git | `~/.config/git/config` と `ignore` | `config` 末尾の相対 include で `config.local` を読み込む。名前・メールアドレスなどはそちらに置く |
| mise | `config.toml` と `mise.lock` | 環境の選択を維持するときは `mise.local.toml` と対応する lock を使う |
| Neovim | 通常の設定と既定の Kanagawa テーマ | `lua/config/options.local.lua` と `lua/plugins/theme.local.lua` があれば環境側を使う。Omarchy のテーマ連携と OSC 52 設定は Arch 側に置く |

既存環境へ初めて復元するときは、元ファイルと比較してローカル設定を先に保全する。WSL の Vault パスや Git の個人情報を、Arch の値で置き換えない。Git は既存の `~/.gitconfig` も読み込むため、そちらの認証ヘルパー指定が共通設定を上書きする場合がある。削除・変更は別途確認し、共通設定の `gh` が実行環境の `PATH` で見つかることも確認する。

Linux のディスク操作関数は共通 fish から分離し、`dotfiles-omarchy` の `dot_config/private_fish/linux-disk.fish` に保持している。WSL でも必要ならその 1 ファイルだけを `~/.config/fish/linux-disk.fish` にコピーし、自分の `local.fish` から `source $__fish_config_dir/linux-disk.fish` で読み込む。Arch 用 `local.fish` を WSL にコピーしない。

Fisher／Tide の関数と導入一覧は保存するが、実行時の `fish_variables` は保存しない。プロンプトの個人設定は既存ファイルを保全するか、復元先で Tide の設定を行う。

Neovim を既存環境に復元する場合、古い `lua/plugins/theme.lua` がシンボリックリンクなら、コピー前にリンク自体をバックアップ先へ移す。リンク越しに Omarchy のテーマ本体を上書きしない。Arch では新しい `theme.local.lua` を chezmoi で配置する。Omarchy の現在テーマが生成済みであることも確認する。WSL では、残っている `omarchy-theme-hotreload.lua` を必要に応じてバックアップ側へ退避し、共通設定だけで起動できる状態にする。

`snacks-animated-scrolling-off.lua` は後から読む `snacks-scroll.lua` に上書きされていたため、共通側には後者だけを保存する。既存環境への復元時は前者をバックアップ側へ退避する。どちらの整理も、このリポジトリへの保存だけでは実環境に適用されない。

## この環境から取り込む

リポジトリのルートで、`git remote get-url origin` と `git status --short` を確認する。以下は `AGENTS.md` だけを取り込む例。

```sh
diff -u home/.omp/agent/AGENTS.md "$HOME/.omp/agent/AGENTS.md"
cp -- "$HOME/.omp/agent/AGENTS.md" home/.omp/agent/AGENTS.md
cmp -- "$HOME/.omp/agent/AGENTS.md" home/.omp/agent/AGENTS.md
git diff -- home/.omp/agent/AGENTS.md
git add -- home/.omp/agent/AGENTS.md
```

`diff` の終了コード 1 は差分ありを意味する。内容を確認してからコピーする。既存のステージ済み変更がある場合は混ぜずに切り分け、今回の対象だけをコミット・push する。他の対象も一覧の対応に従い、1 ファイルずつ同じ手順で扱う。

## 別環境へ復元する

1. このリポジトリを clone または更新し、必要なファイルだけを選ぶ。
2. 配置先の既存ファイルとの差分を確認し、既存ファイルがあればリポジトリ外へバックアップする。
3. 復元を依頼された対象だけ、親ディレクトリを作成してコピーする。
4. `cmp` で一致を確認し、利用するツールで読み込み・動作を確認する。

コピーだけではツールやスキル管理ツールの登録は行われない。ツールによっては設定の再読み込みや次のセッションが必要になる。

## 管理方針の入口

omp の次のセッションには `~/.omp/agent/AGENTS.md` の管理先ルールを渡す。対象リポジトリではルートの `AGENTS.md` とこの文書を読む。別のエージェントを使う場合も、そのエージェントが読む指示ファイルから同じ `AGENTS.md` を参照する。
