import 'package:flutter/material.dart';
import 'package:pocketbase/pocketbase.dart';

import '../../models/app_data.dart';
import '../../data/pocketbase/provider.dart';
import '../../data/provider.dart';
import '../../models/instance.dart';
import 'new_instance_selector.dart';

class NewInstancePage extends StatelessWidget {
  NewInstancePage({
    super.key,
    this.instance,
  });

  final Instance? instance;
  final InstanceData instanceData = InstanceData();

  final GlobalKey<FormState> formKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (instance != null) {
      instanceData.name = instance!.name;
      instanceData.data = instance!.data;
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        elevation: 4,
        title: const Text(
          "New instance",
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: Form(
        key: formKey,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: NewInstanceSelector(instanceData),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    if (formKey.currentState != null &&
                        formKey.currentState!.validate()) {
                      Instance newInstance;
                      if (instance == null) {
                        newInstance = Instance(
                          type: instanceData.type,
                          name: instanceData.name!,
                          data: instanceData.data,
                        );
                      } else {
                        newInstance = instance!;
                        newInstance.type = instanceData.type;
                        newInstance.name = instanceData.name!;
                        newInstance.data = instanceData.data;
                      }
                      try {
                        if (!await Provider.checkCredentials(newInstance)) {
                          throw Exception("Failed to connect");
                        }
                      } on ClientException catch (e) {
                        PocketBaseProvider.onClientException(e, context);
                        return;
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(e.toString()),
                            ),
                          );
                        }
                        return;
                      }

                      await newInstance.conn.save();
                      AppData.instances.add(newInstance);

                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                "Instance ${newInstance.name} ${instance == null ? "created" : "updated"} successfully"),
                          ),
                        );
                      }

                      if (context.mounted && Navigator.canPop(context)) {
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(instance == null
                        ? "Create instance"
                        : "Update instance"),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstanceData {
  String type = 'pocketbase';
  String? name;
  Map<String, dynamic> data = {};
}
