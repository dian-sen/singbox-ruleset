#!/usr/bin/env python3
"""Remove domestic China AI domains from geosite/ai.json"""
import json
from pathlib import Path

path = Path("geosite/ai.json")
if not path.exists():
    raise SystemExit(0)

data = json.loads(path.read_text())
cn_kw = [
    "kimi", "moonshot", "doubao", "deepseek", "baichuan", "zhipu", "chatglm",
    "qwen", "tongyi", "qianwen", "wenxin", "ernie", "yiyan", "hunyuan",
    "spark", "xfyun", "sensetime", "minimaxi", "01.ai", "yi.com", "lingyi",
    "internlm", "skywork", "volcengine", "volces", "thudm",
]

def is_cn(s: str) -> bool:
    s = str(s).lower()
    return any(k in s for k in cn_kw)

def filt(obj):
    if isinstance(obj, dict):
        out = {}
        for k, v in obj.items():
            if k in ("domain", "domain_suffix", "domain_keyword", "domain_regex") and isinstance(v, list):
                out[k] = [x for x in v if not is_cn(x)]
            else:
                out[k] = filt(v)
        return out
    if isinstance(obj, list):
        return [filt(x) for x in obj]
    return obj

path.write_text(json.dumps(filt(data), ensure_ascii=False, indent=2) + "\n")
print("✓ filtered domestic AI from geosite/ai.json")
