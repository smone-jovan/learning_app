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

  Future<void> _addQuiz() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final quiz = QuizModel(
        quizId: const Uuid().v4(),
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
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await _firestore
          .collection('quizzes')
          .doc(quiz.quizId)
          .set(quiz.toMap());

      Get.snackbar(
        'Success',
        'Quiz created successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // Clear form
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
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create quiz: $e',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: const Text('Admin - Add Quiz'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                onPressed: _isLoading ? null : _addQuiz,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Create Quiz',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
