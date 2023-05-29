import 'package:flutter/material.dart';

class DropdownList extends StatefulWidget {
  final List<String> items;
  final Function(String?) callback;

  DropdownList({required this.items,required this.callback});

  @override
  _DropdownListState createState() => _DropdownListState();
}

class _DropdownListState extends State<DropdownList> {
  String? selectedItem;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Selecione uma data:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20), // Espaçamento entre a label e o DropdownButton
        DropdownButton<String>(
            itemHeight: 50.0,
            value: selectedItem ?? widget.items[0],
            onChanged: (String? newValue) {
              widget.callback(newValue);
              setState(() {
                selectedItem = newValue;
              });
            },
            items: widget.items.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
      ],
    );
  }
}
