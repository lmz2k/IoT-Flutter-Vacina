import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../components/drop_down.dart';

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
  List<String> dates = [];
  String? selectedDate;
  String? high;
  String? low;

  double getMaxTemperature(List<TemperatureData> list) {
    if (list.isEmpty) {
      throw Exception('A lista está vazia.');
    }

    return list.map((data) => data.temperature).reduce(
        (currentMax, temperature) =>
            temperature > currentMax ? temperature : currentMax);
  }

  double getMinTemperature(List<TemperatureData> list) {
    if (list.isEmpty) {
      throw Exception('A lista está vazia.');
    }

    return list.map((data) => data.temperature).reduce(
        (currentMin, temperature) =>
            temperature < currentMin ? temperature : currentMin);
  }

  Future <String> getDates(String document) async {
    final snapshot = await FirebaseFirestore.instance
        .collection(document)
        .get();

    List<String> tempDates = [];

    snapshot.docs.forEach((doc) {
      if (!tempDates.contains(doc.data()['date'])) {
        tempDates.add(doc.data()['date']);
      }
    });

    setState(() {
      dates = tempDates;
    });

    return tempDates[0];
  }

  Future<List<TemperatureData>> getData(String document, String? date) async {
    List<TemperatureData> dataList = [];

    date ??= await getDates(document);

    final snapshot = await FirebaseFirestore.instance
        .collection(document)
        .where('date', isEqualTo: date)
        .get();

    print(snapshot.docs.length);

    snapshot.docs.forEach((doc) {
      if(doc.data()['date'] == date) {
        String timestampString = doc.data()['timestamp'];
        DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(int.parse(timestampString) * 1000)
            .toLocal();

        String time =
            "${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}";

        double temperature = double.parse(doc.data()['temperature']);

        dataList.add(TemperatureData(
            time, temperature, int.parse(doc.data()['timestamp'])));
      }
    });

    setState(() {
      high = getMaxTemperature(dataList).toString();
      low = getMinTemperature(dataList).toString();
      selectedDate = date;
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

    if (data == null) {
      setState(() {
        data = getData(selectedContainer, null);
      });
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            data = getData(selectedContainer, selectedDate);
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

                  DropdownList(items: dates, callback: (String? selected){
                    if(selected != null){
                      setState(() {
                        data = getData(selectedContainer, selected);
                      });
                    }
                  }),

              SizedBox(
                height: 48,
                child: Align(
                  alignment: Alignment.center,
                  child: Text(
                    "Os valores mostrados estão em média por minuto da data: $selectedDate",
                    textAlign: TextAlign.center,
                  ),
                )
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
