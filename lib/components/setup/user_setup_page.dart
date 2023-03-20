import 'package:flutter/material.dart';
import 'package:shared/model/setup_data.dart';

class UserSetupPage extends StatelessWidget {
  UserSetupPage(this.setupData, {super.key});

  SetupData setupData;

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      TextFormField(
        initialValue: setupData.pseudo,
        decoration: const InputDecoration(
          labelText: "Pseudo",
          border: OutlineInputBorder(),
        ),

        validator: (value) => value == null || value.isEmpty
            ? 'Your pseudo can\'t be empty'
            : null,
        // onChanged: (value) => update((state) => state.copyWith(pseudo: value)),
        onChanged: (value) => setupData.pseudo = value,
      ),
      const SizedBox(
        height: 12, // <-- SEE HERE
      ),
      TextFormField(
        onChanged: (value) => setupData.firstname = value,
        decoration: const InputDecoration(
          labelText: "First name",
          border: OutlineInputBorder(),
        ),
        // update((state) => state.copyWith(firstname: value)),
      ),
      const SizedBox(
        height: 12, // <-- SEE HERE
      ),
      TextFormField(
        onChanged: (value) => setupData.lastname = value,
        decoration: const InputDecoration(
          labelText: "Last name",
          border: OutlineInputBorder(),
        ),
        // update((state) => state.copyWith(lastname: value)),
      ),
    ]);
  }
}
