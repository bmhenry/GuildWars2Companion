import 'package:dio/dio.dart';
import 'package:flutter/widgets.dart';
import 'package:guildwars2_companion/core/utils/urls.dart';
import 'package:guildwars2_companion/features/trading_post/models/delivery.dart';
import 'package:guildwars2_companion/features/trading_post/models/listing.dart';
import 'package:guildwars2_companion/features/trading_post/models/price.dart';
import 'package:guildwars2_companion/features/trading_post/models/transaction.dart';

class TradingPostService {
  Dio dio;

  TradingPostService({
    @required this.dio,
  });

  Future<TradingPostPrice> getItemPrice(int itemId) async {
    final response = await dio.get(Urls.tradingPostPriceUrl + itemId.toString());

    if (response.statusCode == 200) {
      return TradingPostPrice.fromJson(response.data);
    }

    throw Exception('Failed to load item price');
  }

  Future<TradingPostDelivery> getDelivery() async {
    final response = await dio.get(Urls.tradingPostDeliveryUrl);

    if (response.statusCode == 200) {
      return TradingPostDelivery.fromJson(response.data);
    }

    throw Exception();
  }

  Future<List<TradingPostTransaction>> getTransactions(String time, String type) async {
    final response = await dio.get('${Urls.tradingPostTransactionsUrl}$time/$type');

    if (response.statusCode == 200) {
      List transactions = response.data;
      return transactions.map((a) => TradingPostTransaction.fromJson(a)).toList();
    }

    throw Exception();
  }

  Future<TradingPostListing> getListing(int itemId) async {
    final response = await dio.get(Urls.tradingPostListingsUrl + itemId.toString());

    if (response.statusCode == 200 || response.statusCode == 206) {
      return TradingPostListing.fromJson(response.data);
    }

    throw Exception();
  }
}
