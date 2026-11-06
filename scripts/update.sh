#!/usr/bin/env bash
set -euo pipefail

mkdir -p geosite geoip

download() {
  local url="$1"
  local dest="$2"
  if curl -fsSL --retry 3 --retry-delay 1 -o "$dest.tmp" "$url"; then
    mv "$dest.tmp" "$dest"
    echo "✓ $dest"
    return 0
  else
    rm -f "$dest.tmp"
    return 1
  fi
}

META_GEOIP="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip"
META_GEOSITE="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite"
SAGER_GEOSITE="https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set"
SAGER_GEOIP="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set"

GEOSITE_NAMES=(
  # 基础
  private category-ads-all cn geolocation-cn geolocation-!cn

  # 常用境外服务
  google youtube netflix telegram discord twitter github microsoft apple steam

  # 流媒体补充
  hbo disney primevideo amazon bahamut plex

  # AI 类（拆分）
  openai anthropic deepseek doubao xai perplexity google-gemini

  # 境内主流
  bilibili iqiyi youku tencent jd baidu netease douyin tiktok kuaishou xiaohongshu zhihu bytedance cctv

  # 其他常用
  pixiv httpdns

  # 中国优化版本 & 分类
  apple@cn microsoft@cn steam@cn
  category-games category-entertainment category-media category-entertainment@!cn
)

GEOIP_NAMES=(private cn telegram google cloudflare facebook twitter netflix)

echo "==> Syncing geosite..."
for name in "${GEOSITE_NAMES[@]}"; do
  if ! download "${META_GEOSITE}/${name}.srs" "geosite/${name}.srs"; then
    download "${SAGER_GEOSITE}/geosite-${name}.srs" "geosite/${name}.srs" || true
  fi
  download "${META_GEOSITE}/${name}.json" "geosite/${name}.json" || true
done

# 别名
if [[ -f geosite/category-ads-all.srs && ! -f geosite/ads.srs ]]; then
  cp geosite/category-ads-all.srs geosite/ads.srs
  [[ -f geosite/category-ads-all.json ]] && cp geosite/category-ads-all.json geosite/ads.json || true
  echo "✓ geosite/ads.srs (alias)"
fi
if [[ -f geosite/google-gemini.srs && ! -f geosite/gemini.srs ]]; then
  cp geosite/google-gemini.srs geosite/gemini.srs
  [[ -f geosite/google-gemini.json ]] && cp geosite/google-gemini.json geosite/gemini.json || true
  echo "✓ geosite/gemini.srs (alias of google-gemini)"
fi

echo "==> Syncing geoip..."
for name in "${GEOIP_NAMES[@]}"; do
  if ! download "${META_GEOIP}/${name}.srs" "geoip/${name}.srs"; then
    download "${SAGER_GEOIP}/geoip-${name}.srs" "geoip/${name}.srs" || true
  fi
  download "${META_GEOIP}/${name}.json" "geoip/${name}.json" || true
done

echo "==> Summary"
echo "geosite ($(ls geosite/*.srs 2>/dev/null | wc -l)):"
ls -1 geosite/*.srs 2>/dev/null | sed 's|.*/||' | sort
echo "geoip ($(ls geoip/*.srs 2>/dev/null | wc -l)):"
ls -1 geoip/*.srs 2>/dev/null | sed 's|.*/||' | sort
echo "Done."
