export const NotificationPlugin = async ({ $ }) => {
  const configHome = process.env.XDG_CONFIG_HOME || `${process.env.HOME}/.config`
  const notifyOffFile = `${configHome}/opencode/notify.off`
  const isGhostty =
    process.env.TERM_PROGRAM === "ghostty" ||
    Boolean(process.env.GHOSTTY_RESOURCES_DIR) ||
    Boolean(process.env.GHOSTTY_BIN_DIR)
  const isTmux = Boolean(process.env.TMUX) || (process.env.TERM || "").startsWith("tmux")

  const isNotificationEnabled = async () => {
    const result = await $`test ! -f ${notifyOffFile}; echo $?`.text()
    return result.trim() === "0"
  }

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
    if (!(await isNotificationEnabled())) {
      return
    }

    if (isGhostty) {
      try {
        osc9(message)
        return
      } catch {
      }
    }

    await $`notify-send --app-name=OpenCode OpenCode ${message}`
  }

  return {
    event: async ({ event }) => {
      if (event.type === "session.idle") {
        await notify("Task completed")
      }

      if (event.type === "question.asked") {
        await notify("Input needed")
      }

      if (event.type === "permission.asked") {
        await notify("Permission needed")
      }
    },
  }
}
