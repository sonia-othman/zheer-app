import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:intl/intl.dart';
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
  bool _initialized = false;
  String filter = 'daily'; // or 'weekly', 'monthly'

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (!_initialized) {
      provider = Provider.of<SensorProvider>(context, listen: false);
      provider.clearCurrentData(); // clear old chart data
      _loadFreshData(); // load fresh chart data
      _initialized = true;
    }
  }

  // Load fresh data from API
  Future<void> _loadFreshData() async {
    print(
      '🔄 Loading fresh data for device: ${widget.deviceId} with filter: $filter',
    );
    await provider.loadFilteredSensorData(
      deviceId: widget.deviceId,
      filter: filter,
      forceRefresh: true,
    );
  }

  // Refresh only the latest data from API
  Future<void> _refreshLatestData() async {
    print('🔄 Refreshing latest data from API for: ${widget.deviceId}');
    await provider.refreshCurrentDeviceLatest();
  }

  // Change filter and reload data
  Future<void> _changeFilter(String newFilter) async {
    if (newFilter != filter) {
      setState(() => filter = newFilter);
      await _loadFreshData();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Dashboard: ${widget.deviceId}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.api),
            onPressed: _refreshLatestData,
            tooltip: 'Refresh Latest from API',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFreshData,
            tooltip: 'Refresh All from API',
          ),
        ],
      ),
      body: Consumer<SensorProvider>(
        builder: (context, provider, child) {
          // Show loading state
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Loading fresh data from API...'),
                ],
              ),
            );
          }

          // Show error state
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.red, size: 64),
                  const SizedBox(height: 16),
                  Text(
                    'API Error',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      provider.errorMessage!,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadFreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry API Call'),
                  ),
                ],
              ),
            );
          }

          // Show dashboard content
          return RefreshIndicator(
            onRefresh: _loadFreshData,
            child: ListView(
              padding: const EdgeInsets.all(12),
              children: [
                _buildAPIStatusIndicator(),
                const SizedBox(height: 12),
                _buildSummaryCards(),
                const SizedBox(height: 20),
                _buildChartSection(provider.filteredData),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAPIStatusIndicator() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.blue.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.api, color: Colors.blue),
          const SizedBox(width: 8),
          Text(
            'Device: ${widget.deviceId} | Filter: ${filter.toUpperCase()}',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Colors.blue,
            ),
          ),
          const Spacer(),
          Text(
            'API Data: ${provider.filteredData.length} records',
            style: const TextStyle(fontSize: 12, color: Colors.blue),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCards() {
    final latest = provider.currentDeviceLatest;

    if (latest == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Icon(Icons.cloud_download, size: 48, color: Colors.orange),
              const SizedBox(height: 8),
              const Text('Loading latest data from API...'),
              const SizedBox(height: 12),
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _refreshLatestData,
                icon: const Icon(Icons.api),
                label: const Text('Retry API Call'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Row(
              children: [
                Icon(Icons.api, size: 20, color: Colors.green),
                SizedBox(width: 8),
                Text(
                  'Live API Data',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withOpacity(0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.cloud_done,
                        size: 12,
                        color: Colors.green,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'API: ${DateFormat('HH:mm:ss').format(latest.createdAt.toLocal())}',
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.green,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.api, size: 16),
                  onPressed: _refreshLatestData,
                  tooltip: 'Refresh from API',
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _infoCard(
              'Status',
              latest.status ? 'Online' : 'Offline',
              color: latest.status ? Colors.green : Colors.red,
              icon: latest.status ? Icons.wifi : Icons.wifi_off,
            ),
            _infoCard(
              'Temperature',
              '${latest.temperature.toStringAsFixed(1)} °C',
              icon: Icons.thermostat,
            ),
            _infoCard(
              'Battery',
              '${latest.battery.toStringAsFixed(0)} %',
              color: _getBatteryColor(latest.battery),
              icon: _getBatteryIcon(latest.battery),
            ),
            _infoCard('Count', '${latest.count}', icon: Icons.analytics),
          ],
        ),
      ],
    );
  }

  Widget _infoCard(String title, String value, {Color? color, IconData? icon}) {
    return Card(
      elevation: 2,
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 16, color: color ?? Colors.blue),
                  const SizedBox(width: 4),
                ],
                Flexible(
                  child: Text(
                    title,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(fontSize: 20, color: color ?? Colors.blue),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Color _getBatteryColor(double battery) {
    if (battery > 50) return Colors.green;
    if (battery > 20) return Colors.orange;
    return Colors.red;
  }

  IconData _getBatteryIcon(double battery) {
    if (battery > 75) return Icons.battery_full;
    if (battery > 50) return Icons.battery_5_bar;
    if (battery > 25) return Icons.battery_3_bar;
    if (battery > 10) return Icons.battery_1_bar;
    return Icons.battery_alert;
  }

  Widget _buildChartSection(List<SensorData> data) {
    List<SensorData> filteredData = data;

    if (filter == 'daily') {
      final now = DateTime.now();
      final last24h = now.subtract(const Duration(hours: 24));
      filteredData =
          data.where((e) => e.createdAt.isAfter(last24h)).toList()..sort(
            (a, b) => a.createdAt.compareTo(b.createdAt),
          ); // ✅ sort chronologically
    }

    return Column(
      children: [
        _filterSelector(),
        const SizedBox(height: 10),
        if (filteredData.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(Icons.bar_chart, size: 48, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text(
                    'No chart data available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'API returned no filtered data for $filter period',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadFreshData,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh from API'),
                  ),
                ],
              ),
            ),
          )
        else ...[
          _chart('Event Count', filteredData, 'count'),
          _chart('Temperature (°C)', filteredData, 'temperature'),
          _chart('Battery (%)', filteredData, 'battery'),
        ],
      ],
    );
  }

  Widget _chart(String title, List<SensorData> data, String valueType) {
    // For 'count' type: expand data so each count becomes a separate bar
    List<SensorData> expandedData;

    if (valueType == 'count') {
      expandedData = [];
      for (var record in data) {
        for (int i = 0; i < record.count; i++) {
          expandedData.add(
            SensorData(
              deviceId: record.deviceId,
              temperature: record.temperature,
              battery: record.battery,
              status: record.status,
              count: 1,
              createdAt: record.createdAt.add(
                Duration(seconds: i),
              ), // ✅ unique X
            ),
          );
        }
      }
    } else {
      expandedData = data;
    }

    return SizedBox(
      height: 250,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: SfCartesianChart(
            title: ChartTitle(text: title),
            primaryXAxis: DateTimeAxis(
              intervalType: DateTimeIntervalType.hours,
              dateFormat: DateFormat.Hm(), // HH:mm
              majorGridLines: const MajorGridLines(width: 0),
            ),
            primaryYAxis: NumericAxis(
              title: AxisTitle(text: _getYAxisTitle(title)),
            ),
            tooltipBehavior: TooltipBehavior(enable: true),
            series: <CartesianSeries<SensorData, DateTime>>[
              ColumnSeries<SensorData, DateTime>(
                dataSource: expandedData,
                xValueMapper:
                    (SensorData sensor, _) => sensor.createdAt.toLocal(),
                yValueMapper:
                    (SensorData sensor, _) =>
                        valueType == 'count'
                            ? 1 // One bar per event
                            : _getYValue(sensor, valueType),
                name: title,
                color: _getChartColor(valueType),
                dataLabelSettings: const DataLabelSettings(isVisible: false),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTimeLabel(DateTime dateTime) {
    final localTime = dateTime.toLocal();
    switch (filter) {
      case 'daily':
        // Show actual time from created_at in 24-hour format
        return DateFormat('HH:mm').format(localTime);
      case 'weekly':
        // Show day name (Mon, Tue, etc.)
        return DateFormat('E').format(localTime);
      case 'monthly':
        // Show day of month
        return DateFormat('d').format(localTime);
      default:
        return DateFormat('HH:mm').format(localTime);
    }
  }

  double _getYValue(SensorData sensor, String valueType) {
    switch (valueType) {
      case 'count':
        return sensor.count.toDouble();
      case 'temperature':
        return sensor.temperature;
      case 'battery':
        return sensor.battery;
      default:
        return 0.0;
    }
  }

  String _getYAxisTitle(String chartTitle) {
    if (chartTitle.contains('Temperature')) return 'Temperature (°C)';
    if (chartTitle.contains('Battery')) return 'Battery (%)';
    if (chartTitle.contains('Count')) return 'Event Count';
    return '';
  }

  Color _getChartColor(String valueType) {
    switch (valueType) {
      case 'count':
        return Colors.blue;
      case 'temperature':
        return Colors.orange;
      case 'battery':
        return Colors.green;
      default:
        return Colors.blue;
    }
  }

  Widget _filterSelector() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children:
          ['daily', 'weekly', 'monthly'].map((f) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: ChoiceChip(
                label: Text(f.toUpperCase()),
                selected: filter == f,
                onSelected: (_) => _changeFilter(f),
              ),
            );
          }).toList(),
    );
  }
}
