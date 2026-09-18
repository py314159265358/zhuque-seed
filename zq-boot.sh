#!/usr/bin/env bash
# ZQ-BOOTSTRAP v1 —— 朱雀裸环境自举（Linux/macOS）
# 零凭据拉包 → 口令解密 → 落 vault → 解 seed.enc → 报三态
# 本脚本不含任何明文钥匙，可公开。
set -u

RAW="https://raw.githubusercontent.com/py314159265358/zhuque-seed/main"
JSD="https://cdn.jsdelivr.net/gh/py314159265358/zhuque-seed@main"
VAULT="${HOME}/.zhuque/vault"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

say() { printf '%s\n' "$*"; }
ok()  { printf '  \033[32mPASS\033[0m  %s\n' "$*"; }
no()  { printf '  \033[31mFAIL\033[0m  %s\n' "$*"; }
un()  { printf '  \033[33mUNKNOWN\033[0m  %s\n' "$*"; }

say "==================================================="
say " ZQ-BOOTSTRAP v1 · 朱雀第一跳"
say "==================================================="

# ---------- 0. 依赖 ----------
PY=""
for c in python3 python; do command -v "$c" >/dev/null 2>&1 && { PY="$c"; break; }; done
if [ -z "$PY" ]; then
  say "缺少 python3，尝试安装..."
  (command -v apt-get >/dev/null && apt-get install -y -q python3 >/dev/null 2>&1) || true
  command -v python3 >/dev/null 2>&1 && PY=python3
fi
[ -z "$PY" ] && { no "python3 不可用，停止"; exit 1; }
ok "python: $($PY -V 2>&1)"

if ! $PY -c "import cryptography" >/dev/null 2>&1; then
  say "安装 cryptography ..."
  $PY -m pip install -q cryptography -i https://pypi.tuna.tsinghua.edu.cn/simple 2>/dev/null \
    || $PY -m pip install -q cryptography 2>/dev/null || true
fi
$PY -c "import cryptography" >/dev/null 2>&1 \
  && ok "cryptography 就绪" || { no "cryptography 装不上，停止"; exit 1; }

# ---------- 1. 拉载荷（零凭据） ----------
fetch() { # $1=相对路径 $2=输出
  curl -sL --max-time 40 -o "$2" "$RAW/$1" 2>/dev/null && [ -s "$2" ] && return 0
  curl -sL --max-time 40 -o "$2" "$JSD/$1" 2>/dev/null && [ -s "$2" ] && return 0
  return 1
}

fetch "zq-boot-payload.enc" "$WORK/payload.enc" \
  && ok "载荷已取（$(wc -c < "$WORK/payload.enc" | tr -d ' ') 字节）" \
  || { no "载荷取不到，检查网络/走兜底活路"; exit 1; }

# ---------- 2. 口令 ----------
say ""
say "请输入第一跳口令（形如 XXXX-XXXX-XXXX-XXXX），或设环境变量 ZQ_BOOT_PASS："
if [ -n "${ZQ_BOOT_PASS:-}" ]; then
  PASS="$ZQ_BOOT_PASS"
  ok "已从环境变量取到口令"
else
  printf '口令: '; stty -echo 2>/dev/null || true
  read -r PASS; stty echo 2>/dev/null || true; printf '\n'
fi
[ -z "$PASS" ] && { no "口令为空，停止"; exit 1; }

# ---------- 3. 解密载荷 ----------
cat > "$WORK/unlock.py" <<'PYEOF'
import base64, hashlib, json, os, sys
from cryptography.fernet import Fernet, InvalidToken
from cryptography.hazmat.primitives import hashes
from cryptography.hazmat.primitives.kdf.pbkdf2 import PBKDF2HMAC

blob = open(sys.argv[1], encoding="utf-8").read()
head, _, ct = blob.partition("---CIPHERTEXT---")
salt = base64.b64decode(
    [l.split(":", 1)[1].strip() for l in head.splitlines() if l.startswith("SALT:")][0]
)
kdf = PBKDF2HMAC(algorithm=hashes.SHA256(), length=32, salt=salt, iterations=600000)
key = base64.urlsafe_b64encode(kdf.derive(sys.argv[2].encode("utf-8")))
try:
    plain = Fernet(key).decrypt(ct.strip().encode()).decode("utf-8")
