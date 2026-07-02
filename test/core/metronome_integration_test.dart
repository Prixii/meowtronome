/// Metronome 集成测试
///
/// 运行方式:
///   flutter test test/core/metronome_integration_test.dart
///
/// 这个测试会真实启动计时器，运行一段时间后停止，
/// 并输出可视化格线来展示音符播放序列。
library;

import 'package:meowtronome/core/enums.dart';
import 'package:meowtronome/core/rhythm_pattern.dart';
import 'package:meowtronome/core/scheduler/scheduler.dart';
import 'package:meowtronome/core/metronome.dart';
import 'package:flutter_test/flutter_test.dart';

// ─────────────────────────────────────────────────────────────
// 可视化函数
// ─────────────────────────────────────────────────────────────

String visualize(RhythmPattern pattern, int beatIndex, int noteIndex) {
  final beatCount = pattern.beats.length;
  var maxNoteCount = 0;
  for (final beat in pattern.beats) {
    if (beat.notes.length > maxNoteCount) {
      maxNoteCount = beat.notes.length;
    }
  }
  if (maxNoteCount == 0) return '(empty)';

  // 构建二维字符矩阵 [beat][subdivision]
  final grid = List.generate(beatCount, (_) => List.filled(maxNoteCount, '-'));
  for (var i = 0; i < beatCount; i++) {
    for (var j = 0; j < pattern.beats[i].notes.length; j++) {
      grid[i][j] = pattern.beats[i].notes[j].soundType.index.toString();
    }
  }

  // 标记当前播放位置
  if (beatIndex >= 0 &&
      beatIndex < beatCount &&
      noteIndex >= 0 &&
      noteIndex < pattern.beats[beatIndex].notes.length) {
    grid[beatIndex][noteIndex] = 'X';
  }

  // 每拍一行，展示该拍下所有 subdivision 的音符
  final lines = <String>[];
  for (var col = 0; col < beatCount; col++) {
    final sb = StringBuffer();
    for (var row = 0; row < maxNoteCount; row++) {
      sb.write(grid[col][row]);
    }
    lines.add(sb.toString());
  }
  return lines.join('\n');
}

/// 将毫秒数格式化为可读的字符串
String _fmtMs(double ms) => '${ms.toStringAsFixed(0)}ms';

