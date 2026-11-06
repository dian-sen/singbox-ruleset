# singbox-ruleset

专为中国大陆用户设计的 **sing-box** 规则集仓库，每日自动同步上游更新。

提供 **二进制 `.srs`** 与 **源格式 `.json`** 两种格式。

---

## 更新时间

每天 **北京时间 06:00**（UTC 22:00）通过 GitHub Actions 执行 `scripts/update.sh`。

新增规则只需改脚本中的列表，**一般不必改 workflow 本身**。

---

## 上游来源

按优先级依次尝试：

| 来源 | 用途 |
|------|------|
| [MetaCubeX/meta-rules-dat](https://github.com/MetaCubeX/meta-rules-dat)（`sing` 分支） | 主源，geosite + geoip，同时有 srs/json |
| [SagerNet/sing-geosite](https://github.com/SagerNet/sing-geosite) + [sing-geoip](https://github.com/SagerNet/sing-geoip)（`rule-set` 分支） | 官方 rule-set 备用 |
| [DustinWin/ruleset_geodata](https://github.com/DustinWin/ruleset_geodata)（`sing-box-ruleset` Release） | 补充 appletv、fakeip-filter、ai、media 等 |
| [vernette/rulesets](https://github.com/vernette/rulesets) | 补充部分 AI / 流媒体规则 |
| [Loyalsoldier/geoip](https://github.com/Loyalsoldier/geoip)（`release/srs`） | geoip 备用 |

---

## 规则集列表（节选）

### 基础 / 防污染
`private` · `ads` · `category-ads-all` · `cn` · `geolocation-cn` · `geolocation-!cn` · `httpdns` · **`fakeip-filter`** · **`fakeip-filter-lite`**

### 境外常用 & 流媒体
`google` · `youtube` · `netflix` · `hbo` · `disney` · `primevideo` · `amazon` · **`appletv`** · `bahamut` · `plex` · `telegram` · `discord` · `twitter` · `github` · `microsoft` · `apple` · `steam` · `pixiv`

### AI（拆分）
`openai` · `anthropic` · `gemini` / `google-gemini` · `deepseek` · `doubao` · `xai` · `perplexity` · `ai`（合集）

### 境内主流
`bilibili` · `iqiyi` · `youku` · `tencent` · `jd` · `baidu` · `netease` · `douyin` · `tiktok` · `kuaishou` · `xiaohongshu` · `zhihu` · `bytedance` · `cctv`

### 中国优化 & 分类
`apple@cn` · `microsoft@cn` · `steam@cn` · `category-games` · `category-entertainment` · `category-entertainment@!cn` · `category-media` · `media`

### GeoIP
`private` · `cn` · `telegram` · `google` · `cloudflare` · `facebook` · `twitter` · `netflix`

完整文件见仓库 [`geosite/`](./geosite) 与 [`geoip/`](./geoip) 目录。

---

## 上游仍无独立集的说明

| 需求 | 建议 |
|------|------|
| Emby / Jellyfin / 自建媒体 | 用自有域名写 `domain` / `domain_suffix` 自定义规则 |
| PCDN | 通常靠 IP/ASN 或进程规则，无通用 geosite |
| 更细的 Apple TV+ 域名 | 已提供 `appletv`（DustinWin），可再叠加 `apple` |

需要的话可在本仓库增加 `custom/` 模板目录。

---

## 不建议设置

- 堆大量国家二字码规则（命中率低）
- 滥用宽泛 `category-*`（易误伤）
- 强制所有国内 App 走代理

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
        "tag": "geosite-fakeip-filter",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/fakeip-filter.srs",
        "download_detour": "proxy"
      },
      {
        "type": "remote",
        "tag": "geosite-appletv",
        "format": "binary",
        "url": "https://cdn.jsdelivr.net/gh/dian-sen/singbox-ruleset@main/geosite/appletv.srs",
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

完整 DNS + Route 示例见 [`example-config.json`](./example-config.json)。

---

## 目录结构

```
├── geosite/                 # 域名规则集 (.srs + .json)
├── geoip/                   # IP 规则集 (.srs + .json)
├── example-config.json
├── scripts/update.sh        # 多上游同步逻辑
└── .github/workflows/       # 每日定时任务
```

---

## 许可证

本仓库仅做同步与整理，规则版权归属各上游作者。
