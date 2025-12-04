import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/app/data/models/quiz_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AdminQuizPage extends StatefulWidget {
  const AdminQuizPage({super.key});

  @override
  State<AdminQuizPage> createState() => _AdminQuizPageState();
}

class _AdminQuizPageState extends State<AdminQuizPage> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _categoryController = TextEditingController();
  final _timeLimitController = TextEditingController();
  final _passingScoreController = TextEditingController();
  final _pointsRewardController = TextEditingController();
  final _coinsRewardController = TextEditingController();
  final _totalQuestionsController = TextEditingController();
  
  String _selectedDifficulty = 'Easy';
  bool _isPremium = false;
  bool _isLoading = false;
  int _selectedTab = 0; // 0 = Create, 1 = Manage
  
  // Edit mode
  bool _isEditMode = false;
  String? _editingQuizId;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _categoryController.dispose();
    _timeLimitController.dispose();
    _passingScoreController.dispose();
    _pointsRewardController.dispose();
    _coinsRewardController.dispose();
    _totalQuestionsController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _titleController.clear();
    _descriptionController.clear();
    _categoryController.clear();
    _timeLimitController.clear();
    _passingScoreController.clear();
    _pointsRewardController.clear();
    _coinsRewardController.clear();
    _totalQuestionsController.clear();
    setState(() {
      _selectedDifficulty = 'Easy';
      _isPremium = false;
      _isEditMode = false;
      _editingQuizId = null;
    });
  }

  void _loadQuizForEdit(QuizModel quiz) {
    _titleController.text = quiz.title;
    _descriptionController.text = quiz.description;
    _categoryController.text = quiz.category;
    _timeLimitController.text = quiz.timeLimit.toString();
    _passingScoreController.text = quiz.passingScore.toString();
    _pointsRewardController.text = quiz.pointsReward.toString();
    _coinsRewardController.text = quiz.coinsReward.toString();
    _totalQuestionsController.text = quiz.totalQuestions.toString();
    setState(() {
      _selectedDifficulty = quiz.difficulty;
      _isPremium = quiz.isPremium;
      _isEditMode = true;
      _editingQuizId = quiz.quizId;
      _selectedTab = 0; // Switch to create/edit tab
    });
  }

  Future<void> _saveQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quizId = _isEditMode ? _editingQuizId! : const Uuid().v4();
      
      final quiz = QuizModel(
        quizId: quizId,
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        category: _categoryController.text.trim(),
        difficulty: _selectedDifficulty,
        timeLimit: int.tryParse(_timeLimitController.text) ?? 0,
        passingScore: int.tryParse(_passingScoreController.text) ?? 70,
        pointsReward: int.tryParse(_pointsRewardController.text) ?? 100,
        coinsReward: int.tryParse(_coinsRewardController.text) ?? 10,
        totalQuestions: int.tryParse(_totalQuestionsController.text) ?? 10,
        isPremium: _isPremium,
        createdAt: _isEditMode 
            ? (await _firestore.collection('quizzes').doc(quizId).get())
                .data()?['createdAt']?.toDate() ?? DateTime.now()
            : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('quizzes')
          .doc(quiz.quizId)
          .set(quiz.toMap());

      Get.snackbar(
        'Success',
        _isEditMode ? 'Quiz updated successfully' : 'Quiz created successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      _clearForm();
      setState(() => _selectedTab = 1); // Switch to manage tab
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save quiz: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _toggleQuizVisibility(String quizId, bool isHidden) async {
    try {
      await _firestore.collection('quizzes').doc(quizId).update({
        'isHidden': !isHidden,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      Get.snackbar(
        'Success',
        isHidden ? 'Quiz is now visible' : 'Quiz is now hidden',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update quiz visibility',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _deleteQuiz(String quizId, String title) async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Delete Quiz'),
        content: Text(
          'Are you sure you want to delete "$title"?\n\nThis will also delete all questions and user attempts for this quiz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete quiz
      await _firestore.collection('quizzes').doc(quizId).delete();

      // Delete all questions for this quiz
      final questionsSnapshot = await _firestore
          .collection('questions')
          .where('quizId', isEqualTo: quizId)
          .get();

      for (var doc in questionsSnapshot.docs) {
        await doc.reference.delete();
      }

      // Delete all attempts for this quiz
      final attemptsSnapshot = await _firestore
          .collection('quiz_attempts')
          .where('quizId', isEqualTo: quizId)
          .get();

      for (var doc in attemptsSnapshot.docs) {
        await doc.reference.delete();
      }

      Get.snackbar(
        'Success',
        'Quiz and all related data deleted successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete quiz: $e',
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
        title: const Text('Admin - Quiz Management'),
        bottom: TabBar(
          onTap: (index) => setState(() => _selectedTab = index),
          tabs: const [
            Tab(text: 'Create/Edit'),
            Tab(text: 'Manage Quizzes'),
          ],
        ),
      ),
      body: IndexedStack(
        index: _selectedTab,
        children: [
          _buildCreateEditTab(),
          _buildManageTab(),
        ],
      ),
    );
  }

  Widget _buildCreateEditTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_isEditMode)
              Container(
                padding: const EdgeInsets.all(12),
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.primary),
                ),
                child: Row(
                  children: [
                    Icon(Icons.edit, color: AppColors.primary),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Editing Mode',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    TextButton(
                      onPressed: _clearForm,
                      child: const Text('Cancel'),
                    ),
                  ],
                ),
              ),

            // Title
            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Quiz Title',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter quiz title';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              maxLines: 3,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter description';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Category
            TextFormField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: 'Category (e.g., Flutter, Dart)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter category';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Difficulty
            DropdownButtonFormField<String>(
              value: _selectedDifficulty,
              decoration: const InputDecoration(
                labelText: 'Difficulty',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              items: ['Easy', 'Medium', 'Hard']
                  .map((difficulty) => DropdownMenuItem(
                        value: difficulty,
                        child: Text(difficulty),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() => _selectedDifficulty = value!);
              },
            ),
            const SizedBox(height: 16),

            // Time Limit
            TextFormField(
              controller: _timeLimitController,
              decoration: const InputDecoration(
                labelText: 'Time Limit (seconds, 0 = unlimited)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter time limit';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Passing Score
            TextFormField(
              controller: _passingScoreController,
              decoration: const InputDecoration(
                labelText: 'Passing Score (%)',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter passing score';
                }
                final score = int.tryParse(value);
                if (score == null || score < 0 || score > 100) {
                  return 'Score must be between 0-100';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Points Reward
            TextFormField(
              controller: _pointsRewardController,
              decoration: const InputDecoration(
                labelText: 'Points Reward',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter points reward';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Coins Reward
            TextFormField(
              controller: _coinsRewardController,
              decoration: const InputDecoration(
                labelText: 'Coins Reward',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter coins reward';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Total Questions
            TextFormField(
              controller: _totalQuestionsController,
              decoration: const InputDecoration(
                labelText: 'Total Questions',
                border: OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter total questions';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),

            // Premium Switch
            SwitchListTile(
              title: const Text('Premium Quiz'),
              value: _isPremium,
              onChanged: (value) {
                setState(() => _isPremium = value);
              },
              tileColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveQuiz,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text(
                      _isEditMode ? 'Update Quiz' : 'Create Quiz',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildManageTab() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection('quizzes')
          .orderBy('createdAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.quiz_outlined,
                  size: 80,
                  color: AppColors.textSecondary.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                Text(
                  'No quizzes found',
                  style: Get.textTheme.titleLarge?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                const Text('Create your first quiz!'),
              ],
            ),
          );
        }

        final quizzes = snapshot.data!.docs
            .map((doc) => QuizModel.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: quizzes.length,
          itemBuilder: (context, index) {
            final quiz = quizzes[index];
            final isHidden = quiz.isHidden ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        quiz.title,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          decoration: isHidden 
                              ? TextDecoration.lineThrough 
                              : null,
                          color: isHidden 
                              ? AppColors.textSecondary 
                              : null,
                        ),
                      ),
                    ),
                    if (isHidden)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Hidden',
                          style: TextStyle(
                            color: AppColors.error,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      quiz.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: [
                        Chip(
                          label: Text(quiz.category),
                          backgroundColor: AppColors.primary.withOpacity(0.1),
                          labelStyle: TextStyle(color: AppColors.primary),
                        ),
                        Chip(
                          label: Text(quiz.difficulty),
                          backgroundColor: _getDifficultyColor(quiz.difficulty),
                        ),
                        if (quiz.isPremium)
                          Chip(
                            label: const Text('Premium'),
                            backgroundColor: AppColors.gold.withOpacity(0.2),
                            avatar: Icon(
                              Icons.star,
                              size: 16,
                              color: AppColors.gold,
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'edit') {
                      _loadQuizForEdit(quiz);
                    } else if (value == 'toggle') {
                      _toggleQuizVisibility(quiz.quizId, isHidden);
                    } else if (value == 'delete') {
                      _deleteQuiz(quiz.quizId, quiz.title);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle',
                      child: Row(
                        children: [
                          Icon(
                            isHidden ? Icons.visibility : Icons.visibility_off,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(isHidden ? 'Show' : 'Hide'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text(
                            'Delete',
                            style: TextStyle(color: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getDifficultyColor(String difficulty) {
    switch (difficulty) {
      case 'Easy':
        return AppColors.success.withOpacity(0.2);
      case 'Medium':
        return Colors.orange.withOpacity(0.2);
      case 'Hard':
        return AppColors.error.withOpacity(0.2);
      default:
        return Colors.grey.withOpacity(0.2);
    }
  }
}
