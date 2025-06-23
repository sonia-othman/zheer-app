import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
import 'package:zheer/widgets/custom_app_bar.dart';
import 'package:zheer/l10n/generated/app_localizations.dart';
import '../models/sensor_data.dart';
import '../providers/sensor_provider.dart';

class DeviceDashboard extends StatefulWidget {
  final String deviceId;
  const DeviceDashboard({super.key, required this.deviceId});

  @override
  State<DeviceDashboard> createState() => _DeviceDashboardState();
}

class _DeviceDashboardState extends State<DeviceDashboard> {
  late SensorProvider provider;
  String filter = 'daily';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    provider = Provider.of<SensorProvider>(context, listen: false);
    provider.initializeRealtimeUpdates();
    _loadFreshData();
  }

  Future<void> _loadFreshData() async {
    await provider.loadFilteredSensorData(
      deviceId: widget.deviceId,
      filter: filter,
      forceRefresh: true,
    );
    await provider.loadDailyTimeData(widget.deviceId);
  }

  Future<void> _changeFilter(String newFilter) async {
    if (newFilter != filter) {
      setState(() => filter = newFilter);
      await _loadFreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Color(0xFFF8FAFD),
      appBar: CustomAppBar(title: l10n.deviceDashboard),
      body: Consumer<SensorProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4E7ABA)),
              ),
            );
          } else if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, color: Color(0xFFE74C3C), size: 60),
                  SizedBox(height: 16),
                  Text(
                    l10n.errorLoadingData,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF23538F),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    provider.errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF23538F),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                    onPressed: _loadFreshData,
                    child: Text(
                      l10n.tryAgain,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _loadFreshData,
            color: Color(0xFF23538F),
            child: SingleChildScrollView(
              padding: EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${l10n.deviceDashboard} - ${widget.deviceId}',
                    style: TextStyle(
                      fontFamily: 'NotoSansArabic',
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF23538F),
                    ),
                  ),
                  SizedBox(height: 20),
                  _summaryCards(l10n),
                  SizedBox(height: 24),
                  _filterSelector(l10n),
                  SizedBox(height: 16),
                  _chartSection(provider.filteredData, l10n),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _summaryCards(AppLocalizations l10n) {
    final latest = provider.currentDeviceLatest;
    if (latest == null) return Center(child: CircularProgressIndicator());

    return GridView.count(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      childAspectRatio: 1.2,
      crossAxisSpacing: 16,
      mainAxisSpacing: 16,
      padding: EdgeInsets.zero,
      children: [
        _summaryTile(
          l10n.status,
          latest.status ? l10n.opened : l10n.closed,
          icon: latest.status ? Icons.door_back_door : Icons.door_front_door,
          color: latest.status ? Color(0xFFE74C3C) : Color(0xFF2ECC71),
          iconBg: latest.status ? Color(0xFFFDECEC) : Color(0xFFE8F8EF),
        ),
        _summaryTile(
          l10n.temperature,
          '${latest.temperature} °C',
          icon: Icons.thermostat,
          color: Color(0xFFBA1818),
          iconBg: Color(0xFFF8EAEA),
        ),
        _summaryTile(
          l10n.battery,
          '${latest.battery.toStringAsFixed(1)} V',
          icon: Icons.battery_charging_full,
          color: Color.fromARGB(255, 239, 142, 5),
          iconBg: Color.fromARGB(255, 254, 246, 231),
        ),
        _summaryTile(
          l10n.count,
          '${latest.count}',
          icon: Icons.numbers,
          color: Color(0xFF23538F),
          iconBg: Color(0xFFEEF1F8),
        ),
      ],
    );
  }

  Widget _summaryTile(
    String label,
    String value, {
    required IconData icon,
    required Color color,
    Color? iconBg,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: iconBg ?? Color(0xFFEAF2F8),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3B4E),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chartSection(List<SensorData> data, AppLocalizations l10n) {
    List<SensorData> chartData = data;

    if (chartData.isEmpty && filter == 'daily') {
      final today = DateFormat('yyyy-MM-dd').format(DateTime.now());
      final fallback =
          provider.dailyTimeData.where((dt) {
            return DateFormat('yyyy-MM-dd').format(dt) == today;
          }).toList();

      if (fallback.isNotEmpty) {
        chartData =
            fallback.map((dt) {
              return SensorData(
                deviceId: '',
                status: false,
                temperature: 0,
                battery: 0,
                count: 1,
                createdAt: dt,
                dateLabel: DateFormat('h:mm a').format(dt),
              );
            }).toList();

        print('✅ Using dailyTimeData fallback: ${chartData.length} items');
      }
    }

    if (chartData.isEmpty) {
      return Container(
        padding: EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Text(l10n.noData, style: TextStyle(color: Colors.grey[600])),
        ),
      );
    }

    return Column(
      children: [
        _barChart(l10n.eventCount, chartData),
        SizedBox(height: 16),
        _combinedChart(chartData, l10n),
      ],
    );
  }

  Widget _barChart(String title, List<SensorData> data) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3B4E),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                  minimum: 0,
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Color(0xFF2E3B4E),
                ),
                enableAxisAnimation: true,
                series: <CartesianSeries<SensorData, String>>[
                  ColumnSeries<SensorData, String>(
                    dataSource: data,
                    xValueMapper:
                        (sensor, _) =>
                            sensor.dateLabel ??
                            DateFormat(
                              'h:mm a',
                            ).format(sensor.createdAt.toLocal()),
                    yValueMapper: (sensor, _) => sensor.count.toDouble(),
                    name: title,
                    color: Color(0xFF4E7ABA),
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(4),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _combinedChart(List<SensorData> data, AppLocalizations l10n) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.tempAndBattery,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF2E3B4E),
              ),
            ),
            SizedBox(height: 8),
            SizedBox(
              height: 240,
              child: SfCartesianChart(
                margin: EdgeInsets.zero,
                plotAreaBorderWidth: 0,
                primaryXAxis: CategoryAxis(
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                primaryYAxis: NumericAxis(
                  labelStyle: TextStyle(color: Colors.grey[600]),
                  axisLine: AxisLine(width: 0),
                  majorTickLines: MajorTickLines(size: 0),
                ),
                tooltipBehavior: TooltipBehavior(
                  enable: true,
                  color: Color(0xFF2E3B4E),
                ),
                legend: Legend(
                  isVisible: true,
                  position: LegendPosition.top,
                  overflowMode: LegendItemOverflowMode.wrap,
                ),
                enableAxisAnimation: true,
                series: <CartesianSeries<SensorData, String>>[
                  LineSeries<SensorData, String>(
                    dataSource: data,
                    xValueMapper:
                        (sensor, _) =>
                            sensor.dateLabel ??
                            DateFormat(
                              'h:mm a',
                            ).format(sensor.createdAt.toLocal()),
                    yValueMapper: (sensor, _) => sensor.temperature,
                    name: 'Temperature (°C)',
                    color: Color(0xFFE74C3C),
                    width: 2.5,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: Color(0xFFE74C3C),
                      color: Colors.white,
                    ),
                  ),
                  LineSeries<SensorData, String>(
                    dataSource: data,
                    xValueMapper:
                        (sensor, _) =>
                            sensor.dateLabel ??
                            DateFormat(
                              'h:mm a',
                            ).format(sensor.createdAt.toLocal()),
                    yValueMapper: (sensor, _) => sensor.battery,
                    name: 'Battery (V)',
                    color: Color(0xFF2ECC71),
                    width: 2.5,
                    markerSettings: MarkerSettings(
                      isVisible: true,
                      shape: DataMarkerType.circle,
                      borderWidth: 2,
                      borderColor: Color(0xFF2ECC71),
                      color: Colors.white,
                    ),
                    onRendererCreated: (ChartSeriesController controller) {},
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _filterSelector(AppLocalizations l10n) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Color(0xFFEAF2F8),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            ['daily', 'weekly', 'monthly'].map((f) {
              return Padding(
                padding: EdgeInsets.symmetric(horizontal: 4),
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _changeFilter(f),
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color:
                          filter == f ? Color(0xFF4E7ABA) : Colors.transparent,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      (f == 'daily'
                              ? l10n.daily
                              : f == 'weekly'
                              ? l10n.weekly
                              : l10n.monthly)
                          .toUpperCase(),
                      style: TextStyle(
                        color: filter == f ? Colors.white : Color(0xFF4E7ABA),
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
      ),
    );
  }
}
