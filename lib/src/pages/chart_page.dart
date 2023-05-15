import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureData {
  final String time;
  final int temperature;
  final int timestamp;
  TemperatureData(this.time, this.temperature, this.timestamp);
}

class ChartPage extends StatelessWidget {
  const ChartPage({super.key});

  Future<List<TemperatureData>> getData(String document) async {
    DateTime today = DateTime.now();
    String formattedDate = "${today.day.toString()}/${today.month.toString()}/${today.year.toString()}";
    List<TemperatureData> dataList = [];

    final snapshot = await FirebaseFirestore.instance.collection(document).where('date', isEqualTo: formattedDate).get();

    snapshot.docs.forEach((doc) {
      String timestampString = doc.data()['timestamp'].toString();
      DateTime timestamp = DateTime.fromMillisecondsSinceEpoch(int.parse(timestampString)  * 1000).toLocal();
      String time = "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";
      int temperature = doc.data()['temperature'];

      dataList.add(TemperatureData(time, temperature, doc.data()['timestamp']));
    });

    print(dataList.length);

    List<TemperatureData> sortedList = dataList.toList()..sort((a, b) => a.timestamp.compareTo(b.timestamp));
    Map<String, List<int>> groupedData = {};

    for (final data in sortedList) {
      final time = data.time;
      final temperature = data.temperature;

      if (groupedData.containsKey(time)) {
        groupedData[time]!.add(temperature);
      } else {
        groupedData[time] = [temperature];
      }
    }

    print(sortedList.length);

    final List<TemperatureData> averagedData = groupedData.entries.map((entry) {
      final time = entry.key;
      final temperatures = entry.value;
      final averageTemperature = temperatures.reduce((a, b) => a + b) / temperatures.length;

      return TemperatureData(time, averageTemperature.toInt(), 0);
    }).toList();

    print(averagedData.length);

    return averagedData;
  }

  @override
  Widget build(BuildContext context) {
    final selectedContainer =
    ModalRoute.of(context)!.settings.arguments as String;

    DateTime today = DateTime.now();
    String formattedDate = "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    return Scaffold(
      appBar: AppBar(
        title: Text(selectedContainer),
      ),
      body: FutureBuilder(
        future: getData(selectedContainer),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              Container(
                height: 48, // Defina uma altura para o Container
                child: Center(
                  child: Text(
                      formattedDate
                  ),
                ),
              ),
              Expanded(
                child: SfCartesianChart(
                  primaryXAxis: CategoryAxis(),
                  series: <LineSeries<TemperatureData, String>>[
                    LineSeries<TemperatureData, String>(
                      dataSource: snapshot.data ?? [],
                      xValueMapper: (TemperatureData temperature, _) =>
                      temperature.time,
                      yValueMapper: (TemperatureData temperature, _) =>
                      temperature.temperature,
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}