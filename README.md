# singbox-ruleset

专为中国大陆用户设计的 **sing-box** 规则集仓库，每日自动同步上游更新。

提供 **二进制 `.srs`** 与 **源格式 `.json`** 两种格式，开箱即用。

---

## 更新时间

- 每天 **北京时间 06:00** 自动同步（UTC 22:00）
- 使用 GitHub Actions 从可靠上游拉取并提交

## 规则集列表（精简实用 + AI 拆分 + 境内主流）

### 域名规则集（geosite）

#### 基础
| 规则集 | 建议用途 | 推荐策略 |
|--------|----------|----------|
| `private` | 私有/局域网域名 | direct |
| `ads` / `category-ads-all` | 广告域名 | reject |
| `cn` / `geolocation-cn` | 中国大陆域名 | direct |
| `geolocation-!cn` | 非中国大陆域名 | proxy |

#### 常用境外服务
| 规则集 | 建议用途 | 推荐策略 |
|--------|----------|----------|
| `google` | Google 系 | proxy |
| `youtube` | YouTube | proxy |
| `netflix` | Netflix | proxy |
| `telegram` | Telegram | proxy |
| `discord` | Discord | proxy |
| `twitter` | Twitter / X | proxy |
| `github` | GitHub | proxy（或按需） |
| `microsoft` | Microsoft | 按需（多数可 direct） |
| `apple` | Apple | 按需（多数可 direct） |
| `steam` | Steam | 按需 |

#### AI 类（已拆分）
| 规则集 | 对应服务 | 推荐策略 |
|--------|----------|----------|
| `openai` | OpenAI / ChatGPT | proxy |
| `anthropic` | Anthropic / Claude | proxy |
| `deepseek` | DeepSeek | proxy / 按需 |
| `doubao` | 豆包 | direct / 按需 |
| `xai` | xAI / Grok | proxy |
| `perplexity` | Perplexity | proxy |

#### 境内主流（便于精细分流）
| 规则集 | 对应服务 | 推荐策略 |
|--------|----------|----------|
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
| `bytedance` | 字节跳动系 | direct |
| `cctv` | 央视 | direct |

#### 中国优化版本 & 分类
| 规则集 | 说明 | 推荐策略 |
|--------|------|----------|
| `apple@cn` | Apple 中国相关 | direct |
| `microsoft@cn` | Microsoft 中国相关 | direct |
| `steam@cn` | Steam 中国相关 | 按需 |
| `category-games` | 游戏相关 | 按需 |
| `category-entertainment` | 娱乐 | 按需 |
| `category-media` | 媒体 | 按需 |

### IP 规则集（geoip）

| 规则集 | 建议用途 | 推荐策略 |
|--------|----------|----------|
| `private` | 私有 IP 段 | direct |
| `cn` | 中国大陆 IP | direct |
| `telegram` | Telegram IP | proxy |
| `google` | Google IP | proxy |
| `cloudflare` | Cloudflare | 按需 |
| `facebook` | Facebook IP | proxy |
| `twitter` | Twitter IP | proxy |
| `netflix` | Netflix IP | proxy |

### 不建议设置的内容

- 过多国家/地区二字码规则（如大量 `us.srs`、`jp.srs` 等），实际命中率低且增加维护成本
- 过于宽泛的 `category-*` 规则滥用（容易误伤）
- 强制把所有国内 App 都走代理（反而影响体验与速度）
- 频繁变动且容易误杀的广告/隐私规则（建议用成熟的 `ads` / `category-ads-all`）

---

## 使用方法

### 1. 远程引用（推荐）

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
        "tag": "geosite-openai",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/openai.srs",
        "download_detour": "proxy"
      },
      {
        "type": "remote",
        "tag": "geosite-anthropic",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/anthropic.srs",
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

> `download_detour` 由你在配置里决定走代理还是直连。GitHub 在国内通常需要代理访问。

也可以使用 raw 地址：

```
https://raw.githubusercontent.com/dian-sen/singbox-ruleset/main/geosite/cn.srs
```

### 2. 完整示例配置

请直接查看仓库根目录的 [`example-config.json`](./example-config.json)，包含完整的 DNS + Route 配置示例。

---

## 目录结构

```
├── geosite/          # 域名规则集 (.srs + .json)
├── geoip/            # IP 规则集 (.srs + .json)
├── example-config.json
├── scripts/
│   └── update.sh
└── .github/workflows/
    └── update.yml    # 需手动添加（见下方）
```

---

## GitHub Actions 每日更新

因 Token 权限限制，工作流文件需手动添加一次：

路径：`.github/workflows/update.yml`

```yaml
name: Daily Update Rule Sets

on:
  schedule:
    - cron: '0 22 * * *'   # 北京时间 06:00
  workflow_dispatch:

permissions:
  contents: write

jobs:
  update:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - name: Sync rule sets
        run: bash scripts/update.sh
      - name: Commit and push
        run: |
          git config user.name "github-actions[bot]"
          git config user.email "github-actions[bot]@users.noreply.github.com"
          git add geosite/ geoip/ || true
          if ! git diff --staged --quiet; then
            git commit -m "chore: daily update rule-sets $(date -u +%Y-%m-%d)"
            git push
          fi
```

添加后可在 Actions 页面手动触发测试。

---

## 上游来源

- [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat) (sing 分支)
- [SagerNet/sing-geosite](https://github.com/SagerNet/sing-geosite) (rule-set)
- [SagerNet/sing-geoip](https://github.com/SagerNet/sing-geoip) (rule-set)

感谢以上项目维护者。

---

## 许可证

本仓库仅做同步与整理，规则版权归属原作者。使用请遵循上游项目许可证。
