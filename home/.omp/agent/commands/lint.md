---
description: LLM Wiki をヘルスチェックする
---

LLM Wiki の lint / health-check を実行する。

今回の引数: $ARGUMENTS

最初に必ず次の AgentSkill を読み込み、その指示に従うこと:
- `skill://managing-llm-wiki`
- `skill://japanese-documentation`
- `skill://obsidian-cli`
- `skill://obsidian-markdown`

`managing-llm-wiki` の `lint` として扱う。引数で指定された範囲を対象にし、範囲指定がなければ LLM Wiki 全体を対象にする。修正依頼の有無と対象範囲は分けて解釈する。

確認項目は `managing-llm-wiki` の「チェック項目」に従う。引数で観点が限定されている場合はそれを優先し、通常の構造チェックと対象に応じた内容判断を区別する。

結果は `managing-llm-wiki` の「Lint の出力形式」に従い、診断範囲と未確認範囲、各指摘の根拠・確度・修正案・影響範囲を報告する。重要度は同 Skill の影響に基づく基準で判断する。

既定は読み取り専用の診断とし、修正案を回答内に示す。構造的な finding があっても、それだけではファイルを変更しない。修正を明示された場合だけ、`managing-llm-wiki` の方針に従って、指定範囲の `LLM Wiki/wiki/` と、それに対応する `LLM Wiki/index.md`、`LLM Wiki/log.md` を更新する。

修正を明示され、実際に変更した場合だけ、`managing-llm-wiki` の「Git 同期の安全条件」に従って commit / push する。診断のみ、または変更なしの場合は実施しない。安全条件を満たさない場合は同期を見送り、理由を報告する。
