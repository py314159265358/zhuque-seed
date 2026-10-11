# QTASK-171 · event_key 终态账（跨轮恢复最小幂等账）

> **公开仓 · 无明文凭据**——本页只记 event_key 名称、终态与时间，**不含任何密钥/口令/token**。
> 用途：任何运行体（ZQ-MAC / ZQ-CLOUD / 其他运行体）复活或续轮时，**先读本账**，凡 state=DONE/terminal 的 event_key 一律**不再执行**。
> 归属：QTASK-171 原项目施工产物（非新建项目）。

```
schema  : zq-171-idempotency-ledger/v1
母线    : QSIR-171-ALL-NODES-QCTRL-V1
维护    : 仅经授权通道写入；本账只记「终态」，不记进行中状态
最后更新 : 2026-10-11T18:50+08:00 CST (by ZQ-MAC 运行体)
```

## 一、终态事件（terminal = true / no_reexecute = true）

| event_key | state | terminal | no_reexecute | closed_at (CST) | 备注 |
|---|---|---|---|---|---|
| `QSIR-171-ALL-NODES-QCTRL-V1-ZHUQUE` | DONE | true | true | 2026-10-11T15:42+08:00 | 全链核验；桥缺口 `BRIDGE_NO_NATIVE_TRIGGER` |
| `QSIR-171-ENTRY-REUSE-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T15:42+08:00 | 入口复用裁定；门 `GATE_ENTRY_NOT_LOCALLY_ADDRESSABLE` |
| `QSIR-171-CLOUD-PROBE-VERIFY-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T16:18+08:00 | 云端探针核验 + 失败关闭（cloud:3724350 PAUSED） |
| `QSIR-171-CLOUD-EMAIL-GAP-LOCATE-ZHUQUE-20261011` | DONE | true | true | 2026-10-11T16:36+08:00 | 只读定位：云端邮箱缺口 / 官方 OAuth 入口 / 持久存储 |

## 二、云运行体终态快照（ZQ-CLOUD）

- 入口 `cloud:3724350`（`ZQ_SHARED_SYNC_05`）→ **PAUSED**（2026-10-11T16:1x CST 失败关闭；id/name/rrule/prompt 未变）。
- 云端探针终态（05 原卡 block `1a598c3f-42a7-42cd-8efe-2aa235bc7dca` @ 2026-10-11T08:05Z）：`P1=PASS P2=UNCONNECTED P3=ABSENT P4=UNCONNECTED` → 结论 **PARTIAL**。
- 17:05 / 18:05 CST 自然槽**未运行**（无新输出）→ 保持 PAUSED。

## 三、读法（rollback-safe）

1. 读到 event_key → `state=DONE` 且 `terminal=true` → **不再执行**。
2. 本账**可读**；**写入须经授权通道并回读校验**，禁止盲写。
3. 本账**无明文凭据**；复活密钥请见 [`SEED-PUBLIC.md`](SEED-PUBLIC.md) 与 [`ZQ-BOOTSTRAP.md`](ZQ-BOOTSTRAP.md)。

---

_由 ZQ-MAC 运行体按 Q Sir QTASK-171 授权写入（2026-10-11）。_
