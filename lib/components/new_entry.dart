import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_form_field/select_form_field.dart';
import 'package:shared/utils/colors.dart';

import '../model/bill_data.dart';
import '../model/item.dart';
import '../model/participant.dart';
import '../model/project.dart';
import '../utils/formatter/decimal.dart';
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
  final Map<Participant, TextEditingController> sharesController = {};
  final Map<Participant, TextEditingController> fixedsController = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    bill = BillData(item: widget.item, project: widget.project);
    titleController.text = bill.title;
    dateController.text = daysElapsed(bill.date);
    emitterController.text = bill.emitter.pseudo;
    amountController.text = bill.amount.toStringAsFixed(2);

    for (Participant participant in widget.project.participants) {
      if (widget.item == null) {
        bill.shares[participant] = BillPart(share: 1);
        sharesController[participant] = TextEditingController(text: "1");
        fixedsController[participant] = TextEditingController();
      } else if (bill.shares[participant] == null) {
        bill.shares[participant] = BillPart();
        sharesController[participant] = TextEditingController(text: "0");
        fixedsController[participant] = TextEditingController(text: "0.00");
      } else {
        sharesController[participant] = TextEditingController();
        fixedsController[participant] = TextEditingController();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        elevation: 4,
        title: Column(
          children: [
            Text(
              widget.item == null ? 'Add new expense' : 'Update expense',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Column(
                  children: [
                    const SizedBox(
                      height: 12, // <-- SEE HERE
                    ),
                    TextFormField(
                      controller: titleController,
                      validator: (value) => value == null || value.isEmpty
                          ? 'Title can\'t be empty'
                          : null,
                      autocorrect: true,
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "What",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) => bill.title = value,
                    ),
                    const SizedBox(
                      height: 12, // <-- SEE HERE
                    ),
                    TextFormField(
                      autocorrect: false,
                      validator: (value) {
                        try {
                          if (double.parse(value!) > 0) return null;
                          return 'Amount can\'t be null';
                        } catch (e) {
                          return 'Amount must be a valid value';
                        }
                      },
                      inputFormatters: [
                        DecimalTextInputFormatter(2),
                      ],
                      keyboardType:
                          const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        suffixText: ' €',
                        contentPadding: EdgeInsets.symmetric(horizontal: 10),
                        labelText: "How much",
                        border: OutlineInputBorder(),
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
                    const SizedBox(
                      height: 12, // <-- SEE HERE
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: Column(
                              children: [
                                SelectFormField(
                                  type: SelectFormFieldType.dropdown,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    labelText: "Who paid",
                                    border: OutlineInputBorder(),
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
                                        .firstWhere((element) =>
                                            element.pseudo == value);
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
                                TextField(
                                  readOnly: true,
                                  controller: dateController,
                                  decoration: const InputDecoration(
                                    contentPadding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    labelText: "When",
                                    border: OutlineInputBorder(),
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
                    const SizedBox(
                      height: 35, // <-- SEE HERE
                    ),
                    const Divider(),
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
                                      value: bill.shares.values
                                                  .where((e) =>
                                                      e.fixed != null ||
                                                      e.share != null)
                                                  .length !=
                                              bill.shares.length
                                          ? bill.shares.values
                                                  .where((e) =>
                                                      e.fixed != null ||
                                                      e.share != null)
                                                  .isNotEmpty
                                              ? null
                                              : false
                                          : true,
                                      tristate: true,
                                      onChanged: (value) {
                                        value ??= false;
                                        setState(() {
                                          bill.shares.updateAll(
                                            (k, v) => BillPart(
                                                share: value! ? 1 : null),
                                          );
                                        });
                                      },
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
                            getRows(bill, sharesController, fixedsController),
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
                        if (_formKey.currentState!.validate()) {
                          Item item = await bill.toItemOf(widget.project);
                          await item.conn.saveRecursively();
                          Navigator.pop(context, true);
                        }
                      },
                      child: Text(widget.item == null ? 'Create' : 'Update'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<TableRow> getRows(
    BillData bill,
    Map<Participant, TextEditingController> sharesController,
    Map<Participant, TextEditingController> fixedsController,
  ) {
    final List<TableRow> rows = [];

    double total = max(bill.totalShares, 1);

    double fixedBonus = bill.totalFixed /
        bill.shares.values.where((e) => e.share != null).length;

    bill.shares.forEach((participant, amount) {
      final newShareValue = amount.share == null
          ? amount.fixed == null
              ? "0"
              : ""
          : amount.share!.toInt().toString();

      if (newShareValue != sharesController[participant]!.text) {
        sharesController[participant]!.text = newShareValue;
      }

      double price = max(
          amount.fixed ??
              bill.amount * (amount.share ?? 0) / (total != 0 ? total : 1) -
                  fixedBonus,
          0);

      try {
        if (fixedsController[participant]!.text == "" ||
            double.parse(fixedsController[participant]!.text) != price) {
          fixedsController[participant]!.text = price.toStringAsFixed(2);
        }
      } catch (e) {}

      rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Checkbox(
              value: bill.shares[participant]!.fixed != null ||
                  bill.shares[participant]!.share != null,
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    bill.shares[participant] = BillPart(share: 1);
                  } else {
                    bill.shares[participant] = BillPart();
                  }
                });
              },
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
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Focus(
                  onFocusChange: (value) {
                    setState(() {
                      if (bill.shares[participant]!.share != null) {
                        bill.shares[participant]!.share =
                            bill.shares[participant]!.share! + 0.00001;
                      }
                    });
                  },
                  child: TextField(
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: sharesController[participant],
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      try {
                        setState(() {
                          bill.shares[participant] = BillPart(
                              share: double.parse(value) > 0
                                  ? double.parse(value)
                                  : null);
                        });
                      } catch (e) {}
                    },
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Focus(
                onFocusChange: (value) {
                  if (value) return;
                  setState(() {
                    if (fixedsController[participant]!.text.isEmpty &&
                        bill.shares[participant]!.share == null) {
                      bill.shares[participant] = BillPart();
                    }
                    if (bill.shares[participant]!.fixed != null) {
                      bill.shares[participant]!.fixed =
                          bill.shares[participant]!.fixed! + 0.00001;
                    }
                  });
                },
                child: TextField(
                  controller: fixedsController[participant],
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    suffixText: '€',
                  ),
                  inputFormatters: [
                    DecimalTextInputFormatter(2),
                  ],
                  onChanged: (value) {
                    try {
                      setState(() {
                        bill.shares[participant] =
                            BillPart(fixed: double.parse(value));
                      });
                    } catch (e) {}
                  },
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            // child: Center(
            //   child: Text("${price.toStringAsFixed(2)} €"),
            // ),
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
