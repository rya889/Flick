import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/models.dart';

/// Thin client for Flick `/v1/tldr` (Plus-gated AI proxy).
class TldrApi {
  TldrApi({String? baseUrl})
      : baseUrl = (baseUrl ?? const String.fromEnvironment(
              'FLICK_API_BASE',
              defaultValue: '',
            ))
            .trim();

  /// Empty = same origin (web deploy) or relative path.
  final String baseUrl;

  Uri _uri(String path) {
    if (baseUrl.isEmpty) {
      return Uri.parse(path);
    }
    final root = baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    return Uri.parse('$root$path');
  }

  Future<TldrHealth> health() async {
    try {
      final res = await http.get(_uri('/v1/health')).timeout(const Duration(seconds: 8));
      if (res.statusCode != 200) {
        return const TldrHealth(ok: false);
      }
      final data = jsonDecode(res.body) as Map<String, dynamic>;
      final providers = data['providers'] as Map<String, dynamic>? ?? {};
      return TldrHealth(
        ok: data['ok'] == true,
        groq: providers['groq'] == true,
        gemini: providers['gemini'] == true,
        gateway: providers['gateway'] == true,
      );
    } catch (_) {
      return const TldrHealth(ok: false);
    }
  }

  Future<TldrResult> request({
    required TldrSubmode mode,
    required String text,
    String? contentHash,
    required String entitlementHeader,
    String? appUserId,
  }) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
      'X-Flick-Entitlement': entitlementHeader,
    };
    if (appUserId != null && appUserId.isNotEmpty) {
      headers['X-Flick-App-User'] = appUserId;
    }

    final res = await http
        .post(
          _uri('/v1/tldr'),
          headers: headers,
          body: jsonEncode({
            'mode': mode.name,
            'contentHash': contentHash,
            'text': text,
          }),
        )
        .timeout(const Duration(seconds: 45));

    final data = jsonDecode(res.body.isEmpty ? '{}' : res.body) as Map<String, dynamic>;
    if (res.statusCode >= 400) {
      return TldrResult(
        ok: false,
        error: (data['error'] as String?) ?? 'HTTP ${res.statusCode}',
        code: data['code'] as String?,
      );
    }
    return TldrResult(
      ok: true,
      text: (data['text'] as String?)?.trim() ?? '',
      model: data['model'] as String?,
      cached: data['cached'] == true,
    );
  }
}

class TldrHealth {
  const TldrHealth({
    required this.ok,
    this.groq = false,
    this.gemini = false,
    this.gateway = false,
  });

  final bool ok;
  final bool groq;
  final bool gemini;
  final bool gateway;

  bool get anyProvider => groq || gemini || gateway;
}

class TldrResult {
  const TldrResult({
    required this.ok,
    this.text = '',
    this.model,
    this.cached = false,
    this.error,
    this.code,
  });

  final bool ok;
  final String text;
  final String? model;
  final bool cached;
  final String? error;
  final String? code;
}
