import 'package:flutter_test/flutter_test.dart';
import 'package:flick/models/models.dart';

void main() {
  test('seed shelf includes Bartleby and excludes Kafka Metamorphosis', () {
    expect(sampleLibrary.length, greaterThanOrEqualTo(3));
    final ids = sampleLibrary.map((s) => s.id).toList();
    expect(ids, contains('sample-bartleby'));
    expect(
      ids.any((id) => id.contains('metamorphosis') || id.contains('kafka')),
      isFalse,
    );
    expect(ids, isNot(contains('sample-alice')));
    expect(ids, isNot(contains('sample-holmes')));
  });

  test('Bartleby sample meta points at bundled asset', () {
    final bartleby = sampleLibrary.firstWhere((s) => s.id == 'sample-bartleby');
    expect(bartleby.assetPath, 'assets/samples/bartleby.txt');
    expect(bartleby.title, contains('Bartleby'));
  });
}
