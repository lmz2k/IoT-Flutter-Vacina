import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TemperatureData {
  final String time;
  final double temperature;
  final int timestamp;

  TemperatureData(this.time, this.temperature, this.timestamp);
}

class ChartPage extends StatefulWidget {
  const ChartPage({super.key});

  @override
  State<ChartPage> createState() => _ChartPageState();
}

class _ChartPageState extends State<ChartPage> {

  Future<List<TemperatureData>>? data;
  String? high;
  String? low;

  double getMaxTemperature(List<TemperatureData> list) {
    if (list.isEmpty) {
      throw Exception('A lista está vazia.');
    }

    return list
        .map((data) => data.temperature)
        .reduce((currentMax, temperature) => temperature > currentMax ? temperature : currentMax);
  }

  double getMinTemperature(List<TemperatureData> list) {
    if (list.isEmpty) {
      throw Exception('A lista está vazia.');
    }

    return list
        .map((data) => data.temperature)
        .reduce((currentMin, temperature) => temperature < currentMin ? temperature : currentMin);
  }

  Future<List<TemperatureData>> getData(String document) async {
    DateTime today = DateTime.now();
    String formattedDate =
        "${today.day.toString()}/${today.month.toString()}/${today.year.toString()}";
    List<TemperatureData> dataList = [];

    final snapshot = await FirebaseFirestore.instance
        .collection(document)
        // .where('date', isEqualTo: formattedDate)
        .get();

    snapshot.docs.forEach((doc) {
      print(doc.data());
      print(int.parse(doc.data()['timestamp']));

      String timestampString = doc.data()['timestamp'];
      DateTime timestamp =
          DateTime.fromMillisecondsSinceEpoch(int.parse(timestampString) * 1000)
              .toLocal();

      String time =
          "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

      double temperature = double.parse(doc.data()['temperature']);

      dataList.add(TemperatureData(
          time, temperature, int.parse(doc.data()['timestamp'])));
    });

    setState(() {
        high = getMaxTemperature(dataList).toString();
        low = getMinTemperature(dataList).toString();
    });

    List<TemperatureData> sortedList = dataList.toList()
      ..sort((a, b) => a.timestamp.compareTo(b.timestamp));

    Map<String, List<double>> groupedData = {};

    for (final data in sortedList) {
      final time = data.time;
      final temperature = data.temperature;

      if (groupedData.containsKey(time)) {
        groupedData[time]!.add(temperature);
      } else {
        groupedData[time] = [temperature];
      }
    }

    final List<TemperatureData> averagedData = groupedData.entries.map((entry) {
      final time = entry.key;
      final temperatures = entry.value;
      final averageTemperature =
          temperatures.reduce((a, b) => a + b) / temperatures.length;

      return TemperatureData(time, averageTemperature.toDouble(), 0);
    }).toList();

    return averagedData;
  }

  @override
  Widget build(BuildContext context) {
    final selectedContainer =
        ModalRoute.of(context)!.settings.arguments as String;

    DateTime today = DateTime.now();
    String formattedDate =
        "${today.day.toString().padLeft(2, '0')}/${today.month.toString().padLeft(2, '0')}/${today.year}";

    if(data == null){
      setState(() {
        data = getData(selectedContainer);
      });

    }
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            data = getData(selectedContainer);
          });
        },
        child: const Icon(Icons.refresh),
      ),
      appBar: AppBar(
        title: Text(selectedContainer),
      ),
      body: FutureBuilder(
        future: data,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          return Column(
            children: [
              SizedBox(
                height: 48,
                child: Center(
                  child: Text("Medias por minuto: ${formattedDate}"),
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
              Padding(
                padding: EdgeInsets.only(bottom: 100),
                child: Row(
                  children: [
                    Flexible(
                      child: ListTile(
                        title: Text("Maior Temperatura: "),
                        subtitle: Text(high ?? " "),
                      ),
                    ),
                    Flexible(
                      child: ListTile(
                        title: Text("Menor Temperatura"),
                        subtitle: Text(low ?? " "),
                      ),
                    )
                  ],
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
