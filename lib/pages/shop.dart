// ignore_for_file: cascade_invocations, lines_longer_than_80_chars
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ricochlime/game/components/snowball.dart';
import 'package:ricochlime/utils/stows.dart';
import 'package:ricochlime/widgets/character_avatar.dart';
import 'package:ricochlime/widgets/snow_coin_badge.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ShopPage extends StatefulWidget {
  const ShopPage({super.key, this.initialTab = 0});

  final int initialTab;

  @override
  State<ShopPage> createState() => _ShopPageState();
}

class _ShopPageState extends State<ShopPage> with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final Set<String> _unlockedCharacters = {'default'};
  final Set<String> _unlockedSnowballs = {'normal'};

  final List<Map<String, dynamic>> _characterCatalog = const [
    {'id': 'default', 'name': 'Default', 'price': 0},
    {'id': 'blue_winter', 'name': 'Blue Winter', 'price': 500},
    {'id': 'green_hood', 'name': 'Green Hood', 'price': 800},
    {'id': 'reindeer', 'name': 'Reindeer', 'price': 1200},
    {'id': 'santa', 'name': 'Santa', 'price': 1500},
    {'id': 'penguin', 'name': 'Penguin', 'price': 2000},
  ];

  final List<Map<String, dynamic>> _snowballCatalog = const [
    {'id': 'normal', 'name': 'Normal', 'price': 0, 'type': SnowballType.normal},
    {'id': 'ice_crystal', 'name': 'Ice Crystal', 'price': 300, 'type': SnowballType.iceCrystal},
    {'id': 'fireball', 'name': 'Fireball', 'price': 500, 'type': SnowballType.fireball},
    {'id': 'gift_box', 'name': 'Gift Box', 'price': 800, 'type': SnowballType.giftBox},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 2),
    );
    _loadUnlockedItems();
  }

  Future<void> _loadUnlockedItems() async {
    final prefs = await SharedPreferences.getInstance();
    final chars = prefs.getStringList('unlocked_characters') ?? ['default'];
    final balls = prefs.getStringList('unlocked_snowballs') ?? ['normal'];
    setState(() {
      _unlockedCharacters.addAll(chars);
      _unlockedSnowballs.addAll(balls);
    });
  }

  Future<void> _saveUnlockedItems() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('unlocked_characters', _unlockedCharacters.toList());
    await prefs.setStringList('unlocked_snowballs', _unlockedSnowballs.toList());
  }

  void _buyOrSelectCharacter(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final price = item['price'] as int;

    if (_unlockedCharacters.contains(id)) {
      // Select
      setState(() {
        stows.selectedCharacter.value = id;
      });
      return;
    }

    // Attempt purchase
    if (stows.coins.value >= price) {
      setState(() {
        stows.coins.value -= price;
        _unlockedCharacters.add(id);
        stows.selectedCharacter.value = id;
      });
      _saveUnlockedItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unlocked ${item['name']}!'),
          backgroundColor: const Color(0xFF1E88E5),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: Color(0xFFD32F2F),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  void _buyOrSelectSnowball(Map<String, dynamic> item) {
    final id = item['id'] as String;
    final price = item['price'] as int;

    if (_unlockedSnowballs.contains(id)) {
      // Select
      setState(() {
        stows.selectedSnowball.value = id;
      });
      return;
    }

    // Attempt purchase
    if (stows.coins.value >= price) {
      setState(() {
        stows.coins.value -= price;
        _unlockedSnowballs.add(id);
        stows.selectedSnowball.value = id;
      });
      _saveUnlockedItems();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unlocked ${item['name']} snowball!'),
          backgroundColor: const Color(0xFF1E88E5),
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Not enough coins!'),
          backgroundColor: Color(0xFFD32F2F),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFFB3E5FC),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFF81D4FA),
                Color(0xFFE1F5FE),
                Color(0xFFB3E5FC),
              ],
            ),
          ),
          child: SafeArea(
            child: Column(
              children: [
                // 1. Top Bar: Back Button + Coins
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Image.asset(
                          'assets/images/ui/btn_back.png',
                          width: 38,
                          height: 38,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1976D2),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFF64B5F6), width: 1.5),
                            ),
                            child: const Icon(Icons.arrow_back_rounded, color: Colors.white, size: 22),
                          ),
                        ),
                      ),
                      const SnowCoinBadge(),
                    ],
                  ),
                ),

                // 2. Wooden "Store" Sign Board (matching UI.png!)
                _buildWoodenStoreHeader(),

                const SizedBox(height: 12),

                // 3. Segmented Tabs
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1565C0),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF42A5F5),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    labelColor: Colors.white,
                    unselectedLabelColor: const Color(0xFFBBDEFB),
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                    tabs: const [
                      Tab(
                        icon: Icon(Icons.checkroom_rounded, size: 18),
                        text: 'Characters',
                      ),
                      Tab(
                        icon: Icon(Icons.ac_unit_rounded, size: 18),
                        text: 'Snowballs',
                      ),
                      Tab(
                        icon: Icon(Icons.star_rounded, size: 18),
                        text: 'Effects',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // 4. Tab Views
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCharactersGrid(),
                      _buildSnowballsGrid(),
                      _buildEffectsTab(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWoodenStoreHeader() {
    return Image.asset(
      'assets/images/ui/store_wooden_sign.png',
      height: 56,
      fit: BoxFit.contain,
      filterQuality: FilterQuality.none,
      errorBuilder: (context, error, stackTrace) => Container(
        width: 180,
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFF8D6E63),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF5D4037), width: 3),
          boxShadow: const [
            BoxShadow(
              color: Color(0x33000000),
              blurRadius: 6,
              offset: Offset(0, 3),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: const Text(
          'Store',
          style: TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }

  Widget _buildCharactersGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.72,
      ),
      itemCount: _characterCatalog.length,
      itemBuilder: (context, index) {
        final item = _characterCatalog[index];
        final id = item['id'] as String;
        final name = item['name'] as String;
        final price = item['price'] as int;
        final isSelected = stows.selectedCharacter.value == id;
        final isUnlocked = _unlockedCharacters.contains(id);

        return DecoratedBox(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE0E0E0),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CharacterAvatar(skin: id, size: 55),
              const SizedBox(height: 4),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 6),
              // Action button
              GestureDetector(
                onTap: () => _buyOrSelectCharacter(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1E88E5)
                        : (isUnlocked ? const Color(0xFF4CAF50) : const Color(0xFFFFB300)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Image.asset(
                          'assets/images/ui/icon_check.png',
                          width: 12,
                          height: 12,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.check, size: 12, color: Colors.white),
                        ),
                        const SizedBox(width: 3),
                        const Text(
                          'Selected',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ] else if (isUnlocked) ...[
                        const Text(
                          'Select',
                          style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        Image.asset(
                          'assets/images/ui/coin.png',
                          width: 14,
                          height: 14,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.monetization_on, size: 12, color: Color(0xFF5D4037)),
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '$price',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSnowballsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 1.1,
      ),
      itemCount: _snowballCatalog.length,
      itemBuilder: (context, index) {
        final item = _snowballCatalog[index];
        final id = item['id'] as String;
        final name = item['name'] as String;
        final price = item['price'] as int;
        final type = item['type'] as SnowballType;
        final isSelected = stows.selectedSnowball.value == id;
        final isUnlocked = _unlockedSnowballs.contains(id);

        return Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isSelected ? const Color(0xFF1E88E5) : const Color(0xFFE0E0E0),
              width: isSelected ? 2.5 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x1A000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 42,
                height: 42,
                child: Image.asset(
                  'assets/images/snowballs/$id.png',
                  width: 42,
                  height: 42,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.none,
                  errorBuilder: (context, error, stackTrace) => CustomPaint(
                    painter: _SnowballPreviewPainter(type: type),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  color: Color(0xFF263238),
                ),
              ),
              const SizedBox(height: 8),
              // Action button
              GestureDetector(
                onTap: () => _buyOrSelectSnowball(item),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF1E88E5)
                        : (isUnlocked ? const Color(0xFF4CAF50) : const Color(0xFFFFB300)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        Image.asset(
                          'assets/images/ui/icon_check.png',
                          width: 14,
                          height: 14,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.check, size: 14, color: Colors.white),
                        ),
                        const SizedBox(width: 4),
                        const Text(
                          'Selected',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ] else if (isUnlocked) ...[
                        const Text(
                          'Select',
                          style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ] else ...[
                        Image.asset(
                          'assets/images/ui/coin.png',
                          width: 14,
                          height: 14,
                          filterQuality: FilterQuality.none,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.monetization_on, size: 14, color: Color(0xFF5D4037)),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$price',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEffectsTab() {
    return Center(
      child: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.auto_awesome, color: Color(0xFFFFB300), size: 48),
            SizedBox(height: 12),
            Text(
              'Winter Special Effects',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Color(0xFF1565C0),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Snow trail and frosty burst effects are automatically active for all snowballs!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFF546E7A), fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }
}

class _SnowballPreviewPainter extends CustomPainter {
  _SnowballPreviewPainter({required this.type});

  final SnowballType type;

  @override
  void paint(Canvas canvas, Size size) {
    Snowball.drawSnowball(
      canvas,
      Offset(size.width / 2, size.height / 2),
      radius: size.width * 0.45,
      type: type,
    );
  }

  @override
  bool shouldRepaint(covariant _SnowballPreviewPainter oldDelegate) => oldDelegate.type != type;
}
