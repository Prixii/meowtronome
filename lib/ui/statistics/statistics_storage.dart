import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:meowtronome/ui/statistics/provider/statistics_state.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class StatisticsStorage {
  Directory? _directory;

  Future<void> init({Directory? directory}) async {
    if (directory != null) {
      _directory = directory;
    } else if (_directory == null) {
      final docs = await getApplicationDocumentsDirectory();
      _directory = Directory(p.join(docs.path, 'statistics'));
    }
    await _directory!.create(recursive: true);
  }

  @visibleForTesting
  void resetForTest() {
    _directory = null;
  }

  File fileForYear(int year) {
    final dir = _directory;
    if (dir == null) {
      throw StateError('StatisticsStorage.init() must be called first');
    }
    return File(p.join(dir.path, '$year.json'));
  }

  Future<YearlyStatistics> loadYear(int year) async {
    final file = fileForYear(year);
    if (!await file.exists()) {
      return const YearlyStatistics();
    }

    try {
      final raw = await file.readAsString();
      if (raw.isEmpty) {
        return const YearlyStatistics();
      }
      final json = jsonDecode(raw);
      if (json is! Map<String, dynamic>) {
        return const YearlyStatistics();
      }
      return YearlyStatistics.fromJson(json);
    } on FormatException {
      return const YearlyStatistics();
    } on FileSystemException {
      return const YearlyStatistics();
    }
  }

  Future<void> saveYear(int year, YearlyStatistics statistics) async {
    final file = fileForYear(year);
    final content = jsonEncode(statistics.toJson());
    final tmp = File('${file.path}.tmp');

    await tmp.writeAsString(content, flush: true);
    if (await file.exists()) {
      await file.delete();
    }
    await tmp.rename(file.path);
  }

  Future<List<int>> listYears() async {
    final dir = _directory;
    if (dir == null) {
      throw StateError('StatisticsStorage.init() must be called first');
    }

    final years = <int>[];
    await for (final entity in dir.list()) {
      if (entity is! File) continue;
      final name = p.basename(entity.path);
      if (!name.endsWith('.json')) continue;
      final year = int.tryParse(p.basenameWithoutExtension(name));
      if (year != null) {
        years.add(year);
      }
    }
    years.sort();
    return years;
  }
}

final statisticsStorage = StatisticsStorage();
