import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';

import '../model/bill_data.dart';
import '../model/item.dart';
import '../model/participant.dart';
import '../model/project.dart';
import '../utils/time.dart';

class NewEntryPage extends StatefulWidget {
  const NewEntryPage(this.project, {super.key, this.item});

  final Project project;
  final Item? item;

  @override
  State<NewEntryPage> createState() => _NewEntryPageState();
}

class _NewEntryPageState extends State<NewEntryPage> {
  late BillData bill;
  final dateController = TextEditingController();
  final titleController = TextEditingController();
  final emitterController = TextEditingController();
  final amountController = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bill = BillData(item: widget.item);
    titleController.text = bill.title;
    dateController.text = getFullDate(bill.date);
    emitterController.text = bill.emitter.pseudo;
    amountController.text = bill.amount.toString();

    for (Participant participant in widget.project.participants) {
      if (widget.item == null) {
        bill.shares[participant] = 1;
      } else if (bill.shares[participant] == null) {
        bill.shares[participant] = 0;
      }
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
                DateTime? date = await showDatePicker(
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
                bill.emitter = widget.project.participants
                    .firstWhere((element) => element.pseudo == value);
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
                    getRows(bill),
              ),
            ),
            ElevatedButton(
              onPressed: () async {
                Item item = bill.toItemOf(widget.project);
                await item.db.saveRecursively();
                Navigator.pop(context, true);
              },
              child: Text(widget.item == null ? 'Create' : 'Update'),
            ),
          ],
        ),
      ),
    );
  }

  List<TableRow> getRows(BillData bill) {
    final List<TableRow> rows = [];

    int total = bill.totalShares;

    if (total <= 0) total = 1;

    bill.shares.forEach((participant, amount) {
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
                    bill.shares[participant] = 0;
                  } else {
                    bill.shares[participant] = 1;
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
                onChanged: (value) {
                  try {
                    setState(() {
                      bill.shares[participant] = int.parse(value);
                    });
                  } catch (e) {}
                },
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
              child: Text("${(price * 100).roundToDouble() / 100} €"),
            ),
          ),
        ],
      ));
    });

    return rows;
  }
}
