part of 'mhu_struct.dart';

abstract class MstBuiltinType with MixSingletonKey<int> {
  TemplateMsg get template;
}

final mstBuiltinSchemas = [
  mhuDartModelPbschema,
];

final _typeToMarker = mstBuiltinSchemas
    .pbschemaFlattenHierarchy()
    .createPbschemasLookupMessageMarkerByType();

final mstBuiltinTypes = Singletons.mixin<int, MstBuiltinType>({
  0: MstStringPath(),
});

const mstBuiltinTypesTag = 0;

Future<TemplateMsg> mstLoadTemplate(TypeKey typeKey) async {
  final builtinKey = typeKey.single;
  final type =
      mstBuiltinTypes.singletonsByKey[builtinKey] ?? (throw builtinKey);
  return type.template;
}

class MstBuiltins {
  late final tagAssignment = {
    0: CmnStringPathMsg,
  };

  late final tagToTypeBiMap = tagAssignment.createIBiMap();

  late final typeToTag = tagToTypeBiMap.valueToKey;

  late final typeNameToTag = typeToTag.map(
    (key, value) => MapEntry(key.toString(), value),
  );

  late final schemasFlat = mstBuiltinSchemas.pbschemaFlattenHierarchy();

  late final fileDescriptorSet = FileDescriptorSet()
    ..file.addAll(
      schemasFlat.expand((s) => s.pbschemaFileDescriptorSet().file),
    );

  late final schemaCollection = descriptorSchemaCollection(
    fileDescriptorSet: fileDescriptorSet,
    messageReference: memoryCreateTypeReference(),
    dependencies: [],
  );

  late final mpbMessageByReference = {
    for (final reference in schemaCollection.referencedMessages)
      reference.reference: reference.msg,
  };
  late final mpbEnumByReference = {
    for (final reference in schemaCollection.referencedEnums)
      reference.reference: reference.msg,
  };

  String mpbMessageTypeName({
    required MpbMessageMsg message,
  }) {
    return message
        .messageMsgPath(resolveMessage: mpbMessageByReference.getOrThrow)
        .map((e) => e.description)
        .descriptionMsgPathTypeName();
  }

  String mpbEnumTypeName({
    required MpbEnumMsg enumMsg,
  }) {
    final enclosing =
        enumMsg.enclosingMessageOpt?.let(mpbMessageByReference.getOrThrow);
    return [
      ...enclosing
          .messageMsgPath(resolveMessage: mpbMessageByReference.getOrThrow)
          .map((e) => e.description),
      enumMsg.description,
    ].descriptionMsgPathTypeName();
  }

  ReferenceMsg mstReference({
    required String typeName,
  }) {
    final tag = typeNameToTag.imapGetOrThrow$(typeName);

    return MpbReferenceMsg$.create(
      referencePath: [
        Int64(mstBuiltinTypesTag),
        Int64(tag),
      ],
    );
  }

  ReferenceMsg mstMessageReference(
    MpbReferenceMsg mpbReferenceMsg,
  ) {
    final mpbMessageMsg = mpbMessageByReference.getOrThrow(mpbReferenceMsg);
    final typeName = mpbMessageTypeName(message: mpbMessageMsg);
    return mstReference(typeName: typeName);
  }

  ReferenceMsg mstEnumReference(
    MpbReferenceMsg mpbReferenceMsg,
  ) {
    final mpbEnumMsg = mpbEnumByReference.getOrThrow(mpbReferenceMsg);
    final typeName = mpbEnumTypeName(enumMsg: mpbEnumMsg);
    return mstReference(typeName: typeName);
  }

  MstTemplateSingleTypeMsg singleType(
    MpbSingleTypeMsg mpbSingleType,
  ) {
    final mstSingleType = MstTemplateSingleTypeMsg();
    switch (mpbSingleType.whichType()) {
      case MpbSingleTypeMsg_Type.scalarType:
        mstSingleType.scalarType = mpbSingleType.scalarType;
      case MpbSingleTypeMsg_Type.enumType:
        mstSingleType.enumType = mstEnumReference(mpbSingleType.enumType);
      case MpbSingleTypeMsg_Type.messageType:
        mstSingleType.messageType = MstTemplateMessageReferenceMsg$.create(
          messageReference: mstMessageReference(mpbSingleType.messageType),
          templateArguments: null,
        );
      case MpbSingleTypeMsg_Type.notSet:
        throw mpbSingleType;
    }

    return mstSingleType;
  }

  MstTemplateFieldMsg field(MpbFieldMsg mpbPhysicalField) {
    final mstPhysicalField = MstTemplateFieldMsg$.create(
      fieldInfo: mpbPhysicalField.fieldInfo,
    );
    switch (mpbPhysicalField.whichType()) {
      case MpbFieldMsg_Type.singleType:
        mstPhysicalField.singleType = singleType(mpbPhysicalField.singleType);
      case MpbFieldMsg_Type.repeatedType:
        mstPhysicalField.repeatedType = MstTemplateRepeatedTypeMsg$.create(
          singleType: singleType(mpbPhysicalField.singleType),
        );
      case MpbFieldMsg_Type.mapType:
        mstPhysicalField.mapType = MstTemplateMapTypeMsg$.create(
          keyType: mpbPhysicalField.mapType.keyType,
          valueType: singleType(mpbPhysicalField.mapType.valueType),
        );
      case MpbFieldMsg_Type.notSet:
        throw mpbPhysicalField;
    }
    return mstPhysicalField;
  }

  MstTemplateMessageMsg templateMessage(
    MpbMessageMsg mpbMessageMsg,
  ) {
    return MstTemplateMessageMsg$.create(
      description: mpbMessageMsg.descriptionOpt,
      fields: mpbMessageMsg.fields.map((mpbLogicalField) {
        final result = MstTemplateLogicalFieldMsg();
        switch (mpbLogicalField.whichType()) {
          case MpbLogicalFieldMsg_Type.physicalField:
            result.physicalField = field(mpbLogicalField.physicalField);
          case MpbLogicalFieldMsg_Type.oneof:
            final mpbOneof = mpbLogicalField.oneof;
            result.oneof = MstTemplateOneofMsg$.create(
              description: mpbOneof.descriptionOpt,
              fields: mpbOneof.fields.map(field),
            );
          case MpbLogicalFieldMsg_Type.notSet:
            throw (mpbMessageMsg, mpbLogicalField);
        }
        return result;
      }),
      parameters: null,
    );
  }
}

String descriptionMsgPathTypeName({
  @ext required Iterable<MpbDescriptionMsg> descriptions,
}) {
  return descriptions.map((e) => e.protoName).join("_");
}

Iterable<MpbMessageMsg> messageMsgPath({
  @ext required MpbMessageMsg? message,
  required MpbMessageMsg Function(ReferenceMsg referenceMsg) resolveMessage,
}) {
  return message
      .finiteIterable((item) => item.enclosingMessageOpt?.let(resolveMessage))
      .toList()
      .reversed;
}
