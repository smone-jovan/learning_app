import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import 'package:learning_app/app/data/models/question_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class AdminQuestionPage extends StatefulWidget {
  const AdminQuestionPage({super.key});

  @override
  State<AdminQuestionPage> createState() => _AdminQuestionPageState();
}

class _AdminQuestionPageState extends State<AdminQuestionPage> {
  final _firestore = FirebaseFirestore.instance;
  final _formKey = GlobalKey<FormState>();
  
  // Form controllers
  final _quizIdController = TextEditingController();
  final _questionTextController = TextEditingController();
  final _explanationController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _orderController = TextEditingController();
  
  String _correctAnswer = 'A';
  String _selectedQuestionType = 'multiple_choice';
  bool _isLoading = false;

  List<Map<String, dynamic>> _quizzes = [];
  bool _isLoadingQuizzes = true;

  @override
  void initState() {
    super.initState();
    _loadQuizzes();
  }

  Future<void> _loadQuizzes() async {
    try {
      final snapshot = await _firestore.collection('quizzes').get();
      setState(() {
        _quizzes = snapshot.docs
            .map((doc) => {
                  'id': doc.id,
                  'title': doc.data()['title'] ?? 'Untitled',
                })
            .toList();
        _isLoadingQuizzes = false;
      });
    } catch (e) {
      print('Error loading quizzes: $e');
      setState(() => _isLoadingQuizzes = false);
    }
  }

  @override
  void dispose() {
    _quizIdController.dispose();
    _questionTextController.dispose();
    _explanationController.dispose();
    _option1Controller.dispose();
    _option2Controller.dispose();
    _option3Controller.dispose();
    _option4Controller.dispose();
    _orderController.dispose();
    super.dispose();
  }

  Future<void> _addQuestion() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final options = <String>[
        _option1Controller.text.trim(),
        _option2Controller.text.trim(),
        _option3Controller.text.trim(),
        _option4Controller.text.trim(),
      ];

      final question = QuestionModel(
        questionId: const Uuid().v4(),
        quizId: _quizIdController.text.trim(),
        questionType: _selectedQuestionType,
        questionText: _questionTextController.text.trim(),
        options: options,
        correctAnswer: _correctAnswer,
        explanation: _explanationController.text.trim(),
        order: int.tryParse(_orderController.text) ?? 1,
        createdAt: DateTime.now(),
      );

      await _firestore
          .collection('questions')
          .doc(question.questionId)
          .set(question.toMap());

      Get.snackbar(
        'Success',
        'Question created successfully',
        backgroundColor: AppColors.success,
        colorText: Colors.white,
      );

      // Clear form
      _questionTextController.clear();
      _explanationController.clear();
      _option1Controller.clear();
      _option2Controller.clear();
      _option3Controller.clear();
      _option4Controller.clear();
      _orderController.clear();
      setState(() {
        _correctAnswer = 'A';
        _selectedQuestionType = 'multiple_choice';
      });
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create question: $e',
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
        title: const Text('Admin - Add Question'),
      ),
      body: _isLoadingQuizzes
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Quiz Selection
                    DropdownButtonFormField<String>(
                      value: _quizIdController.text.isEmpty
                          ? null
                          : _quizIdController.text,
                      decoration: const InputDecoration(
                        labelText: 'Select Quiz',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _quizzes
                          .map((quiz) => DropdownMenuItem(
                                value: quiz['id'],
                                child: Text(quiz['title']),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _quizIdController.text = value!);
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please select a quiz';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Question Type
                    DropdownButtonFormField<String>(
                      value: _selectedQuestionType,
                      decoration: const InputDecoration(
                        labelText: 'Question Type',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ['multiple_choice', 'true_false', 'short_answer']
                          .map((type) => DropdownMenuItem(
                                value: type,
                                child: Text(type.replaceAll('_', ' ').toUpperCase()),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedQuestionType = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Question Text
                    TextFormField(
                      controller: _questionTextController,
                      decoration: const InputDecoration(
                        labelText: 'Question Text',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter question text';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Options
                    Text(
                      'Options',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 8),

                    // Option A
                    TextFormField(
                      controller: _option1Controller,
                      decoration: const InputDecoration(
                        labelText: 'Option A',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter option A';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Option B
                    TextFormField(
                      controller: _option2Controller,
                      decoration: const InputDecoration(
                        labelText: 'Option B',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter option B';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Option C
                    TextFormField(
                      controller: _option3Controller,
                      decoration: const InputDecoration(
                        labelText: 'Option C',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter option C';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 8),

                    // Option D
                    TextFormField(
                      controller: _option4Controller,
                      decoration: const InputDecoration(
                        labelText: 'Option D',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter option D';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Correct Answer
                    DropdownButtonFormField<String>(
                      value: _correctAnswer,
                      decoration: const InputDecoration(
                        labelText: 'Correct Answer',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: ['A', 'B', 'C', 'D']
                          .map((answer) => DropdownMenuItem(
                                value: answer,
                                child: Text('Option $answer'),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _correctAnswer = value!);
                      },
                    ),
                    const SizedBox(height: 16),

                    // Explanation
                    TextFormField(
                      controller: _explanationController,
                      decoration: const InputDecoration(
                        labelText: 'Explanation (optional)',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 16),

                    // Order
                    TextFormField(
                      controller: _orderController,
                      decoration: const InputDecoration(
                        labelText: 'Question Order',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter question order';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isLoading ? null : _addQuestion,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Create Question',
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
