import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:get/get.dart';

import '../../../util/colors.dart';
import '../controller/order_controller.dart';

class DraggableChatHead extends StatefulWidget {
  final OrderController ctrl;
  const DraggableChatHead({required this.ctrl, super.key});

  @override
  State<DraggableChatHead> createState() => _DraggableChatHeadState();
}

class _DraggableChatHeadState extends State<DraggableChatHead>
    with TickerProviderStateMixin {
  late Offset position;
  bool expanded = false;

  // Physics state (manual ticker for fling physics)
  late Ticker _ticker;
  Offset _velocity = Offset.zero; // pixels per second
  Duration _lastTick = Duration.zero;
  bool _isFlinging = false;

  // Single reusable snap controller (avoids creating multiple controllers/tickers)
  late AnimationController _snapController;
  late Offset _snapStart;
  late Offset _snapDelta;

  // Expansion animation (fade + slide + size)
  late AnimationController _expandController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  // Card measurement key to avoid overlap
  final GlobalKey _cardKey = GlobalKey();
  double? _measuredCardHeight;

  // Sizing constants
  static const double headSize = 64.0;
  static const double cardMaxWidth = 420.0;
  static const double margin = 8.0;

  @override
  void initState() {
    super.initState();
    position = const Offset(16, 420);
    _ticker = createTicker(_onTick);

    _snapController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    // expansion controller
    _expandController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _fadeAnim = CurvedAnimation(parent: _expandController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .chain(CurveTween(curve: Curves.easeOutCubic))
        .animate(_expandController);

    // single listener for snap animation; uses easeOutBack curve
    _snapController.addListener(() {
      final curved = Curves.easeOutBack.transform(_snapController.value);
      setState(() {
        position = _snapStart + _snapDelta * curved;
      });
    });
  }

  @override
  void dispose() {
    _ticker.dispose();
    _snapController.dispose();
    _expandController.dispose();
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed;
    final dt = (_lastTick == Duration.zero)
        ? 0.0
        : (now - _lastTick).inMicroseconds /
        Duration.microsecondsPerSecond;
    _lastTick = now;

    if (dt <= 0) return;

    // Apply motion: pos += vel * dt
    var next = position + _velocity * dt;

    // bounds (parent size must be grabbed from context)
    final parent = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final minY = margin + padding.top;
    // include bottom safe area padding here (fix vanish-under-bottom)
    final maxX = math.max(margin, parent.width - headSize - margin);
    final maxY = math.max(margin, parent.height - headSize - margin - padding.bottom);

    // **No bounce**: clamp and zero out the velocity component when hitting an edge.
    if (next.dx < margin) {
      next = Offset(margin, next.dy);
      _velocity = Offset(0, _velocity.dy);
    } else if (next.dx > maxX) {
      next = Offset(maxX, next.dy);
      _velocity = Offset(0, _velocity.dy);
    }

    if (next.dy < minY) {
      next = Offset(next.dx, minY);
      _velocity = Offset(_velocity.dx, 0);
    } else if (next.dy > maxY) {
      next = Offset(next.dx, maxY);
      _velocity = Offset(_velocity.dx, 0);
    }

    // friction: exponential decay (keeps the glide natural)
    const double friction = 3.8;
    final decay = math.exp(-friction * dt);
    _velocity = Offset(_velocity.dx * decay, _velocity.dy * decay);

    setState(() {
      position = next;
    });

    // stop if very slow: then snap to nearest edge (attach)
    if (_velocity.distance < 20) {
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

  void _onPanStart(DragStartDetails details) {
    _stopFling();
    // if user starts dragging while a snap is running, stop the snap.
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
    // If the card is expanded, close it when user starts dragging (safer UX)
    if (expanded) {
      _toggleExpanded();
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position = (position + details.delta);
      // clamp immediately to keep head visible
      final parent = MediaQuery.of(context).size;
      final padding = MediaQuery.of(context).padding;
      final maxX = math.max(margin, parent.width - headSize - margin);
      final maxY = math.max(margin, parent.height - headSize - margin - padding.bottom);
      position = Offset(position.dx.clamp(margin, maxX),
          position.dy.clamp(margin + padding.top, maxY));
    });
  }

  void _onPanEnd(DragEndDetails details) {
    final velocity = details.velocity.pixelsPerSecond;
    // start physics-based fling if velocity sufficient
    if (velocity.distance > 200) {
      _startFling(velocity);
    } else {
      // small velocity -> snap to nearby edge smoothly for nicer UX
      _snapToEdge();
    }
  }

  void _snapToEdge() {
    final parent = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final minY = margin + padding.top;
    final maxX = math.max(margin, parent.width - headSize - margin);
    final maxY = math.max(margin, parent.height - headSize - margin - padding.bottom);

    final midX = parent.width / 2;
    final targetX = (position.dx < midX) ? margin : maxX;
    final targetY = position.dy.clamp(minY, maxY);

    _snapStart = position;
    _snapDelta = Offset(targetX - _snapStart.dx, targetY - _snapStart.dy);

    // restart controller
    if (_snapController.isAnimating) {
      _snapController.stop();
    }
    _snapController.value = 0.0;
    _snapController.forward();
  }

  void _toggleExpanded() {
    setState(() {
      expanded = !expanded;
      if (expanded) {
        _stopFling();
        // stop ongoing snap when expanding
        if (_snapController.isAnimating) _snapController.stop();

        // animate expansion
        _expandController.forward();

        // schedule a post-frame callback to measure the card (so we can avoid overlap)
        WidgetsBinding.instance.addPostFrameCallback((_) => _measureCard());
      } else {
        // when closing, reverse animation then snap
        _expandController.reverse().whenCompleteOrCancel(() {
          // After collapse ensure it's attached to nearest edge
          _snapToEdge();
          // clear measurement (optional)
          // _measuredCardHeight = null;
        });
      }
    });
  }

  // Try to measure card height for accurate placement when placing above the head
  void _measureCard() {
    try {
      final ctx = _cardKey.currentContext;
      if (ctx == null) return;
      final size = ctx.size;
      if (size == null) return;
      // add slight extra gap so head never overlaps content
      final measured = size.height;
      if (_measuredCardHeight != measured) {
        setState(() {
          _measuredCardHeight = measured;
        });
      }
    } catch (_) {
      // ignore measurement errors
    }
  }

  String _formatShortTotal(double total) {
    if (total >= 1000000) {
      return '${(total / 1000000).toStringAsFixed(1)}M';
    } else if (total >= 1000) {
      final value = (total / 1000);
      return '${value.truncate() == value ? value.toInt() : value.toStringAsFixed(1)}k';
    } else {
      return total.truncateToDouble() == total ? total.toInt().toString() : total.toStringAsFixed(2);
    }
  }

  @override
  Widget build(BuildContext context) {
    final parent = MediaQuery.of(context).size;
    final padding = MediaQuery.of(context).padding;
    final maxX = math.max(margin, parent.width - headSize - margin);
    final maxY = math.max(margin, parent.height - headSize - margin - padding.bottom);

    // defensive clamp
    position = Offset(position.dx.clamp(margin, maxX),
        position.dy.clamp(margin + padding.top, maxY));

    return Obx(() {
      final items = widget.ctrl.newItems;
      final total = items.fold<double>(
        0.0,
            (s, it) {
          final est = it.estimatedCost ?? 0.0;
          return s + est;
        },
      );

      // prepare rows for table preview (unchanged from your version)
      final rows = items
          .map((it) {
        final per = it.estimatedCost;
        final perText = per != null ? per.truncateToDouble() == per ? per.toInt().toString() : per.toStringAsFixed(2) : '-';
        final totalText = perText;
        return {
          'product': it.productName.isEmpty ? '-' : it.productName,
          'qty': '${it.quantity}',
          'unit': it.unit ?? '-',
          'per': perText,
          'total': totalText,
        };
      })
          .toList(); // show all rows

      // compute card placement: prefer above head if there's space, otherwise below
      final cardWidth = math.min(parent.width * 0.86, cardMaxWidth);
      final desiredLeft = (position.dx + headSize / 2) - cardWidth / 2;
      final left = desiredLeft.clamp(margin, parent.width - cardWidth - margin);
      // desired top when placing above (we will adjust if measured)
      final fallbackCardHeight = 220.0; // used until measurement available
      final aboveTopFallback = position.dy - 12 - fallbackCardHeight;
      final placeAbove = aboveTopFallback >= padding.top + margin;
      double top;
      if (placeAbove) {
        final bh = _measuredCardHeight ?? fallbackCardHeight;
        // ensure a small gap between card bottom and head top so head doesn't overlap card
        const double gap = 8.0;
        top = position.dy - 12 - bh - gap;
        // if measured top would push card under top safe area, clamp it
        top = top.clamp(padding.top + margin, parent.height - margin - bh - padding.bottom);
      } else {
        top = (position.dy + headSize + 12).clamp(padding.top + margin, parent.height - margin - padding.bottom);
      }

      // Build the stack: card then head (head on top visually)
      return Stack(
        children: [
          // barrier when expanded
          if (expanded)
            Positioned.fill(
              child: GestureDetector(
                onTap: _toggleExpanded,
                behavior: HitTestBehavior.opaque,
                child: Container(color: Colors.black.withOpacity(0.12)),
              ),
            ),

          // expanded card (Fade + Slide + AnimatedSize). We attach the _cardKey to measure.
          Positioned(
            left: left,
            top: top,
            child: IgnorePointer(
              ignoring: !expanded,
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
                            // header + close
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

                            // Table header
                            Container(
                              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                              decoration: BoxDecoration(
                                color: Theme.of(context).dividerColor.withOpacity(0.04),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: const [
                                  Expanded(flex: 2, child: Text('Product', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Qty', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Unit', textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Cost', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                  Expanded(flex: 1, child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // All rows visible (no fixed ListView height)
                            if (rows.isEmpty)
                              Center(child: Text('No items yet', style: Theme.of(context).textTheme.bodySmall))
                            else
                              Column(
                                children: rows.map((r) {
                                  return Padding(
                                    padding: const EdgeInsets.symmetric(vertical: 6),
                                    child: Row(
                                      children: [
                                        Expanded(flex: 2, child: Text(r['product']!, overflow: TextOverflow.ellipsis)),
                                        Expanded(flex: 1, child: Text(r['qty']!, textAlign: TextAlign.center)),
                                        Expanded(flex: 1, child: Text(r['unit']!, textAlign: TextAlign.center)),
                                        Expanded(flex: 1, child: Text(r['per']!, textAlign: TextAlign.right)),
                                        Expanded(flex: 1, child: Text(r['total']!, textAlign: TextAlign.right)),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),

                            const Divider(height: 16),

                            // Footer: total
                            Row(
                              children: [
                                Expanded(
                                  child: Text('Grand Total', style: Theme.of(context).textTheme.bodyLarge),
                                ),
                                Text(
                                  '৳ ${total.toStringAsFixed(total.truncateToDouble() == total ? 0 : 2)}',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 8),
                                TextButton(
                                  onPressed: () {
                                    _toggleExpanded();
                                  },
                                  child: const Text('Review'),
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

          // The chat-head (draggable button showing total) -> keep this rendered after card so it stays visually on top
          Positioned(
            left: position.dx,
            top: position.dy,
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
                      color: Colors.black.withOpacity(0.18),
                      blurRadius: 10,
                      offset: const Offset(0, 6),
                    )
                  ],
                  borderRadius: BorderRadius.circular(headSize / 2),
                ),
                child: SizedBox(
                  width: headSize,
                  height: headSize,
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '৳',
                          style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 12, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 2),
                        FittedBox(
                          child: Text(
                            _formatShortTotal(total),
                            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
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
