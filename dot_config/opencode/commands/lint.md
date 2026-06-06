---
description: LLM Wiki をヘルスチェックする
---

LLM Wiki の lint / health-check を実行する。

最初に必ず次の AgentSkill を読み込み、その指示に従うこと:
- `managing-llm-wiki`
- `obsidian-cli`
- `obsidian-markdown`

`managing-llm-wiki` の `lint` として扱い、LLM Wiki 全体を対象にする。

確認する観点:
- ページ間の矛盾
- 新しい source で古くなった主張
- 孤立ページ
- 重要だが独立ページがない概念
- 足りない `[[wikilink]]`
- データギャップ
- 次に調べるとよい問い

一時報告で十分な軽微な指摘は更新不要。再利用価値のある構造的な finding がある場合のみ、`managing-llm-wiki` の方針に従って `LLM Wiki/wiki/`、`LLM Wiki/index.md`、`LLM Wiki/log.md` のみを更新する。

変更した場合は、コミットして `git push` まで行う。
