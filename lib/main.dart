import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'data/quiz_questions.dart';
import 'models/quiz_question.dart';

void main() => runApp(const ClicksyApp());

class C {
  static const ink = Color(0xFF28264F);
  static const purple = Color(0xFF6C5CE7);
  static const yellow = Color(0xFFFFD166);
  static const coral = Color(0xFFFF7B72);
  static const mint = Color(0xFF68DDB5);
  static const sky = Color(0xFF72C9F8);
  static const muted = Color(0xFF85839C);
  static const green = Color(0xFF25A96A);
  static const red = Color(0xFFE65B65);
}

class ClicksyApp extends StatelessWidget {
  const ClicksyApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Clicksy',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: const Color(0xFFFFFCF5),
      colorScheme: ColorScheme.fromSeed(seedColor: C.purple),
    ),
    home: const ClicksyHome(),
  );
}

class ClicksyHome extends StatefulWidget {
  const ClicksyHome({super.key});
  @override
  State<ClicksyHome> createState() => _ClicksyHomeState();
}

class _ClicksyHomeState extends State<ClicksyHome> {
  static const tints = [C.sky, C.yellow, C.mint, C.coral];
  bool started = false, correct = false, celebrate = false;
  int index = 0, score = 0, streak = 0;
  String? selected, feedback;
  QuizQuestion get question => quizQuestions[index];
  bool get finished => index >= quizQuestions.length;

  void startGame() => setState(() {
    started = true; index = 0; score = 0; streak = 0;
    selected = null; correct = false; feedback = null; celebrate = false;
  });

  void choose(String id) {
    if (correct) return;
    final right = id == question.correctOptionId;
    setState(() {
      selected = id;
      if (right) {
        correct = true; score++; streak++; celebrate = true;
        feedback = question.explanation ?? 'You got it right!';
      } else {
        streak = 0; feedback = 'Good try! Have another go. You can do it!';
      }
    });
    if (right) {
      Future<void>.delayed(const Duration(milliseconds: 1300), () {
        if (mounted) setState(() => celebrate = false);
      });
    }
  }

  void next() {
    if (!correct) return;
    setState(() {
      index++; selected = null; correct = false;
      feedback = null; celebrate = false;
    });
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(children: [
      const _Backdrop(),
      SafeArea(child: Center(child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1040),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 380),
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(begin: const Offset(.04, .02), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: !started
              ? _Welcome(key: const ValueKey('welcome'), onStart: startGame)
              : finished
                ? _Results(key: const ValueKey('results'), score: score, total: quizQuestions.length, onReplay: startGame)
                : _gameView(),
          ),
        ),
      ))),
      if (celebrate) const Positioned.fill(child: _Confetti()),
    ]),
  );

  Widget _gameView() {
    final q = question;
    return Column(key: ValueKey(q.id), children: [
      Row(children: [
        _SmallButton(onTap: () => setState(() { started = false; celebrate = false; })),
        const Spacer(), const _Brand(), const Spacer(),
        _Pill(icon: Icons.star_rounded, label: '$score', color: C.yellow),
        const SizedBox(width: 8),
        _Pill(icon: Icons.local_fire_department_rounded, label: '$streak', color: C.coral),
      ]),
      const SizedBox(height: 21),
      _Progress(progress: (index + (correct ? 1 : 0)) / quizQuestions.length, current: index + 1, total: quizQuestions.length),
      const SizedBox(height: 18),
      Expanded(child: LayoutBuilder(builder: (context, box) {
        final compact = box.maxHeight < 520;
        return SingleChildScrollView(child: ConstrainedBox(
          constraints: BoxConstraints(minHeight: box.maxHeight),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            _QuestionPanel(question: q, compact: compact),
            const SizedBox(height: 15),
            LayoutBuilder(builder: (context, constraints) {
              final cols = constraints.maxWidth < 560 ? 1 : 2;
              final width = cols == 1 ? constraints.maxWidth : (constraints.maxWidth - 14) / 2;
              return Wrap(spacing: 14, runSpacing: 12, children: List.generate(q.options.length, (i) {
                final option = q.options[i];
                final isSelected = selected == option.id;
                return SizedBox(width: width, child: _AnswerCard(
                  label: option.label, emoji: option.emoji,
                  letter: String.fromCharCode(65 + i), tint: tints[i % tints.length],
                  state: isSelected ? (correct ? _AnswerState.correct : _AnswerState.wrong) : _AnswerState.idle,
                  enabled: !correct, onTap: () => choose(option.id),
                ));
              }));
            }),
            const SizedBox(height: 12),
            AnimatedSwitcher(duration: const Duration(milliseconds: 220),
              child: feedback == null
                ? const SizedBox(height: 40, key: ValueKey('empty'))
                : Container(key: ValueKey(feedback), width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
                    decoration: BoxDecoration(
                      color: correct ? const Color(0xFFE1F8EC) : const Color(0xFFFFF0D8),
                      borderRadius: BorderRadius.circular(14)),
                    child: Text((correct ? '🎉 Brilliant! ' : '💪 ') + feedback!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: correct ? const Color(0xFF167849) : const Color(0xFF966015), fontWeight: FontWeight.w900, fontSize: 13)),
                  ),
            ),
            const SizedBox(height: 12),
            _BigButton(
              label: index == quizQuestions.length - 1 ? 'See my score!' : 'Next question',
              icon: index == quizQuestions.length - 1 ? Icons.emoji_events_rounded : Icons.arrow_forward_rounded,
              enabled: correct, onTap: next,
            ),
            const SizedBox(height: 8),
          ]),
        ));
      })),
    ]);
  }
}

