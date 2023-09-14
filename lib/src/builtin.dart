part of 'mhu_struct.dart';

abstract class MstBuiltinType with MixSingletonKey<int> {
  TemplateMsg get template;
}

final mstBuiltinTypes = Singletons.mixin<int, MstBuiltinType>({
  0: MstStringPath(),
});

const mstLoaderKey = 0;

Future<TemplateMsg> mstLoadTemplate(TypeKey typeKey) async {
  final builtinKey = typeKey.single;
  final type =
      mstBuiltinTypes.singletonsByKey[builtinKey] ?? (throw builtinKey);
  return type.template;
}
