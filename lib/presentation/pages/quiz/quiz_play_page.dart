import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:learning_app/core/constant/colors.dart';
import '../../controllers/quiz_controller.dart';

class QuizPlayPage extends GetView<QuizController> {
  const QuizPlayPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final quizId = args?['quizId'] as String?;

    if (quizId == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Quiz')),
        body: const Center(child: Text('Quiz not found')),
      );
    }

    controller.startQuiz(quizId);

    return WillPopScope(
      onWillPop: () async {
        final shouldExit = await _showExitDialog();
        return shouldExit ?? false;
      },
      child: Scaffold(
        backgroundColor: AppColors.cream,
        appBar: AppBar(
          backgroundColor: AppColors.primary,
          title: Obx(() => Text(
                controller.selectedQuiz.value?.title ?? 'Quiz',
              )),
          leading: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () async {
              final shouldExit = await _showExitDialog();
              if (shouldExit == true) Get.back();
            },
          ),
          actions: [
            Obx(() {
              final timeLimit = controller.selectedQuiz.value?.timeLimit ?? 0;
              if (timeLimit > 0 && controller.isQuizStarted.value) {
                final remainingTime = controller.remainingTime.value;
                return Center(
                  child: Container(
                    margin: const EdgeInsets.only(right: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: remainingTime < 60
                          ? AppColors.error
                          : Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.timer_outlined,
                          size: 16,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatTime(remainingTime),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SizedBox.shrink();
            }),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.questions.isEmpty) {
            return const Center(child: Text('No questions available'));
          }

          final currentQuestion =
              controller.questions[controller.currentQuestionIndex.value];

          return Column(
            children: [
              LinearProgressIndicator(
                value: (controller.currentQuestionIndex.value + 1) /
                    controller.questions.length,
                backgroundColor: AppColors.textSecondary.withOpacity(0.1),
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Question ${controller.currentQuestionIndex.value + 1} of ${controller.questions.length}',
                        style: Get.textTheme.bodyMedium?.copyWith(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        currentQuestion.questionText,
                        style: Get.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildOptions(currentQuestion),
                      const SizedBox(height: 24),
                      _buildQuestionGrid(),
                    ],
                  ),
                ),
              ),
              _buildBottomNavigation(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOptions(dynamic question) {
    switch (question.type) {
      case 'multiple_choice':
        final options = question.options as List<dynamic>? ?? [];
        return Column(
          children: options.map<Widget>((option) {
            final optionText = option.toString();
            return Obx(() {
              final isSelected =
                  controller.userAnswers[question.questionId] == optionText;
              return GestureDetector(
                onTap: () =>
                    controller.selectAnswer(question.questionId, optionText),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          optionText,
                          style: Get.textTheme.bodyLarge?.copyWith(
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                            color: isSelected
                                ? AppColors.primary
                                : AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            });
          }).toList(),
        );

      case 'true_false':
        return Column(
          children: ['True', 'False'].map((option) {
            return Obx(() {
              final isSelected =
                  controller.userAnswers[question.questionId] == option;
              return GestureDetector(
                onTap: () => controller.selectAnswer(question.questionId, option),
                child: Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withOpacity(0.1)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.textSecondary.withOpacity(0.2),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      option,
                      style: Get.textTheme.titleMedium?.copyWith(
                        fontWeight:
                            isSelected ? FontWeight.bold : FontWeight.w600,
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ),
              );
            });
          }).toList(),
        );

      case 'text_input':
        return Obx(() {
          final textController = TextEditingController(
            text: controller.userAnswers[question.questionId] ?? '',
          );
          return TextField(
            controller: textController,
            onChanged: (value) {
              controller.selectAnswer(question.questionId, value);
            },
            decoration: InputDecoration(
              hintText: 'Type your answer here...',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            maxLines: 3,
          );
        });

      default:
        return const Text('Unknown question type');
    }
  }

  Widget _buildQuestionGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.textSecondary.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Questions',
            style: Get.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: List.generate(
              controller.questions.length,
              (index) {
                final question = controller.questions[index];
                final isAnswered =
                    controller.userAnswers.containsKey(question.questionId);
                final isCurrent =
                    controller.currentQuestionIndex.value == index;

                return GestureDetector(
                  onTap: () => controller.goToQuestion(index),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isCurrent
                          ? AppColors.primary
                          : isAnswered
                              ? AppColors.success.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isCurrent
                            ? AppColors.primary
                            : isAnswered
                                ? AppColors.success
                                : Colors.grey,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: isCurrent
                              ? Colors.white
                              : isAnswered
                                  ? AppColors.success
                                  : Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            if (controller.currentQuestionIndex.value > 0)
              Expanded(
                child: OutlinedButton(
                  onPressed: controller.previousQuestion,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Previous'),
                ),
              ),
            if (controller.currentQuestionIndex.value > 0)
              const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: Obx(() {
                final isLastQuestion =
                    controller.currentQuestionIndex.value ==
                        controller.questions.length - 1;
                final allAnswered = controller.userAnswers.length ==
                    controller.questions.length;

                return ElevatedButton(
                  onPressed: () {
                    if (isLastQuestion) {
                      if (allAnswered) {
                        _showSubmitDialog();
                      } else {
                        Get.snackbar(
                          'Incomplete',
                          'Please answer all questions before submitting',
                          snackPosition: SnackPosition.BOTTOM,
                        );
                      }
                    } else {
                      controller.nextQuestion();
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isLastQuestion && allAnswered
                        ? AppColors.success
                        : AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    isLastQuestion ? 'Submit Quiz' : 'Next',
                    style: Get.textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Future<bool?> _showExitDialog() {
    return Get.dialog<bool>(
      AlertDialog(
        title: const Text('Exit Quiz?'),
        content: const Text(
          'Are you sure you want to exit? Your progress will be lost.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Get.back(result: true),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.error,
            ),
            child: const Text('Exit'),
          ),
        ],
      ),
    );
  }

  Future<void> _showSubmitDialog() async {
    final confirm = await Get.dialog<bool>(
      AlertDialog(
        title: const Text('Submit Quiz?'),
        content: const Text(
          'Are you ready to submit your answers? You cannot change them after submission.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(result: false),
            child: const Text('Review'),
          ),
          ElevatedButton(
            onPressed: () => Get.back(result: true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.success,
            ),
            child: const Text('Submit'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await controller.submitQuiz();
    }
  }
}
