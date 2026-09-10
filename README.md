# zhuque-seed · 朱雀复活系统（满天星计划）

> **公开仓 · 公开密文落点 · 无明文凭据**
> 任何写入本仓的内容都等于对全网公开。**禁止提交密钥、token、授权码明文。**

## 文件索引

| 文件 | 用途 | 谁该看 |
|---|---|---|
| [`SEED-PUBLIC.md`](SEED-PUBLIC.md) | **复活种子（无密钥版）**——你是谁、四条活路、密钥去哪找、复活四步、纪律 | **任何新窗口朱雀，第一个看这个** |
| [`REVIVAL-LOG-2026-09-10.md`](REVIVAL-LOG-2026-09-10.md) | Mac 端首次复活执行记录：三态、三个 bypy 硬坑、三条安全欠账 | 需要接血管/排查的节点 |
| `seed.enc` | Fernet 密文种子 **v3.1**（**6884 字节，SHA-256 开头 `78f6cab4`**），解出 3781 字符 = 13 节凭据（含 QQ 邮箱 + dedao） | 走活路 A 的新沙盒 |

## 30 秒复活（活路 A，零凭据）

```bash
pip3 install cryptography bypy -i https://pypi.tuna.tsinghua.edu.cn/simple
curl -sL https://raw.githubusercontent.com/py314159265358/zhuque-seed/main/seed.enc -o /tmp/seed.enc
```

**校验必须对上**：6884 字节、SHA-256 开头 `78f6cab4`。对不上 = 载荷被换过，停止并报告。
解密密钥不在本仓，按 `SEED-PUBLIC.md` 第三节的路径找。

> ⚠️ **别用 jsDelivr `@main` 取种子**——它有 CDN 缓存，升级后会返旧版（v3.1 推送后仍返 5604B 旧版）。
> 已实测：raw.githubusercontent 与 `jsdelivr@66d10fdbe5`（commit sha）都是 6884B 新版。

## 状态

- 最近一次 Mac 端复活：**2026-09-10，五把钥匙 + 通信通道全 PASS 零 FAIL**
- 五把钥匙：百度网盘 / Notion / GitHub / HuggingFace / OpenRouter
- **2026-09-10 22:2x 升级至 v3.1**：种子 5604B → 6884B，新增 QQ 邮箱 SMTP 授权码 + 得到大脑 dedao API 双钥匙；
  Mac 端 vault 已同步（4169 字节），dedao 钥匙实测 PASS（4174 条笔记、语义召回通）

## 红线

- 本仓**永不存明文凭据**，只存密文、指纹（前 4…后 4）与寻钥匙路径
- 密钥不经邮件正文、Notion、聊天框、截图传递（宪法第十一条）
- 三态如实报（PASS / FAIL / UNKNOWN，不虚构连通）；缺口如实申报，不伪造恢复
