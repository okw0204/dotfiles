#!/usr/bin/env node

import { mkdtemp, cp, rm, mkdir } from "node:fs/promises"
import { existsSync } from "node:fs"
import { tmpdir } from "node:os"
import { dirname, join } from "node:path"
import { spawn } from "node:child_process"
import net from "node:net"

const BRAVE_PATH = process.env.BRAVE_PATH || "/usr/bin/brave"
const BRAVE_USER_DATA_DIR =
  process.env.BRAVE_USER_DATA_DIR || `${process.env.HOME}/.config/BraveSoftware/Brave-Browser`
const BRAVE_PROFILE = process.env.BRAVE_PROFILE || "Default"
const BRAVE_HEADLESS = process.env.BRAVE_HEADLESS === "1"
const USAGE_ENDPOINT = "https://chatgpt.com/backend-api/codex/usage"
const USAGE_PAGE = "https://chatgpt.com/codex/cloud/settings/usage"
const COPY_PATHS = [
  "Local State",
  join(BRAVE_PROFILE, "Cookies"),
  join(BRAVE_PROFILE, "Preferences"),
  join(BRAVE_PROFILE, "Local Storage"),
  join(BRAVE_PROFILE, "Session Storage"),
  join(BRAVE_PROFILE, "IndexedDB"),
]

const sleep = (ms) => new Promise((resolve) => setTimeout(resolve, ms))

async function getFreePort() {
  return new Promise((resolve, reject) => {
    const server = net.createServer()
    server.listen(0, "127.0.0.1", () => {
      const address = server.address()
      if (!address || typeof address === "string") {
        server.close()
        reject(new Error("failed to allocate a debug port"))
        return
      }
      const { port } = address
      server.close((error) => {
        if (error) {
          reject(error)
          return
        }
        resolve(port)
      })
    })
    server.on("error", reject)
  })
}

async function copyBrowserState(tempUserDataDir) {
  for (const relativePath of COPY_PATHS) {
    const sourcePath = join(BRAVE_USER_DATA_DIR, relativePath)
    if (!existsSync(sourcePath)) {
      continue
    }

    const targetPath = join(tempUserDataDir, relativePath)
    await mkdir(dirname(targetPath), { recursive: true })
    await cp(sourcePath, targetPath, { recursive: true, force: true })
  }
}

async function stopBrowser(browser) {
  if (!browser || browser.killed) {
    return
  }

  const exited = new Promise((resolve) => {
    browser.once("exit", resolve)
  })
  browser.kill("SIGTERM")
  await Promise.race([exited, sleep(3000)])
}

async function waitForJson(url, timeoutMs = 15000) {
  const startedAt = Date.now()
  let lastError
  while (Date.now() - startedAt < timeoutMs) {
    try {
      const response = await fetch(url)
      if (response.ok) {
        return response.json()
      }
      lastError = new Error(`unexpected status ${response.status}`)
    } catch (error) {
      lastError = error
    }
    await sleep(250)
  }
  throw lastError || new Error(`timed out waiting for ${url}`)
}

async function sendCdp(wsUrl, expression) {
  return new Promise((resolve, reject) => {
    const ws = new WebSocket(wsUrl)
    const timer = setTimeout(() => {
      ws.close()
      reject(new Error("timed out waiting for browser response"))
    }, 15000)

    ws.addEventListener("open", () => {
      ws.send(
        JSON.stringify({
          id: 1,
          method: "Runtime.evaluate",
          params: {
            expression,
            awaitPromise: true,
            returnByValue: true,
          },
        }),
      )
    })

    ws.addEventListener("message", (event) => {
      const payload = JSON.parse(event.data)
      if (payload.id !== 1) {
        return
      }
      clearTimeout(timer)
      ws.close()
      if (payload.error) {
        reject(new Error(payload.error.message || "CDP evaluation failed"))
        return
      }
      if (payload.result?.exceptionDetails) {
        reject(new Error(payload.result.exceptionDetails.text || "evaluation raised an exception"))
        return
      }
      resolve(payload.result?.result?.value)
    })

    ws.addEventListener("error", (error) => {
      clearTimeout(timer)
      reject(error)
    })
  })
}

function findFirstValue(value, matcher) {
  if (Array.isArray(value)) {
    for (const item of value) {
      const found = findFirstValue(item, matcher)
      if (found !== undefined) {
        return found
      }
    }
    return undefined
  }

  if (!value || typeof value !== "object") {
    return undefined
  }

  for (const [key, nested] of Object.entries(value)) {
    if (matcher(key, nested)) {
      return nested
    }
    const found = findFirstValue(nested, matcher)
    if (found !== undefined) {
      return found
    }
  }

  return undefined
}

function flattenPercentages(value, path = []) {
  const matches = []
  if (Array.isArray(value)) {
    value.forEach((item, index) => {
      matches.push(...flattenPercentages(item, [...path, String(index)]))
    })
    return matches
  }

  if (value && typeof value === "object") {
    const entries = Object.entries(value)
    for (const [key, nested] of entries) {
      matches.push(...flattenPercentages(nested, [...path, key]))
    }
    return matches
  }

  if (typeof value === "number" && value >= 0 && value <= 100) {
    const joinedPath = path.join(".")
    if (/(remaining|remain|percent|percentage|available|left)/i.test(joinedPath)) {
      matches.push({ path: joinedPath, value })
    }
  }

  return matches
}

