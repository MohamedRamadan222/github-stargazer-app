import 'dart:async';

import 'package:flutter/material.dart';

class RateLimitWidget extends StatefulWidget {
  final DateTime resetTime;
  final VoidCallback onRetry;

  const RateLimitWidget({
    super.key,
    required this.resetTime,
    required this.onRetry,
  });

  @override
  State<RateLimitWidget> createState() => _RateLimitWidgetState();
}

class _RateLimitWidgetState extends State<RateLimitWidget> {
  late Timer _timer;
  Duration _timeLeft = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateTime();
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) => _updateTime(),
    );
  }

  void _updateTime() {
    final now = DateTime.now();
    if (widget.resetTime.isAfter(now)) {
      setState(() {
        _timeLeft = widget.resetTime.difference(now);
      });
    } else {
      _timer.cancel();
      widget.onRetry(); // إعادة المحاولة تلقائياً لما الوقت يخلص
    }
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final minutes = _timeLeft.inMinutes.toString().padLeft(2, '0');
    final seconds = (_timeLeft.inSeconds % 60).toString().padLeft(2, '0');

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.timer_off, size: 64, color: Colors.orange),
          const SizedBox(height: 16),
          const Text(
            'تخطينا الحد المسموح للطلبات',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            '$minutes:$seconds',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'سيتم تحديث الصفحة تلقائياً عند انتهاء الوقت',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
