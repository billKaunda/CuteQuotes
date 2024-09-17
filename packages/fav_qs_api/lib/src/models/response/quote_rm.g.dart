// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'quote_rm.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

QuoteRM _$QuoteRMFromJson(Map<String, dynamic> json) => QuoteRM(
      id: (json['id'] as num).toInt(),
      body: json['body'] as String?,
      favoritesCount: (json['favorites_count'] as num?)?.toInt() ?? 0,
      upvotesCount: (json['upvotes_count'] as num?)?.toInt() ?? 0,
      downvotesCount: (json['downvotes_count'] as num?)?.toInt() ?? 0,
      author: json['author'] as String?,
      userInfo: json['user_details'] == null
          ? null
          : QuoteUserInfoRM.fromJson(
              json['user_details'] as Map<String, dynamic>),
    );
