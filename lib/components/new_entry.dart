import 'package:flutter/material.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared/utils/colors.dart';

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
    dateController.text = daysElapsed(bill.date);
    emitterController.text = bill.emitter.pseudo;
    amountController.text = bill.amount.toStringAsFixed(2);

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
      resizeToAvoidBottomInset: true,
// resizeToAvoidBottomPadding: false,

      appBar: AppBar(
        centerTitle: true,
        title: Column(
          children: [
            Text(
              widget.item == null ? 'Add new bill' : 'Update bill',
              style: const TextStyle(
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  const TitleField("What ?"),
                  TextField(
                    controller: titleController,
                    autocorrect: true,
                    decoration: const InputDecoration(
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    onChanged: (value) => bill.title = value,
                  ),
                  const TitleField('How much ?'),
                  TextField(
                    autocorrect: false,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      suffixText: ' €',
                      contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: Column(
                            children: [
                              const TitleField("Who paid ?"),
                              SelectFormField(
                                type: SelectFormFieldType.dropdown,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                ),
                                items: widget.project.participants
                                    .map((p) => <String, dynamic>{
                                          'value': p.pseudo,
                                          'label': p.pseudo,
                                        })
                                    .toList(),
                                controller: emitterController,
                                onChanged: (value) {
                                  bill.emitter = widget.project.participants
                                      .firstWhere(
                                          (element) => element.pseudo == value);
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(left: 8.0),
                          child: Column(
                            children: [
                              const TitleField("When ?"),
                              TextField(
                                readOnly: true,
                                controller: dateController,
                                decoration: const InputDecoration(
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10),
                                  hintText: 'Pick your Date',
                                ),
                                onTap: () async {
                                  DateTime? date = await showDatePicker(
                                    context: context,
                                    initialDate: bill.date,
                                    firstDate: DateTime(1900),
                                    lastDate: DateTime(2100),
                                  );
                                  if (date != null) {
                                    dateController.text = daysElapsed(date);
                                    bill.date = date;
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  // const TitleField('For whom ?'),
                  Padding(
                    padding: const EdgeInsets.only(top: 25),
                    child: Table(
                      // border: const TableBorder(
                      //   horizontalInside: BorderSide(
                      //     width: 1,
                      //     color: Colors.blue,
                      //   ),
                      //   verticalInside: BorderSide(
                      //     width: 1,
                      //     color: Colors.blue,
                      //   ),
                      //   bottom: BorderSide(
                      //     width: 1,
                      //     color: Colors.blue,
                      //   ),
                      //   left: BorderSide(
                      //     width: 1,
                      //     color: Colors.blue,
                      //   ),
                      //   right: BorderSide(
                      //     width: 1,
                      //     color: Colors.blue,
                      //   ),
                      //   top: BorderSide(
                      //     width: 1,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                      columnWidths: const {
                        0: FixedColumnWidth(50),
                        1: FlexColumnWidth(5),
                        2: FlexColumnWidth(2),
                        3: FlexColumnWidth(2),
                      },
                      children: <TableRow>[
                            TableRow(
                              children: [
                                TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Checkbox(
                                    value: bill.shares.values.contains(0)
                                        ? bill.shares.values.contains(1)
                                            ? null
                                            : false
                                        : true,
                                    tristate: true,
                                    onChanged: (value) {
                                      print(bill.shares);
                                      value ??= false;
                                      setState(() {
                                        bill.shares.updateAll(
                                          (k, v) => value! ? 1 : 0,
                                        );
                                      });
                                      print(bill.shares);
                                    },
                                    side: BorderSide(
                                      color: ColorModel.red,
                                    ),
                                    activeColor: ColorModel.green,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(3),
                                    ),
                                  ),
                                ),
                                const TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Text(
                                    "For whom ?",
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
                                  child: Text(
                                    "Rate",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const TableCell(
                                  verticalAlignment:
                                      TableCellVerticalAlignment.middle,
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: ElevatedButton(
                    onPressed: () async {
                      Item item = bill.toItemOf(widget.project);
                      await item.db.saveRecursively();
                      Navigator.pop(context, true);
                    },
                    child: Text(widget.item == null ? 'Create' : 'Update'),
                  ),
                ),
              ),
            ],
          ),
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
              side: BorderSide(
                color: ColorModel.red,
              ),
              activeColor: ColorModel.green,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(3),
              ),
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
                // decoration: const InputDecoration(
                //   border: OutlineInputBorder(
                //       borderSide: BorderSide(
                //     width: 0,
                //     style: BorderStyle.none,
                //   )),
                // ),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Center(
              child: Text("${price.toStringAsFixed(2)} €"),
            ),
          ),
        ],
      ));
    });

    return rows;
  }
}

class TitleField extends StatelessWidget {
  const TitleField(
    this.text, {
    super.key,
  });

  final String text;

  @override
  Widget build(BuildContext context) {
    // return Padding(
    //   padding: const EdgeInsets.only(left: 8.0, top: 20),
    //   child: Align(
    //     // alignment: Alignment.centerLeft,
    //     alignment: Alignment.center,
    //     child: Text(
    //       text,
    //       maxLines: 1,
    //       textAlign: TextAlign.left,
    //       style: const TextStyle(
    //         fontWeight: FontWeight.bold,
    //         fontSize: 18,
    //         fontFamily: 'Lato',
    //       ),
    //     ),
    //   ),
    // );
    return Padding(
      padding: const EdgeInsets.only(left: 8.0, top: 20),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Text(
          text,
          maxLines: 1,
          textAlign: TextAlign.left,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 11,
            fontFamily: 'Lato',
            color: ColorModel.text.withOpacity(0.6),
          ),
        ),
      ),
    );
  }
}