class _Backdrop extends StatelessWidget {
  const _Backdrop();
  @override
  Widget build(BuildContext context) => Stack(children: [
    Positioned(top: -90, right: -70, child: _Bubble(245, C.yellow.withValues(alpha: .18))),
    Positioned(bottom: -100, left: -80, child: _Bubble(260, C.sky.withValues(alpha: .18))),
    Positioned(top: 145, left: 30, child: Icon(Icons.auto_awesome_rounded, color: C.coral.withValues(alpha: .35), size: 25)),
    Positioned(bottom: 90, right: 38, child: Icon(Icons.star_rounded, color: C.yellow.withValues(alpha: .8), size: 30)),
  ]);
}

class _Bubble extends StatelessWidget {
  const _Bubble(this.size, this.color);
  final double size; final Color color;
  @override
  Widget build(BuildContext context) => Container(width: size, height: size, decoration: BoxDecoration(color: color, shape: BoxShape.circle));
}

class _Brand extends StatelessWidget {
  const _Brand();
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Container(width: 35, height: 35, decoration: BoxDecoration(color: C.purple, borderRadius: BorderRadius.circular(11)),
      child: const Icon(Icons.ads_click_rounded, color: Colors.white, size: 22)),
    const SizedBox(width: 8),
    const Text('Clicksy', style: TextStyle(color: C.ink, fontSize: 20, fontWeight: FontWeight.w900)),
  ]);
}

class _SmallButton extends StatelessWidget {
  const _SmallButton({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => OutlinedButton.icon(
    onPressed: onTap, icon: const Icon(Icons.home_rounded, size: 17), label: const Text('Home'),
    style: OutlinedButton.styleFrom(
      foregroundColor: C.ink, side: const BorderSide(color: Color(0xFFECEAF4)), backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      textStyle: const TextStyle(fontWeight: FontWeight.w900)),
  );
}

class _Pill extends StatelessWidget {
  const _Pill({required this.icon, required this.label, required this.color});
  final IconData icon; final String label; final Color color;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
    decoration: BoxDecoration(color: color.withValues(alpha: .23), borderRadius: BorderRadius.circular(30)),
    child: Row(children: [Icon(icon, color: C.ink, size: 17), const SizedBox(width: 5),
      Text(label, style: const TextStyle(color: C.ink, fontWeight: FontWeight.w900))]),
  );
}

class _Progress extends StatelessWidget {
  const _Progress({required this.progress, required this.current, required this.total});
  final double progress; final int current, total;
  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      const Text('YOUR ADVENTURE', style: TextStyle(color: C.muted, fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 1.2)),
      Text('$current of $total', style: const TextStyle(color: C.ink, fontWeight: FontWeight.w900)),
    ]),
    const SizedBox(height: 8),
    ClipRRect(borderRadius: BorderRadius.circular(30), child: TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: progress), duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic,
      builder: (context, value, _) => LinearProgressIndicator(value: value, minHeight: 11,
        backgroundColor: const Color(0xFFECEAF4), valueColor: const AlwaysStoppedAnimation(C.purple)),
    )),
  ]);
}

