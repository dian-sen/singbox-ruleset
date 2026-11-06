#!/usr/bin/env bash
set -euo pipefail

# 多上游同步：
# 1. MetaCubeX/meta-rules-dat (sing)
# 2. SagerNet/sing-geosite + sing-geoip (rule-set)
# 3. DustinWin/ruleset_geodata (sing-box-ruleset release)
# 4. vernette/rulesets (srs) — 补充 AI / 流媒体等

mkdir -p geosite geoip

download() {
  local url="$1"
  local dest="$2"
  if [[ -f "$dest" ]]; then
    return 0
  fi
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
DUSTIN_REL="https://github.com/DustinWin/ruleset_geodata/releases/download/sing-box-ruleset"
VERNETTE="https://raw.githubusercontent.com/vernette/rulesets/main/srs"
LOYAL_GEOIP="https://raw.githubusercontent.com/Loyalsoldier/geoip/release/srs"

GEOSITE_NAMES=(
  private category-ads-all cn geolocation-cn geolocation-!cn httpdns
  google youtube netflix hbo disney primevideo amazon bahamut plex
  telegram discord twitter github microsoft apple steam pixiv
  openai anthropic deepseek doubao xai perplexity google-gemini
  bilibili iqiyi youku tencent jd baidu netease douyin tiktok kuaishou xiaohongshu zhihu bytedance cctv
  apple@cn microsoft@cn steam@cn
  category-games category-entertainment category-media category-entertainment@!cn
)

GEOIP_NAMES=(private cn telegram google cloudflare facebook twitter netflix)

echo "==> [1/4] MetaCubeX geosite..."
for name in "${GEOSITE_NAMES[@]}"; do
  download "${META_GEOSITE}/${name}.srs" "geosite/${name}.srs" || true
  download "${META_GEOSITE}/${name}.json" "geosite/${name}.json" || true
done

echo "==> [2/4] SagerNet fallback geosite..."
for name in "${GEOSITE_NAMES[@]}"; do
  download "${SAGER_GEOSITE}/geosite-${name}.srs" "geosite/${name}.srs" || true
done

echo "==> [3/4] DustinWin release (appletv / fakeip-filter / ai / media ...)"
# DustinWin 使用不同命名，单独拉取关键补充
declare -A DUSTIN_MAP=(
  [appletv]=appletv
  [fakeip-filter]=fakeip-filter
  [fakeip-filter-lite]=fakeip-filter-lite
  [ai]=ai
  [media]=media
  [ads]=ads
  [cn]=cn
  [bilibili]=bilibili
  [disney]=disney
)
for local_name in "${!DUSTIN_MAP[@]}"; do
  remote_name="${DUSTIN_MAP[$local_name]}"
  download "${DUSTIN_REL}/${remote_name}.srs" "geosite/${local_name}.srs" || true
  download "${DUSTIN_REL}/${remote_name}.json" "geosite/${local_name}.json" || true
done

echo "==> [4/4] vernette/rulesets 补充 (claude/copilot/grok/gemini ...)"
for name in claude copilot gemini grok openai youtube netflix telegram tiktok discord spotify; do
  download "${VERNETTE}/${name}.srs" "geosite/${name}.srs" || true
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
  echo "✓ geosite/gemini.srs (alias)"
fi
if [[ -f geosite/claude.srs && ! -f geosite/anthropic.srs ]]; then
  cp geosite/claude.srs geosite/anthropic.srs || true
fi
if [[ -f geosite/grok.srs && ! -f geosite/xai.srs ]]; then
  cp geosite/grok.srs geosite/xai.srs || true
fi

echo "==> GeoIP (MetaCubeX -> SagerNet -> Loyalsoldier) -> geoip-{name}.*"
for name in "${GEOIP_NAMES[@]}"; do
  download "${META_GEOIP}/${name}.srs" "geoip/geoip-${name}.srs" || true
  download "${META_GEOIP}/${name}.json" "geoip/geoip-${name}.json" || true
  download "${SAGER_GEOIP}/geoip-${name}.srs" "geoip/geoip-${name}.srs" || true
  download "${LOYAL_GEOIP}/${name}.srs" "geoip/geoip-${name}.srs" || true
done

python3 scripts/filter_ai.py || true
if command -v sing-box >/dev/null; then
  sing-box rule-set compile geosite/ai.json -o geosite/ai.srs 2>/dev/null || true
fi
echo "==> Summary"
echo "geosite ($(ls geosite/*.srs 2>/dev/null | wc -l)):"
ls -1 geosite/*.srs 2>/dev/null | sed 's|.*/||' | sort
echo "geoip ($(ls geoip/*.srs 2>/dev/null | wc -l)):"
ls -1 geoip/*.srs 2>/dev/null | sed 's|.*/||' | sort
echo "Done."
