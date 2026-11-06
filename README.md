# singbox-ruleset

专为中国大陆用户设计的 **sing-box** 规则集仓库，每日自动同步上游更新。

提供 **二进制 `.srs`** 与 **源格式 `.json`** 两种格式。

---

## 更新时间

每天 **北京时间 06:00**（UTC 22:00）通过 GitHub Actions 自动同步。

工作流只需跑一次 `scripts/update.sh`，**新增规则只需改脚本里的列表，一般不用改 workflow 文件本身**。

---

## 规则集列表

### 域名规则集（geosite）

#### 基础
| 规则集 | 用途 | 建议策略 |
|--------|------|----------|
| `private` | 私有/局域网 | direct |
| `ads` / `category-ads-all` | 广告 | reject |
| `cn` / `geolocation-cn` | 中国大陆域名 | direct |
| `geolocation-!cn` | 非中国大陆域名 | proxy |
| `httpdns` | HTTPDNS（防污染相关） | 按需（通常 direct 或 reject） |

#### 常用境外服务
| 规则集 | 用途 | 建议策略 |
|--------|------|----------|
| `google` | Google | proxy |
| `youtube` | YouTube | proxy |
| `netflix` | Netflix | proxy |
| `hbo` | HBO | proxy |
| `disney` | Disney+ | proxy |
| `primevideo` | Prime Video | proxy |
| `amazon` | Amazon | 按需 |
| `bahamut` | 巴哈姆特 | proxy |
| `telegram` | Telegram | proxy |
| `discord` | Discord | proxy |
| `twitter` | Twitter / X | proxy |
| `github` | GitHub | proxy / 按需 |
| `microsoft` | Microsoft | 按需 |
| `apple` | Apple | 按需 |
| `steam` | Steam | 按需 |
| `pixiv` | Pixiv | proxy |
| `plex` | Plex | 按需 |

#### AI 类（拆分）
| 规则集 | 服务 | 建议策略 |
|--------|------|----------|
| `openai` | OpenAI / ChatGPT | proxy |
| `anthropic` | Anthropic / Claude | proxy |
| `gemini` / `google-gemini` | Google Gemini | proxy |
| `deepseek` | DeepSeek | proxy / 按需 |
| `doubao` | 豆包 | direct / 按需 |
| `xai` | xAI / Grok | proxy |
| `perplexity` | Perplexity | proxy |

#### 境内主流
| 规则集 | 服务 | 建议策略 |
|--------|------|----------|
| `bilibili` | B站 | direct |
| `iqiyi` | 爱奇艺 | direct |
| `youku` | 优酷 | direct |
| `tencent` | 腾讯系 | direct |
| `jd` | 京东 | direct |
| `baidu` | 百度 | direct |
| `netease` | 网易 | direct |
| `douyin` | 抖音 | direct |
| `tiktok` | TikTok | proxy |
| `kuaishou` | 快手 | direct |
| `xiaohongshu` | 小红书 | direct |
| `zhihu` | 知乎 | direct |
| `bytedance` | 字节跳动 | direct |
| `cctv` | 央视 | direct |

#### 中国优化 & 分类
| 规则集 | 说明 | 建议策略 |
|--------|------|----------|
| `apple@cn` | Apple 中国相关 | direct |
| `microsoft@cn` | Microsoft 中国相关 | direct |
| `steam@cn` | Steam 中国相关 | 按需 |
| `category-games` | 游戏 | 按需 |
| `category-entertainment` | 娱乐 | 按需 |
| `category-entertainment@!cn` | 非中国娱乐 | proxy |
| `category-media` | 媒体 | 按需 |

### IP 规则集（geoip）

| 规则集 | 用途 | 建议策略 |
|--------|------|----------|
| `private` | 私有 IP | direct |
| `cn` | 中国大陆 IP | direct |
| `telegram` | Telegram IP | proxy |
| `google` | Google IP | proxy |
| `cloudflare` | Cloudflare | 按需 |
| `facebook` | Facebook IP | proxy |
| `twitter` | Twitter IP | proxy |
| `netflix` | Netflix IP | proxy |

---

## 上游没有独立规则集的说明

以下常见需求**上游目前没有独立 `.srs`**，需要自己写 source JSON 或 inline 规则：

| 需求 | 建议做法 |
|------|----------|
| **Emby / Jellyfin / 自建媒体** | 用自己的域名做 `domain` / `domain_suffix` 自定义规则集 |
| **PCDN** | 多数靠 IP/ASN 或进程规则，没有通用 geosite |
| **Fake-IP 过滤（fakeip-filter）** | 属于 DNS/路由策略，不是 geosite 分类；在 `dns` / `route` 里用 `ip_is_private`、自定义域名列表处理 |
| **Apple TV+ 独立集** | 可先用 `apple` / `disney` 等近似，或自行维护域名列表 |

如需，我可以再帮你在本仓库加一个 `custom/` 目录，专门放 Emby、Fake-IP 过滤等自定义规则模板。

---

## 不建议设置

- 堆大量国家二字码（`us`/`jp`/`kr`…）——命中率低、维护成本高
- 滥用宽泛 `category-*` ——容易误伤
- 强行让所有国内 App 走代理 ——体验和速度都会变差

---

## 使用示例

```json
{
  "route": {
    "rule_set": [
      {
        "type": "remote",
        "tag": "geosite-cn",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/cn.srs",
        "download_detour": "proxy"
      },
      {
        "type": "remote",
        "tag": "geosite-gemini",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/gemini.srs",
        "download_detour": "proxy"
      },
      {
        "type": "remote",
        "tag": "geosite-hbo",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/hbo.srs",
        "download_detour": "proxy"
      },
      {
        "type": "remote",
        "tag": "geoip-cn",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geoip/cn.srs",
        "download_detour": "proxy"
      }
    ]
  }
}
```

`download_detour` 由你在配置里决定走代理还是直连。

完整 DNS + Route 示例见 [`example-config.json`](./example-config.json)。

---

## 目录结构

```
├── geosite/               # 域名规则集 (.srs + .json)
├── geoip/                 # IP 规则集 (.srs + .json)
├── example-config.json
├── scripts/update.sh      # 同步列表在这里维护
└── .github/workflows/     # 每日定时任务
```

---

## 上游来源

- [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat)（sing 分支）
- [SagerNet/sing-geosite](https://github.com/SagerNet/sing-geosite)
- [SagerNet/sing-geoip](https://github.com/SagerNet/sing-geoip)

---

## 许可证

本仓库仅做同步与整理，规则版权归属原作者。