function summarizeUsage(payload) {
  if (!payload || typeof payload !== "object") {
    return String(payload)
  }

  const primary = payload.rate_limit?.primary_window
  const secondary = payload.rate_limit?.secondary_window
  if (primary && secondary) {
    const formatRemaining = (window) => {
      const used = typeof window.used_percent === "number" ? window.used_percent : null
      const remaining = used === null ? null : Math.max(0, 100 - used)
      const resetAfter = typeof window.reset_after_seconds === "number" ? window.reset_after_seconds : null
      const hours = resetAfter === null ? null : Math.floor(resetAfter / 3600)
      const minutes = resetAfter === null ? null : Math.floor((resetAfter % 3600) / 60)
      const resetText =
        hours === null || minutes === null ? "" : `, resets in ${hours}h ${minutes}m`
      return `${remaining}% left (${used}% used${resetText})`
    }

    return `5h: ${formatRemaining(primary)} | week: ${formatRemaining(secondary)}`
  }

  const matches = flattenPercentages(payload)
  if (matches.length > 0) {
    const preferred = matches
      .sort((a, b) => a.path.localeCompare(b.path))
      .map((item) => `${item.path}: ${item.value}%`)
    return preferred.join(" | ")
  }

  return JSON.stringify(payload, null, 2)
}

async function main() {
  const raw = process.argv.includes("--json") || process.argv.includes("--raw")
  const tempUserDataDir = await mkdtemp(join(tmpdir(), "opencode-codex-usage-"))
  const port = await getFreePort()
  let browser

  try {
    await copyBrowserState(tempUserDataDir)

    const braveArgs = [
      `--user-data-dir=${tempUserDataDir}`,
      `--profile-directory=${BRAVE_PROFILE}`,
      `--remote-debugging-port=${port}`,
      "--disable-gpu",
      "--no-first-run",
      "--no-default-browser-check",
      "--start-minimized",
      USAGE_PAGE,
    ]
    if (BRAVE_HEADLESS) {
      braveArgs.splice(3, 0, "--headless=new")
    }

    browser = spawn(BRAVE_PATH, braveArgs, {
      stdio: ["ignore", "ignore", "pipe"],
    })

    let stderr = ""
    browser.stderr.on("data", (chunk) => {
      stderr += chunk.toString()
    })

    const version = await waitForJson(`http://127.0.0.1:${port}/json/version`)
    const targets = await waitForJson(`http://127.0.0.1:${port}/json/list`)
    const page = targets.find((target) => target.type === "page")
    if (!page?.webSocketDebuggerUrl) {
      throw new Error("failed to locate a debuggable Brave page")
    }

    // Cloudflare clearance and app boot can take a moment even with a copied profile.
    await sleep(7000)

    const expression = `
      (async () => {
        const readJson = async (url) => {
          const response = await fetch(url, {
            credentials: 'include',
            headers: { Accept: 'application/json' },
          })
          const body = await response.text()
          let parsed = null
          try {
            parsed = JSON.parse(body)
          } catch {
            parsed = null
          }
          return {
            ok: response.ok,
            status: response.status,
            statusText: response.statusText,
            body,
            parsed,
          }
        }

        const session = await readJson('https://chatgpt.com/api/auth/session')
        const sessionData = session.parsed && typeof session.parsed === 'object' ? session.parsed : {}
        const accessToken = ${findFirstValue.toString()}(sessionData, (key, value) => {
          return typeof value === 'string' && /access_?token/i.test(key)
        })
        const accountId = ${findFirstValue.toString()}(sessionData, (key, value) => {
          return typeof value === 'string' && /(account_?id|workspace_?id|organization_?id)/i.test(key)
        })

        const headers = { Accept: 'application/json' }
        if (typeof accessToken === 'string' && accessToken.length > 0) {
          headers.Authorization = 'Bearer ' + accessToken
        }
        if (typeof accountId === 'string' && accountId.length > 0) {
          headers['chatgpt-account-id'] = accountId
        }

        const response = await fetch(${JSON.stringify(USAGE_ENDPOINT)}, {
          credentials: 'include',
          headers,
        })
        const body = await response.text()
        return JSON.stringify({
          ok: response.ok,
          status: response.status,
          statusText: response.statusText,
          body,
          sessionStatus: session.status,
          hasAccessToken: Boolean(accessToken),
          hasAccountId: Boolean(accountId),
          userAgent: navigator.userAgent,
          debugger: ${JSON.stringify(version.Browser || 'unknown')}
        })
      })()
    `
    const evaluated = await sendCdp(page.webSocketDebuggerUrl, expression)
    const result = JSON.parse(evaluated)
    let parsedBody
    try {
      parsedBody = JSON.parse(result.body)
    } catch {
      parsedBody = result.body
    }

    if (!result.ok) {
      const details = typeof parsedBody === "string" ? parsedBody : JSON.stringify(parsedBody, null, 2)
      throw new Error(`usage request failed (${result.status} ${result.statusText})\n${details}`)
    }

    if (raw) {
      process.stdout.write(`${JSON.stringify(parsedBody, null, 2)}\n`)
      return
    }

    process.stdout.write(`${summarizeUsage(parsedBody)}\n`)
  } finally {
    await stopBrowser(browser)
    await rm(tempUserDataDir, { recursive: true, force: true })
  }
}

main().catch((error) => {
  const message = error instanceof Error ? error.message : String(error)
  process.stderr.write(`${message}\n`)
  process.exitCode = 1
})
