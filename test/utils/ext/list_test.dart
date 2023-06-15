import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitr/models/data.dart';
import 'package:splitr/utils/ext/list.dart';

class MockData extends Mock implements Data {}

void main() {
  group('ListExtension', () {
    test(
        'setPresence() should add the element if presence is true and not already present',
        () {
      final list = <int>[1, 2, 3];

      list.setPresence(true, 4);
      expect(list, <int>[1, 2, 3, 4]);

      list.setPresence(true, 3);
      expect(list, <int>[1, 2, 3, 4]);
    });

    test('setPresence() should remove the element if presence is false', () {
      final list = <int>[1, 2, 3];

      list.setPresence(false, 2);
      expect(list, <int>[1, 3]);

      list.setPresence(false, 4);
      expect(list, <int>[1, 3]);
    });
  });

  group('DataListExtension', () {
    late List<Data> dataList;
    late MockData data1;
    late MockData data2;
    late MockData data3;

    setUp(() {
      data1 = MockData();
      data2 = MockData();
      data3 = MockData();

      dataList = <Data>[
        data1,
        data2,
        data3,
      ];
    });

    test('enabled() should return only enabled elements', () {
      when(() => data1.deleted).thenAnswer((invocation) => false);
      when(() => data2.deleted).thenAnswer((invocation) => true);
      when(() => data3.deleted).thenAnswer((invocation) => false);

      final enabledList = dataList.enabled();
      expect(enabledList.toList(), <Data>[data1, data3]);
    });

    test('enabled() should return empty when no enabled elements', () {
      when(() => data1.deleted).thenAnswer((invocation) => true);
      when(() => data2.deleted).thenAnswer((invocation) => true);
      when(() => data3.deleted).thenAnswer((invocation) => true);

      final enabledList = dataList.enabled();
      expect(enabledList.toList(), <Data>[]);
    });
    test('enabled() should not change anything when all enabled elements', () {
      when(() => data1.deleted).thenAnswer((invocation) => false);
      when(() => data2.deleted).thenAnswer((invocation) => false);
      when(() => data3.deleted).thenAnswer((invocation) => false);

      final enabledList = dataList.enabled();
      expect(enabledList.toList(), dataList);
    });
  });
}
