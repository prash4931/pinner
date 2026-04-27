# Changelog

All notable changes to this project will be documented in this file.

The format is based on Keep a Changelog, and this project adheres to Semantic Versioning.

---

## [0.0.1] - 2026-04-27

### 🎉 Initial Release

### ✨ Features

* SSL pinning using **SPKI (SHA-256)**
* Cross-platform support:

  * Android (native implementation)
  * iOS (URLSessionDelegate-based pinning)
* MethodChannel-based communication between Flutter and native layers
* Platform interface for testability and extensibility
* Support for multiple pins (primary + backup)

### 🔐 Security

* Validates full certificate chain
* Performs system trust validation before pinning
* Protects against Man-in-the-Middle (MITM) attacks

### 🧪 Testing

* Unit tests for core logic
* Method channel tests
* Integration tests with real hosts

### 📦 Example

* Example app demonstrating SSL pinning usage

---

## Upcoming

* Dio integration helper
* Multi-domain support
* Automated SPKI generation
* Improved error handling and logging
