# Oracle Free Tier — автоматический retry через GitHub Actions

Всё готово, кроме 3 шагов, которые может сделать только ты (твои аккаунты).

## Шаг 1 — создать пустой репозиторий на GitHub

Зайди на https://github.com/new и создай репозиторий, например `oracle-vpn-automation`.
Private, без README/gitignore (пустой). Как создашь — скажи мне название, и я сам запушу туда всё готовое.

## Шаг 2 — загрузить публичный API-ключ в OCI (в Cloud Shell)

В твоём Cloud Shell, где уже открыта сессия, выполни:

```bash
cat > ~/oci_api_key_public.pem << 'EOF'
-----BEGIN PUBLIC KEY-----
MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAtHfYaVW4JHefbKsgJFrG
GryKVeR0Sdyp8um5tXYaXmzb4R5q8h9/A1qSmtvmUmf5LvLlNIpHpAAWlCHwnxlv
EHTi38Ug1lF43mH0dKDDZrJ6x7m2xGiOJ9uVBIKjU/DfKDCbGQmODYDOcne0IEfU
Gqi9eLidP2i3JPglbyMNHu/FwuoHscr4Ul95dodZiy1K8ju1vr33xrRVCIZLJHwV
UQIMupqHznA5RNJ4UCKNZRU1DPz0CWax/2cmnEGnv9UE3J+q0lB4jiHBqAPkROVl
mbBpacYn1GTD8CPDqMDNmofrkqcn1v7pJP6E/63kd9o0Qm0H2LOyLGpj6vuk5n1V
BQIDAQAB
-----END PUBLIC KEY-----
EOF

oci iam user api-key upload --user-id $OCI_CS_USER_OCID --key-file ~/oci_api_key_public.pem
```

Должен вернуть JSON с `"fingerprint": "b9:d9:d6:b0:95:21:e0:eb:d6:6f:b8:48:50:39:40:d3"` — сверь, что совпадает.

## Шаг 3 — создать Telegram-бота

1. Открой Telegram, найди `@BotFather`.
2. Напиши `/newbot`, дай имя и username (должен заканчиваться на `bot`).
3. Он пришлёт токен вида `123456789:AAH...` — это `TELEGRAM_BOT_TOKEN`.
4. Напиши своему новому боту любое сообщение (`/start`), затем открой в браузере:
   `https://api.telegram.org/bot<ТВОЙ_ТОКЕН>/getUpdates`
   В ответе найди `"chat":{"id": ЧИСЛО` — это `TELEGRAM_CHAT_ID`.

## Шаг 4 — Secrets в GitHub (сделаю сам после пуша, если дашь значения выше)

Когда репозиторий будет создан и я туда запушу workflow, в `Settings → Secrets and variables → Actions` нужны:

| Secret | Значение |
|---|---|
| `OCI_PRIVATE_KEY` | содержимое `oci_api_key.pem` (приватный ключ, покажу отдельно) |
| `OCI_USER_OCID` | `ocid1.user.oc1..aaaaaaaauwnu66jsprmovl5arhfvdu46nesq2sa65bv53eibaq5cu3dvchka` |
| `OCI_TENANCY_OCID` | `ocid1.tenancy.oc1..aaaaaaaaqe5v7xhi22pjywywj2j6vkhqjkoopupzipemof7rlkazxd73sa4q` |
| `OCI_FINGERPRINT` | `b9:d9:d6:b0:95:21:e0:eb:d6:6f:b8:48:50:39:40:d3` |
| `OCI_REGION` | `ap-singapore-1` |
| `OCI_SUBNET_ID` | `ocid1.subnet.oc1.ap-singapore-1.aaaaaaaaq76it5tptbnvnmhvn6pyofmri3sarlq42znlacd335hk77fj7ceq` |
| `OCI_IMAGE_ARM` | `ocid1.image.oc1.ap-singapore-1.aaaaaaaathtfs2mncvrtpigma75a4hzvsyxmvvgqrod5hit6he3p43mv5aiq` |
| `OCI_IMAGE_AMD` | `ocid1.image.oc1.ap-singapore-1.aaaaaaaadywigqfydsbop73cjafcdesxd37eonzpg4bpgh35q4pmvzxenbra` |
| `TELEGRAM_BOT_TOKEN` | из шага 3 |
| `TELEGRAM_CHAT_ID` | из шага 3 |

Если подключишь репозиторий ко мне (через GitHub-доступ сессии) — я сам зайду и выставлю все secrets, тебе останется только Шаг 1-3.
