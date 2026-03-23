import { existsSync } from "node:fs"

export const NotificationPlugin = async ({ $ }) => {
  const configHome = process.env.XDG_CONFIG_HOME || `${process.env.HOME}/.config`
  const notifyOffFile = `${configHome}/opencode/notify.off`
  const isGhostty =
    process.env.TERM_PROGRAM === "ghostty" ||
    Boolean(process.env.GHOSTTY_RESOURCES_DIR) ||
    Boolean(process.env.GHOSTTY_BIN_DIR)
  const isTmux = Boolean(process.env.TMUX) || (process.env.TERM || "").startsWith("tmux")
  let lastTaskCompletedAt = 0

  const isNotificationEnabled = () => !existsSync(notifyOffFile)

  const osc9 = (message) => {
    const clean = message.replace(/[\u0007\u001b\r\n]/g, " ")
    const base = `\u001b]9;${clean}\u001b\\`
    if (!isTmux) {
      process.stdout.write(base)
      return
    }

    // tmux配下では passthrough 形式で OSC を転送する
    const escaped = base.replace(/\u001b/g, "\u001b\u001b")
    process.stdout.write(`\u001bPtmux;${escaped}\u001b\\`)
  }

  const notify = async (message) => {
    if (!isNotificationEnabled()) {
      return
    }

    // Ghostty では tmux 配下も含めて OSC 9 を優先。失敗時のみ notify-send へフォールバック。
    if (isGhostty) {
      try {
        osc9(message)
        return
      } catch (error) {
        console.error("[opencode notify] OSC9 failed", error)
      }
    }

    try {
      await $`notify-send --app-name=OpenCode OpenCode ${message}`
    } catch (error) {
      console.error("[opencode notify] notify-send failed", error)
    }
  }

  return {
    event: async ({ event }) => {
      const notifyTaskCompleted = async () => {
        const now = Date.now()
        if (now - lastTaskCompletedAt < 1500) {
          return
        }
        lastTaskCompletedAt = now
        await notify("Task completed")
      }

      if (event.type === "session.idle") {
        await notifyTaskCompleted()
      }

      if (event.type === "session.status" && event.properties?.status?.type === "idle") {
        await notifyTaskCompleted()
      }

      if (event.type === "question.asked") {
        await notify("Input needed")
      }

      if (
        event.type === "permission.asked" ||
        event.type === "permission.updated" ||
        event.type === "permission.replied"
      ) {
        await notify("Permission needed")
      }
    },
  }
}
