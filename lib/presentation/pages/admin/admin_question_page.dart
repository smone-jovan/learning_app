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
  final _questionTextController = TextEditingController();
  final _explanationController = TextEditingController();
  final _option1Controller = TextEditingController();
  final _option2Controller = TextEditingController();
  final _option3Controller = TextEditingController();
  final _option4Controller = TextEditingController();
  final _orderController = TextEditingController(text: '1');
  
  String? _selectedQuizId;
  int _correctAnswerIndex = 0; // 0=A, 1=B, 2=C, 3=D
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

    if (_selectedQuizId == null) {
      Get.snackbar(
        'Error',
        'Please select a quiz',
        backgroundColor: AppColors.error,
        colorText: Colors.white,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      List<String> options = [];
      String correctAnswer = '';

      if (_selectedQuestionType == 'multiple_choice') {
        // Build options array
        options = [
          _option1Controller.text.trim(),
          _option2Controller.text.trim(),
          _option3Controller.text.trim(),
          _option4Controller.text.trim(),
        ];

        // ✅ FIX: Save actual option text as correct answer
        correctAnswer = options[_correctAnswerIndex];
      } else if (_selectedQuestionType == 'true_false') {
        options = ['True', 'False'];
        correctAnswer = options[_correctAnswerIndex];
      } else {
        // short_answer - no options
        correctAnswer = _option1Controller.text.trim();
      }

      final question = QuestionModel(
        questionId: const Uuid().v4(),
        quizId: _selectedQuizId!,
        type: _selectedQuestionType,
        questionText: _questionTextController.text.trim(),
        options: options,
        correctAnswer: correctAnswer,
        explanation: _explanationController.text.trim().isEmpty 
            ? null 
            : _explanationController.text.trim(),
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
      _orderController.text = '1';
      setState(() {
        _correctAnswerIndex = 0;
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
                      value: _selectedQuizId,
                      decoration: const InputDecoration(
                        labelText: 'Select Quiz',
                        border: OutlineInputBorder(),
                        filled: true,
                        fillColor: Colors.white,
                      ),
                      items: _quizzes
                          .map<DropdownMenuItem<String>>((quiz) => DropdownMenuItem<String>(
                                value: quiz['id'] as String,
                                child: Text(quiz['title'] as String),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() => _selectedQuizId = value);
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
                        setState(() {
                          _selectedQuestionType = value!;
                          _correctAnswerIndex = 0;
                        });
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

                    // Options Section
                    if (_selectedQuestionType == 'multiple_choice') ..._buildMultipleChoiceOptions(),
                    if (_selectedQuestionType == 'true_false') ..._buildTrueFalseOptions(),
                    if (_selectedQuestionType == 'short_answer') ..._buildShortAnswerOption(),

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
                        if (int.tryParse(value) == null) {
                          return 'Please enter a valid number';
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

  List<Widget> _buildMultipleChoiceOptions() {
    return [
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
        decoration: InputDecoration(
          labelText: 'Option A',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: _correctAnswerIndex == 0 ? AppColors.success.withOpacity(0.1) : Colors.white,
          suffixIcon: Radio<int>(
            value: 0,
            groupValue: _correctAnswerIndex,
            onChanged: (value) {
              setState(() => _correctAnswerIndex = value!);
            },
          ),
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
        decoration: InputDecoration(
          labelText: 'Option B',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: _correctAnswerIndex == 1 ? AppColors.success.withOpacity(0.1) : Colors.white,
          suffixIcon: Radio<int>(
            value: 1,
            groupValue: _correctAnswerIndex,
            onChanged: (value) {
              setState(() => _correctAnswerIndex = value!);
            },
          ),
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
        decoration: InputDecoration(
          labelText: 'Option C',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: _correctAnswerIndex == 2 ? AppColors.success.withOpacity(0.1) : Colors.white,
          suffixIcon: Radio<int>(
            value: 2,
            groupValue: _correctAnswerIndex,
            onChanged: (value) {
              setState(() => _correctAnswerIndex = value!);
            },
          ),
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
        decoration: InputDecoration(
          labelText: 'Option D',
          border: const OutlineInputBorder(),
          filled: true,
          fillColor: _correctAnswerIndex == 3 ? AppColors.success.withOpacity(0.1) : Colors.white,
          suffixIcon: Radio<int>(
            value: 3,
            groupValue: _correctAnswerIndex,
            onChanged: (value) {
              setState(() => _correctAnswerIndex = value!);
            },
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter option D';
          }
          return null;
        },
      ),
    ];
  }

  List<Widget> _buildTrueFalseOptions() {
    return [
      Text(
        'Select Correct Answer',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      
      RadioListTile<int>(
        title: const Text('True'),
        value: 0,
        groupValue: _correctAnswerIndex,
        onChanged: (value) {
          setState(() => _correctAnswerIndex = value!);
        },
        tileColor: _correctAnswerIndex == 0 ? AppColors.success.withOpacity(0.1) : Colors.white,
      ),
      const SizedBox(height: 8),
      
      RadioListTile<int>(
        title: const Text('False'),
        value: 1,
        groupValue: _correctAnswerIndex,
        onChanged: (value) {
          setState(() => _correctAnswerIndex = value!);
        },
        tileColor: _correctAnswerIndex == 1 ? AppColors.success.withOpacity(0.1) : Colors.white,
      ),
    ];
  }

  List<Widget> _buildShortAnswerOption() {
    return [
      Text(
        'Correct Answer',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
      ),
      const SizedBox(height: 8),
      
      TextFormField(
        controller: _option1Controller,
        decoration: const InputDecoration(
          labelText: 'Correct Answer',
          border: OutlineInputBorder(),
          filled: true,
          fillColor: Colors.white,
          hintText: 'Enter the correct answer',
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter the correct answer';
          }
          return null;
        },
      ),
    ];
  }
}
