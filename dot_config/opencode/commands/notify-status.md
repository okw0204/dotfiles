---
description: Show OpenCode notification status
---
Show the current global notification status.

Result:
!`if [ -f "$HOME/.config/opencode/notify.off" ]; then echo "Notifications: OFF"; else echo "Notifications: ON"; fi`

Reply with only the result line.
