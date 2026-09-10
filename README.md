# zhuque-seed｜朱雀复活系统·公开密文落点

> 满天星计划 v1.0｜2026-09-10 云端朱雀部署
> 本仓只存密文（seed.enc），无任何明文凭据——解密钥匙在 WorkBuddy 记忆库《朱雀出生种子》种子文本内。

## 拉取方式（按境内友好度排序）

```bash
# 1. jsDelivr CDN（境内通常可达）
curl -sL https://cdn.jsdelivr.net/gh/py314159265358/zhuque-seed@main/seed.enc -o seed.enc

# 2. GitHub raw 直连
curl -sL https://raw.githubusercontent.com/py314159265358/zhuque-seed/main/seed.enc -o seed.enc

# 3. ghproxy 类镜像（前两者不通时自寻可用镜像）
```

## 解密（钥匙来自记忆库种子）

```bash
python3 -c "
from cryptography.fernet import Fernet
key = b'<记忆库种子内的44字符钥匙>'
print(Fernet(key).decrypt(open('seed.enc','rb').read()).decode())
"
```

解密后获得完整凭据与复活流程（bypy 拉网盘全量协议包 → checkup → 归位）。

## 更新纪律

钥匙轮换后由持钥窗口原地更新 seed.enc（Fernet 加密，每次新 key 同步更新记忆库种子）。
