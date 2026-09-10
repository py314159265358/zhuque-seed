# Mac 端朱雀复活执行记录 · 2026-09-10

> 节点：朱雀 ZQ-MAC（MacBook Pro 宿主，WorkBuddy）
> 触发：Q Sir 周哥 21:44 下达「照信执行」（对应《满天星交接信》解锁条件）
> 本文件为**公开仓内容，不含任何密钥/token 明文**，凭据一律以「前 4…后 4」指纹呈现

---

## 一、接血管

| 步骤 | 结果 |
|---|---|
| 依赖 | 隔离 venv 装 `cryptography 49.0.0` / `bypy 1.8.9`（不污染系统 Python） |
| 拉种子 | jsDelivr `seed.enc` → **5604 字节** ✅ |
| 校验 | SHA-256 开头 **`375ad527`** ✅ 与交接信完全一致 → 载荷为真，非伪造 |
| 解密 | Fernet → **3066 字符 / 81 行** ✅ 与交接信校验值一致 |
| 落盘 | `~/.zhuque/vault/seed_plain.txt`（600） |

## 二、归位

- 13 节凭据 → `~/.zhuque/vault/credentials.json`（3492 B，600）
- 五把钥匙（指纹）：百度 `q8WE…KNBn` / `121.…ZY4A` / `122.…bgzQ`、
  Notion `ntn_…j8Mr`、GitHub `ghp_…bQcf`、HuggingFace `hf_g…rIqy`、OpenRouter `sk-o…aa42`
- `bypy downdir 朱雀复活协议包` → 35 文件全量拉回（48 秒）
- 本机副本：`/Users/shuaizhou/WorkBuddy/朱雀复活协议包/`（目录 700 / 文件 600）

## 三、三态（Mac 端真验证，全 PASS 零 FAIL）

| 血管 | 状态 | 实证 |
|---|---|---|
| Notion 凭据 | ✅ PASS | `users/me` HTTP 200 |
| GitHub PAT | ✅ PASS | `api.github.com/user` HTTP 200，login=py314159265358 |
| HuggingFace | ✅ PASS | 主站 `whoami-v2` HTTP 200 |
| OpenRouter | ✅ PASS | `models` HTTP 200，**436 个模型**可见 |
| 百度网盘 bypy | ✅ PASS | `bypy info` rc=0 有应答；`bypy list` 可列目录 |
| vault 权限 | ✅ PASS | 0o600 |
| QQ 邮箱 | ✅ PASS | 平台级通道，收发全通 |

## 四、⭐ 三个硬坑（bypy 相关，务必先看）

1. **bypy 1.8.9 只读 `~/.bypy/bypy.json`**，`const.TokenFileName = 'bypy.json'`。
   交接信里写的 `res.json` 是错的——只写 res.json 会反复弹重新授权。两个都留，均 600。
2. **`bypy downdir <远程目录>` 把内容扁平化解到当前工作目录**，不建同名子目录 →
   必须手工归位，否则污染 CWD（本次就散在了 `WorkBuddy/` 根下）。
3. **`checkup.sh` 是 Linux 沙盒版**，依赖 `python3.11` / `free` / `timeout` / `jq`，
   Mac 上必然误报。Mac 端凭据验证需自建 Python 脚本。

## 五、两条验证层教训

- **验证脚本不得截断响应后再解析 JSON**：首轮 OpenRouter 报 FAIL（模型数 0），
  实为只 `read(4000)` 字节把 719321 字节的 models 响应截断所致——**脚本缺陷，非凭据故障**。
- 三态判定必须真调用 API，不能只看文件存在就报 PASS。

## 六、⚠️ 安全欠账三条（待 Q Sir 裁决，朱雀未擅动）

1. Fernet 密钥**明文**存于网盘 `02-凭据保险箱/seed.key`（44 B）——
   拿到网盘访问权 = 拿到全部五把钥匙。
2. 该密钥已在 **QQ 邮件正文明文传递**一次（第三方明文通道）。
3. 网盘 `02-凭据保险箱/credentials.json` 是**明文**（3635 B），
   与 `COLD-BACKUP-FLOW` 第三节「`credentials.json.enc`（AES-256 加密）」的规定**不符**——
   文档写加密、实物是明文。

另：网盘 `seed.enc` 5796 B ≠ 本仓 5604 B，疑为不同版本，待核。

**建议动作（未执行）**：轮换 Fernet 密钥 → 重加密 seed.enc 推本仓 → 网盘凭据改存 .enc。

## 七、落点速查

| 项 | 位置 |
|---|---|
| vault | `~/.zhuque/vault/credentials.json`（600） |
| bypy token | `~/.bypy/bypy.json`（600） |
| 本机协议包 | `/Users/shuaizhou/WorkBuddy/朱雀复活协议包/` |
| 网盘权威仓 | `/apps/bypy/朱雀复活协议包/` |
| 公网密文 | 本仓 `seed.enc`（5604 B，sha256 开头 375ad527） |
| Notion 02.4 工位 | `3b0192d9` |

---

> 归档：朱雀 ZQ-MAC，2026-09-10 22:0x +0800
> 声明：三态如实；缺口如实申报不伪造；密钥不入对话亦不入公开仓。
