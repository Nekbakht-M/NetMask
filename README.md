# NetMask

IP subnet calculator for system administrators. Android first, desktop later (Flutter).

**Тоҷикӣ** · Калкулятори зершабакаи IPv4 ва IPv6 барои мудирони система.
**Русский** · Калькулятор подсетей IPv4 и IPv6 для системных администраторов.

## Features (planned)
- IPv4: network class filter, subnet mask dropdown (/1–/32), full result table, extra fields behind "More details".
- "All networks" list on a separate screen.
- IPv6: prefix /1–/128, full address, network, range, total addresses.
- Languages: Tajik (default), Russian, English — choice is remembered.
- Dark/light theme, calculation history, copy any value.

See [docs/plan.md](docs/plan.md) for the full plan.

## Development
- `flutter test` — calculation tests (values checked against calculator.net).
- `flutter test --update-goldens --run-skipped -t screens` — renders screen snapshots to `test/goldens/` for layout review.
- APK: GitHub → Actions → **Build Android APK** → Run workflow. The APK appears in Releases.
- `prototype/index.html` — the approved HTML mockup.

Fonts: JetBrains Mono and IBM Plex Sans, SIL Open Font License (see `assets/fonts/`).

## Author
Created by **Neka** · Telegram [@Neka_m](https://t.me/Neka_m) — websites, Android apps and software to order.
