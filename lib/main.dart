// Mohamed Mohamed - Activity 06: CustomPainter Smiley Lab.

import 'dart:math' show Random, pi;

import 'package:flutter/material.dart';

enum FaceStyle { classic, sleepy, surprised }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CustomPainter Smiley Lab',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const SmileyPage(),
    );
  }
}

class SmileyPage extends StatefulWidget {
  const SmileyPage({super.key});

  @override
  State<SmileyPage> createState() => _DrawingPlaygroundState();
}

class _DrawingPlaygroundState extends State<SmileyPage> {
  double _mood = 0.0;
  FaceStyle selectedFace = FaceStyle.classic;
  final Random _random = Random();

  String get _faceLabel => switch (selectedFace) {
    FaceStyle.classic => 'Classic',
    FaceStyle.sleepy => 'Sleepy',
    FaceStyle.surprised => 'Surprised',
  };

  void _showFeedback(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..removeCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  void _cycleFace() {
    setState(() {
      selectedFace =
          FaceStyle.values[(selectedFace.index + 1) % FaceStyle.values.length];
    });
    _showFeedback('Face changed to $_faceLabel');
  }

  void _randomizeFace() {
    setState(() {
      selectedFace = FaceStyle.values[_random.nextInt(FaceStyle.values.length)];
      _mood = _random.nextDouble();
    });
    _showFeedback('Randomized: $_faceLabel, mood ${_mood.toStringAsFixed(2)}');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('CustomPainter Smiley Lab')),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SegmentedButton<FaceStyle>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: FaceStyle.classic,
                      label: Text('Classic'),
                    ),
                    ButtonSegment(
                      value: FaceStyle.sleepy,
                      label: Text('Sleepy'),
                    ),
                    ButtonSegment(
                      value: FaceStyle.surprised,
                      label: Text('Surprised'),
                    ),
                  ],
                  selected: {selectedFace},
                  onSelectionChanged: (selection) =>
                      setState(() => selectedFace = selection.single),
                ),
                const SizedBox(height: 24),
                Flexible(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _cycleFace,
                      onLongPress: _randomizeFace,
                      child: CustomPaint(
                        size: const Size(240, 240),
                        painter: SmileyPainter(
                          mood: _mood,
                          faceStyle: selectedFace,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                Text('Mood: ${_mood.toStringAsFixed(2)}'),
                Slider(
                  value: _mood,
                  min: 0.0,
                  max: 1.0,
                  label: _mood.toStringAsFixed(2),
                  onChanged: (value) => setState(() => _mood = value),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  const SmileyPainter({required this.mood, required this.faceStyle});

  final double mood;
  final FaceStyle faceStyle;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.shortestSide / 2 - 4;
    final Color faceColor;
    if (mood < 0.35) {
      faceColor = Colors.lightBlue.shade300;
    } else if (mood <= 0.70) {
      faceColor = Colors.yellow.shade600;
    } else {
      faceColor = Colors.orange.shade400;
    }
    canvas.drawCircle(center, radius, Paint()..color = faceColor);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..color = const Color(0xFF212121)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 4,
    );

    final eyePaint = Paint()..color = Colors.black87;
    final eyeY = center.dy - radius * 0.18;
    final eyeDx = radius * 0.35;
    final eyeRadius = radius * (faceStyle == FaceStyle.surprised ? 0.16 : 0.10);

    for (final dx in [-eyeDx, eyeDx]) {
      final eyeCenter = Offset(center.dx + dx, eyeY);
      if (faceStyle == FaceStyle.sleepy) {
        eyePaint
          ..style = PaintingStyle.stroke
          ..strokeWidth = radius * 0.035
          ..strokeCap = StrokeCap.round;
        canvas.drawArc(
          Rect.fromCenter(
            center: eyeCenter,
            width: radius * 0.30,
            height: radius * 0.16,
          ),
          0.10 * pi,
          0.80 * pi,
          false,
          eyePaint,
        );
      } else {
        canvas.drawCircle(eyeCenter, eyeRadius, eyePaint);
      }
    }

    final mouthPaint = Paint()
      ..color = Colors.black87
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeCap = StrokeCap.round;
    if (faceStyle == FaceStyle.surprised) {
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.38),
          width: radius * 0.32,
          height: radius * (0.38 + mood * 0.14),
        ),
        mouthPaint,
      );
      return;
    }
    if (faceStyle == FaceStyle.sleepy) {
      mouthPaint.strokeWidth = radius * 0.025;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy + radius * 0.35),
          width: radius * 0.55,
          height: radius * (mood > 0.70 ? 0.30 : 0.16),
        ),
        (mood < 0.35 ? 1.15 : 0.15) * pi,
        0.70 * pi,
        false,
        mouthPaint,
      );
      return;
    }
    final Rect mouthRect;
    final double startAngle;
    if (mood < 0.35) {
      mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.55),
        width: radius,
        height: radius * 0.6,
      );
      startAngle = 1.15 * pi;
    } else if (mood <= 0.70) {
      mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.25),
        width: radius,
        height: radius * 0.25,
      );
      startAngle = 0.15 * pi;
    } else {
      mouthRect = Rect.fromCenter(
        center: Offset(center.dx, center.dy + radius * 0.15),
        width: radius * 1.2,
        height: radius * 0.8,
      );
      startAngle = 0.15 * pi;
    }

    canvas.drawArc(mouthRect, startAngle, 0.70 * pi, false, mouthPaint);
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) =>
      oldDelegate.mood != mood || oldDelegate.faceStyle != faceStyle;
}
