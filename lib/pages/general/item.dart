import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guildwars2_companion/models/items/item.dart';
import 'package:guildwars2_companion/models/items/skin.dart';
import 'package:guildwars2_companion/models/trading_post/price.dart';
import 'package:guildwars2_companion/repositories/trading_post.dart';
import 'package:guildwars2_companion/utils/gw.dart';
import 'package:guildwars2_companion/widgets/appbar.dart';
import 'package:guildwars2_companion/widgets/coin.dart';
import 'package:guildwars2_companion/widgets/item_box.dart';

class ItemPage extends StatelessWidget {

  final Item item;
  final Skin skin;

  ItemPage({
    @required this.item,
    this.skin
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CompanionAppBar(
        title: '',
        color: Colors.red,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: <Widget>[
          _buildHeader(),
          Expanded(
            child: ListView(
              children: <Widget>[
                if (skin != null)
                  _buildOriginalItemInfo(),
                if (item.description != null && item.description.isNotEmpty)
                  _buildItemDescription(),
                if (item.details != null)
                  _buildItemDetails()
                else
                  _buildRarityOnlyDetails(),
                _buildValue(context)
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black38,
            blurRadius: 8.0,
          ),
        ],
        borderRadius: BorderRadius.only(bottomLeft: Radius.circular(12.0), bottomRight: Radius.circular(12.0))
      ),
      margin: EdgeInsets.only(bottom: 16.0),
      width: double.infinity,
      child: SafeArea(
        minimum: EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
        child: Column(
          children: <Widget>[
            CompanionItemBox(
              item: item,
              skin: skin,
              size: 60.0,
              enablePopup: false,
            ),
            Padding(
              padding: EdgeInsets.all(4.0),
              child: Text(
                skin != null ? skin.name : item.name,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22.0,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Text(
              item.type != null ? typeToName(item.type) : '',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOriginalItemInfo() {
    return Column(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(bottom: 8.0),
          child: Text(
            'Transmuted',
            style: TextStyle(
              fontSize: 18.0
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            CompanionItemBox(
              item: item,
              size: 60.0,
              enablePopup: false,
            ),
            Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                item.name,
                style: TextStyle(
                  fontSize: 22.0
                ),
                textAlign: TextAlign.center,
              ),
            )
          ],
        )
      ],
    );
  }

  Widget _buildItemDescription() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Description',
              style: TextStyle(
                fontSize: 18.0
              ),
            ),
          ),
          Text(
            removeAllHtmlTags(item.description),
            style: TextStyle(
              fontSize: 16.0
            ),
          ),
        ],
      ),
    );
  }

  String removeAllHtmlTags(String htmlText) {
    RegExp exp = RegExp(
      r"<[^>]*>",
      multiLine: true,
      caseSensitive: true
    );

    return htmlText.replaceAll(exp, '');
  }

  Widget _buildItemDetails() {
    if ([
      'Armor',
      'Bag',
      'Consumable',
      'Gathering',
      'Tool',
      'Trinket',
      'UpgradeComponent',
      'Weapon'
    ].contains(item.type))  {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
        child: Column(
          children: <Widget>[
            Padding(
              padding: EdgeInsets.only(bottom: 8.0),
              child: Text(
                'Stats',
                style: TextStyle(
                  fontSize: 18.0
                ),
              ),
            ),
            if (item.type == 'Armor')
              _buildArmorDetails(),
            if (item.type == 'Bag')
              _buildBagDetails(),
            if (item.type == 'Consumable')
              _buildConsumableDetails(),
            if (item.type == 'Gathering' || item.type == 'Trinket' || item.type == 'UpgradeComponent')
              _buildTypeOnlyDetails(),
            if (item.type == 'Tool')
              _buildToolDetails(),
            if (item.type == 'Weapon')
              _buildWeaponDetails()
          ],
        ),
      );
    }

    return _buildRarityOnlyDetails();
  }

  Widget _buildArmorDetails() {
    return Column(
      children: <Widget>[
        _buildInfoRow(
          header: 'Rarity',
          text: item.rarity
        ),
        _buildInfoRow(
          header: 'Type',
          text: typeToName(item.details.type)
        ),
        _buildInfoRow(
          header: 'Weight Class',
          text: item.details.weightClass
        ),
        _buildInfoRow(
          header: 'Defense',
          text: GuildWarsUtil.intToString(item.details.defense)
        ),
      ],
    );
  }

  Widget _buildBagDetails() {
    return Column(
      children: <Widget>[
        _buildInfoRow(
          header: 'Rarity',
          text: item.rarity
        ),
        _buildInfoRow(
          header: 'Size',
          text: GuildWarsUtil.intToString(item.details.size)
        ),
      ],
    );
  }

