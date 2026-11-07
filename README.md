# dotfiles

OS に依存しない設定を、必要なファイルだけ選んで保存する。Git と明示的なコピーを使い、自動同期・自動適用は行わない。作業時の判断基準は [AGENTS.md](AGENTS.md) を参照する。

Arch Linux／Omarchy 専用の設定は [dotfiles-omarchy](https://github.com/okw0204/dotfiles-omarchy) にあり、そちらだけで chezmoi を継続する。

## 同期対象

`home/` 以下は配置先を表すための構造であり、一括コピーの対象ではない。`~` はコピー先のユーザーのホームを表す。

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

Herdr スキルの出典は [herdrdev/herdr の skills/herdr/SKILL.md](https://github.com/herdrdev/herdr/blob/main/skills/herdr/SKILL.md)。原文を保存し、このリポジトリ独自のライセンスとして扱わない。スキル管理ツール全体の lock ファイルや、他のスキルは対象に含めない。

### 復元時の前提

- omp の `config.yml` は `approvalMode: yolo` とコマンド拒否パターンを含む。復元先で使うモデル・プロバイダーと承認方針を確認してから適用する。認証情報は別途用意する。
- Wiki コマンドは `managing-llm-wiki`、`japanese-documentation`、`obsidian-cli`、`obsidian-markdown` の各スキルを参照する。このリポジトリには含めていないため、復元先で別途導入する。
- Herdr の設定は `fish` と reviewr プラグインの `persiyanov.reviewr.toggle` を参照する。プラグインやエージェント連携は Herdr 側で導入し、生成されたフック・プラグイン本体・セッション状態はここには保存しない。

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
