import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:select_form_field/select_form_field.dart';

import '../../../../model/bill_data.dart';
import '../../../../model/item.dart';
import '../../../../model/participant.dart';
import '../../../../model/project.dart';
import '../../../../screens/new_screen.dart';
import '../../../../utils/formatter/decimal.dart';
import '../../../../utils/time.dart';

class NewEntryPage extends StatelessWidget {
  const NewEntryPage(this.project, {super.key, this.item});

  final Project project;
  final Item? item;

  @override
  Widget build(BuildContext context) {
    BillData bill = BillData(item: item, project: project);
    return NewScreen(
      title: item == null ? 'Add new expense' : 'Update expense',
      onValidate: (context, key) async {
        if (key.currentState!.validate()) {
          Item item = await bill.toItemOf(project);
          await item.conn.saveRecursively();
          if (context.mounted) Navigator.pop(context, true);
        }
      },
      child: NewEntrySubPage(
        project,
        bill,
        item: item,
      ),
    );
  }
}

class NewEntrySubPage extends StatefulWidget {
  const NewEntrySubPage(this.project, this.bill, {super.key, this.item});

  final Project project;
  final Item? item;
  final BillData bill;

  @override
  State<NewEntrySubPage> createState() => _NewEntrySubPageState();
}

class _NewEntrySubPageState extends State<NewEntrySubPage> {
  final dateController = TextEditingController();
  final titleController = TextEditingController();
  final emitterController = TextEditingController();
  final amountController = TextEditingController();
  final Map<Participant, TextEditingController> sharesController = {};
  final Map<Participant, TextEditingController> fixedsController = {};

  @override
  void dispose() {
    // Clean up the controller when the widget is removed
    dateController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    titleController.text = widget.bill.title;
    dateController.text = daysElapsed(widget.bill.date);
    emitterController.text = widget.bill.emitter.pseudo;
    amountController.text = widget.bill.amount.toStringAsFixed(2);

    for (Participant participant in widget.project.participants) {
      if (widget.item == null) {
        widget.bill.shares[participant] = BillPart(share: 1);
        sharesController[participant] = TextEditingController(text: "1");
        fixedsController[participant] = TextEditingController();
      } else if (widget.bill.shares[participant] == null) {
        widget.bill.shares[participant] = BillPart();
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
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          const SizedBox(
            height: 5,
          ),
          TextFormField(
            controller: titleController,
            validator: (value) =>
                value == null || value.isEmpty ? 'Title can\'t be empty' : null,
            autocorrect: true,
            decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
              labelText: "What",
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => widget.bill.title = value,
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
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
                  widget.bill.amount = parsed;
                });
                // ignore: empty_catches
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
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
                          widget.bill.emitter = widget.project.participants
                              .firstWhere((element) => element.pseudo == value);
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
                          contentPadding: EdgeInsets.symmetric(horizontal: 10),
                          labelText: "When",
                          border: OutlineInputBorder(),
                          hintText: 'Pick your Date',
                        ),
                        onTap: () async {
                          DateTime? date = await showDatePicker(
                            context: context,
                            initialDate: widget.bill.date,
                            firstDate: DateTime(1900),
                            lastDate: DateTime(2100),
                          );
                          if (date != null) {
                            dateController.text = daysElapsed(date);
                            widget.bill.date = date;
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
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Checkbox(
                            value: widget.bill.shares.values
                                        .where((e) =>
                                            e.fixed != null || e.share != null)
                                        .length !=
                                    widget.bill.shares.length
                                ? widget.bill.shares.values
                                        .where((e) =>
                                            e.fixed != null || e.share != null)
                                        .isNotEmpty
                                    ? null
                                    : false
                                : true,
                            tristate: true,
                            onChanged: (value) {
                              value ??= false;
                              setState(() {
                                widget.bill.shares.updateAll(
                                  (k, v) => BillPart(share: value! ? 1 : null),
                                );
                              });
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "For whom ?",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
                          child: Text(
                            "Rate",
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const TableCell(
                          verticalAlignment: TableCellVerticalAlignment.middle,
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
                  getRows(widget.bill, sharesController, fixedsController),
            ),
          ),
        ],
      ),
    );
  }

  List<TableRow> getRows(
    BillData bill,
    Map<Participant, TextEditingController> sharesController,
    Map<Participant, TextEditingController> fixedsController,
  ) {
    final List<TableRow> rows = [];

    double total = widget.bill.totalShares;

    double fixedBonus = widget.bill.totalFixed /
        widget.bill.shares.values.where((e) => e.share != null).length;

    widget.bill.shares.forEach((participant, amount) {
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
              widget.bill.amount * (amount.share ?? 0) / total - fixedBonus,
          0);

      if (price.isNaN) price = 0;

      try {
        if (fixedsController[participant]!.text == "" ||
            double.parse(fixedsController[participant]!.text) != price) {
          fixedsController[participant]!.text = price.toStringAsFixed(2);
        }
        // ignore: empty_catches
      } catch (e) {}

      rows.add(TableRow(
        children: [
          TableCell(
            verticalAlignment: TableCellVerticalAlignment.middle,
            child: Checkbox(
              value: widget.bill.shares[participant]!.fixed != null ||
                  widget.bill.shares[participant]!.share != null,
              onChanged: (value) {
                setState(() {
                  if (value != null && value) {
                    widget.bill.shares[participant] = BillPart(share: 1);
                  } else {
                    widget.bill.shares[participant] = BillPart();
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
                      if (widget.bill.shares[participant]!.share != null) {
                        widget.bill.shares[participant]!.share =
                            widget.bill.shares[participant]!.share! + 0.00001;
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
                          widget.bill.shares[participant] = BillPart(
                              share: double.parse(value) > 0
                                  ? double.parse(value)
                                  : null);
                        });
                        // ignore: empty_catches
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
                        widget.bill.shares[participant]!.share == null) {
                      widget.bill.shares[participant] = BillPart();
                    }
                    if (widget.bill.shares[participant]!.fixed != null) {
                      widget.bill.shares[participant]!.fixed =
                          widget.bill.shares[participant]!.fixed! + 0.00001;
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
                        widget.bill.shares[participant] =
                            BillPart(fixed: double.parse(value));
                      });
                      // ignore: empty_catches
                    } catch (e) {}
                  },
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ));
    });

    return rows;
  }
}
