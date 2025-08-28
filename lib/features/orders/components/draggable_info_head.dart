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

  // Sizing constants
  static const double headSize = 64.0;
  static const double cardMaxWidth = 420.0;
  static const double cardHeight = 220.0;
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
    super.dispose();
  }

  void _onTick(Duration elapsed) {
    final now = elapsed;
    final dt = (_lastTick == Duration.zero)
        ? 0.0
        : (now - _lastTick).inMicroseconds / Duration.microsecondsPerSecond;
    _lastTick = now;

    if (dt <= 0) return;

    // Apply motion: pos += vel * dt
    var next = position + _velocity * dt;

    // bounds (parent size must be grabbed from context)
    final parent = MediaQuery.of(context).size;
    final minY = margin + MediaQuery.of(context).padding.top;
    final maxX = math.max(margin, parent.width - headSize - margin);
    final maxY = math.max(margin, parent.height - headSize - margin);

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
  }

  void _onPanUpdate(DragUpdateDetails details) {
    setState(() {
      position = (position + details.delta);
      // clamp immediately to keep head visible
      final parent = MediaQuery.of(context).size;
      final maxX = math.max(margin, parent.width - headSize - margin);
      final maxY = math.max(margin, parent.height - headSize - margin);
      position = Offset(position.dx.clamp(margin, maxX),
          position.dy.clamp(margin + MediaQuery.of(context).padding.top, maxY));
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
    final minY = margin + MediaQuery.of(context).padding.top;
    final maxX = math.max(margin, parent.width - headSize - margin);
    final maxY = math.max(margin, parent.height - headSize - margin);

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
      } else {
        // when closing, ensure it's attached
        _snapToEdge();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final parent = MediaQuery.of(context).size;
    final maxX = math.max(margin, parent.width - headSize - margin);
    final maxY = math.max(margin, parent.height - headSize - margin);

    // clamp position (defensive)
    position = Offset(position.dx.clamp(margin, maxX),
        position.dy.clamp(margin + MediaQuery.of(context).padding.top, maxY));

    return Obx(() {
      final items = widget.ctrl.newItems;
      // SUM of estimatedCost directly (user-specified inclusive cost per item)
      final total = items.fold<double>(
        0.0,
            (s, it) {
          final est = it.estimatedCost ?? 0.0;
          return s + est;
        },
      );

      // prepare rows for table preview
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
          .take(8)
          .toList();

      // compute card placement: prefer above head if there's space, otherwise below
      final cardWidth = math.min(parent.width * 0.86, cardMaxWidth);
      final desiredLeft = (position.dx + headSize / 2) - cardWidth / 2;
      final left = desiredLeft.clamp(margin, parent.width - cardWidth - margin);
      final aboveTop = position.dy - 12 - cardHeight;
      final placeAbove = aboveTop >= MediaQuery.of(context).padding.top + margin;
      final top = placeAbove ? aboveTop : (position.dy + headSize + 12);

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

          // expanded card
          Positioned(
            left: left,
            top: top,
            child: AnimatedOpacity(
              opacity: expanded ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOut,
              child: IgnorePointer(
                ignoring: !expanded,
                child: Material(
                  elevation: 18,
                  borderRadius: BorderRadius.circular(14),
                  child: AnimatedSize(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Container(
                      width: cardWidth,
                      // 🔥 remove fixed height
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min, // 🔥 important: size depends on children
                        children: [
                          // header + close
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  'Order Details',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
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

                          // Table rows (🔥 no fixed height: all rows visible)
                          if (rows.isEmpty)
                            Center(child: Text('No items yet', style: Theme.of(context).textTheme.bodySmall))
                          else
                            Column(
                              children: rows.map((r) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 4),
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
                                onPressed: _toggleExpanded,
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


          // The chat-head (draggable button showing total)
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
                    colors: [AppColors.primary, AppColors.primary.withOpacity(0.9)],
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
}
