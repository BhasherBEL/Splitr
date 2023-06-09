import 'package:objectbox/objectbox.dart';
import 'package:splitr/model/project.dart';

@Entity()
class Participant {
  @Id()
  int id;

  final project = ToOne<Project>();

  Participant({
    this.id = 0,
  });
}