class _Welcome extends StatelessWidget {
  const _Welcome({super.key, required this.onStart});
  final VoidCallback onStart;
  @override
  Widget build(BuildContext context) => LayoutBuilder(builder: (context, box) {
    final narrow = box.maxWidth < 650;
    return Center(child: SingleChildScrollView(child: Padding(
      padding: const EdgeInsets.symmetric(vertical: 22),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        const _Brand(), const SizedBox(height: 32),
        Container(width: narrow ? 150 : 185, height: narrow ? 150 : 185,
          decoration: BoxDecoration(color: const Color(0xFFEDE9FF), borderRadius: BorderRadius.circular(52)),
          child: const Center(child: Text('🖥️', style: TextStyle(fontSize: 96)))),
        const SizedBox(height: 25),
        Text('Ready to click\nyour way to fun?', textAlign: TextAlign.center,
          style: TextStyle(color: C.ink, fontSize: narrow ? 35 : 48, fontWeight: FontWeight.w900, height: 1.08)),
        const SizedBox(height: 12),
        const Text('Play, learn and discover the amazing world of computers!', textAlign: TextAlign.center,
          style: TextStyle(color: C.muted, fontSize: 16, fontWeight: FontWeight.w700)),
        const SizedBox(height: 25),
        const Wrap(alignment: WrapAlignment.center, spacing: 10, runSpacing: 10, children: [
          _FeatureChip('⭐', 'Earn stars'), _FeatureChip('🧩', 'Fun questions'), _FeatureChip('🎉', 'Big cheers'),
        ]),
        const SizedBox(height: 30),
        _BigButton(label: "Let's Play!", icon: Icons.play_arrow_rounded, enabled: true, onTap: onStart),
        const SizedBox(height: 12),
        Text(quizQuestions.length.toString() + ' fun questions • No timer • Just play!',
          style: const TextStyle(color: C.muted, fontSize: 12, fontWeight: FontWeight.w700)),
      ]),
    )));
  });
}

class _FeatureChip extends StatelessWidget {
  const _FeatureChip(this.emoji, this.label);
  final String emoji, label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), border: Border.all(color: const Color(0xFFECEAF4))),
    child: Row(mainAxisSize: MainAxisSize.min, children: [Text(emoji), const SizedBox(width: 7),
      Text(label, style: const TextStyle(color: C.ink, fontSize: 12, fontWeight: FontWeight.w900))]),
  );
}

class _QuestionPanel extends StatelessWidget {
  const _QuestionPanel({required this.question, required this.compact});
  final QuizQuestion question; final bool compact;
  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(horizontal: compact ? 18 : 25, vertical: compact ? 15 : 21),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(25),
      border: Border.all(color: const Color(0xFFECEAF4)),
      boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .045), blurRadius: 22, offset: const Offset(0, 8))]),
    child: Column(children: [
      Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(color: const Color(0xFFEDE9FF), borderRadius: BorderRadius.circular(30)),
        child: Text(question.category.toUpperCase(), style: const TextStyle(color: C.purple, fontSize: 10, fontWeight: FontWeight.w900, letterSpacing: 1))),
      SizedBox(height: compact ? 8 : 12),
      Text(question.illustration, style: TextStyle(fontSize: compact ? 38 : 47)),
      SizedBox(height: compact ? 7 : 11),
      Text(question.question, textAlign: TextAlign.center,
        style: TextStyle(color: C.ink, fontSize: compact ? 20 : 25, fontWeight: FontWeight.w900, height: 1.2)),
      const SizedBox(height: 7),
      const Text('Choose the right answer!', style: TextStyle(color: C.muted, fontSize: 12, fontWeight: FontWeight.w700)),
    ]),
  );
}

