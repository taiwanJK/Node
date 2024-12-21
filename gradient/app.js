const { Builder, By, until, Capabilities } = require("selenium-webdriver")
const chrome = require("selenium-webdriver/chrome")
const url = require("url")
const fs = require("fs")
const crypto = require("crypto")
const request = require("request")
const path = require("path")
const FormData = require("form-data")
const proxy = require("selenium-webdriver/proxy")
const proxyChain = require("proxy-chain")
require('console-stamp')(console, {
  format: ':date(yyyy/mm/dd HH:MM:ss.l)'
})
require("dotenv").config()

const extensionId = "caacbgbklghmpodbdafajbgdnegacfmo"
const CRX_URL = `https://clients2.google.com/service/update2/crx?response=redirect&prodversion=98.0.4758.102&acceptformat=crx2,crx3&x=id%3D${extensionId}%26uc&nacl_arch=x86-64`
const USER_AGENT =
  "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/98.0.4758.102 Safari/537.36"

const USER = process.env.APP_USER || ""
const PASSWORD = process.env.APP_PASS || ""
const ALLOW_DEBUG = !!process.env.DEBUG?.length || false
const EXTENSION_FILENAME = "app.crx"
const PROXY = process.env.PROXY || undefined

console.log("-> 启动中...")
console.log("-> 用户:", USER)
console.log("-> 密码:", PASSWORD)
console.log("-> SOCKS5代理:", SOCKS5_PROXY)
console.log("-> 调试模式:", ALLOW_DEBUG)

if (!USER || !PASSWORD) {
  console.error("请设置 APP_USER 和 APP_PASS 环境变量")
  process.exit()
}

if (!SOCKS5_PROXY) {
  console.error("请设置 SOCKS5_PROXY 环境变量");
  process.exit();
}

if (ALLOW_DEBUG) {
  console.log(
    "-> 调试模式已启用! 错误时会生成截图和控制台日志!"
  )
}

async function downloadExtension(extensionId) {
  const url = CRX_URL.replace(extensionId, extensionId)
  const headers = { "User-Agent": USER_AGENT }

  console.log("-> 正在从以下地址下载扩展:", url)

  if (fs.existsSync(EXTENSION_FILENAME) && fs.statSync(EXTENSION_FILENAME).mtime > Date.now() - 86400000) {
    console.log("-> 扩展已下载! 跳过下载...")
    return
  }

  return new Promise((resolve, reject) => {
    request({ url, headers, encoding: null }, (error, response, body) => {
      if (error) {
        console.error("下载扩展时出错:", error)
        return reject(error)
      }
      fs.writeFileSync(EXTENSION_FILENAME, body)
      if (ALLOW_DEBUG) {
        const md5 = crypto.createHash("md5").update(body).digest("hex")
        console.log("-> 扩展 MD5: " + md5)
      }
      resolve()
    })
  })
}

async function takeScreenshot(driver, filename) {
  if (!ALLOW_DEBUG) {
    return
  }

  const data = await driver.takeScreenshot()
  fs.writeFileSync(filename, Buffer.from(data, "base64"))
}

async function generateErrorReport(driver) {
  const dom = await driver.findElement(By.css("html")).getAttribute("outerHTML")
  fs.writeFileSync("error.html", dom)

  await takeScreenshot(driver, "error.png")

  const logs = await driver.manage().logs().get("browser")
  fs.writeFileSync(
    "error.log",
    logs.map((log) => `${log.level.name}: ${log.message}`).join("\n")
  )
}

async function getDriverOptions() {
  const options = new chrome.Options()

  options.addArguments("--headless")
  options.addArguments("--single-process")
  options.addArguments(`user-agent=${USER_AGENT}`)
  options.addArguments("--remote-allow-origins=*")
  options.addArguments("--disable-dev-shm-usage")
  options.addArguments('enable-automation')
  options.addArguments("--window-size=1920,1080")
  options.addArguments("--start-maximized")
  options.addArguments("--disable-renderer-backgrounding")
  options.addArguments("--disable-background-timer-throttling")
  options.addArguments("--disable-backgrounding-occluded-windows")
  options.addArguments("--disable-low-res-tiling")
  options.addArguments("--disable-client-side-phishing-detection")
  options.addArguments("--disable-crash-reporter")
  options.addArguments("--disable-oopr-debug-crash-dump")
  options.addArguments("--disable-infobars")
  options.addArguments("--dns-prefetch-disable")
  options.addArguments("--disable-crash-reporter")
  options.addArguments("--disable-in-process-stack-traces")
  options.addArguments("--disable-popup-blocking")
  options.addArguments("--disable-gpu")
  options.addArguments("--disable-web-security")
  options.addArguments("--disable-default-apps")
  options.addArguments("--ignore-certificate-errors")
  options.addArguments("--ignore-ssl-errors")
  options.addArguments("--no-sandbox")
  options.addArguments("--no-crash-upload")
  options.addArguments("--no-zygote")
  options.addArguments("--no-first-run")
  options.addArguments("--no-default-browser-check")
  options.addArguments("--remote-allow-origins=*")
  options.addArguments("--allow-running-insecure-content")
  options.addArguments("--enable-unsafe-swiftshader")

  if (!ALLOW_DEBUG) {
    // options.addArguments("--blink-settings=imagesEnabled=false")
  }

  if (SOCKS5_PROXY) {
    console.log("-> 设置 SOCKS5 代理中...");

    const proxyAuth = `${SOCKS5_USERNAME}:${SOCKS5_PASSWORD}`;
    const proxyUrl = SOCKS5_PROXY.replace("socks5://", "");

    options.addArguments(
      `--proxy-server=socks5://${proxyAuth}@${proxyUrl}`
    );

    console.log("-> SOCKS5 代理设置完成!");
  } else {
    console.log("-> 未设置代理!");
  }

  return options
}

