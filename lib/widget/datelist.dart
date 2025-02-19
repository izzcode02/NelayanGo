import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateList extends StatefulWidget {
  const DateList({super.key});

  @override
  State<DateList> createState() => _DateListState();
}

class _DateListState extends State<DateList> {
  final TextEditingController _dateController = TextEditingController();
  final FocusNode _dateFocus = FocusNode();

  void _showDatePicker() async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2010),
      lastDate: DateTime(2030),
    );
    if (date != null) {
      _dateController.text = DateFormat.yMd().format(date);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      // crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          height: 100,
          width: 1025,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.3),
                spreadRadius: 2,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                width: 679,
                child: TextFormField(
                  controller: _dateController,
                  focusNode: _dateFocus,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(Icons.calendar_today),
                      onPressed: _showDatePicker,
                    ),
                  ),
                  onTap: _showDatePicker,
                  readOnly: true,
                ),
              ),
              ElevatedButton(
                onPressed: () {},
                style: ButtonStyle(
                  minimumSize: MaterialStatePropertyAll(Size(224, 58)),
                  backgroundColor: MaterialStatePropertyAll(Colors.blue),
                ),
                child: Text('Search'),
              )
            ],
          ),
        ),
      ],
    );
  }
}