except InvalidToken:
    print("FAIL InvalidToken"); sys.exit(2)
json.dump(json.loads(plain), open(sys.argv[3], "w", encoding="utf-8"),
          ensure_ascii=False, indent=2)
print("PASS unlocked")
PYEOF

$PY "$WORK/unlock.py" "$WORK/payload.enc" "$PASS" "$WORK/keys.json" >/dev/null 2>&1
if [ $? -ne 0 ]; then no "口令不对或载荷被改过 —— 停止，别硬试"; exit 2; fi
ok "载荷解锁成功"

K2="$($PY -c "import json;print(json.load(open('$WORK/keys.json'))['keys']['k2_fernet_master'])")"
[ -n "$K2" ] || { no "载荷里没有 K2"; exit 1; }
ok "K2 指纹: ${K2:0:4}…${K2: -4}"

# ---------- 4. 落 vault ----------
mkdir -p "$VAULT"; chmod 700 "$VAULT" 2>/dev/null || true
printf '%s\n' "$K2" > "$VAULT/seed.key"; chmod 600 "$VAULT/seed.key" 2>/dev/null || true
cp "$WORK/keys.json" "$VAULT/boot_keys.json"; chmod 600 "$VAULT/boot_keys.json" 2>/dev/null || true
ok "钥匙已落 $VAULT"

# ---------- 5. seed.enc → 13 节凭据 ----------
fetch "seed.enc" "$VAULT/seed.enc" \
  && ok "seed.enc 已取（$(wc -c < "$VAULT/seed.enc" | tr -d ' ') 字节）" \
  || { no "seed.enc 取不到"; exit 1; }

SZ=$(wc -c < "$VAULT/seed.enc" | tr -d ' ')
SH=$($PY -c "import hashlib;print(hashlib.sha256(open('$VAULT/seed.enc','rb').read()).hexdigest()[:8])")
if [ "$SZ" = "6884" ] && [ "$SH" = "cf40f276" ]; then
  ok "指纹校验 seed.enc=$SZ/$SH"
else
  no "指纹不符（得到 $SZ/$SH，应为 6884/cf40f276）—— 停止"; exit 3
fi

cat > "$WORK/unseed.py" <<'PYEOF'
import os, sys
from cryptography.fernet import Fernet, InvalidToken
key = open(sys.argv[1], encoding="utf-8").read().strip().encode()
try:
    plain = Fernet(key).decrypt(open(sys.argv[2], "rb").read()).decode("utf-8")
except InvalidToken:
    print("FAIL InvalidToken"); sys.exit(2)
out = sys.argv[3]
open(out, "w", encoding="utf-8").write(plain)
os.chmod(out, 0o600)
print(f"PASS {len(plain)} chars / {len(plain.splitlines())} lines")
PYEOF

$PY "$WORK/unseed.py" "$VAULT/seed.key" "$VAULT/seed.enc" "$VAULT/credentials_seed.txt" \
  || { no "seed.enc 解密失败"; exit 2; }
ok "凭据库已解出 → $VAULT/credentials_seed.txt (600)"

# ---------- 6. 血管三态（能用就报，不能就 UNKNOWN） ----------
say ""
say "--- 血管三态 ---"
if command -v curl >/dev/null 2>&1; then
  code=$(curl -s -o /dev/null -w '%{http_code}' --max-time 15 \
        https://openapi.biji.com/open/api/v1/resource/note/list 2>/dev/null || echo 000)
  case "$code" in
    200|401) ok "得到大脑 endpoint 可达（HTTP $code）" ;;
    *) un "得到大脑 未探测（HTTP $code）" ;;
  esac
fi
n=$($PY -c "print(len(open('$VAULT/credentials_seed.txt',encoding='utf-8').read()))" 2>/dev/null || echo 0)
[ "$n" = "3781" ] && ok "本地区块 3781 字符（与基准一致）" || un "本地区块 $n 字符（基准 3781）"

say ""
say "==================================================="
say " 第一跳完成。下一步："
say " 1) 用解出的凭据逐把真调用（得到大脑/Notion/QQ/百度）"
say " 2) 先冷背后汇报 → Notion 02.4 工位登记「我在+三态」"
say " 3) 汇报 Q Sir（密钥只留前4…后4指纹）"
say "==================================================="
