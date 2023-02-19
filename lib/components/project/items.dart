import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:shared/model/item.dart';
import 'package:shared/model/project.dart';

class ItemsScreen extends StatefulWidget {
  const ItemsScreen(this.project, {super.key});

  final Project project;

  @override
  State<ItemsScreen> createState() => _ItemsScreenState();
}

class _ItemsScreenState extends State<ItemsScreen> {
  late List<Map<String, Object?>> items;
  bool isLoading = true;

  Future refreshItems() async {
    setState(() => isLoading = true);
    items = await widget.project.getItemsForList();
    setState(() => isLoading = false);
  }

  @override
  void initState() {
    super.initState();
    refreshItems();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Text('loading ...')
        : ListView.builder(
            itemBuilder: (BuildContext context, int index) {
              Map<String, Object?> item = items.elementAt(index);
              String title = item[ItemFields.title] as String;
              String emitter = item[ItemFields.emitter] as String;
              String participants = item['participants'] as String;
              return ListTile(
                title: Text(title),
                subtitle: Text("$emitter -> $participants"),
              );
            },
            itemCount: items.length,
          );
  }
}
