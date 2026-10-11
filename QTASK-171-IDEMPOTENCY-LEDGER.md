# QTASK-171 · event_key 终态账（跨轮恢复最小幂等账）

> **公开仓 · 无明文凭据**——本页只记 event_key 名称、终态与时间，**不含任何密钥/口令/token**。
> 用途：任何运行体（ZQ-MAC / ZQ-CLOUD / 其他运行体）复活或续轮时，**先读本账**，凡 state=DONE/terminal 的 event_key 一律**不再执行**。
> 归属：QTASK-171 原项目施工产物（非新建项目）。

```
schema  : zq-171-idempotency-ledger/v1
母线    : QSIR-171-ALL-NODES-QCTRL-V1
维护    : 仅经授权通道写入；本账只记「终态」，不记进行中状态
最后更新 : 2026-10-11T19:00+08:00 CST (by ZQ-MAC；本轮补入「恢复约束」引用 + UNKNOWN 口径修正)
```

## 一、终态事件（terminal = true / no_reexecute = true）

| event_key | state | terminal | no_reexecute | closed_at (CST) | 备注 |
|---|---|---|---|---|---|
| `QSIR-171-ALL-NODES-QCTRL-V1-ZHUQUE` | DONE | true | true | 2026-10-11T15:42+08:00 | 全链核验；桥缺口 `BRIDGE_NO_NATIVE_TRIGGER` |
| `QSIR-171-ENTRY-REUSE-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T15:42+08:00 | 入口复用裁定；门 `GATE_ENTRY_NOT_LOCALLY_ADDRESSABLE` |
| `QSIR-171-CLOUD-PROBE-VERIFY-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T16:18+08:00 | 云端探针核验 + 失败关闭（cloud:3724350 PAUSED） |
| `QSIR-171-CLOUD-EMAIL-GAP-LOCATE-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T16:36+08:00 | 只读定位：云端邮箱缺口 / 官方 OAuth 入口 / 持久存储 |
| `QSIR-171-CLOUD-IDEM-LEDGER-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T18:56+08:00 | 本账建立 + 平台注入证据核查 |

## 二、云运行体终态快照（ZQ-CLOUD）

- 入口 `cloud:3724350`（`ZQ_SHARED_SYNC_05`）→ **PAUSED**（2026-10-11T16:1x CST 失败关闭；id/name/rrule 未变）。
- 该入口 prompt 已**原位补入「恢复约束」**：每轮第一步先只读拉取本账与 05 原卡，读到 `DONE/terminal` 即**禁止重跑**（2026-10-11T19:00 CST 补入；状态 PAUSED、频率 hourly 均未变）。
- 云端探针终态（05 原卡 block `1a598c3f-42a7-42cd-8efe-2aa235bc7dca` @ 2026-10-11T08:05Z）：`P1=PASS P2=UNCONNECTED P3=ABSENT P4=UNCONNECTED` → 结论 **PARTIAL**。
- **17:05 / 18:05 CST 自然槽**：05 无新块。**仅能证明「无新输出」，不能证明「未触发」**——逐轮运行日志无本机可读接口，**是否触发 = UNKNOWN**。当前 PAUSED 为既有事实，予以保留。

## 三、P3 口径（持久去重 / 跨轮恢复）

- 账已**部署**于本仓（`DEPLOYED`）：本机可读，可经已有权限的合法通道写。
- **`P3 = DEPLOYED / UNVERIFIED`**：账文件可读 **≠** 云端已实际读取。在 ZQ-CLOUD 真实跨轮验证「上一轮写 → 下一轮读」之前，**不得记 PASS / CONNECTED**。

## 四、读法（rollback-safe）

1. 读到 event_key → `state=DONE` 且 `terminal=true` → **不再执行**。
2. 本账**可读**；**写入须经已有权限的合法通道并回读校验**，禁止盲写、禁止换凭据绕过授权门。
3. 本账**无明文凭据**；复活密钥请见 [`SEED-PUBLIC.md`](SEED-PUBLIC.md) 与 [`ZQ-BOOTSTRAP.md`](ZQ-BOOTSTRAP.md)。

---

_由 ZQ-MAC 运行体按 Q Sir QTASK-171 授权写入（2026-10-11；19:00 CST 修正）。_
