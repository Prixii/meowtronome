import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:pub_semver/pub_semver.dart';

class AppUpdateInfo {
  const AppUpdateInfo({
    required this.version,
    required this.releaseNotes,
    required this.htmlUrl,
  });

  final String version;
  final String releaseNotes;
  final String htmlUrl;
}

class UpdateChecker {
  UpdateChecker({http.Client? client}) : _client = client;

  static const _owner = 'Prixii';
  static const _repo = 'meowtronome';

  final http.Client? _client;

  Future<AppUpdateInfo?> checkForUpdate() async {
    final uri = Uri.https(
      'api.github.com',
      '/repos/$_owner/$_repo/releases/latest',
    );
    const headers = {
      'Accept': 'application/vnd.github+json',
      'X-GitHub-Api-Version': '2022-11-28',
    };
    final response = _client == null
        ? await http.get(uri, headers: headers)
        : await _client.get(uri, headers: headers);

    if (response.statusCode == 404) {
      return null;
    }
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('GitHub release request failed: ${response.statusCode}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final tagName = json['tag_name'] as String? ?? '';
    final remoteVersion = _parseVersion(tagName);
    if (remoteVersion == null) {
      throw Exception('Invalid release tag: $tagName');
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final localVersion = _parseVersion(packageInfo.version);
    if (localVersion == null) {
      throw Exception('Invalid local version: ${packageInfo.version}');
    }

    if (remoteVersion <= localVersion) {
      return null;
    }

    final body = (json['body'] as String?)?.trim() ?? '';
    final htmlUrl =
        (json['html_url'] as String?) ??
        'https://github.com/$_owner/$_repo/releases/tag/$tagName';

    return AppUpdateInfo(
      version: tagName.startsWith('v') ? tagName.substring(1) : tagName,
      releaseNotes: body.isEmpty ? '暂无更新说明' : body,
      htmlUrl: htmlUrl,
    );
  }

  Version? _parseVersion(String raw) {
    final normalized = raw.trim();
    if (normalized.isEmpty) return null;
    final withoutPrefix =
        normalized.startsWith('v') || normalized.startsWith('V')
        ? normalized.substring(1)
        : normalized;
    try {
      return Version.parse(withoutPrefix);
    } on FormatException {
      return null;
    }
  }
}
