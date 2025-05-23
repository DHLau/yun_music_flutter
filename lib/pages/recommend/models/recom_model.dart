import 'package:json_annotation/json_annotation.dart';

import '../../../commons/models/ui_element_model.dart';
import 'creative_model.dart';

part 'recom_model.g.dart';

@JsonSerializable()
class RecomModelWrap extends Object {
  @JsonKey(name: 'code')
  int? code;
  @JsonKey(name: 'data')
  RecomModel? data;

  RecomModelWrap(
    this.code,
    this.data,
  );
  factory RecomModelWrap.fromJson(Map<String, dynamic> srcJson) =>
      _$RecomModelWrapFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RecomModelWrapToJson(this);
}

@JsonSerializable()
class RecomModel extends Object {
  @JsonKey(name: 'cursor')
  String? cursor;

  @JsonKey(name: 'blocks')
  List<Blocks> blocks;

  @JsonKey(name: 'pageConfig')
  PageConfig pageConfig;

  RecomModel(
    this.cursor,
    this.blocks,
    this.pageConfig,
  );

  factory RecomModel.fromJson(Map<String, dynamic> srcJson) =>
      _$RecomModelFromJson(srcJson);

  Map<String, dynamic> toJson() => _$RecomModelToJson(this);
}

@JsonSerializable()
class Blocks extends Object {
  @JsonKey(name: 'blockCode')
  String blockCode;

  @JsonKey(name: 'showType')
  String showType;

  @JsonKey(name: 'extInfo')
  dynamic extInfo;

  @JsonKey(name: 'uiElement')
  UiElementModel? uiElement;

  @JsonKey(name: 'creatives')
  List<CreativeModel>? creatives;

  @JsonKey(name: 'canClose')
  bool canClose;

  Blocks(
    this.blockCode,
    this.showType,
    this.extInfo,
    this.uiElement,
    this.creatives,
    this.canClose,
  );

  factory Blocks.fromJson(Map<String, dynamic> srcJson) =>
      _$BlocksFromJson(srcJson);

  Map<String, dynamic> toJson() => _$BlocksToJson(this);
}

@JsonSerializable()
class PageConfig extends Object {
  @JsonKey(name: 'refreshToast')
  String? refreshToast;

  @JsonKey(name: 'nodataToast')
  String? nodataToast;

  @JsonKey(name: 'refreshInterval')
  int refreshInterval;

  PageConfig(
    this.refreshToast,
    this.nodataToast,
    this.refreshInterval,
  );

  factory PageConfig.fromJson(Map<String, dynamic> srcJson) =>
      _$PageConfigFromJson(srcJson);

  Map<String, dynamic> toJson() => _$PageConfigToJson(this);
}