enum _AnswerState { idle, correct, wrong }

class _AnswerCard extends StatefulWidget {
  const _AnswerCard({required this.label, required this.emoji, required this.letter, required this.tint,
    required this.state, required this.enabled, required this.onTap});
  final String label, emoji, letter; final Color tint; final _AnswerState state;
  final bool enabled; final VoidCallback onTap;
  @override
  State<_AnswerCard> createState() => _AnswerCardState();
}

class _AnswerCardState extends State<_AnswerCard> {
  bool hovered = false, pressed = false;
  @override
  Widget build(BuildContext context) {
    final good = widget.state == _AnswerState.correct;
    final bad = widget.state == _AnswerState.wrong;
    final border = good ? C.green : bad ? C.red : hovered ? widget.tint : const Color(0xFFECEAF4);
    return MouseRegion(
      onEnter: (_) => setState(() => hovered = true), onExit: (_) => setState(() => hovered = false),
      child: GestureDetector(
        onTapDown: widget.enabled ? (_) => setState(() => pressed = true) : null,
        onTapCancel: () => setState(() => pressed = false),
        onTapUp: widget.enabled ? (_) => setState(() => pressed = false) : null,
        onTap: widget.enabled ? widget.onTap : null,
        child: AnimatedScale(scale: pressed ? .97 : (hovered && widget.enabled ? 1.015 : 1),
          duration: const Duration(milliseconds: 130),
          child: AnimatedContainer(duration: const Duration(milliseconds: 220), curve: Curves.easeOutCubic,
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 14),
            decoration: BoxDecoration(
              color: good ? const Color(0xFFE1F8EC) : bad ? const Color(0xFFFFE8E8) : Colors.white,
              borderRadius: BorderRadius.circular(21), border: Border.all(color: border, width: good || bad ? 2 : 1.5),
              boxShadow: [BoxShadow(color: (good ? C.green : bad ? C.red : C.ink).withValues(alpha: hovered ? .12 : .055),
                blurRadius: hovered ? 17 : 10, offset: Offset(0, hovered ? 7 : 4))]),
            child: Row(children: [
              Container(width: 35, height: 35, alignment: Alignment.center,
                decoration: BoxDecoration(color: good ? C.green : bad ? C.red : widget.tint.withValues(alpha: .18), borderRadius: BorderRadius.circular(11)),
                child: Text(widget.letter, style: TextStyle(color: good || bad ? Colors.white : C.ink, fontWeight: FontWeight.w900))),
              const SizedBox(width: 12), Text(widget.emoji, style: const TextStyle(fontSize: 27)),
              const SizedBox(width: 12), Expanded(child: Text(widget.label, style: const TextStyle(color: C.ink, fontSize: 16, fontWeight: FontWeight.w900))),
              AnimatedSwitcher(duration: const Duration(milliseconds: 180),
                child: good ? const Icon(Icons.check_circle_rounded, key: ValueKey('good'), color: C.green, size: 25)
                  : bad ? const Icon(Icons.cancel_rounded, key: ValueKey('bad'), color: C.red, size: 25)
                  : const Icon(Icons.circle_outlined, key: ValueKey('idle'), color: Color(0xFFD8D5E5), size: 22)),
            ]),
          ),
        ),
      ),
    );
  }
}

class _BigButton extends StatefulWidget {
  const _BigButton({required this.label, required this.icon, required this.enabled, required this.onTap});
  final String label; final IconData icon; final bool enabled; final VoidCallback onTap;
  @override
  State<_BigButton> createState() => _BigButtonState();
}