async function getProxyIpInfo(driver, proxyUrl) {
  const url = "https://myip.ipip.net"

  console.log("-> 获取代理IP信息:", proxyUrl)

  try {
    await driver.get(url)
    await driver.wait(until.elementLocated(By.css("body")), 30000)
    const pageText = await driver.findElement(By.css("body")).getText()
    console.log("-> 代理IP信息:", pageText)
  } catch (error) {
    console.error("-> 获取代理IP信息失败:", error)
    throw new Error("获取代理IP信息失败!")
  }
}

(async () => {
  await downloadExtension(extensionId)

  const options = await getDriverOptions()

  options.addExtensions(path.resolve(__dirname, EXTENSION_FILENAME))

  console.log(`-> 扩展已添加! ${EXTENSION_FILENAME}`)

  if (ALLOW_DEBUG) {
    options.addArguments("--enable-logging")
    options.addArguments("--v=1")
  }

  let driver
  try {
    console.log("-> 启动浏览器...")

    driver = await new Builder()
      .forBrowser("chrome")
      .setChromeOptions(options)
      .build()

    console.log("-> 浏览器已启动!")

    if (PROXY) {
      try {
        await getProxyIpInfo(driver, PROXY)
      } catch (error) {
        throw new Error("获取代理IP信息失败，请通过命令 'curl -vv -x ${PROXY} https://myip.ipip.net' 检查代理")
      }
    }

    console.log("-> 已启动! 正在登录 https://app.gradient.network/...")
    await driver.get("https://app.gradient.network/")

    const emailInput = By.css('[placeholder="Enter Email"]')
    const passwordInput = By.css('[type="password"]')
    const loginButton = By.css("button")

    await driver.wait(until.elementLocated(emailInput), 30000)
    await driver.wait(until.elementLocated(passwordInput), 30000)
    await driver.wait(until.elementLocated(loginButton), 30000)

    await driver.findElement(emailInput).sendKeys(USER)
    await driver.findElement(passwordInput).sendKeys(PASSWORD)
    await driver.findElement(loginButton).click()

    await driver.wait(until.elementLocated(By.css('a[href="/dashboard/setting"]')), 30000)

    console.log("-> 已登录! 等待打开扩展...")

    takeScreenshot(driver, "logined.png")

    await driver.get(`chrome-extension://${extensionId}/popup.html`)

    console.log("-> 扩展已打开!")

    await driver.wait(
      until.elementLocated(By.xpath('//div[contains(text(), "Status")]')),
      30000
    )

    console.log("-> 扩展已加载!")

    try {
      const gotItButton = await driver.findElement(
        By.xpath('//button[contains(text(), "I got it")]')
      )
      await gotItButton.click()
      console.log('-> "我知道了"按钮已点击!')
    } catch (error) {
      const dom = await driver
        .findElement(By.css("html"))
        .getAttribute("outerHTML")
      fs.writeFileSync("dom.html", dom)
      console.error('-> 未找到 "我知道了" 按钮!(跳过)')
    }

    try {
      const notAvailable = await driver.findElement(
        By.xpath(
          '//*[contains(text(), "Sorry, Gradient is not yet available in your region.")]'
        )
      )
      console.log("-> 抱歉,Gradient 在您所在的地区暂不可用。")
      await driver.quit()
      process.exit(1)
    } catch (error) {
      console.log("-> Gradient 在您所在的地区可用。")
    }

    const supportStatus = await driver
      .findElement(By.css(".absolute.mt-3.right-0.z-10"))
      .getText()

    if (ALLOW_DEBUG) {
      const dom = await driver
        .findElement(By.css("html"))
        .getAttribute("outerHTML")
      fs.writeFileSync("dom.html", dom)
      await takeScreenshot(driver, "status.png")
    }

    console.log("-> 状态:", supportStatus)

    if (supportStatus.includes("Disconnected")) {
      console.log(
        "-> 连接失败! 请检查以下内容: ",
      )
      console.log(`
    - 确保代理正常工作,可以通过 'curl -vv -x ${PROXY} https://myip.ipip.net' 检查
    - 确保 docker 镜像是最新的,通过 'docker pull overtrue/gradient-bot' 更新并重启容器
    - 官方服务本身不太稳定。所以看到异常情况是正常的。耐心等待它会自动重启
    - 如果您使用免费代理,可能被官方服务封禁。请尝试其他静态住宅代理
  `)
      await generateErrorReport(driver)
      await driver.quit()
      setTimeout(() => {
        process.exit(1)
      }, 5000)
    }

    console.log("-> 已连接! 开始运行...")

    takeScreenshot(driver, "connected.png")

    console.log({
      support_status: supportStatus,
    })

    console.log("-> 已启动!")

    setInterval(() => {
      driver.getTitle().then((title) => {
        console.log(`-> [${USER}] 运行中...`, title)
      })

      if (PROXY) {
        console.log(`-> [${USER}] 使用代理 ${PROXY} 运行中...`)
      } else {
        console.log(`-> [${USER}] 未使用代理运行中...`)
      }
    }, 30000)
  } catch (error) {
    console.error("发生错误:", error)
    console.error(error.stack)

    if (driver) {
      await generateErrorReport(driver)
      console.error("-> 错误报告已生成!")
      console.error(fs.readFileSync("error.log").toString())
      driver.quit()
    }

    process.exit(1)
  }
})()