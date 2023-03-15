import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';

import '../model/bill_data.dart';
import '../model/item.dart';
import '../model/participant.dart';
import '../model/project.dart';
import '../utils/time.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage(this.project, {super.key});

  final Project project;

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  final BillData bill = BillData();
  final dateController = TextEditingController();
  final titleController = TextEditingController();
  final emitterController = TextEditingController();
  final amountController = TextEditingController();

  final Map<Participant, int> participants = {};

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    titleController.text = bill.title;
    dateController.text = getFullDate(bill.date);
    emitterController.text = bill.emitter.pseudo;
    amountController.text = bill.amount.toString();

    for (Participant participant in widget.project.participants) {
      participants[participant] = 1;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            const Text(
              "Add new bill",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              widget.project.name,
              style: const TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(left: 8.0, bottom: 10),
              child: Text(
                "What ?",
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              controller: titleController,
              autocorrect: false,
              decoration: const InputDecoration(border: OutlineInputBorder()),
              onChanged: (value) => bill.title = value,
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 10, bottom: 10),
              child: Text(
                "When ?",
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              readOnly: true,
              controller: dateController,
              decoration: const InputDecoration(hintText: 'Pick your Date'),
              onTap: () async {
                var date = await showDatePicker(
                  context: context,
                  initialDate: bill.date,
                  firstDate: DateTime(1900),
                  lastDate: DateTime(2100),
                );
                if (date != null) {
                  dateController.text = getFullDate(date);
                  bill.date = date;
                }
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 10),
              child: Text(
                "Who paid ?",
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            SelectFormField(
              type: SelectFormFieldType.dropdown,
              items: widget.project.participants
                  .map((p) => <String, dynamic>{
                        'value': p.pseudo,
                        'label': p.pseudo,
                      })
                  .toList(),
              controller: emitterController,
              onChanged: (value) {
                bill.emitter = Participant(pseudo: value);
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 10),
              child: Text(
                "How much ?",
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            TextField(
              autocorrect: false,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                suffixText: ' €',
              ),
              controller: amountController,
              onChanged: (value) {
                try {
                  double parsed = double.parse(value);
                  setState(() {
                    bill.amount = parsed;
                  });
                } catch (e) {}
              },
            ),
            const Padding(
              padding: EdgeInsets.only(left: 8.0, top: 20, bottom: 10),
              child: Text(
                "For whom ?",
                maxLines: 1,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: Table(
                border: const TableBorder(
                  horizontalInside: BorderSide(
                    width: 1,
                    color: Colors.blue,
                  ),
                  verticalInside: BorderSide(
                    width: 1,
                    color: Colors.blue,
                  ),
                  bottom: BorderSide(
                    width: 1,
                    color: Colors.blue,
                  ),
                  left: BorderSide(
                    width: 1,
                    color: Colors.blue,
                  ),
                  right: BorderSide(
                    width: 1,
                    color: Colors.blue,
                  ),
                  top: BorderSide(
                    width: 1,
                    color: Colors.blue,
                  ),
                ),
                columnWidths: const {
                  0: FixedColumnWidth(50),
                  1: FlexColumnWidth(3),
                  2: FlexColumnWidth(1),
                  3: FlexColumnWidth(1),
                },
                children: <TableRow>[
                      const TableRow(
                        children: [
                          TableCell(
                            child: Text(""),
                          ),
                          TableCell(
                            child: Text(""),
                          ),
                          TableCell(
                            child: Text(
                              "Rate",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          TableCell(
                            child: Text(
                              "Total",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ] +
                    getRows(bill, participants),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Item item = bill.toItemOf(widget.project);
                item.db.saveRecursively();
                Navigator.pop(context, true);
              },
              child: const Text('Create'),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> getRows(BillData bill, Map<Participant, int> participants) {
    final List<TableRow> rows = [];

    int total = participants.values.reduce((a, b) => a + b);

    if (total <= 0) total = 1;

    participants.forEach((participant, amount) {
      TextEditingController controller =
          TextEditingController(text: amount.toString());

      double price = bill.amount * amount / total;

      rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Checkbox(
              value: amount > 0,
              onChanged: (value) {
                setState(() {
                  if (amount > 0) {
                    participants[participant] = 0;
                  } else {
                    participants[participant] = 1;
                  }
                });
              },
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Text(
              participant.pseudo,
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Center(
              child: TextFormField(
                controller: controller,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                      borderSide: BorderSide(
                    width: 0,
                    style: BorderStyle.none,
                  )),
                ),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Center(
              child: Text("$price €"),
            ),
          ),
        ],
      ));
    });

    return rows;
  }
}