  Widget _buildConsumableDetails() {
    return Column(
      children: <Widget>[
        _buildInfoRow(
          header: 'Rarity',
          text: item.rarity
        ),
        _buildInfoRow(
          header: 'Type',
          text: typeToName(item.details.type)
        ),
        if (item.details.durationMs != null)
          _buildInfoRow(
            header: 'Duration',
            text: GuildWarsUtil.durationToTextString(Duration(milliseconds: item.details.durationMs)),
          ),
        if (item.details.name != null)
          _buildInfoRow(
            header: 'Effect Type',
            text: item.details.name
          ),
      ],
    );
  }

  Widget _buildTypeOnlyDetails() {
    return Column(
      children: <Widget>[
        _buildInfoRow(
          header: 'Rarity',
          text: item.rarity
        ),
        _buildInfoRow(
          header: 'Type',
          text: item.details.type
        ),
      ],
    );
  }

  Widget _buildToolDetails() {
    return Column(
      children: <Widget>[
        _buildInfoRow(
          header: 'Rarity',
          text: item.rarity
        ),
        _buildInfoRow(
          header: 'Charges',
          text: GuildWarsUtil.intToString(item.details.charges)
        ),
      ],
    );
  }

  Widget _buildRarityOnlyDetails() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
      child: Column(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(bottom: 8.0),
            child: Text(
              'Stats',
              style: TextStyle(
                fontSize: 18.0
              ),
            ),
          ),
          _buildInfoRow(
            header: 'Rarity',
            text: item.rarity
          ),
        ],
      ),
    );
  }

  Widget _buildWeaponDetails() {
    return Column(
      children: <Widget>[
        _buildInfoRow(
          header: 'Rarity',
          text: item.rarity
        ),
        _buildInfoRow(
          header: 'Type',
          text: item.details.type
        ),
        _buildInfoRow(
          header: 'Weapon Strength',
          text: '${GuildWarsUtil.intToString(item.details.minPower)} - ${GuildWarsUtil.intToString(item.details.maxPower)}'
        ),
        if (item.details.defense != null && item.details.defense > 0)
          _buildInfoRow(
            header: 'Defense',
            text: GuildWarsUtil.intToString(item.details.defense)
          ),
      ],
    );
  }

  Widget _buildValue(BuildContext context) {
    return FutureBuilder<TradingPostPrice>(
      future: RepositoryProvider.of<TradingPostRepository>(context).getItemPrice(item.id),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Value',
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
                _buildInfoRow(
                  header: 'Vendor',
                  widget: CompanionCoin(item.vendorValue)
                ),
                _buildInfoRow(
                  header: 'TP Buy',
                  text: '-'
                ),
                _buildInfoRow(
                  header: 'TP Sell',
                  text: '-'
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData) {
          print(item.id);
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    'Value',
                    style: TextStyle(
                      fontSize: 18.0
                    ),
                  ),
                ),
                _buildInfoRow(
                  header: 'Vendor',
                  widget: CompanionCoin(item.vendorValue)
                ),
                _buildInfoRow(
                  header: 'TP Buy',
                  widget: Container(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
                _buildInfoRow(
                  header: 'TP Sell',
                  widget: Container(
                    width: 16.0,
                    height: 16.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.0,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(bottom: 8.0),
                child: Text(
                  'Value',
                  style: TextStyle(
                    fontSize: 18.0
                  ),
                ),
              ),
              _buildInfoRow(
                header: 'Vendor',
                widget: CompanionCoin(item.vendorValue)
              ),
              _buildInfoRow(
                header: 'Trading Post Buy',
                widget: CompanionCoin(snapshot.data.buys.unitPrice)
              ),
              _buildInfoRow(
                header: 'Trading Post Sell',
                widget: CompanionCoin(snapshot.data.sells.unitPrice)
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildInfoRow({@required String header, String text, Widget widget }) {
    return Container(
      width: 400.0,
      margin: EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Text(
            header,
            style: TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16.0
            ),
          ),
          if (widget != null)
            widget
          else
            Text(
              text,
              style: TextStyle(
                fontSize: 16.0
              ),
            )
        ],
      ),
    );
  }

  String typeToName(String type) {
    switch (type) {
      case 'HelmAquatic':
        return 'Helm Aquatic';
      case 'AppearanceChange':
        return 'Appearance Change';
      case 'ContractNpc':
        return 'Npc Contract';
      case 'MountRandomUnlock':
        return 'Random Mount Unlock';
      case 'RandomUnlock':
        return 'Random Unlock';
      case 'UpgradeRemoval':
        return 'Upgrade Removal';
      case 'TeleportToFriend':
        return 'Teleport To Friend';
      case 'CraftingMaterial':
        return 'Crafting Material';
      case 'UpgradeComponent':
        return 'Upgrade Component';
      default:
        return type;
    }
  }
}