part of 'mhu_struct.dart';

typedef TypeKey = IList<int>;

typedef TemplateMsg = MstTemplateMessageMsg;

typedef LoadTemplate = Future<TemplateMsg> Function(
  TypeKey typeKey,
);

LoadTemplate loadTemplateComposition({
  required IMap<int, LoadTemplate> loaders,
}) {
  return (typeKey) {
    final loaderKey = typeKey.first;
    final loader = loaders[loaderKey] ?? (throw loaderKey);
    return loader(typeKey.remove(0));
  };
}


