import 'dart:math';
import 'package:flutter/material.dart';

// ─── Public widget — drop into any Stack as first child ──────────────────────
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({super.key});
  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground> {
  static final List<_CircleDef> _defs = [
    // ── TOP ────────────────────────────────────────────────────────
    const _CircleDef(
        x: 0.10,
        y: -0.10,
        size: 183,
        bw: 30,
        ring: true,
        color: Color(0xFF10A2EA)),
    const _CircleDef(
        x: 0.90,
        y: 0.07,
        size: 167,
        bw: 30,
        ring: true,
        color: Color(0xFF10A2EA)),
    const _CircleDef(
        x: 0.30,
        y: 0.03,
        size: 94,
        op: 0.30,
        grad: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
    const _CircleDef(
        x: 0.09,
        y: 0.09,
        size: 89,
        op: 0.30,
        grad: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]),
    const _CircleDef(
        x: 0.55, y: 0.14, size: 48, op: 0.18, color: Color(0xFF10A2EA)),
    // ── MIDDLE ─────────────────────────────────────────────────────
    const _CircleDef(
        x: 0.35,
        y: 0.27,
        size: 154,
        op: 0.28,
        grad: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
    const _CircleDef(
        x: -0.05,
        y: 0.42,
        size: 130,
        bw: 22,
        ring: true,
        color: Color(0xFF10A2EA)),
    const _CircleDef(
        x: 0.20, y: 0.48, size: 58, op: 0.15, color: Color(0xFF10A2EA)),
    // ── BOTTOM — 2 rings, 2 blobs, 1 dot ──────────────────────────
    const _CircleDef(
        x: 0.12,
        y: 0.85,
        size: 160,
        bw: 28,
        ring: true,
        color: Color(0xFF10A2EA)),
    const _CircleDef(
        x: 0.88,
        y: 0.90,
        size: 140,
        bw: 24,
        ring: true,
        color: Color(0xFF10A2EA)),
    const _CircleDef(
        x: 0.70,
        y: 0.76,
        size: 105,
        op: 0.22,
        grad: [Color(0xAFFDEDCA), Color(0xFF0A9BE2)]),
    const _CircleDef(
        x: 0.18,
        y: 0.90,
        size: 75,
        op: 0.20,
        grad: [Color(0xFFFDEDCA), Color(0xFF0A9BE2)]),
    const _CircleDef(
        x: 0.50, y: 0.95, size: 50, op: 0.18, color: Color(0xFF10A2EA)),
  ];

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.hardEdge,
      children: [
        Container(color: const Color(0xFF0796DE)),
        ...List.generate(
            _defs.length,
            (i) => _FloatingCircleWidget(
                  def: _defs[i],
                  delay: i * 110,
                )),
      ],
    );
  }
}

// ─── One self-contained floating circle — owns its own AnimationController ───
class _FloatingCircleWidget extends StatefulWidget {
  final _CircleDef def;
  final int delay;
  const _FloatingCircleWidget({required this.def, required this.delay});

  @override
  State<_FloatingCircleWidget> createState() => _FloatingCircleWidgetState();
}

class _FloatingCircleWidgetState extends State<_FloatingCircleWidget>
    with SingleTickerProviderStateMixin {
  static final Random _rng = Random();

  // Travel distance as fraction of screen
  static const double _drift = 0.10;
  static const int _minMs = 1300;
  static const int _maxMs = 2500;

  late AnimationController _ctrl;
  late Animation<Offset> _anim;
  Offset _from = Offset.zero;
  Offset _to = Offset.zero;

  Offset _rndOff() => Offset(
        (_rng.nextDouble() * 2 - 1) * _drift,
        (_rng.nextDouble() * 2 - 1) * _drift,
      );

  Duration _rndDur() =>
      Duration(milliseconds: _minMs + _rng.nextInt(_maxMs - _minMs));

  void _nextSegment() {
    if (!mounted) return;
    _from = _to; // continue from where we stopped
    _to = _rndOff(); // pick a completely new random destination
    _ctrl.duration = _rndDur(); // vary speed per segment
    _anim = Tween<Offset>(begin: _from, end: _to)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));
    _ctrl.forward(from: 0); // restart controller for this segment
  }

  @override
  void initState() {
    super.initState();
    _from = _rndOff();
    _to = _rndOff();
    _ctrl = AnimationController(vsync: this, duration: _rndDur());
    _anim = Tween<Offset>(begin: _from, end: _to)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeInOutSine));

    _ctrl.addStatusListener((s) {
      if (s == AnimationStatus.completed) _nextSegment();
    });

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) _ctrl.forward();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final sz = MediaQuery.of(context).size;
    final d = widget.def;
    return AnimatedBuilder(
      animation: _anim,
      builder: (_, child) {
        final off = _anim.value;
        return Positioned(
          left: (d.x + off.dx) * sz.width - d.size / 2,
          top: (d.y + off.dy) * sz.height - d.size / 2,
          child: child!,
        );
      },
      child: Opacity(opacity: d.op, child: _buildShape(d)),
    );
  }

  Widget _buildShape(_CircleDef d) {
    if (d.grad != null) {
      return Container(
        width: d.size,
        height: d.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(
            begin: const Alignment(0.93, 0.35),
            end: const Alignment(0.06, 0.40),
            colors: d.grad!,
          ),
        ),
      );
    }
    if (d.ring) {
      return Container(
        width: d.size,
        height: d.size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(width: d.bw, color: d.color!),
        ),
      );
    }
    return Container(
      width: d.size,
      height: d.size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: d.color),
    );
  }
}

// ─── Data class ───────────────────────────────────────────────────────────────
class _CircleDef {
  final double x, y, size, bw, op;
  final bool ring;
  final Color? color;
  final List<Color>? grad;
  const _CircleDef({
    required this.x,
    required this.y,
    required this.size,
    this.bw = 0,
    this.op = 1.0,
    this.ring = false,
    this.color,
    this.grad,
  });
}