class _BigButtonState extends State<_BigButton> {
  bool hovered = false;
  @override
  Widget build(BuildContext context) => MouseRegion(
    onEnter: (_) => setState(() => hovered = true), onExit: (_) => setState(() => hovered = false),
    child: AnimatedScale(scale: hovered && widget.enabled ? 1.035 : 1, duration: const Duration(milliseconds: 150),
      child: ElevatedButton.icon(onPressed: widget.enabled ? widget.onTap : null,
        icon: Icon(widget.icon, size: 22), label: Text(widget.label),
        style: ElevatedButton.styleFrom(backgroundColor: C.purple, foregroundColor: Colors.white,
          disabledBackgroundColor: C.purple.withValues(alpha: .35), disabledForegroundColor: Colors.white,
          elevation: hovered ? 7 : 3, shadowColor: C.purple.withValues(alpha: .3),
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 17),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900))),
    ),
  );
}

class _Results extends StatelessWidget {
  const _Results({super.key, required this.score, required this.total, required this.onReplay});
  final int score, total; final VoidCallback onReplay;
  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : (score / total * 100).round();
    final message = percent == 100 ? 'Perfect! You are a computer star!'
      : percent >= 70 ? 'Amazing work! You know your computers!'
      : percent >= 40 ? 'Great effort! Keep discovering!'
      : 'Good try! Every click helps you learn!';
    return Center(child: SingleChildScrollView(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      const Text('🏆', style: TextStyle(fontSize: 86)), const SizedBox(height: 14),
      const Text('Quiz complete!', style: TextStyle(color: C.ink, fontSize: 38, fontWeight: FontWeight.w900)),
      const SizedBox(height: 10),
      Text(message, textAlign: TextAlign.center, style: const TextStyle(color: C.muted, fontSize: 16, fontWeight: FontWeight.w700)),
      const SizedBox(height: 24),
      Container(padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0xFFECEAF4)),
          boxShadow: [BoxShadow(color: C.ink.withValues(alpha: .06), blurRadius: 24, offset: const Offset(0, 9))]),
        child: Column(children: [
          const Text('YOUR SCORE', style: TextStyle(color: C.muted, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          const SizedBox(height: 5), Text('$score / $total', style: const TextStyle(color: C.purple, fontSize: 54, fontWeight: FontWeight.w900)),
          Text('$percent% correct', style: const TextStyle(color: C.ink, fontWeight: FontWeight.w800)),
        ])),
      const SizedBox(height: 27),
      _BigButton(label: 'Play again!', icon: Icons.replay_rounded, enabled: true, onTap: onReplay),
      const SizedBox(height: 16), const _Brand(),
    ])));
  }
}

class _Confetti extends StatefulWidget {
  const _Confetti();
  @override
  State<_Confetti> createState() => _ConfettiState();
}

class _ConfettiState extends State<_Confetti> with SingleTickerProviderStateMixin {
  late final AnimationController controller;
  @override
  void initState() {
    super.initState();
    controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1150))..forward();
  }
  @override
  void dispose() { controller.dispose(); super.dispose(); }
  @override
  Widget build(BuildContext context) => IgnorePointer(child: AnimatedBuilder(
    animation: controller,
    builder: (context, _) => CustomPaint(painter: _ConfettiPainter(controller.value), size: Size.infinite),
  ));
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);
  final double progress;
  static const colors = [C.yellow, C.coral, C.mint, C.sky, C.purple];
  @override
  void paint(Canvas canvas, Size size) {
    final random = math.Random(21);
    for (var i = 0; i < 46; i++) {
      final startX = random.nextDouble() * size.width;
      final startY = -random.nextDouble() * size.height * .45;
      final drift = (random.nextDouble() - .5) * 110;
      final fall = progress * (size.height * .95 + random.nextDouble() * 150);
      canvas.save();
      canvas.translate(startX + drift * progress, startY + fall);
      canvas.rotate(progress * (random.nextDouble() * 8 - 4));
      final paint = Paint()..color = colors[i % colors.length].withValues(alpha: (1 - progress * .25).clamp(0.0, 1.0).toDouble());
      canvas.drawRRect(RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: 8 + (i % 3) * 2, height: 12 + (i % 4) * 2),
        const Radius.circular(2)), paint);
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => oldDelegate.progress != progress;
}
