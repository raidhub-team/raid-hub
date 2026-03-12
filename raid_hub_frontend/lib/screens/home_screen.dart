import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/raid_video.dart';
import '../models/playlist_item.dart';
import '../models/cheat_sheet.dart';
import '../services/api_service.dart';
import '../services/auth_service.dart';
import '../providers/theme_provider.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'landing_screen.dart';
import '../widgets/skeleton_ui.dart';
import '../widgets/cheat_sheet_card.dart';
import '../widgets/video_cards.dart';
import '../widgets/upload_dialogs.dart';

class HomePage extends StatefulWidget {
  final int initialIndex;
  const HomePage({super.key, this.initialIndex = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();

  // Navigation & Filter State
  late int _currentIndex;

  String _selectedGuideKeyword = '전체';
  String _searchQuery = '';
  String _sortOption = '최신순'; // '최신순', '제목순'
  // 드롭다운에서 선택된 대분류/소분류 상태
  String _selectedCategory = '전체 레이드';
  String _selectedRaid = '전체';

  final _searchController = TextEditingController();

  // Data - Videos
  List<dynamic> _allContent = [];
  List<dynamic> _filteredContent = [];
  List<dynamic> _blockedContent = [];
  List<String> _blockedVideoIds = [];

  // Data - Cheat Sheets
  List<CheatSheet> _allCheatSheets = [];
  List<CheatSheet> _filteredCheatSheets = [];

  // Loading State
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _loadData();
    _searchController.addListener(() {
      setState(() => _searchQuery = _searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      List<Future> futures = [
        _apiService.getVideos(),
        _apiService.getBlockedVideoIds(),
        _apiService.getCheatSheets()
      ];
      for (final playlistId in RaidConstants.playlistIds) {
        futures.add(_apiService.getPlaylistItems(playlistId));
      }

      final results = await Future.wait(futures);

      if (mounted) {
        setState(() {
          final raidVideos = results[0] as List<RaidVideo>;
          _blockedVideoIds = results[1] as List<String>;
          _allCheatSheets = results[2] as List<CheatSheet>;

          final List<PlaylistItem> playlistItems = [];
          for (int i = 0; i < RaidConstants.playlistIds.length; i++) {
            final items = results[i + 3] as List<PlaylistItem>;
            final playlistId = RaidConstants.playlistIds[i];
            playlistItems.addAll(items.map((item) => item.copyWith(playlistId: playlistId)));
          }

          _blockedContent = playlistItems.where((item) => _blockedVideoIds.contains(item.videoId)).toList();
          final filteredPlaylistItems = playlistItems.where((item) => !_blockedVideoIds.contains(item.videoId)).toList();
          _allContent = [...raidVideos, ...filteredPlaylistItems];
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshVideos() async {
    await _loadData();
  }

  // 키워드 매칭 로직을 별도로 분리하여 관리
  bool _checkKeywordMatch(dynamic item, String keyword) {
    if (keyword == '전체') return true;

    String title = (item is RaidVideo) ? item.title : (item as PlaylistItem).title;
    String raidName = (item is RaidVideo) ? item.raidName : '';
    bool isEtcPlaylist = (item is PlaylistItem && item.playlistId == 'PLSC2n1C_PEtut5Q3C0NTDBkiclH2Xqctm');

    if (keyword == '로아 유용한 팁') return isEtcPlaylist;
    if (isEtcPlaylist) return false;

    DateTime? videoDate;
    if (item is PlaylistItem) {
      videoDate = DateTime.tryParse(item.publishedAt);
    } else if (item is RaidVideo) {
      videoDate = item.createdAt;
    }

    final actKeywords = ['서막', '1막', '2막', '3막', '4막', '종막'];
    List<String> itemActs = [];
    for (String act in actKeywords) {
      String mappedRaid = RaidConstants.keywordMapping[act] ?? act;
      if (title.contains(act) || title.contains(mappedRaid) || raidName.contains(act) || raidName.contains(mappedRaid)) {
        itemActs.add(act);
      }
    }

    // 종막 예외 처리 등 기존 로직 유지
    if (itemActs.contains('종막') && itemActs.length > 1) {
      if (!title.contains('종막') && !raidName.contains('종막')) itemActs.remove('종막');
    }

    bool isAfter2MakDate = videoDate != null && !videoDate.isBefore(DateTime(2024, 9, 25));
    if (title.contains('아브렐슈드') || raidName.contains('아브렐슈드') || title.contains('2막') || raidName.contains('2막')) {
      if (isAfter2MakDate) { if (!itemActs.contains('2막')) itemActs.add('2막'); } 
      else { itemActs.remove('2막'); }
    }

    bool isAfter4MakDate = videoDate != null && !videoDate.isBefore(DateTime(2025, 8, 20));
    if (title.contains('서막') || title.contains('에키드나') || raidName.contains('서막') || raidName.contains('에키드나') ||
        title.contains('4막') || title.contains('아르모체') || raidName.contains('4막') || raidName.contains('아르모체')) {
      if (isAfter4MakDate) {
        itemActs.remove('서막');
        if (!itemActs.contains('4막')) itemActs.add('4막');
      } else {
        itemActs.remove('4막');
        if (!itemActs.contains('서막')) itemActs.add('서막');
      }
    }

    String? primaryAct;
    for (String act in actKeywords.reversed) {
      if (itemActs.contains(act)) { primaryAct = act; break; }
    }

    if (RaidConstants.keywordMapping.containsKey(keyword)) {
      return (primaryAct == keyword);
    } else {
      bool matches = title.contains(keyword) || raidName.contains(keyword);
      if (keyword == '아브렐슈드' && isAfter2MakDate) return false;
      if (matches && primaryAct != null) return false;
      return matches;
    }
  }

  void _applyFilters() {
    List<dynamic> filteredVideos = _allContent.where((item) {
      String title = (item is RaidVideo) ? item.title : (item as PlaylistItem).title;
      String uploader = (item is RaidVideo) ? item.uploaderName : (item as PlaylistItem).channelTitle;
      String raidName = (item is RaidVideo) ? item.raidName : '';

      // 1. 대분류 필터링
      bool matchesCategory = true;
      if (_selectedCategory != '전체 레이드') {
        List<String> subRaids = RaidConstants.dropdownCategory[_selectedCategory] ?? [];
        List<String> actualRaids = subRaids.where((r) => r != '전체').toList();
        
        matchesCategory = actualRaids.any((raid) {
          // 괄호 포함된 레이드명에서 실제 키워드만 추출 (예: (서막)에키드나 -> 서막, 에키드나)
          if (raid.contains('(')) {
            RegExp regex = RegExp(r'\((.*?)\)');
            String act = regex.firstMatch(raid)?.group(1) ?? '';
            String realRaid = raid.split(')').last;
            return _checkKeywordMatch(item, act) || title.contains(realRaid) || raidName.contains(realRaid);
          }
          return _checkKeywordMatch(item, raid);
        });
      }

      // 2. 소분류 필터링 (기존 _selectedGuideKeyword 기반)
      bool matchesKeyword = _checkKeywordMatch(item, _selectedGuideKeyword);

      // 3. 검색어 필터링
      bool matchesSearch = _searchQuery.isEmpty || 
          title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          uploader.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          raidName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesKeyword && matchesSearch;
    }).toList();

    if (_sortOption == '최신순') {
        filteredVideos.sort((a, b) {
            DateTime dateA = (a is RaidVideo) ? (a.createdAt ?? DateTime(2000)) : DateTime.tryParse((a as PlaylistItem).publishedAt) ?? DateTime(2000);
            DateTime dateB = (b is RaidVideo) ? (b.createdAt ?? DateTime(2000)) : DateTime.tryParse((b as PlaylistItem).publishedAt) ?? DateTime(2000);
            return dateB.compareTo(dateA);
        });
    } else {
        filteredVideos.sort((a, b) {
            String titleA = (a is RaidVideo) ? a.title : (a as PlaylistItem).title;
            String titleB = (b is RaidVideo) ? b.title : (b as PlaylistItem).title;
            return titleA.compareTo(titleB);
        });
    }
    _filteredContent = filteredVideos;

    // 컨닝페이퍼 필터링도 동일한 대분류 로직 적용
    List<CheatSheet> filteredCS = _allCheatSheets.where((cs) {
      bool matchesCategory = true;
      if (_selectedCategory != '전체 레이드') {
        List<String> subRaids = RaidConstants.dropdownCategory[_selectedCategory] ?? [];
        List<String> actualRaids = subRaids.where((r) => r != '전체').toList();
        matchesCategory = actualRaids.any((raid) {
           String term = raid.contains('(') ? RegExp(r'\((.*?)\)').firstMatch(raid)?.group(1) ?? raid : raid;
           String realRaid = raid.contains(')') ? raid.split(')').last : raid;
           return cs.raidName.contains(term) || cs.title.contains(term) || cs.raidName.contains(realRaid) || cs.title.contains(realRaid);
        });
      }

      bool matchesKeyword = false;
      if (_selectedGuideKeyword == '전체') {
        matchesKeyword = true;
      } else if (_selectedGuideKeyword == '로아 유용한 팁') {
        final keywords = RaidConstants.guideKeywords.where((k) => k != '전체' && k != '로아 유용한 팁').toList();
        matchesKeyword = !keywords.any((k) => cs.raidName.contains(k) || cs.title.contains(k));
      } else {
        final term = RaidConstants.keywordMapping[_selectedGuideKeyword] ?? _selectedGuideKeyword;
        matchesKeyword = cs.raidName.contains(term) || cs.title.contains(term);
      }

      bool matchesSearch = _searchQuery.isEmpty || 
          cs.title.toLowerCase().contains(_searchQuery.toLowerCase()) || 
          cs.raidName.toLowerCase().contains(_searchQuery.toLowerCase());

      return matchesCategory && matchesKeyword && matchesSearch;
    }).toList();

    if (_sortOption == '최신순') {
        filteredCS.sort((a, b) => (b.createdAt ?? DateTime(2000)).compareTo(a.createdAt ?? DateTime(2000)));
    } else {
        filteredCS.sort((a, b) => a.title.compareTo(b.title));
    }
    _filteredCheatSheets = filteredCS;
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoading && _allContent.isNotEmpty) _applyFilters();
    final authService = Provider.of<AuthService>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_currentIndex == 0 ? 'Lost Ark Raid Hub' : 'Raid Cheat Sheets'),
        leading: IconButton(
          icon: const Icon(Icons.home),
          tooltip: '메인 화면으로 가기',
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const LandingScreen()),
            );
          },
        ),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            tooltip: themeProvider.isDarkMode ? '라이트 모드로 전환' : '다크 모드로 전환',
            onPressed: () => themeProvider.toggleTheme(),
          ),
          if (authService.isAdmin)
            IconButton(
              icon: const Icon(Icons.visibility_off),
              tooltip: '숨긴 영상 관리',
              onPressed: _showBlockedVideosDialog,
            ),
          IconButton(
            icon: Icon(authService.isAuthenticated ? Icons.logout : Icons.admin_panel_settings),
            tooltip: authService.isAuthenticated ? '로그아웃' : '관리자 로그인',
            onPressed: () {
                if (authService.isAuthenticated) {
                    authService.logout();
                } else {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                }
            },
          ),
        ],
      ),
      body: Column(
              children: [
                _buildSearchAndSortBar(),
                _buildDropdownFilters(),
                Expanded(
                  child: _isLoading 
                    ? _buildSkeletonGrid() 
                    : (_allContent.isEmpty && !_isLoading)
                      ? _buildErrorView()
                      : (_currentIndex == 0 ? _buildVideosGrid() : _buildCheatSheetsGrid()),
                ),
              ],
            ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videocam), label: '공략 영상'),
          BottomNavigationBarItem(icon: Icon(Icons.description), label: '컨닝 페이퍼'),
        ],
      ),
      floatingActionButton: authService.isAdmin
          ? FloatingActionButton(
              onPressed: _currentIndex == 0 ? _showAddVideoDialog : _showAddCheatSheetDialog,
              child: const Icon(Icons.add),
            )
          : null,
    );
  }

  Widget _buildSkeletonGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: _currentIndex == 0 ? 300 : 400,
        childAspectRatio: _currentIndex == 0 ? 0.8 : 1.2,
        crossAxisSpacing: 20,
        mainAxisSpacing: 20,
      ),
      itemCount: 8,
      itemBuilder: (context, index) => const SkeletonCard(),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
          const SizedBox(height: 16),
          const Text("데이터를 불러오지 못했습니다.", style: TextStyle(fontSize: 18)),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            onPressed: _loadData,
            icon: const Icon(Icons.refresh),
            label: const Text("다시 시도"),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndSortBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '제목, 작성자, 레이드 검색...',
                prefixIcon: const Icon(Icons.search),
                isDense: true,
                contentPadding: const EdgeInsets.all(10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          DropdownButton<String>(
            value: _sortOption,
            underline: const SizedBox(),
            icon: const Icon(Icons.sort),
            items: ['최신순', '제목순'].map((String val) {
              return DropdownMenuItem<String>(value: val, child: Text(val));
            }).toList(),
            onChanged: (val) {
              if (val != null) setState(() => _sortOption = val);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedCategory,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: RaidConstants.dropdownCategory.keys.map((String category) {
                    return DropdownMenuItem<String>(
                      value: category,
                      child: Text(category, style: const TextStyle(fontSize: 14)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedCategory = newValue;
                        _selectedRaid = '전체';
                        _updateGuideKeywordFromDropdown();
                      });
                    }
                  },
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 3,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.withOpacity(0.3)),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  isExpanded: true,
                  value: _selectedRaid,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: RaidConstants.dropdownCategory[_selectedCategory]!.map((String raid) {
                    return DropdownMenuItem<String>(
                      value: raid,
                      child: Text(raid, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedRaid = newValue;
                        _updateGuideKeywordFromDropdown();
                      });
                    }
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _updateGuideKeywordFromDropdown() {
    if (_selectedRaid == '전체') {
       _selectedGuideKeyword = '전체'; 
    } else if (_selectedRaid.contains('(')) {
       RegExp regex = RegExp(r'\((.*?)\)');
       Match? match = regex.firstMatch(_selectedRaid);
       if (match != null) {
          _selectedGuideKeyword = match.group(1)!;
       }
    } else {
       _selectedGuideKeyword = _selectedRaid;
    }
  }

  Widget _buildVideosGrid() {
    return _filteredContent.isEmpty && !_isLoading
        ? const Center(child: Text("해당 키워드의 공략 영상이 없습니다."))
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 350, 
              childAspectRatio: 0.85, 
              crossAxisSpacing: 20, 
              mainAxisSpacing: 20,
            ),
            itemCount: _filteredContent.length,
            itemBuilder: (context, index) {
              final item = _filteredContent[index];
              if (item is RaidVideo) {
                return VideoCard(
                  video: item, 
                  thumbnailUrl: _getYouTubeThumbnail(item.youtubeUrl),
                  onDelete: () => _showDeleteVideoConfirm(item),
                );
              } else {
                return PlaylistCard(
                  item: item as PlaylistItem,
                  onBlock: () => _showBlockVideoConfirm(item),
                );
              }
            },
          );
  }

  Widget _buildCheatSheetsGrid() {
    return _filteredCheatSheets.isEmpty && !_isLoading
        ? const Center(child: Text("해당 키워드의 컨닝 페이퍼가 없습니다."))
        : GridView.builder(
            padding: const EdgeInsets.all(20),
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 450, 
              childAspectRatio: 1.1, 
              crossAxisSpacing: 20, 
              mainAxisSpacing: 20,
            ),
            itemCount: _filteredCheatSheets.length,
            itemBuilder: (context, index) => CheatSheetCard(
              cheatSheet: _filteredCheatSheets[index],
              onDelete: () => _confirmDeleteCheatSheet(_filteredCheatSheets[index]),
            ),
          );
  }

  void _showDeleteVideoConfirm(RaidVideo video) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("영상 삭제"),
        content: const Text("정말로 이 영상을 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await _apiService.deleteVideo(video.id!);
                _refreshVideos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("삭제 실패: $e")));
              }
            },
            child: const Text("삭제", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _showBlockVideoConfirm(PlaylistItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("영상 숨기기"),
        content: const Text("이 영상을 목록에서 숨기시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(
            onPressed: () async {
              try {
                await _apiService.blockVideo(item.videoId, "관리자 숨김 처리");
                Navigator.pop(ctx);
                _refreshVideos();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("숨김 실패: $e")));
              }
            },
            child: const Text("숨기기", style: TextStyle(color: Colors.orange)),
          ),
        ],
      ),
    );
  }

  void _showAddCheatSheetDialog() {
    final authService = Provider.of<AuthService>(context, listen: false);
    showDialog(
      context: context,
      builder: (context) => CheatSheetUploadDialog(
        raidByCategory: RaidConstants.raidByCategory,
        onUpload: (title, raid, gate, uploaderName, bytes, name) async {
          try {
            await _apiService.uploadCheatSheet(
              title: title, 
              raidName: raid, 
              gate: gate, 
              uploaderName: uploaderName.isNotEmpty ? uploaderName : (authService.username ?? 'admin'),
              fileBytes: bytes, 
              fileName: name
            );
            Navigator.pop(context);
            _refreshVideos();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('컨닝 페이퍼가 등록되었습니다!')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
          }
        },
      ),
    );
  }

  void _confirmDeleteCheatSheet(CheatSheet cs) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("삭제 확인"),
        content: const Text("이 컨닝 페이퍼를 삭제하시겠습니까?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("취소")),
          TextButton(onPressed: () async {
            Navigator.pop(ctx);
            try {
              await _apiService.deleteCheatSheet(cs.id!);
              _refreshVideos();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("삭제 실패: $e")));
            }
          }, child: const Text("삭제", style: TextStyle(color: Colors.red))),
        ],
      ),
    );
  }

  void _showAddVideoDialog() {
    showDialog(
      context: context,
      builder: (context) => VideoUploadDialog(
        raidByCategory: RaidConstants.raidByCategory,
        onUpload: (video) async {
          try {
            await _apiService.createVideo(video);
            Navigator.pop(context);
            _refreshVideos();
            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('영상이 성공적으로 등록되었습니다!')));
          } catch (e) {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('등록 실패: $e')));
          }
        },
      ),
    );
  }

  void _showBlockedVideosDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('숨겨진 영상 목록'),
        content: SizedBox(
          width: double.maxFinite,
          child: _blockedContent.isEmpty
              ? const Center(child: Text("숨겨진 영상이 없습니다."))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _blockedContent.length,
                  itemBuilder: (context, index) {
                    final item = _blockedContent[index] as PlaylistItem;
                    return ListTile(
                      leading: Image.network(item.thumbnailUrl, width: 100, fit: BoxFit.cover, errorBuilder: (ctx, _, __) => const Icon(Icons.broken_image)),
                      title: Text(item.title, maxLines: 1, overflow: TextOverflow.ellipsis),
                      subtitle: Text(item.channelTitle),
                      trailing: IconButton(
                        icon: const Icon(Icons.restore, color: Colors.green),
                        onPressed: () async {
                          try {
                            await _apiService.unblockVideo(item.videoId);
                            Navigator.pop(context);
                            _refreshVideos();
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("복구 실패: $e")));
                          }
                        },
                      ),
                    );
                  },
                ),
        ),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('닫기'))],
      ),
    );
  }

  String? _getYouTubeVideoId(String url) {
    try {
      Uri uri = Uri.parse(url);
      if (uri.host.contains("youtu.be")) return uri.pathSegments.first;
      if (uri.host.contains("youtube.com")) return uri.queryParameters['v'];
    } catch (e) {}
    return null;
  }

  String? _getYouTubeThumbnail(String url) {
    final videoId = _getYouTubeVideoId(url);
    return videoId != null ? "https://img.youtube.com/vi/$videoId/mqdefault.jpg" : null;
  }
}
