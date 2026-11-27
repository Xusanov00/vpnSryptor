# Google Cloud WireGuard VPN — тестовый сервер

## Шаг 1 — регистрация (только твоими руками)

1. Зайди на https://cloud.google.com/free
2. Зарегистрируйся (карта только для холда, деньги не спишут)
3. Создай проект (любое имя, например `vpn-test`)

## Шаг 2 — открой Cloud Shell

В консоли Google Cloud (вверху справа) нажми иконку терминала `>_` (Activate Cloud Shell).
Это такой же браузерный терминал, как был у Oracle — gcloud CLI уже внутри, ничего ставить не надо.

## Шаг 3 — создать VM и открыть порт (вставь в Cloud Shell)

```bash
gcloud compute instances create vpn-server \
  --zone=asia-southeast1-b \
  --machine-type=e2-small \
  --image-family=ubuntu-2204-lts \
  --image-project=ubuntu-os-cloud \
  --tags=vpn-server

gcloud compute firewall-rules create allow-wireguard \
  --allow=udp:51820 \
  --target-tags=vpn-server \
  --direction=INGRESS
```

Подожди ~30-60 сек, пока VM поднимется, затем узнай её внешний IP:

```bash
gcloud compute instances describe vpn-server --zone=asia-southeast1-b --format='get(networkInterfaces[0].accessConfigs[0].natIP)'
```

## Шаг 4 — зайти по SSH и запустить установку WireGuard

Прямо из того же Cloud Shell:

```bash
gcloud compute ssh vpn-server --zone=asia-southeast1-b
```

(Первый раз gcloud сам сгенерирует SSH-ключи — просто соглашайся на всё, что спросит).

Когда окажешься внутри VM (поменяется промпт), вставь этот скрипт одной командой (скачивает и сразу выполняет мой готовый установщик):

```bash
curl -fsSL https://raw.githubusercontent.com/Xusanov00/vpnSryptor/main/gcp/setup_wireguard.sh -o setup_wireguard.sh
chmod +x setup_wireguard.sh
sudo ./setup_wireguard.sh
```

В конце скрипт сам:
- установит и настроит WireGuard
- покажет QR-код прямо в терминале — сканируешь официальным приложением **WireGuard** из App Store на iPhone
- выведет текстовый конфиг на случай, если QR не отсканируется

## Шаг 5 — iOS

1. Установи бесплатное приложение **WireGuard** (разработчик: WireGuard Development Team) из App Store
2. В приложении: `+` → `Create from QR code` → наведи камеру на QR из терминала
3. Один раз вручную включи туннель в приложении, чтобы iOS создала системный VPN-профиль
4. В Shortcuts (Команды) теперь появится этот туннель как доступный для действия **"Set VPN"** — настраивай автоматизацию как и хотел изначально
