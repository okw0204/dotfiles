---
name: managing-llm-wiki
description: Manages the user's Obsidian-based LLM Wiki. Use this skill whenever the user mentions `LLM Wiki`, wants to ingest or import source material into `LLM Wiki/raw/`, passes a URL or web page to be incorporated as source, wants to update or reorganize synthesized notes in `LLM Wiki/wiki/`, wants to refresh `LLM Wiki/index.md` or `LLM Wiki/log.md`, wants to ask questions grounded in that wiki, or wants a lint/health-check of the wiki. Use it even when the user does not explicitly say `ingest`, `query`, or `lint`, as long as the request is clearly about operating this LLM Wiki while preserving the raw/wiki boundary, Japanese writing style, frontmatter tag rules, and `[[wikilink]]` conventions.
argument-hint: [ingest <path> | query <question> | lint <scope>]
---

# Managing LLM Wiki

この Skill は、ユーザーの Obsidian ベースの LLM Wiki を小さく安全な単位で運用する。元資料は `raw/` に不変のまま保管し、長く使う知識は `wiki/` に整理する。ユーザーが明示しない限り、Vault 内の無関係なノートは作業対象にしない。

## 管理範囲

- Vault root: `/home/okw/ghq/github.com/okw0204/Obsidian`
- LLM Wiki root: `/home/okw/ghq/github.com/okw0204/Obsidian/LLM Wiki`
- 不変の元資料置き場: `LLM Wiki/raw/`
- 書き込み対象の知識領域: `LLM Wiki/wiki/`, `LLM Wiki/index.md`, `LLM Wiki/log.md`

この Skill の境界として、次のルールを守る。

- ユーザーが明示しない限り、`Knowledge/`、`Ideas/`、`Inbox/` など既存の別ノート領域を取り込まない。必要な場合も、まず `LLM Wiki/raw/` にコピーしてから扱う。
- `LLM Wiki/raw/` に入った元資料は編集しない。
- wiki 本文は日本語を優先する。
- 内部参照は Obsidian の `[[wikilink]]` を優先する。
- frontmatter は近くのファイルの流儀に合わせる。特に強いローカルルールがなければ、`tags` だけの最小構成を基本にする。
- 変更は小さく戻しやすくする。1 つの焦点化されたノート更新で十分なら、Wiki 全体の再設計をしない。

## 最初に向きを合わせる

既存の LLM Wiki に対して作業する前に、必要な範囲だけ現在地を確認する。これにより、重複ページ、既存リンクの見落とし、最近の作業の巻き戻しを避ける。

1. `LLM Wiki/index.md` を読む。
2. `LLM Wiki/log.md` の最近の記録を読む。
3. 作業対象に関係しそうな既存ページを `LLM Wiki/wiki/` から検索する。
4. もし `LLM Wiki/README.md` や `LLM Wiki/SCHEMA.md` のようなローカルルールが存在する場合だけ読む。存在しない schema を新規に仮定しない。

大きな Wiki では、ページ作成や大きめの更新の前に、関連語で `LLM Wiki/wiki/` を検索する。index だけに頼ると、古いページや別名ページを見落としやすい。

## 最初の分岐: 依頼を読む

依頼は原則として次の 3 つに割り当てる。

- `ingest <path>`
- `query <question>`
- `lint <scope>`

ユーザーがこの形式で書いている場合はそのまま扱う。自然文の場合は意図から推定する。

- ファイル、記事、ノート、PDF、Web ページを追加・取り込み・要約・反映したい依頼は `ingest`
- 既存の LLM Wiki に基づいて答える、説明する、比較する、要約する依頼は `query`
- 健康診断、監査、lint、矛盾、古いページ、孤立ページ、保守不足を探す依頼は `lint`
- 「追加する価値がある情報源を探して」など、まだファイル更新を明示していない依頼は source recommendation として扱い、勝手に `ingest` しない

意図が本当に曖昧なときだけ短く確認する。ユーザーに `ingest` や `query` という語彙を覚えさせる必要はない。

## Workflow: `ingest <path>`

新しい元資料を LLM Wiki に追加するときに使う。

1. パスまたは URL を解決し、存在や取得可否を確認する。
2. 元資料がすでに `LLM Wiki/raw/` 内にあるか確認する。
3. `raw/` の外にある資料は、元ファイルを変更せず `LLM Wiki/raw/` にコピーする。
4. URL の場合は、URL と取得日が残る形で、できれば cleaned Markdown や exported text としてローカルに不変コピーを保存する。
5. 元資料を読み、今すぐ残す価値がある最小の durable knowledge を見極める。
6. 既存ページを検索し、明確に拡張できるページがあれば更新する。混ぜると濁る場合だけ新規ページを作る。
7. 必要に応じて `LLM Wiki/wiki/` に 1 つ以上のノートを作成または更新する。
8. 新しい入口や重要リンクが増えた場合だけ `LLM Wiki/index.md` を更新する。
9. 永続的な変更をしたら `LLM Wiki/log.md` に `YYYY-MM-DD HH:MM:SS` 形式の絶対時刻で操作記録を追記する。
10. コピーしたもの、変更した wiki ページ、意図的に後回しにしたことを報告する。

### Ingest の注意

- 元資料を保存する。`raw/` は scratchpad ではなく、不変の保管庫である。
- 既存 Vault ノートを資料にする場合も、原本を直接 source として扱わず、まず `raw/` にコピーする。
- 1 つの source から巨大な分類体系を作らない。最初は source summary や焦点化された概念ページで十分なことが多い。
- 新規ノート名は、後から `[[wikilink]]` として使っても意味が通る安定した日本語タイトルにする。
- 10 ファイル以上、または多数の既存ページに触れそうな場合は、作業範囲を確認してから進める。

