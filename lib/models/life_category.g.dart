// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'life_category.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class LifeCategoryAdapter extends TypeAdapter<LifeCategory> {
  @override
  final int typeId = 0;

  @override
  LifeCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return LifeCategory.sport;
      case 1:
        return LifeCategory.learning;
      case 2:
        return LifeCategory.discipline;
      case 3:
        return LifeCategory.order;
      case 4:
        return LifeCategory.social;
      case 5:
        return LifeCategory.nutrition;
      case 6:
        return LifeCategory.career;
      default:
        return LifeCategory.sport;
    }
  }

  @override
  void write(BinaryWriter writer, LifeCategory obj) {
    switch (obj) {
      case LifeCategory.sport:
        writer.writeByte(0);
        break;
      case LifeCategory.learning:
        writer.writeByte(1);
        break;
      case LifeCategory.discipline:
        writer.writeByte(2);
        break;
      case LifeCategory.order:
        writer.writeByte(3);
        break;
      case LifeCategory.social:
        writer.writeByte(4);
        break;
      case LifeCategory.nutrition:
        writer.writeByte(5);
        break;
      case LifeCategory.career:
        writer.writeByte(6);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LifeCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
