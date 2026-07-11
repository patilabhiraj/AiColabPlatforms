import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import '../../../../core/theme/app_colors.dart';
import '../../domain/entities/usage_log_entity.dart';

class UsageLineChart extends StatefulWidget {
  const UsageLineChart({
    super.key,
    required this.rows,
    required this.days,
  });

  final List<DailyModelUsageEntity> rows;
  final int days;

  @override
  State<UsageLineChart> createState() => _UsageLineChartState();
}

class _UsageLineChartState extends State<UsageLineChart> {
  late Set<String> _activeModels;
  int? _hoverIndex;

  @override
  void initState() {
    super.initState();
    _activeModels = _series().modelNames.toSet();
  }

  @override
  void didUpdateWidget(covariant UsageLineChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.rows != widget.rows) {
      _activeModels = _series().modelNames.toSet();
    }
  }

  _ChartSeries _series() => _buildSeries(widget.rows, widget.days);

  void _toggleModel(String name) {
    setState(() {
      if (_activeModels.contains(name)) {
        if (_activeModels.length > 1) _activeModels.remove(name);
      } else {
        _activeModels.add(name);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final series = _series();

    if (series.modelNames.isEmpty) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 32),
        child: Center(
          child: Text(
            'No model usage in this window yet.',
            style: TextStyle(color: context.cMuted, fontSize: 13),
          ),
        ),
      );
    }

    final colors = _colorsFor(context, series.modelNames);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 220,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return GestureDetector(
                onPanDown: (details) => _updateHover(details.localPosition, constraints.maxWidth, series),
                onPanUpdate: (details) => _updateHover(details.localPosition, constraints.maxWidth, series),
                onPanEnd: (_) => setState(() => _hoverIndex = null),
                onTapDown: (details) => _updateHover(details.localPosition, constraints.maxWidth, series),
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 220),
                  painter: _LineChartPainter(
                    series: series,
                    activeModels: _activeModels,
                    colors: colors,
                    hoverIndex: _hoverIndex,
                    gridColor: context.cBorder,
                    axisTextColor: context.cMuted,
                  ),
                ),
              );
            },
          ),
        ),
        if (_hoverIndex != null) _buildTooltip(context, series, colors),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: series.modelNames.map((name) {
            final active = _activeModels.contains(name);
            final color = colors[name]!;
            return GestureDetector(
              onTap: () => _toggleModel(name),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: active
                      ? context.cCard.withValues(alpha: context.isDark ? 0.6 : 1)
                      : context.cMuted.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: active ? context.cBorder : Colors.transparent,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 11.5,
                        color: active ? context.cFg : context.cMuted.withValues(alpha: 0.6),
                        decoration: active ? null : TextDecoration.lineThrough,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  void _updateHover(Offset localPosition, double width, _ChartSeries series) {
    if (series.data.isEmpty) return;
    const leftPad = 44.0;
    final plotWidth = width - leftPad;
    if (plotWidth <= 0) return;
    final ratio = ((localPosition.dx - leftPad) / plotWidth).clamp(0.0, 1.0);
    final index = (ratio * (series.data.length - 1)).round();
    setState(() => _hoverIndex = index.clamp(0, series.data.length - 1));
  }

  Widget _buildTooltip(BuildContext context, _ChartSeries series, Map<String, Color> colors) {
    final index = _hoverIndex!;
    final point = series.data[index];
    final entries = series.modelNames
        .where((name) => _activeModels.contains(name) && (point.values[name] ?? 0) > 0)
        .toList()
      ..sort((a, b) => (point.values[b] ?? 0).compareTo(point.values[a] ?? 0));

    if (entries.isEmpty) return const SizedBox.shrink();

    final formatter = NumberFormat.decimalPattern();

    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: context.cCard,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: context.cBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            point.label,
            style: TextStyle(color: context.cFg, fontWeight: FontWeight.w700, fontSize: 12.5),
          ),
          const SizedBox(height: 6),
          ...entries.map((name) => Padding(
                padding: const EdgeInsets.only(top: 3),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: colors[name]),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        name,
                        style: TextStyle(color: context.cMuted, fontSize: 12),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      formatter.format(point.values[name] ?? 0),
                      style: TextStyle(
                        color: context.cFg,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Map<String, Color> _colorsFor(BuildContext context, List<String> names) {
    final palette = context.isDark
        ? const [
            AppColors.darkChart1,
            AppColors.darkChart2,
            AppColors.darkChart3,
            AppColors.darkChart4,
            AppColors.darkChart5,
          ]
        : const [
            AppColors.lightChart1,
            AppColors.lightChart2,
            AppColors.lightChart3,
            AppColors.lightChart4,
            AppColors.lightChart5,
          ];
    return {
      for (var i = 0; i < names.length; i++) names[i]: palette[i % palette.length],
    };
  }
}

// ── Data shaping ──────────────────────────────────────────────────────────────

class _ChartPoint {
  final String label;
  final Map<String, int> values;
  _ChartPoint(this.label, this.values);
}

class _ChartSeries {
  final List<_ChartPoint> data;
  final List<String> modelNames;
  _ChartSeries(this.data, this.modelNames);
}

_ChartSeries _buildSeries(List<DailyModelUsageEntity> rows, int days) {
  final end = DateTime.now().toUtc();
  final endDay = DateTime.utc(end.year, end.month, end.day);
  final startDay = endDay.subtract(Duration(days: days - 1));

  final dateKeys = <String>[];
  for (var d = startDay; !d.isAfter(endDay); d = d.add(const Duration(days: 1))) {
    dateKeys.add(d.toIso8601String().substring(0, 10));
  }

  final totalsByModel = <String, int>{};
  for (final row in rows) {
    totalsByModel[row.modelName] = (totalsByModel[row.modelName] ?? 0) + row.tokens;
  }
  final modelNames = totalsByModel.keys.toList()
    ..sort((a, b) => totalsByModel[b]!.compareTo(totalsByModel[a]!));

  final byDay = <String, Map<String, int>>{};
  for (final row in rows) {
    final day = row.day.length >= 10 ? row.day.substring(0, 10) : row.day;
    final map = byDay.putIfAbsent(day, () => {});
    map[row.modelName] = (map[row.modelName] ?? 0) + row.tokens;
  }

  final dateFormat = DateFormat.MMMd();
  final data = dateKeys.map((dateStr) {
    final date = DateTime.parse('${dateStr}T12:00:00.000Z');
    final dayMap = byDay[dateStr] ?? const {};
    return _ChartPoint(
      dateFormat.format(date),
      {for (final name in modelNames) name: dayMap[name] ?? 0},
    );
  }).toList();

  return _ChartSeries(data, modelNames);
}

// ── Painter ───────────────────────────────────────────────────────────────────

class _LineChartPainter extends CustomPainter {
  _LineChartPainter({
    required this.series,
    required this.activeModels,
    required this.colors,
    required this.hoverIndex,
    required this.gridColor,
    required this.axisTextColor,
  });

  final _ChartSeries series;
  final Set<String> activeModels;
  final Map<String, Color> colors;
  final int? hoverIndex;
  final Color gridColor;
  final Color axisTextColor;

  static const double _leftPad = 44;
  static const double _bottomPad = 20;
  static const double _topPad = 8;

  @override
  void paint(Canvas canvas, Size size) {
    if (series.data.isEmpty) return;

    final plotWidth = size.width - _leftPad;
    final plotHeight = size.height - _bottomPad - _topPad;

    var maxValue = 1;
    for (final point in series.data) {
      for (final name in activeModels) {
        final v = point.values[name] ?? 0;
        if (v > maxValue) maxValue = v;
      }
    }
    // Round up to a "nice" ceiling for grid lines.
    final niceMax = _niceCeil(maxValue);

    // ── Grid lines + Y axis labels ──────────────────────────────────────────
    final gridPaint = Paint()
      ..color = gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1;
    const gridSteps = 4;
    for (var i = 0; i <= gridSteps; i++) {
      final y = _topPad + plotHeight - (plotHeight * i / gridSteps);
      canvas.drawLine(Offset(_leftPad, y), Offset(size.width, y), gridPaint);

      final value = niceMax * i / gridSteps;
      final label = _formatTick(value);
      final tp = TextPainter(
        text: TextSpan(
          text: label,
          style: TextStyle(color: axisTextColor, fontSize: 10.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas, Offset(_leftPad - tp.width - 6, y - tp.height / 2));
    }

    // ── X axis labels (first, mid, last) ────────────────────────────────────
    final xIndices = <int>{0, series.data.length - 1};
    if (series.data.length > 2) xIndices.add(series.data.length ~/ 2);
    for (final i in xIndices) {
      final x = _leftPad + plotWidth * (series.data.length == 1 ? 0 : i / (series.data.length - 1));
      final tp = TextPainter(
        text: TextSpan(
          text: series.data[i].label,
          style: TextStyle(color: axisTextColor, fontSize: 10.5),
        ),
        textDirection: TextDirection.ltr,
      )..layout();
      double dx = x - tp.width / 2;
      dx = dx.clamp(_leftPad, size.width - tp.width);
      tp.paint(canvas, Offset(dx, size.height - _bottomPad + 4));
    }

    // ── Lines ────────────────────────────────────────────────────────────────
    double xFor(int i) =>
        _leftPad + plotWidth * (series.data.length == 1 ? 0 : i / (series.data.length - 1));
    double yFor(int value) =>
        _topPad + plotHeight - (plotHeight * value / niceMax).clamp(0, plotHeight);

    for (final name in series.modelNames) {
      if (!activeModels.contains(name)) continue;
      final color = colors[name]!;
      final path = Path();
      for (var i = 0; i < series.data.length; i++) {
        final x = xFor(i);
        final y = yFor(series.data[i].values[name] ?? 0);
        if (i == 0) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(
        path,
        Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );
    }

    // ── Hover crosshair + dots ───────────────────────────────────────────────
    if (hoverIndex != null && hoverIndex! < series.data.length) {
      final x = xFor(hoverIndex!);
      canvas.drawLine(
        Offset(x, _topPad),
        Offset(x, size.height - _bottomPad),
        Paint()
          ..color = axisTextColor.withValues(alpha: 0.35)
          ..strokeWidth = 1,
      );
      for (final name in series.modelNames) {
        if (!activeModels.contains(name)) continue;
        final value = series.data[hoverIndex!].values[name] ?? 0;
        if (value <= 0) continue;
        final y = yFor(value);
        final color = colors[name]!;
        canvas.drawCircle(Offset(x, y), 5, Paint()..color = Colors.white.withValues(alpha: 0.9));
        canvas.drawCircle(Offset(x, y), 3.5, Paint()..color = color);
      }
    }
  }

  int _niceCeil(int value) {
    if (value <= 0) return 1;
    final magnitude = _pow10Floor(value);
    final fraction = value / magnitude;
    double niceFraction;
    if (fraction <= 1) {
      niceFraction = 1;
    } else if (fraction <= 2) {
      niceFraction = 2;
    } else if (fraction <= 5) {
      niceFraction = 5;
    } else {
      niceFraction = 10;
    }
    return (niceFraction * magnitude).round();
  }

  int _pow10Floor(int value) {
    var magnitude = 1;
    while (magnitude * 10 <= value) {
      magnitude *= 10;
    }
    return magnitude;
  }

  String _formatTick(num n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return n.round().toString();
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.series != series ||
        oldDelegate.activeModels != activeModels ||
        oldDelegate.hoverIndex != hoverIndex;
  }
}
