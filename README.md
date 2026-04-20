# 🔐 Pinner – SSL Pinning (SPKI) for Flutter

A lightweight and secure Flutter plugin for **SSL Certificate Pinning using SPKI (SHA-256)** on both Android & iOS.

Protect your app from **Man-in-the-Middle (MITM) attacks** by verifying the server's public key instead of trusting system CAs alone.

---

## ✨ Features

* 🔐 **SPKI (SHA-256) Pinning** – Industry-standard approach
* 📱 **iOS & Android Support**
* ⚡ **Lightweight & Fast**
* 🛡️ **Prevents MITM Attacks**
* 🔄 **Supports Multiple Pins (Backup Pins)**
* 🧪 **Built-in Debug Logging**
* 🎯 **Simple API**

---

## 📸 Demo

<img src="https://via.placeholder.com/300x600.png?text=SSL+Pinning+Demo" width="250" />

---

## 🚀 Getting Started

Add dependency:

```yaml
dependencies:
  pinner: ^1.0.0
```

---

## 🧪 Usage

```dart
import 'package:pinner/pinner.dart';

final pinner = Pinner();

final isSecure = await pinner.verify(
  host: "sha256.badssl.com",
  pins: [
    "chBKGC2E4cdpgMD2jlsFLLJvoujxm9EUKcSlUiZN6Rc=",
  ],
);

if (isSecure) {
  print("✅ Connection Secure");
} else {
  print("❌ Pin Mismatch");
}
```

---

## ⚠️ Important Notes

* This example uses **sha256.badssl.com** for demonstration.
* Always use your **own backend domain and SPKI pins** in production.
* Pinning to public domains like Google is **not recommended** for production apps.

---

## 🔐 What is SPKI Pinning?

SPKI (Subject Public Key Info) pinning ensures that your app only trusts a **specific public key**, even if the certificate changes.

```text
Certificate → Public Key → SHA-256 Hash → Pin
```

This is the same approach used by:

* Google
* Meta
* OWASP

---

## 🛠️ How to Generate Pins

### Option 1: Using OpenSSL

```bash
echo | openssl s_client -connect yourdomain.com:443 -servername yourdomain.com 2>/dev/null \
| openssl x509 -pubkey -noout \
| openssl pkey -pubin -outform der \
| openssl dgst -sha256 -binary \
| openssl enc -base64
```

---

### Option 2: Using Pinner (Debug)

Enable logging and run:

```dart
await pinner.verify(host: "yourdomain.com", pins: []);
```

Check console logs:

```text
SPKI[0]: xxxxxxxxxxxxxxxxxxxxxxxxx=
SPKI[1]: yyyyyyyyyyyyyyyyyyyyyyyyy=
```

---

## 🔄 Backup Pins (Recommended)

Always provide at least **2 pins**:

```dart
pins: [
  "primary_pin",
  "backup_pin",
]
```

This ensures your app continues working when certificates rotate.

---

## ❌ Failure Handling

If pinning fails:

* Connection will be **blocked**
* `PlatformException` will be thrown

Handle it like:

```dart
try {
  await pinner.verify(...);
} catch (e) {
  // Handle securely
}
```

---

## 📱 Platform Support

| Platform | Supported |
| -------- | --------- |
| Android  | ✅ Yes     |
| iOS      | ✅ Yes     |

---

## 🧪 Example App

Check the `/example` folder for a complete working demo.

---

## 🛡️ Security Best Practices

* Never hardcode pins without backup
* Always use HTTPS
* Rotate pins before certificate expiry
* Avoid disabling pinning in production

---

## 🤝 Contributing

Pull requests are welcome! Feel free to open issues or suggest improvements.

---

## 📄 License

MIT License

---

## ⭐ Support

If you like this package, give it a ⭐ on pub.dev and GitHub!

---

## 👨‍💻 Author

Built with ❤️ for secure Flutter apps.