### 複数資料の ingest

複数の資料をまとめて取り込むときは、1 件ずつ index と log を更新し続けない。

1. すべての資料を先に確認する。
2. 資料群に共通する entity、concept、論点を洗い出す。
3. 既存ページ検索をまとめて行う。
4. wiki ページの作成・更新をまとめて行う。
5. `index.md` を最後に 1 回更新する。
6. `log.md` には batch ingest として 1 つの操作記録を残す。

### Ingest の出力形式

ユーザーが別形式を求めていない限り、最後は次の形にする。

1. `Copied to raw`: 元資料のパスとコピー先
2. `Updated wiki`: 変更したノートパス
3. `Index/log`: `index.md` と `log.md` の変更有無
4. `Next useful step`: 必要なら次に有用な `ingest` や焦点化された `query`

## Workflow: source recommendation

ユーザーが「LLM Wiki に足すとよさそうな情報源を探して」「このテーマの材料を集めて」のように、更新ではなく候補探しを求めたときに使う。

- 勝手にページ構造を提案したり、`wiki/` を更新したりしない。
- タイトル、URL、残す価値、注意点や不確実性を短く並べる。
- 必要ならニュース、論文、OSS repo、公式ブログ、イベント、動画、展示、ニッチなプロジェクトまで広く見る。
- ユーザーが「取り込んで」「反映して」と明示した時点で `ingest` に切り替える。

## Workflow: `query <question>`

現在の LLM Wiki に基づいて回答するときに使う。

1. `LLM Wiki/index.md` と関連する `LLM Wiki/wiki/` を検索する。
2. 必要な場合だけ関連する `LLM Wiki/raw/` を読む。
3. raw と wiki の両方がある場合は、まず合成済みの wiki ページを優先する。
4. 日本語で簡潔に答え、関連するノートパスを示す。
5. 質問から durable な知識ギャップや有用な新しい関係が見つかり、根拠がすでにある場合だけ、小さく `wiki/` に反映して log に記録する。
6. 新しい資料が必要な場合は、Wiki に既にあるかのように答えず、その不足を明確に伝える。

### Query の注意

- 基本は read-first。質問されたからといって広いノートツリーを作らない。
- 比較、分析、再利用価値の高い synthesis は、将来の検索性を上げる場合に限って wiki に戻す。
- 管理範囲外の Vault 知識を黙って混ぜない。
- 内部知識を引用するときは、クリックしやすいノートパスか `[[wikilink]]` に対応する名前を使う。

### Query の出力形式

ユーザーが別形式を求めていない限り、次の形にする。

1. 短い日本語の回答
2. `Relevant notes`: 参照した主なノートパス
3. `Wiki updates`: `none` または更新したファイル
4. `Gap`: 不足資料や不確実性があれば記載

## Workflow: `lint <scope>`

新しい資料追加や回答ではなく、LLM Wiki の健康診断をするときに使う。

`lint` は、Wiki を長く育つ知識ベースとして保つための保守作業である。スコープは軽く絞る。ユーザーが広い棚卸しを求めていない限り、全体再設計にしない。

Lint では必要に応じて次を見る。

- ページ間の矛盾。
- 新しい source によって古くなった主張。
- inbound/outbound link が乏しい孤立ページ。
- 存在しないページを指す broken `[[wikilink]]`。
- `index.md` に載っていない `wiki/` ページ。
- 複数ページに出てくるのに独立ページがない重要概念。
- 関連ページ間の cross-reference 不足。
- frontmatter の明らかな欠落や近傍ルールとの不一致。
- 追加 source や focused web search で埋められそうな情報ギャップ。
- 次に調べる価値がある問い。
- サイズが大きくなりすぎたページ。
- `log.md` が肥大化していて分割を検討すべき状態。

問題は重要度順に報告する。目安は、broken link、矛盾、index 不整合、孤立ページ、古い内容、style issue の順。lint によって永続的な変更をした場合は、他の操作と同じく `LLM Wiki/log.md` に記録する。

## ノート作成ルール

wiki ノートを作成または更新するときは、次を守る。

- 日本語と英数字の間は、必要に応じて半角スペースを入れる。
- 句読点は `、。` を使う。
- tag は frontmatter を正とする。
- frontmatter はローカルの流儀に合わせる。強いルールがなければ最小にする。
- 見出しで読みやすくする。
- 同じ説明を複数ページに複製するより、隣接概念への `[[wikilink]]` を張る。
- raw extraction より synthesis を優先する。wiki ページは「source に何が書いてあるか」だけでなく「なぜ重要か」を説明する。

新規 wiki ノートの安全なデフォルトは次の形にする。

```yaml
---
tags:
  - AI
---
```

## 判断ルール

- Markdown 内容の変更が中心なら、Obsidian で有効な形を保ちながら直接編集する。
- 情報を探すだけなら、ファイル全体を読む前に検索する。
- `ingest` がディレクトリを指す場合は、明確に関連するファイルだけ処理し、スキップしたものを伝える。
- source が noisy または大きすぎる場合は、まず compact summary を作り、深い再編は後続作業に残す。
- ユーザーが広い redesign を求めた場合は、最小の ingest/query 作業とは分けて扱う。

## 完了前チェック

完了前に確認する。

- 書き込みが許可された対象内に収まっている。
- `raw/` の元資料を編集していない。
- 新規または更新ノートのタイトルが日本語として自然で、`[[wikilink]]` として使いやすい。
- 永続的な ingest/query/lint 由来の変更が `LLM Wiki/log.md` に記録されている。
- 最終応答で、何を変更したかを具体的に伝えている。
