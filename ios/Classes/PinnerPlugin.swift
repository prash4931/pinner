import Flutter
import UIKit
import Security
import CryptoKit

public class PinnerPlugin: NSObject, FlutterPlugin, URLSessionDelegate {

    private var result: FlutterResult?
    private var allowedPins: [String] = []
    private var expectedHost: String = ""

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "pinner", binaryMessenger: registrar.messenger())
        let instance = PinnerPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard call.method == "getSPKI",
              let args = call.arguments as? [String: Any],
              let host = args["host"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENT", message: "Invalid input", details: nil))
            return
        }

        self.result = result
        self.expectedHost = host
        self.allowedPins = args["pins"] as? [String] ?? []

        startRequest()
    }

    private func startRequest() {
        guard let url = URL(string: "https://\(expectedHost)") else {
            fail("Invalid URL")
            return
        }

        let config = URLSessionConfiguration.ephemeral
        config.timeoutIntervalForRequest = 10
        config.timeoutIntervalForResource = 10

        let session = URLSession(
            configuration: config,
            delegate: self,
            delegateQueue: nil
        )

        session.dataTask(with: url).resume()
    }

    public func urlSession(_ session: URLSession,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust,
              challenge.protectionSpace.host == expectedHost else {
            fail("Invalid host or trust")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Step 1: System trust validation
        guard SecTrustEvaluateWithError(trust, nil) else {
            fail("System trust failed")
            completionHandler(.cancelAuthenticationChallenge, nil)
            return
        }

        // Step 2: SPKI Pinning
        if let spki = findMatchingSPKI(trust: trust) {
            success(spki)
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            fail("Pin mismatch")
            completionHandler(.cancelAuthenticationChallenge, nil)
        }
    }

    // MARK: - Pin Validation
    private func findMatchingSPKI(trust: SecTrust) -> String? {
        let certCount = SecTrustGetCertificateCount(trust)

        for i in 0..<certCount {
            guard let cert = SecTrustGetCertificateAtIndex(trust, i),
                  let spki = extractSPKIHash(from: cert) else { continue }

            #if DEBUG
            print("🔐 SPKI[\(i)]: \(spki)")
            #endif

            if allowedPins.contains(spki) {
                return spki
            }
        }
        return nil
    }

    // MARK: - Correct SPKI Extraction (RSA + EC Safe)
    private func extractSPKIHash(from cert: SecCertificate) -> String? {
        guard let key = SecCertificateCopyKey(cert),
              let keyData = SecKeyCopyExternalRepresentation(key, nil) as Data? else {
            return nil
        }

        let keyType = SecKeyCopyAttributes(key) as NSDictionary?
        let keyTypeValue = keyType?[kSecAttrKeyType] as? String

        var spki: Data

        if keyTypeValue == (kSecAttrKeyTypeRSA as String) {
            // RSA header
            let rsaHeader: [UInt8] = [
                0x30, 0x82, 0x01, 0x22,
                0x30, 0x0d,
                0x06, 0x09,
                0x2a, 0x86, 0x48, 0x86,
                0xf7, 0x0d, 0x01, 0x01,
                0x01, 0x05, 0x00,
                0x03, 0x82, 0x01, 0x0f,
                0x00
            ]
            spki = Data(rsaHeader) + keyData

        } else {
            // EC (ECDSA) header
            let ecHeader: [UInt8] = [
                0x30, 0x59,
                0x30, 0x13,
                0x06, 0x07,
                0x2a, 0x86, 0x48, 0xce,
                0x3d, 0x02, 0x01,
                0x06, 0x08,
                0x2a, 0x86, 0x48, 0xce,
                0x3d, 0x03, 0x01, 0x07,
                0x03, 0x42,
                0x00
            ]
            spki = Data(ecHeader) + keyData
        }

        let hash = SHA256.hash(data: spki)
        return Data(hash).base64EncodedString()
    }

    // MARK: - Result Handling
    private func success(_ value: String) {
        guard let result = result else { return }
        self.result = nil
        result(value)
    }

    private func fail(_ message: String) {
        guard let result = result else { return }
        self.result = nil
        result(FlutterError(code: "PINNING_ERROR", message: message, details: nil))
    }
}
