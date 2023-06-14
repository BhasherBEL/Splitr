import 'package:flutter/material.dart';

import '../../models/app_data.dart';
import '../../models/instance.dart';
import '../../utils/helper/navigator.dart';
import '../new_instance/new_instance_page.dart';
import 'instance_tile.dart';

class InstancesListPage extends StatefulWidget {
  const InstancesListPage({super.key});

  @override
  State<InstancesListPage> createState() => _InstancesListPageState();
}

class _InstancesListPageState extends State<InstancesListPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        title: const Text(
          'Instances',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ListView.builder(
              shrinkWrap: true,
              itemBuilder: (context, index) {
                Instance instance = AppData.instances.elementAt(index);
                return InstanceTile(
                  instance: instance,
                  onChange: () => setState(() {}),
                );
              },
              itemCount: AppData.instances.length,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: 50,
              child: IconButton(
                onPressed: () => setState(() {
                  navigatorPush(context, () => NewInstancePage());
                }),
                icon: const Icon(Icons.add),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
