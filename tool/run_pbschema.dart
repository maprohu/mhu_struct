import 'package:mhu_dart_pbgen/mhu_dart_pbgen.dart';
import 'package:mhu_dart_pbschema_pbschema/proto.dart';

Future<void> main() async {
  await runPbSchemaGenerator(
    dependencies: [
      mhuDartPbschemaPbschemaPbschema,
    ],
  );
}
