import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../controllers/auth_controller.dart';

class LeaderboardPage extends StatefulWidget {
  const LeaderboardPage({super.key});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  final _firestore = FirebaseFirestore.instance;
  final _authController = Get.find<AuthController>();
  
  List<Map<String, dynamic>> _leaderboard = [];
  bool _isLoading = true;
  String _selectedFilter = 'points'; // points, level, streak

  @override
  void initState() {
    super.initState();
    _loadLeaderboard();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);

    try {
      String orderField = _selectedFilter;
      
      final snapshot = await _firestore
          .collection('users')
          .orderBy(orderField, descending: true)
          .limit(100)
          .get();

      setState(() {
        _leaderboard = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'userId': doc.id,
            'displayName': data['displayName'] ?? 'Unknown',
            'email': data['email'] ?? '',
            'points': data['points'] ?? 0,
            'level': data['level'] ?? 1,
            'currentStreak': data['currentStreak'] ?? 0,
            'photoURL': data['photoURL'],
          };
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading leaderboard: $e');
      setState(() => _isLoading = false);
      Get.snackbar(
        'Error',
        'Failed to load leaderboard',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Leaderboard'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Filter Tabs
          Container(
            color: AppColors.primary,
            child: Row(
              children: [
                _buildFilterTab('Points', 'points'),
                _buildFilterTab('Level', 'level'),
                _buildFilterTab('Streak', 'currentStreak'),
              ],
            ),
          ),

          // Leaderboard Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _leaderboard.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.leaderboard_rounded,
                              size: 80,
                              color: AppColors.textSecondary.withOpacity(0.5),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No users found',
                              style: Get.textTheme.titleLarge?.copyWith(
                                color: AppColors.textSecondary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _loadLeaderboard,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _leaderboard.length,
                          itemBuilder: (context, index) {
                            final user = _leaderboard[index];
                            final isCurrentUser = user['userId'] == _authController.currentUser?.uid;
                            final rank = index + 1;

                            return _buildLeaderboardItem(
                              rank: rank,
                              user: user,
                              isCurrentUser: isCurrentUser,
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTab(String label, String filterValue) {
    final isSelected = _selectedFilter == filterValue;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedFilter = filterValue);
          _loadLeaderboard();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardItem({
    required int rank,
    required Map<String, dynamic> user,
    required bool isCurrentUser,
  }) {
    Color? rankColor;
    IconData? rankIcon;

    if (rank == 1) {
      rankColor = AppColors.gold;
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 2) {
      rankColor = Colors.grey[400];
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank == 3) {
      rankColor = Colors.brown[300];
      rankIcon = Icons.emoji_events_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isCurrentUser 
            ? AppColors.primary.withOpacity(0.1) 
            : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCurrentUser 
              ? AppColors.primary 
              : AppColors.textSecondary.withOpacity(0.1),
          width: isCurrentUser ? 2 : 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Rank
            SizedBox(
              width: 40,
              child: rankIcon != null
                  ? Icon(rankIcon, color: rankColor, size: 32)
                  : Text(
                      '#$rank',
                      style: Get.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
            ),
            const SizedBox(width: 16),

            // Avatar
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.primary,
              child: Text(
                user['displayName'].substring(0, 1).toUpperCase(),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // User Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['displayName'],
                    style: Get.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isCurrentUser ? 'You' : 'Level ${user['level']}',
                    style: Get.textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            // Score
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  _getScoreText(user),
                  style: Get.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  _getScoreLabel(),
                  style: Get.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getScoreText(Map<String, dynamic> user) {
    switch (_selectedFilter) {
      case 'level':
        return '${user['level']}';
      case 'currentStreak':
        return '${user['currentStreak']}';
      default:
        return '${user['points']}';
    }
  }

  String _getScoreLabel() {
    switch (_selectedFilter) {
      case 'level':
        return 'Level';
      case 'currentStreak':
        return 'Days';
      default:
        return 'Points';
    }
  }
}
