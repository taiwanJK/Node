const axios = require('axios');
const crypto = require('crypto');
const { SocksProxyAgent } = require('socks-proxy-agent');
const ProxyChecker = require('./proxyChecker');

class Bot {
  constructor(config, logger) {
    this.config = config;
    this.logger = logger;
    this.proxyCheck = new ProxyChecker(config, logger);
  }

  async connect(token, proxy = null) {
    try {
      const userAgent = 'Mozilla/5.0 ... Safari/537.3';
      const accountInfo = await this.getSession(token, userAgent, proxy);

      console.log(
        `✅ ${'Connected to session'.green} for UID: ${accountInfo.uid}`
      );
      this.logger.info('Session info', {
        uid: accountInfo.uid,
        name: accountInfo.name,
        useProxy: !!proxy,
      });

      console.log('');

      const interval = setInterval(async () => {
        try {
          await this.sendPing(accountInfo, token, userAgent, proxy);
        } catch (error) {
          console.log(`❌ ${'Ping error'.red}: ${error.message}`);
          this.logger.error('Ping error', { error: error.message });
        }
      }, this.config.retryInterval);

      process.on('SIGINT', () => clearInterval(interval));
    } catch (error) {
      console.log(`❌ ${'Connection error'.red}: ${error.message}`);
      this.logger.error('Connection error', { error: error.message, proxy });
    }
  }

  async getSession(token, userAgent, proxy) {
    try {
      const config = {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
          'User-Agent': userAgent,
          Accept: 'application/json',
        },
      };

      if (proxy) {
        config.httpAgent = this.buildSocksProxyAgent(proxy);
        config.httpsAgent = this.buildSocksProxyAgent(proxy);
      }

      const response = await axios.post(this.config.sessionURL, {}, config);
      return response.data.data;
    } catch (error) {
      throw new Error('Session request failed');
    }
  }

  async sendPing(accountInfo, token, userAgent, proxy) {
    const uid = accountInfo.uid || crypto.randomBytes(8).toString('hex');
    const browserId =
      accountInfo.browser_id || crypto.randomBytes(8).toString('hex');

    const pingData = {
      id: uid,
      browser_id: browserId,
      timestamp: Math.floor(Date.now() / 1000),
      version: '2.2.7',
    };

    try {
      const config = {
        headers: {
          Authorization: `Bearer ${token}`,
          'Content-Type': 'application/json',
          'User-Agent': userAgent,
          Accept: 'application/json',
        },
      };

      if (proxy) {
        config.httpAgent = this.buildSocksProxyAgent(proxy);
        config.httpsAgent = this.buildSocksProxyAgent(proxy);
      }

      await axios.post(this.config.pingURL, pingData, config);
      console.log(`📡 ${'Ping sent'.cyan} for UID: ${uid}`);
      this.logger.info('Ping sent', {
        uid,
        browserId,
        ip: proxy ? proxy.host : 'direct',
      });
    } catch (error) {
      throw new Error('Ping request failed');
    }
  }

  buildSocksProxyAgent(proxy) {
    if (!proxy || !proxy.host || !proxy.port) {
      return null;
    }

    const proxyUrl = `socks5://${proxy.host}:${proxy.port}`;
    if (proxy.username && proxy.password) {
      const auth = `${encodeURIComponent(proxy.username)}:${encodeURIComponent(proxy.password)}@`;
      return new SocksProxyAgent(`socks5://${auth}${proxy.host}:${proxy.port}`);
    }
    return new SocksProxyAgent(proxyUrl);
  }
}

module.exports = Bot;