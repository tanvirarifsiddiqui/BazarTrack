import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../base/price_format.dart';
import '../../../util/colors.dart';
import '../controller/order_controller.dart';

class DraggableChatHead extends StatefulWidget {
  final OrderController ctrl;
  final Offset? initialPosition;

  const DraggableChatHead({
    required this.ctrl,
    this.initialPosition,
    super.key,
  });

  @override
  State<DraggableChatHead> createState() => _DraggableChatHeadState();
}

class _DraggableChatHeadState extends State<DraggableChatHead>
    with TickerProviderStateMixin {
  // --- Constants & tuning ---
  static const double _headSize = 64.0;
  static const double _cardMaxWidth = 420.0;
  static const double _margin = 8.0;

  // physics tuning
  static const double _flingThreshold = 200.0; // px/s to consider fling
  static const double _stopVelocityThreshold = 20.0; // px/s to stop ticker
  static const double _friction = 3.8; // exponential decay constant

  // --- State ---
  late Offset _position;
  bool _expanded = false;

  // manual ticker for fling physics
  late final Ticker _ticker;
  Offset _velocity = Offset.zero;
  Duration _lastTick = Duration.zero;
  bool _isFlinging = false;

  // snap animation
  late final AnimationController _snapController;
  late Offset _snapStart;
  late Offset _snapDelta;

  // expansion animation
  late final AnimationController _expandController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // card measurement
  final GlobalKey _cardKey = GlobalKey();
  double? _measuredCardHeight;

  @override
  void initState() {
    super.initState();

    // set initial position (falls back to sensible default)
    _position = widget.initialPosition ?? const Offset(16, 420);

    _ticker = createTicker(_onTick);

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnim = CurvedAnimation(parent: _expandController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_expandController);

    // keep snap listener compact and safe (update position using easeOutBack)
    _snapController.addListener(() {
      final curved = Curves.easeOutBack.transform(_snapController.value);
      final next = _snapStart + _snapDelta * curved;
      if (!mounted) return;
      setState(() => _position = next);
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _snapController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  // ---------- Physics ticker ----------
  void _onTick(Duration elapsed) {
    final now = elapsed;
    final dt = (_lastTick == Duration.zero)
        ? 0.0
        : (now - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = now;

    if (dt <= 0) return;

    var next = _position + _velocity * dt;

    // compute bounds once per tick
    final bounds = _getBounds();
    next = _clampToBounds(next, bounds);

    // if hitting edges we zero out the relevant velocity axis
    if (next.dx <= bounds.minX || next.dx >= bounds.maxX) {
      _velocity = Offset(0, _velocity.dy);
    }
    if (next.dy <= bounds.minY || next.dy >= bounds.maxY) {
      _velocity = Offset(_velocity.dx, 0);
    }

    // exponential friction decay
    final decay = math.exp(-_friction * dt);
    _velocity = Offset(_velocity.dx * decay, _velocity.dy * decay);

    if (!mounted) return;
    setState(() => _position = next);

    // stop condition
    if (_velocity.distance < _stopVelocityThreshold) {
      _stopFling();
      _snapToEdge();
    }
  }

  void _startFling(Offset pixelsPerSecond) {
    _velocity = pixelsPerSecond;
    _lastTick = Duration.zero;
    _isFlinging = true;
    _ticker.start();
  }

  void _stopFling() {
    if (_isFlinging) {
      _isFlinging = false;
      _ticker.stop();
    }
    _velocity = Offset.zero;
    _lastTick = Duration.zero;
  }

  // ---------- Gesture handlers ----------
  void _onPanStart(DragStartDetails details) {
    _stopFling();
    if (_snapController.isAnimating) _snapController.stop();

    if (_expanded) {
      // if the card is open, close it for safer UX when dragging
      _toggleExpanded();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final bounds = _getBounds();
    final candidate = _position + details.delta;
    final clamped = _clampToBounds(candidate, bounds);
    if (!mounted) return;
    setState(() => _position = clamped);
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    if (velocity.distance > _flingThreshold) {
      _startFling(velocity);
    } else {
      _snapToEdge();
    }
  }

  // ---------- Snap logic ----------
  void _snapToEdge() {
    final bounds = _getBounds();
    final parentWidth = bounds.parentWidth;

    final midX = parentWidth / 2;
    final targetX = (_position.dx < midX) ? bounds.minX : bounds.maxX;
    final clampedY = _position.dy.clamp(bounds.minY, bounds.maxY);

    _snapStart = _position;
    _snapDelta = Offset(targetX - _snapStart.dx, clampedY - _snapStart.dy);

    if (_snapController.isAnimating) _snapController.stop();
    _snapController.value = 0.0;
    _snapController.forward();
  }

  // ---------- Expansion ----------
  void _toggleExpanded() {
    if (!mounted) return;

    setState(() => _expanded = !_expanded);

    if (_expanded) {
      _stopFling();
      if (_snapController.isAnimating) _snapController.stop();
      _expandController.forward();
      // measure after layout
      WidgetsBinding.instance.addPostFrameCallback((_) => _measureCard());
    } else {
      _expandController.reverse().whenCompleteOrCancel(() {
        // snap after collapse
        _snapToEdge();
      });
    }
  }

  void _measureCard() {
    try {
      final ctx = _cardKey.currentContext;
      if (ctx == null) return;
      final size = ctx.size;
      if (size == null) return;
      final measured = size.height;
      if (_measuredCardHeight != measured && mounted) {
        setState(() => _measuredCardHeight = measured);
      }
    } catch (_) {
      // silent failure
    }
  }

  // ---------- Helpers / bounds ----------
  _Bounds _getBounds() {
    final parent = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final minX = _margin;
    final maxX = math.max(_margin, parent.width - _headSize - _margin);
    final minY = _margin + padding.top;
    final maxY = math.max(_margin, parent.height - _headSize - _margin - padding.bottom - 100);
    return _Bounds(minX: minX, maxX: maxX, minY: minY, maxY: maxY, parentWidth: parent.width, parentHeight: parent.height, paddingTop: padding.top, paddingBottom: padding.bottom);
  }

  Offset _clampToBounds(Offset p, _Bounds b) {
    final x = p.dx.clamp(b.minX, b.maxX);
    final y = p.dy.clamp(b.minY, b.maxY);
    return Offset(x, y);
  }

  String _formatShortTotal(double total) {
    if (total >= 1_000_000) {
      return '${(total / 1_000_000).toStringAsFixed(1)}M';
    } else if (total >= 1_000) {
      final value = (total / 1000);
      // show integer if exact
      if (value == value.truncateToDouble()) {
        return '${value.toInt()}k';
      }
      return '${value.toStringAsFixed(1)}k';
    } else {
      if (total == total.truncateToDouble()) {
        return total.toInt().toString();
      }
      return total.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    // defensive clamp at start of build to keep head visible on rotation / size change
    final bounds = _getBounds();
    _position = _clampToBounds(_position, bounds);

    return Obx(() {
      final items = widget.ctrl.newItems;
      final total = items.fold<double>(0.0, (s, it) => s + (it.estimatedCost ?? 0.0));

      // --- prepare rows (store numeric per as double? not as '-' string) ---
      final rows = items.map<Map<String, dynamic>>((it) {
        return {
          'product': it.productName.isEmpty ? '-' : it.productName,
          'qty': '${it.quantity}',
          'unit': it.unit ?? '-',        // ensure string fallback
          'per_val': it.estimatedCost,   // double? kept numeric
        };
      }).toList();


      // card geometry
      final parent = MediaQuery.of(context).size;
      final cardWidth = math.min(parent.width * 0.86, _cardMaxWidth);
      final desiredLeft = (_position.dx + _headSize / 2) - cardWidth / 2;
      final left = desiredLeft.clamp(_margin, parent.width - cardWidth - _margin);

      final fallbackCardHeight = 220.0;
      final aboveTopFallback = _position.dy - 12 - fallbackCardHeight;
      final placeAbove = aboveTopFallback >= MediaQuery.of(context).padding.top + _margin;

      double top;
      if (placeAbove) {
        final bh = _measuredCardHeight ?? fallbackCardHeight;
        const double gap = 8.0;
        top = _position.dy - 12 - bh - gap;
        top = top.clamp(MediaQuery.of(context).padding.top + _margin, parent.height - _margin - bh - MediaQuery.of(context).padding.bottom);
      } else {
        top = (_position.dy + _headSize + 12).clamp(MediaQuery.of(context).padding.top + _margin, parent.height - _margin - MediaQuery.of(context).padding.bottom);
      }

      return Stack(
        children: [
          if (_expanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleExpanded,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withValues(alpha: 0.12)),
              ),
            ),

          Positioned(
            left: left,
            top: top,
            child: IgnorePointer(
              ignoring: !_expanded,
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 260),
                    curve: Curves.easeInOut,
                    child: Material(
                      key: _cardKey,
                      elevation: 18,
                      borderRadius: BorderRadius.circular(14),
                      child: Container(
                        width: cardWidth,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).cardColor,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    'Order Details',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                  ),
                                ),
                                IconButton(
                                  onPressed: _toggleExpanded,
                                  icon: const Icon(Icons.close),
                                  splashRadius: 20,
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                color: AppColors.tertiary.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(flex: 1, child: Text('Product', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Unit', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Cost', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            if (rows.isEmpty)
                              Center(child: Text('No items yet', style: Theme.of(context).textTheme.bodySmall))
                            else
                              Column(
                                children: rows.map((r) {
                                  final perVal = r['per_val'] as double?;
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 1, child: Text(r['product'], overflow: TextOverflow.ellipsis)),
                                        Expanded(flex: 1, child: Text(r['qty']!, textAlign: TextAlign.center)),
                                        Expanded(flex: 1, child: Text(r['unit']!, textAlign: TextAlign.center)),
                                        Expanded(
                                          flex: 1,
                                          child: Text(
                                            perVal != null ? formatPrice(perVal) : '-',
                                            textAlign: TextAlign.right,
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            const Divider(height: 16, color: Colors.grey,),
                            Row(
                              children: [
                                Expanded(child: Text('Grand Total', style: Theme.of(context).textTheme.bodyLarge)),
                                Text(
                                  // '৳ ${total.toStringAsFixed(total == total.truncateToDouble() ? 0 : 2)}',
                                  formatPrice(total),
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),

                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Chat head
          Positioned(
            left: _position.dx,
            top: _position.dy,
            child: GestureDetector(
              onPanStart: _onPanStart,
              onPanUpdate: _onPanUpdate,
              onPanEnd: _onPanEnd,
              onTap: _toggleExpanded,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.tertiary, AppColors.tertiary.withValues(alpha: 0.9)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                  borderRadius: BorderRadius.circular(_headSize / 2),
                ),
                child: SizedBox(
                  width: _headSize,
                  height: _headSize,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '৳',
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.95), fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        FittedBox(
                          child: Text(
                            _formatShortTotal(total),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    });
  }
}

/// Simple struct for bounds values returned from _getBounds()
class _Bounds {
  final double minX;
  final double maxX;
  final double minY;
  final double maxY;
  final double parentWidth;
  final double parentHeight;
  final double paddingTop;
  final double paddingBottom;

  _Bounds({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
    required this.parentWidth,
    required this.parentHeight,
    required this.paddingTop,
    required this.paddingBottom,
  });
}
