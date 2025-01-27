import 'package:guildwars2_companion/features/achievement/models/achievement.dart';
import 'package:guildwars2_companion/features/achievement/models/achievement_category.dart';
import 'package:guildwars2_companion/features/achievement/models/achievement_data.dart';
import 'package:guildwars2_companion/features/achievement/models/achievement_group.dart';
import 'package:guildwars2_companion/features/achievement/models/achievement_progress.dart';
import 'package:guildwars2_companion/features/achievement/models/daily.dart';
import 'package:guildwars2_companion/features/character/models/title.dart';
import 'package:guildwars2_companion/features/item/models/item.dart';
import 'package:guildwars2_companion/features/item/models/mini.dart';
import 'package:guildwars2_companion/features/achievement/services/achievement.dart';
import 'package:guildwars2_companion/features/character/services/character.dart';
import 'package:guildwars2_companion/features/item/models/skin.dart';
import 'package:guildwars2_companion/features/item/services/item.dart';
import 'package:guildwars2_companion/features/mastery/models/mastery.dart';
import 'package:guildwars2_companion/features/mastery/models/mastery_data.dart';
import 'package:guildwars2_companion/features/mastery/models/mastery_progress.dart';
import 'package:meta/meta.dart';

class AchievementRepository {
  final AchievementService achievementService;
  final CharacterService characterService;
  final ItemService itemService;

  AchievementRepository({
    @required this.achievementService,
    @required this.characterService,
    @required this.itemService,
  });