void main() {
  test('Metronome 集成测试 — 观察音符播放序列', () async {
    // ============================================================
    // 1. 自定义一个节奏型
    //    4 拍，每拍内音符数不同，音色也不同
    // ============================================================
    final pattern = RhythmPattern(
      name: '测试节奏',
      beats: [
        // beat 0: 2 个音符 (type1, type2)
        Beat(
          notes: [
            Note.initial(soundType: SoundType.type1),
            Note.initial(soundType: SoundType.type2),
          ],
        ),
        // beat 1: 3 个音符 (type3, type1, type2)
        Beat(
          notes: [
            Note.initial(soundType: SoundType.type3),
            Note.initial(soundType: SoundType.type1),
            Note.initial(soundType: SoundType.type2),
          ],
        ),
        // beat 2: 1 个音符 (none → 静音)
        Beat(notes: [Note.initial(soundType: SoundType.type4)]),
        // beat 3: 2 个音符 (type3, type3)
        Beat(
          notes: [
            Note.initial(soundType: SoundType.type3),
            Note.initial(soundType: SoundType.type3),
          ],
        ),
      ],
    );

    // ============================================================
    // 2. 收集事件 + 实时可视化
    // ============================================================
    final stopwatch = Stopwatch()..start();

    final metronome = Metronome();

    // 通过 setOnPlayNote 注册回调，收到 Scheduler 实例后读取当前位置
    metronome.setOnPlayNote((Scheduler scheduler) {
      final beatIndex = scheduler.runtimeState.currentBeatIndex;
      final noteIndex = scheduler.runtimeState.currentNoteIndex;
      final queue = scheduler.state.noteQueue;
      final note = queue[beatIndex][noteIndex];

      print(
        '  [${stopwatch.elapsedMilliseconds}ms] '
        'beat[$beatIndex][$noteIndex] = ${note.soundType.name}',
      );
      print(visualize(pattern, beatIndex, noteIndex));
      print('');
    });

    // ============================================================
    // 3. 设置 BPM = 60（每拍 1000ms，方便观察时间间隔）
    // ============================================================
    metronome.setBpm(60);
    metronome.setPattern(pattern);

    // 打印预期的时间配置
    print('═══════════════════════════════════════════════');
    print('  BPM: ${metronome.bpm}');
    print('  每拍时长: ${_fmtMs(60_000 / metronome.bpm)}');
    print('  节奏型: ${pattern.name}');
    print('  拍数: ${pattern.beats.length}');
    print('\n可视化图例:');
    print('  每行 = 一个拍子，展示该拍所有 subdivision 的音符');
    print('  列 = subdivision 层');
    print('  X  = 当前播放的音符');
    print('  数字 = SoundType.index (0=none, 1=type1, 2=type2, 3=type3)');
    print('  -  = 无音符');
    print('\n完整的网格 (未播放时的样子):');
    print(visualize(pattern, -1, -1));
    print('');
    for (var i = 0; i < pattern.beats.length; i++) {
      final beat = pattern.beats[i];
      final noteTime = (60_000 / metronome.bpm) / beat.notes.length;
      print(
        '  beat[$i]: ${beat.notes.length} 个音符, '
        '每个 ${_fmtMs(noteTime)}',
      );
    }
    print('═══════════════════════════════════════════════');
    print('\n播放序列:\n');

    // ============================================================
    // 4. 启动并运行 2 个完整循环（8 拍）
    //    每拍 1000ms → 8 秒 + 100ms 余量
    // ============================================================
    metronome.start();
    await Future.delayed(const Duration(milliseconds: 8100));
    metronome.stop();
    stopwatch.stop();

    print('══════════════ 播放结束 ══════════════');
    metronome.dispose();
  }, timeout: const Timeout(Duration(seconds: 15)));

  // ============================================================
  // 测试 2: 运行时修改 BPM
  // ============================================================
  test('集成测试 — 运行时修改 BPM', () async {
    final pattern = RhythmPattern(
      name: 'BPM 测试',
      beats: List.generate(
        4,
        (_) => Beat(
          notes: [
            Note.initial(soundType: SoundType.type1),
            Note.initial(soundType: SoundType.type2),
          ],
        ),
      ),
    );

    final metronome = Metronome();
    metronome.setOnPlayNote((Scheduler scheduler) {
      final beatIndex = scheduler.runtimeState.currentBeatIndex;
      final noteIndex = scheduler.runtimeState.currentNoteIndex;
      final queue = scheduler.state.noteQueue;
      final note = queue[beatIndex][noteIndex];
      print(
        '  [${_fmtMs(note.timeValueMs)}] '
        'beat[$beatIndex][$noteIndex] = ${note.soundType.name}',
      );
    });

    print('\n══════════ 运行时修改 BPM ══════════');
    print('  初始 BPM: 120（每拍 500ms, 每音符 250ms）');
    print(visualize(pattern, -1, -1));

    metronome.setBpm(120);
    metronome.setPattern(pattern);
    metronome.start();

    await Future.delayed(const Duration(seconds: 2));

    print('\n  → 切换 BPM: 200（每拍 300ms, 每音符 150ms）\n');
    metronome.setBpm(200);

    await Future.delayed(const Duration(seconds: 2));
    metronome.stop();

    print('\n  ✅ 完成');
    metronome.dispose();
  }, timeout: const Timeout(Duration(seconds: 10)));

  // ============================================================
  // 测试 3: 运行时修改节奏型
  // ============================================================
  test('集成测试 — 运行时修改节奏型', () async {
    final patternA = RhythmPattern(
      name: '节奏 A',
      beats: List.generate(
        2,
        (_) => Beat(
          notes: List.generate(
            4,
            (i) => Note.initial(
              soundType: i.isEven ? SoundType.type1 : SoundType.type2,
            ),
          ),
        ),
      ),
    );

    final patternB = RhythmPattern(
      name: '节奏 B',
      beats: List.generate(
        3,
        (_) => Beat(
          notes: [
            Note.initial(soundType: SoundType.type3),
            Note.initial(soundType: SoundType.type4),
          ],
        ),
      ),
    );

    final metronome = Metronome();
    metronome.setOnPlayNote((Scheduler scheduler) {
      final beatIndex = scheduler.runtimeState.currentBeatIndex;
      final noteIndex = scheduler.runtimeState.currentNoteIndex;
      // 用当前 metronome 的 state 来可视化（因为 pattern 可能已切换）
      print(visualize(metronome.state.pattern, beatIndex, noteIndex));
      print('');
    });

    metronome.setBpm(120);

    print('\n══════════ 运行时修改节奏型 ══════════');

    print('节奏 A (2拍 × 4音符):');
    print(visualize(patternA, -1, -1));
    print('');

    metronome.setPattern(patternA);
    metronome.start();
    await Future.delayed(const Duration(seconds: 2));

    print('  → 切换到节奏 B (3拍 × 2音符):\n');
    metronome.setPattern(patternB);

    await Future.delayed(const Duration(seconds: 2));
    metronome.stop();

    print('  ✅ 完成');
    metronome.dispose();
  }, timeout: const Timeout(Duration(seconds: 10)));
}
