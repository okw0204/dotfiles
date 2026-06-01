const DOCUMENT_REMINDER = [
  "人が読むドキュメント本文は原則日本語で記述してください。",
  "コード識別子、API名、コマンド、ログ、引用、固有名詞等は英語のままで構いません。",
  "この方針を反映して、もう一度編集してください。",
].join("\n")

const remindedSessions = new Set()

const EDIT_TOOL_NAMES = new Set(["edit", "write", "apply_patch"])

export const isEditTool = (input) => EDIT_TOOL_NAMES.has(input?.tool)

const normalizePath = (path) => path.replaceAll("\\", "/")

export const isDocumentationPath = (path) => {
  if (typeof path !== "string" || path.length === 0) {
    return false
  }

  const normalized = normalizePath(path)
  return (
    normalized.endsWith(".md") ||
    normalized.endsWith(".html") ||
    normalized === "docs" ||
    normalized.startsWith("docs/") ||
    normalized.includes("/docs/")
  )
}

const collectPath = (paths, value) => {
  if (typeof value === "string" && isDocumentationPath(value)) {
    paths.add(value)
  }
}

const collectPatchPaths = (paths, patchText) => {
  if (typeof patchText !== "string") {
    return
  }

  for (const line of patchText.split("\n")) {
    const match = line.match(/^\*\*\* (?:Add|Update|Delete) File: (.+)$/)
    if (match) {
      collectPath(paths, match[1])
    }
  }
}

export const getDocumentationPaths = (args) => {
  const paths = new Set()
  if (!args || typeof args !== "object") {
    return []
  }

  collectPath(paths, args.filePath)
  collectPath(paths, args.path)
  collectPath(paths, args.file)
  collectPatchPaths(paths, args.patchText)
  collectPatchPaths(paths, args.patch)

  return [...paths]
}

export const JapaneseDocsPlugin = async () => {
  return {
    "tool.execute.before": async (input, output) => {
      if (!isEditTool(input)) {
        return
      }

      if (getDocumentationPaths(output.args).length === 0) {
        return
      }

      if (remindedSessions.has(input.sessionID)) {
        return
      }

      remindedSessions.add(input.sessionID)
      throw new Error(DOCUMENT_REMINDER)
    },
  }
}