  Future<AchievementData> getAchievements(bool includeProgress) async {
    await achievementService.loadCachedData();

    List networkResults = await Future.wait([
      achievementService.getAchievementGroups(),
      achievementService.getAchievementCategories(),
      achievementService.getDailies(),
      achievementService.getDailies(tomorrow: true)
    ]);

    List<AchievementGroup> achievementGroups = networkResults[0];
    List<AchievementCategory> achievementCategories = networkResults[1];
    DailyGroup dailies = networkResults[2];
    DailyGroup dailiesTomorrow = networkResults[3];

    List<int> achievementIds = [];
    achievementCategories.forEach((c) => achievementIds.addAll(c.achievements));
    dailies.pve.forEach((c) => achievementIds.add(c.id));
    dailies.pvp.forEach((c) => achievementIds.add(c.id));
    dailies.wvw.forEach((c) => achievementIds.add(c.id));
    dailies.fractals.forEach((c) => achievementIds.add(c.id));
    dailiesTomorrow.pve.forEach((c) => achievementIds.add(c.id));
    dailiesTomorrow.pvp.forEach((c) => achievementIds.add(c.id));
    dailiesTomorrow.wvw.forEach((c) => achievementIds.add(c.id));
    dailiesTomorrow.fractals.forEach((c) => achievementIds.add(c.id));

    List<Achievement> achievements = await achievementService.getAchievements(achievementIds.toSet().toList());

    int achievementPoints = 0;

    List<AchievementProgress> progress;
    if (includeProgress) {
      progress = await achievementService.getAchievementProgress();
    }

    achievements.forEach((a) {
      a.progress = includeProgress ? progress.firstWhere((p) => p.id == a.id, orElse: () => null) : null;
      
      processAchievementPoints(a);

      if (a.progress != null && a.progress.points > 0) {
        achievementPoints += a.progress.points;
      }
    });

    achievementCategories.forEach((c) {
      c.achievementsInfo = [];
      c.regions = [];
      c.completedAchievements = includeProgress ? 0 : null;
      c.achievements.forEach((i) {
        Achievement achievement = achievements.firstWhere((a) => a.id == i);

        if (achievement != null) {
          c.achievementsInfo.add(achievement);
          achievement.categoryName = c.name;

          if (achievement.icon == null) {
            achievement.icon = c.icon;
          }

          if (achievement.rewards != null && (achievement.progress == null || !achievement.progress.done)
            && achievement.rewards.any((r) => r.type == 'Mastery')) {
            c.regions.addAll(achievement.rewards.where((r) => r.type == 'Mastery').map((r) => r.region).toList());
          }

          if (includeProgress && achievement.progress != null && achievement.progress.done) {
            c.completedAchievements++;
          }
        }
      });
      c.achievementsInfo.sort((a, b) => -_getProgressionRate(a, a.progress).compareTo(_getProgressionRate(b, b.progress)));
      c.regions = c.regions.toSet().toList();
    });

    dailies.pve.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailies.pvp.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailies.wvw.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailies.fractals.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailiesTomorrow.pve.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailiesTomorrow.pvp.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailiesTomorrow.wvw.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));
    dailiesTomorrow.fractals.forEach((d) => d.achievementInfo = achievements.firstWhere((a) => a.id == d.id, orElse: () => null));

    achievementGroups.forEach((g) {
      g.categoriesInfo = [];
      g.regions = [];

      g.categories.forEach((c) {
        AchievementCategory category = achievementCategories.firstWhere((ac) => ac.id == c, orElse: () => null);

        if (category != null) {
          g.categoriesInfo.add(category);
          g.regions.addAll(category.regions);
        }
      });

      g.regions = g.regions.toSet().toList();
      g.categoriesInfo.sort((a, b) => a.order.compareTo(b.order));
    });
    achievementGroups.sort((a, b) => a.order.compareTo(b.order));

    List<Achievement> favoriteAchievements = await getFavoriteAchievements(achievements);

    return AchievementData(
      achievementGroups: achievementGroups,
      achievementPoints: achievementPoints,
      achievements: achievements,
      favoriteAchievements: favoriteAchievements,
      dailies: dailies,
      dailiesTomorrow: dailiesTomorrow
    );
  }

  Future<List<Achievement>> getFavoriteAchievements(List<Achievement> achievements) async {
    List<int> favoriteAchievementsIds = await achievementService.getFavoriteAchievements();
    achievements.forEach((a) => a.favorite = favoriteAchievementsIds.contains(a.id));
    return achievements.where((a) => a.favorite).toList();
  }

  Future<void> setFavoriteAchievement(int id) => achievementService.setFavoriteAchievement(id);
  Future<void> removeFavoriteAchievement(int id) => achievementService.removeFavoriteAchievement(id);

  Future<void> updateAchievementProgress(Achievement achievement) async {
    List<AchievementProgress> progress = await achievementService.getAchievementProgress();

    achievement.progress = progress.firstWhere((p) => p.id == achievement.id, orElse: () => null);
      
    processAchievementPoints(achievement);

    achievement.loading = false;

    return;
  }

  void processAchievementPoints(Achievement achievement) {
    int maxPoints = 0;
    achievement.tiers.forEach((t) {
      maxPoints += t.points;

      if (achievement.progress != null 
        && ((achievement.progress.current != null && achievement.progress.current >= t.count) 
        || (achievement.progress.done && achievement.pointCap == null))) {
        achievement.progress.points += t.points;
      }
    });

    if (achievement.progress != null && achievement.progress.repeated != null) {
      achievement.progress.points += maxPoints * achievement.progress.repeated;

      if (achievement.pointCap != null && achievement.progress.points > achievement.pointCap) {
        achievement.progress.points = achievement.pointCap;
        achievement.progress.done = true;
      } else if (achievement.pointCap != null && achievement.progress.points < achievement.pointCap) {
        achievement.progress.done = false;
      }
    }

    achievement.maxPoints = achievement.pointCap ?? maxPoints;
  }

  Future<MasteryData> getMasteries(bool includeProgress) async {
    List networkResults = await Future.wait([
      achievementService.getMasteries(),
      if (includeProgress)
        achievementService.getMasteryProgress()
    ]);

    List<Mastery> masteries = networkResults[0];

    int masteryLevel;

    if (includeProgress && networkResults[1] != null) {
      List<MasteryProgress> masteryProgress = networkResults[1];
      masteryLevel = 0;

      masteries.forEach((mastery) {
        MasteryProgress progress = masteryProgress.firstWhere((m) => m.id == mastery.id, orElse: () => null);

        if (progress != null) {
          mastery.level = progress.level + 1;
          mastery.levels.where((l) => mastery.levels.indexOf(l) <= progress.level)
            .forEach((l) {
              l.done = true;
              masteryLevel += l.pointCost;
            });
        } else {
          mastery.level = 0;
        }
      });
    }

    masteries.sort((a, b) => _getMasteryRate(a).compareTo(_getMasteryRate(b)));

    return MasteryData(
      masteries: masteries,
      masteryLevel: masteryLevel
    );
  }

  Future<void> loadAchievementDetails(Achievement achievement, List<Achievement> achievements) async {
    if (achievement.prerequisites != null) {
      achievement.prerequisitesInfo = [];
      achievement.prerequisites.forEach((id) {
        Achievement prerequisite = achievements.firstWhere((a) => a.id == id, orElse: () => null);

        if (prerequisite != null) {
          achievement.prerequisitesInfo.add(prerequisite);
        }
      });
    }

    List<int> itemIds = [];
    List<int> skinIds = [];
    List<int> miniIds = [];

    if (achievement.bits != null) {
      achievement.bits.forEach((bit) {
        switch (bit.type) {
          case 'Item':
            itemIds.add(bit.id);
            break;
          case 'Skin':
            skinIds.add(bit.id);
            break;
          case 'Minipet':
            miniIds.add(bit.id);
            break;
        }
      });
    }
    
    if (achievement.rewards != null) {
      achievement.rewards.forEach((reward) {
        if (reward.type == 'Item') {
          itemIds.add(reward.id);
        }
      });
    }

    List<Item> items = itemIds.isEmpty ? [] : await itemService.getItems(itemIds);
    List<Skin> skins = skinIds.isEmpty ? [] : await itemService.getSkins(skinIds);
    List<Mini> minis = miniIds.isEmpty ? [] : await itemService.getMinis(miniIds);
    List<AccountTitle> titles = await characterService.getTitles();

    if (achievement.bits != null) {
      achievement.bits.forEach((bit) {
        switch (bit.type) {
          case 'Item':
            bit.item = items.firstWhere((i) => i.id == bit.id, orElse: () => null);
            break;
          case 'Skin':
            bit.skin = skins.firstWhere((i) => i.id == bit.id, orElse: () => null);
            break;
          case 'Minipet':
            bit.mini = minis.firstWhere((i) => i.id == bit.id, orElse: () => null);
            break;
        }
      });
    }

    if (achievement.rewards != null) {
      achievement.rewards.forEach((reward) {
        switch (reward.type) {
          case 'Item':
            reward.item = items.firstWhere((i) => i.id == reward.id, orElse: () => null);
            break;
          case 'Title':
            reward.title = titles.firstWhere((i) => i.id == reward.id, orElse: () => null);
            break;
        }
      });
    }

    achievement.loading = false;
    achievement.loaded = true;

    return;
  }

  Future<void> clearCache() {
    return achievementService.clearCache();
  }

  Future<int> getCachedAchievementsCount() {
    return achievementService.getCachedAchievementsCount();
  }

  int _getProgressionRate(Achievement achievement, AchievementProgress progress) {
    if (progress == null) {
      return 0;
    }

    if (progress.done) {
      return -1;
    }

    if (progress.current == null || progress.max == null) {
      return 0;
    }

    if (progress.repeated != null) {
      return ((progress.points / achievement.maxPoints) * 100).round();
    }

    return ((progress.current / progress.max) * 100).round();
  }

  int _getMasteryRate(Mastery mastery) {
    int region = 0;

    switch (mastery.region) {
      case 'Desert':
        region = 20;
        break;
      case 'Maguuma':
        region = 10;
        break;
      case 'Tyria':
        break;
      default:
        region = 30;
        break;
    }

    return region + mastery.order;
  }
}