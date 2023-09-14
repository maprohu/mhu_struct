part of '../mhu_struct.dart';

class MstStringPath extends MstBuiltinType {
  final template = MstTemplateMessageMsg$.create(
    fields: [
      MstTemplateLogicalFieldMsg$.create(
        physicalField: MstTemplateFieldMsg$.create(
          fieldInfo: MpbFieldInfoMsg$.create(
            tagNumber: 1,
            description: MpbDescriptionMsg$.create(
              protoName: "path",
            )
          ),
          repeatedType: MstTemplateRepeatedTypeMsg$.create(
            singleType: MstTemplateSingleTypeMsg$.create(
              scalarType: MpbScalarTypeEnm.TYPE_STRING,
            ),
          ),
        ),
      ),
    ],
  );
}
