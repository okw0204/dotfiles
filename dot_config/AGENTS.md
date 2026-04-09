# 運用ルール

- chezmoi で config 管理しているため、変更後はリモートまで上げて同期する。
- config の実体は `~/.config` 側を正とし、必要に応じて chezmoi の source へ取り込んで同期する。
- `chezmoi apply` など source 側から反映する前に、`~/.config` で直した変更は先に `chezmoi add` で source へ取り込む。
- config 変更時は、必要に応じて日本語のインラインコメントを入れる（意図が伝わりにくい箇所を優先）。
