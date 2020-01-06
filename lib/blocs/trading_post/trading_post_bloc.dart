import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:flutter/widgets.dart';
import 'package:guildwars2_companion/models/items/item.dart';
import 'package:guildwars2_companion/models/trading_post/delivery.dart';
import 'package:guildwars2_companion/models/trading_post/listing.dart';
import 'package:guildwars2_companion/models/trading_post/transaction.dart';
import 'package:guildwars2_companion/repositories/item.dart';
import 'package:guildwars2_companion/repositories/trading_post.dart';
import './bloc.dart';

class TradingPostBloc extends Bloc<TradingPostEvent, TradingPostState> {
  @override
  TradingPostState get initialState => LoadingTradingPostState();

  final TradingPostRepository tradingPostRepository;
  final ItemRepository itemRepository;

  TradingPostBloc({
    @required this.tradingPostRepository,
    @required this.itemRepository,
  });

  @override
  Stream<TradingPostState> mapEventToState(
    TradingPostEvent event,
  ) async* {
    if (event is LoadTradingPostEvent) {
      yield LoadingTradingPostState();

      List<TradingPostTransaction> buying = await tradingPostRepository.getTransactions('current', 'buys');
      List<TradingPostTransaction> selling = await tradingPostRepository.getTransactions('current', 'sells');
      List<TradingPostTransaction> bought = await tradingPostRepository.getTransactions('history', 'buys');
      List<TradingPostTransaction> sold = await tradingPostRepository.getTransactions('history', 'sells');
      TradingPostDelivery tradingPostDelivery = await tradingPostRepository.getDelivery();

      List<int> itemIds = [];
      buying.forEach((t) => itemIds.add(t.itemId));
      selling.forEach((t) => itemIds.add(t.itemId));
      bought.forEach((t) => itemIds.add(t.itemId));
      sold.forEach((t) => itemIds.add(t.itemId));
      tradingPostDelivery.items.forEach((d) => itemIds.add(d.id));

      List<Item> items = await itemRepository.getItems(itemIds.toSet().toList());

      buying.forEach((t) => t.itemInfo = items.firstWhere((i) => i.id == t.itemId, orElse: () => null));
      selling.forEach((t) => t.itemInfo = items.firstWhere((i) => i.id == t.itemId, orElse: () => null));
      bought.forEach((t) => t.itemInfo = items.firstWhere((i) => i.id == t.itemId, orElse: () => null));
      sold.forEach((t) => t.itemInfo = items.firstWhere((i) => i.id == t.itemId, orElse: () => null));
      tradingPostDelivery.items.forEach((d) => d.itemInfo = items.firstWhere((i) => i.id == d.id, orElse: () => null));

      yield LoadedTradingPostState(
        buying: buying,
        selling: selling,
        bought: bought,
        sold: sold,
        tradingPostDelivery: tradingPostDelivery
      );
    } else if (event is LoadTradingPostListingsEvent) {
      yield LoadedTradingPostState(
        buying: event.buying,
        selling: event.selling,
        bought: event.bought,
        sold: event.sold,
        tradingPostDelivery: event.tradingPostDelivery,
        listingsLoading: true
      );

      TradingPostListing listing = await tradingPostRepository.getListing(event.itemId);

      if (listing != null) {
        event.buying.where((t) => t.itemId == event.itemId).forEach((t) => t.listing = listing);
        event.selling.where((t) => t.itemId == event.itemId).forEach((t) => t.listing = listing);
        event.bought.where((t) => t.itemId == event.itemId).forEach((t) => t.listing = listing);
        event.sold.where((t) => t.itemId == event.itemId).forEach((t) => t.listing = listing);
      }

      yield LoadedTradingPostState(
        buying: event.buying,
        selling: event.selling,
        bought: event.bought,
        sold: event.sold,
        tradingPostDelivery: event.tradingPostDelivery
      );
    }
  }
}
