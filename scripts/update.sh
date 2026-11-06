#!/usr/bin/env bash
set -euo pipefail

# 精简实用版规则集同步脚本
# 优先使用 MetaCubeX/meta-rules-dat (sing 分支)，同时兼容 SagerNet

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

# MetaCubeX (推荐，命名干净，同时有 .srs + .json)
META_GEOIP="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geoip"
META_GEOSITE="https://raw.githubusercontent.com/MetaCubeX/meta-rules-dat/sing/geo/geosite"

# SagerNet 备用
SAGER_GEOSITE="https://raw.githubusercontent.com/SagerNet/sing-geosite/rule-set"
SAGER_GEOIP="https://raw.githubusercontent.com/SagerNet/sing-geoip/rule-set"

GEOSITE_NAMES=(
  private
  category-ads-all
  cn
  geolocation-cn
  geolocation-!cn
  google
  youtube
  netflix
  openai
  telegram
  discord
  twitter
  github
  microsoft
  apple
  steam
  bilibili
  category-games
)

GEOIP_NAMES=(
  private
  cn
  telegram
  google
  cloudflare
  facebook
  twitter
  netflix
)

echo "==> Syncing geosite..."
for name in "${GEOSITE_NAMES[@]}"; do
  # 优先 MetaCubeX
  if ! download "${META_GEOSITE}/${name}.srs" "geosite/${name}.srs"; then
    # 备用 SagerNet 命名
    download "${SAGER_GEOSITE}/geosite-${name}.srs" "geosite/${name}.srs" || true
  fi
  # json 源格式
  download "${META_GEOSITE}/${name}.json" "geosite/${name}.json" || true
done

# 兼容 ads 别名
if [[ -f geosite/category-ads-all.srs && ! -f geosite/ads.srs ]]; then
  cp geosite/category-ads-all.srs geosite/ads.srs
  [[ -f geosite/category-ads-all.json ]] && cp geosite/category-ads-all.json geosite/ads.json || true
  echo "✓ geosite/ads.srs (alias of category-ads-all)"
fi

echo "==> Syncing geoip..."
for name in "${GEOIP_NAMES[@]}"; do
  if ! download "${META_GEOIP}/${name}.srs" "geoip/${name}.srs"; then
    download "${SAGER_GEOIP}/geoip-${name}.srs" "geoip/${name}.srs" || true
  fi
  download "${META_GEOIP}/${name}.json" "geoip/${name}.json" || true
done

echo "==> Summary"
echo "geosite:"
ls -1 geosite/*.srs 2>/dev/null | sed 's|.*/||' || echo "(none)"
echo "geoip:"
ls -1 geoip/*.srs 2>/dev/null | sed 's|.*/||' || echo "(none)"
echo "Done."
