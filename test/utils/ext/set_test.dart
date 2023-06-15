import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:splitr/models/data.dart';
import 'package:splitr/utils/ext/set.dart';

class MockData extends Mock implements Data {}

void main() {
  group('DataSetExtension', () {
    late Set<Data> dataList;
    late MockData data1;
    late MockData data2;
    late MockData data3;

    setUp(() {
      data1 = MockData();
      data2 = MockData();
      data3 = MockData();

      dataList = <Data>{
        data1,
        data2,
        data3,
      };
    });

    test('enabled() should return only enabled elements', () {
      when(() => data1.deleted).thenAnswer((invocation) => false);
      when(() => data2.deleted).thenAnswer((invocation) => true);
      when(() => data3.deleted).thenAnswer((invocation) => false);

      final enabledList = dataList.enabled();
      expect(enabledList.toSet(), <Data>{data1, data3});
    });

    test('enabled() should return empty when no enabled elements', () {
      when(() => data1.deleted).thenAnswer((invocation) => true);
      when(() => data2.deleted).thenAnswer((invocation) => true);
      when(() => data3.deleted).thenAnswer((invocation) => true);

      final enabledList = dataList.enabled();
      expect(enabledList.toSet(), <Data>{});
    });
    test('enabled() should not change anything when all enabled elements', () {
      when(() => data1.deleted).thenAnswer((invocation) => false);
      when(() => data2.deleted).thenAnswer((invocation) => false);
      when(() => data3.deleted).thenAnswer((invocation) => false);

      final enabledList = dataList.enabled();
      expect(enabledList.toSet(), dataList);
    });
  });
}
