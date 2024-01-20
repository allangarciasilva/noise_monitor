import 'package:flutter/material.dart';
import 'package:noise_monitor/models/device.dart';
import 'package:noise_monitor/utils/scaffold.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:noise_monitor/api/api.dart' as api;

class DeviceMonitoringView extends StatefulWidget {
  const DeviceMonitoringView({super.key, required this.device});

  final Device device;

  @override
  State<DeviceMonitoringView> createState() => _DeviceMonitoringViewState();
}

class PlotPoint {
  PlotPoint(this.index, this.value);

  int index;
  double value;
}

class _DeviceMonitoringViewState extends State<DeviceMonitoringView> {
  late final WebSocketChannel _channel;

  static const int maxRecordedValues = 10;
  var _recordedValues = List<double>.generate(
    maxRecordedValues,
    (index) => 0,
  );

  void _recordValue(double? value) {
    if (value == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      _recordedValues.add(value);
      if (_recordedValues.length > maxRecordedValues) {
        _recordedValues = _recordedValues.sublist(1);
      }
    });
  }


  @override
  void initState() {
    _channel = api.connectToWebsocket("/ws/noise/${widget.device.name}");
    _channel.stream.listen((event) {
      _recordValue(double.tryParse(event));
    });
    super.initState();
  }

  @override
  void dispose() {
    _channel.sink.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LoggedScaffold(
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            Container(
              margin: EdgeInsets.only(bottom: 15),
              child: Text(
                widget.device.name,
                style: TextStyle(fontSize: 18),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: SfCartesianChart(
                primaryXAxis: CategoryAxis(),
                primaryYAxis: NumericAxis(minimum: 0, maximum: 20),
                series: [
                  LineSeries<num, int>(
                    dataSource: _recordedValues.map((e) {
                      return 110 - e * e;
                    }).toList(),
                    xValueMapper: (_, index) => index + 1,
                    yValueMapper: (value, _) => value,
                    animationDuration: 0,
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
