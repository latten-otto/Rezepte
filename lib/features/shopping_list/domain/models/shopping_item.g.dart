// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_item.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ShoppingItemImpl _$$ShoppingItemImplFromJson(Map<String, dynamic> json) =>
    _$ShoppingItemImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      amount: (json['amount'] as num?)?.toDouble(),
      unit: json['unit'] as String?,
      category: json['category'] as String? ?? 'Sonstiges',
      isChecked: json['isChecked'] as bool? ?? false,
      fromRecipeIds:
          (json['fromRecipeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$ShoppingItemImplToJson(_$ShoppingItemImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'amount': instance.amount,
      'unit': instance.unit,
      'category': instance.category,
      'isChecked': instance.isChecked,
      'fromRecipeIds': instance.fromRecipeIds,
    };
