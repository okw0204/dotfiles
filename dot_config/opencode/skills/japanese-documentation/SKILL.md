---
name: japanese-documentation
description: Use when writing or editing human-readable documentation such as README, docs, Markdown, AGENTS.md, SKILL.md, design docs, specs, guides, notes, or HTML.
---

# Japanese Documentation

## 原則

人が読む文書は、日本語で記述する。opencode が README、docs、Markdown、AGENTS.md、SKILL.md、設計書、仕様書、手順書、Obsidian ノート、HTML などを作成または編集するときに適用する。

この方針は、読み手がユーザー本人である文書にも、将来のエージェントや共同作業者が読む文書にも適用する。

## 英語のままでよいもの

次の内容は、読みやすさや正確性のために英語のままでよい。

| 種類 | 例 |
| --- | --- |
| コード識別子 | `getUser`, `ConfigInvalidError` |
| API名・型名 | `tool.execute.before`, `PluginInput` |
| コマンド・パス | `node --test`, `docs/guide.md` |
| ログ・エラーメッセージ | `ENOENT`, `ConfigInvalidError` |
| 引用 | 外部文書からの原文引用 |
| 固有名詞 | 製品名、ライブラリ名、仕様名 |

## 書き方

- 見出し、説明文、手順、注意書きは日本語で書く。
- 英語の用語を残す場合は、必要に応じて日本語で補足する。
- 外部公開や upstream への提出など、英語が明確に必要な場合は、その理由を簡潔に示して英語で書く。
- 太字は強調が本当に必要な語句に限り、文全体を太字にしない。
- 英語直訳調を避け、日本語として自然に読める表現にする。

## 判断基準

迷ったら「人間が読むための本文か」を基準にする。

| 対象 | 方針 |
| --- | --- |
| README、docs、設計書、仕様書、手順書 | 日本語 |
| AGENTS.md、SKILL.md、エージェント向け説明 | 日本語 |
| コード、設定キー、コマンド、ログ | 英語のままでよい |

## よくある失敗

| 失敗 | 修正 |
| --- | --- |
| Skill の本文を英語で書く | `SKILL.md` も人が読む文書なので日本語で書く |
| README の追記だけ英語にする | 日本語が適切な文書では、追記も日本語で書く |
| コード名まで翻訳する | コード識別子、API名、コマンドは翻訳しない |
