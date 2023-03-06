import 'package:flutter/material.dart';
import 'package:shared/model/setup_data.dart';

class UserSetupPage extends StatelessWidget {
  UserSetupPage(this.setupData, {super.key});

  SetupData setupData;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      const Text("How do you want to be called ?"),
      TextFormField(
        initialValue: setupData.pseudo,
        validator: (value) => value == null || value.isEmpty
            ? 'Your pseudo can\'t be empty'
            : null,
        // onChanged: (value) => update((state) => state.copyWith(pseudo: value)),
        onChanged: (value) => setupData.pseudo = value,
      ),
      const Text("What's your firstname ?"),
      TextFormField(
        onChanged: (value) => setupData.firstname = value,
        // update((state) => state.copyWith(firstname: value)),
      ),
      const Text("What's your lastname ?"),
      TextFormField(
        onChanged: (value) => setupData.lastname = value,
        // update((state) => state.copyWith(lastname: value)),
      ),
    ]);
  }
}
