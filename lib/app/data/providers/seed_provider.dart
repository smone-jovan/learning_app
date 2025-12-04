import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';
import '../../core/constant/firebase_collections.dart';

/// Provider untuk seeding initial data ke Firestore
class SeedProvider {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  /// Check if database already seeded
  Future<bool> isDatabaseSeeded() async {
    try {
      final quizSnapshot = await _firestore
          .collection(FirebaseCollections.quizzes)
          .limit(1)
          .get();
      
      return quizSnapshot.docs.isNotEmpty;
    } catch (e) {
      print('❌ Error checking seed status: $e');
      return false;
    }
  }

  /// Seed all data (quizzes, courses, achievements)
  Future<void> seedAll() async {
    try {
      print('🌱 Starting database seeding...');
      
      final alreadySeeded = await isDatabaseSeeded();
      if (alreadySeeded) {
        print('✅ Database already seeded, skipping...');
        return;
      }
      
      await seedQuizzes();
      await seedCourses();
      await seedAchievements();
      
      print('🎉 Database seeding completed successfully!');
    } catch (e) {
      print('❌ Error seeding database: $e');
    }
  }

  /// Seed sample quizzes
  Future<void> seedQuizzes() async {
    try {
      print('🎯 Seeding quizzes...');
      
      final quizzes = [
        {
          'title': 'HTML Basics',
          'description': 'Test your knowledge of HTML fundamentals including tags, attributes, and document structure.',
          'category': 'Web Development',
          'difficulty': 'Beginner',
          'passingScore': 70,
          'timeLimit': 300, // 5 minutes
          'pointsReward': 100,
          'coinsReward': 50,
          'isHidden': false,
          'questions': [
            {
              'question': 'What does HTML stand for?',
              'options': ['Hyper Text Markup Language', 'High Tech Modern Language', 'Home Tool Markup Language', 'Hyperlinks and Text Markup Language'],
              'correctAnswer': 'Hyper Text Markup Language',
            },
            {
              'question': 'Which HTML tag is used for creating a hyperlink?',
              'options': ['<link>', '<a>', '<href>', '<url>'],
              'correctAnswer': '<a>',
            },
            {
              'question': 'What is the correct HTML element for inserting a line break?',
              'options': ['<break>', '<br>', '<lb>', '<newline>'],
              'correctAnswer': '<br>',
            },
            {
              'question': 'Which attribute is used to provide alternative text for an image?',
              'options': ['title', 'alt', 'src', 'text'],
              'correctAnswer': 'alt',
            },
            {
              'question': 'What is the correct HTML for making a text bold?',
              'options': ['<b>', '<bold>', '<strong>', 'Both <b> and <strong>'],
              'correctAnswer': 'Both <b> and <strong>',
            },
          ],
        },
        {
          'title': 'CSS Fundamentals',
          'description': 'Learn and test your understanding of CSS styling, selectors, and properties.',
          'category': 'Web Development',
          'difficulty': 'Beginner',
          'passingScore': 70,
          'timeLimit': 300,
          'pointsReward': 100,
          'coinsReward': 50,
          'isHidden': false,
          'questions': [
            {
              'question': 'What does CSS stand for?',
              'options': ['Cascading Style Sheets', 'Computer Style Sheets', 'Creative Style Sheets', 'Colorful Style Sheets'],
              'correctAnswer': 'Cascading Style Sheets',
            },
            {
              'question': 'Which CSS property is used to change the text color?',
              'options': ['text-color', 'font-color', 'color', 'text-style'],
              'correctAnswer': 'color',
            },
            {
              'question': 'How do you add a background color in CSS?',
              'options': ['bg-color:', 'background-color:', 'color:', 'bgcolor:'],
              'correctAnswer': 'background-color:',
            },
            {
              'question': 'Which CSS property controls the text size?',
              'options': ['font-size', 'text-size', 'font-style', 'text-style'],
              'correctAnswer': 'font-size',
            },
            {
              'question': 'How do you make text bold in CSS?',
              'options': ['font-weight: bold', 'text-style: bold', 'font: bold', 'text-weight: bold'],
              'correctAnswer': 'font-weight: bold',
            },
          ],
        },
        {
          'title': 'JavaScript Introduction',
          'description': 'Master JavaScript basics including variables, functions, and control structures.',
          'category': 'Programming',
          'difficulty': 'Intermediate',
          'passingScore': 70,
          'timeLimit': 420, // 7 minutes
          'pointsReward': 150,
          'coinsReward': 75,
          'isHidden': false,
          'questions': [
            {
              'question': 'Which keyword is used to declare a constant in JavaScript?',
              'options': ['var', 'let', 'const', 'constant'],
              'correctAnswer': 'const',
            },
            {
              'question': 'What is the correct syntax for a JavaScript function?',
              'options': ['function myFunction()', 'def myFunction()', 'func myFunction()', 'function: myFunction()'],
              'correctAnswer': 'function myFunction()',
            },
            {
              'question': 'How do you write "Hello World" in an alert box?',
              'options': ['alert("Hello World")', 'msg("Hello World")', 'alertBox("Hello World")', 'msgBox("Hello World")'],
              'correctAnswer': 'alert("Hello World")',
            },
            {
              'question': 'Which operator is used to assign a value to a variable?',
              'options': ['=', '==', '===', ':='],
              'correctAnswer': '=',
            },
            {
              'question': 'What will "typeof null" return in JavaScript?',
              'options': ['"null"', '"undefined"', '"object"', '"number"'],
              'correctAnswer': '"object"',
            },
          ],
        },
      ];

      for (var quizData in quizzes) {
        final quizId = _uuid.v4();
        final questions = quizData['questions'] as List;
        
        // Create quiz document
        await _firestore
            .collection(FirebaseCollections.quizzes)
            .doc(quizId)
            .set({
          'quizId': quizId,
          'title': quizData['title'],
          'description': quizData['description'],
          'category': quizData['category'],
          'difficulty': quizData['difficulty'],
          'passingScore': quizData['passingScore'],
          'timeLimit': quizData['timeLimit'],
          'pointsReward': quizData['pointsReward'],
          'coinsReward': quizData['coinsReward'],
          'isHidden': quizData['isHidden'],
          'totalQuestions': questions.length,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });

        // Create question documents
        for (var i = 0; i < questions.length; i++) {
          final questionData = questions[i] as Map<String, dynamic>;
          final questionId = _uuid.v4();
          
          await _firestore
              .collection(FirebaseCollections.quizzes)
              .doc(quizId)
              .collection('questions')
              .doc(questionId)
              .set({
            'questionId': questionId,
            'quizId': quizId,
            'question': questionData['question'],
            'options': questionData['options'],
            'correctAnswer': questionData['correctAnswer'],
            'order': i + 1,
            'createdAt': FieldValue.serverTimestamp(),
          });
        }
        
        print('✅ Seeded quiz: ${quizData['title']} with ${questions.length} questions');
      }
      
      print('🎯 Quizzes seeded successfully!');
    } catch (e) {
      print('❌ Error seeding quizzes: $e');
    }
  }

  /// Seed sample courses
  Future<void> seedCourses() async {
    try {
      print('📚 Seeding courses...');
      
      final courses = [
        {
          'title': 'Complete Web Development',
          'description': 'Learn HTML, CSS, and JavaScript from scratch to build modern websites.',
          'category': 'Web Development',
          'level': 'Beginner',
          'duration': 40, // hours
          'price': 0, // Free
          'instructor': 'John Doe',
          'imageUrl': 'https://picsum.photos/seed/webdev/400/300',
          'rating': 4.8,
          'studentsEnrolled': 1234,
          'modules': [
            {'title': 'HTML Basics', 'duration': 120, 'isCompleted': false},
            {'title': 'CSS Styling', 'duration': 150, 'isCompleted': false},
            {'title': 'JavaScript Fundamentals', 'duration': 180, 'isCompleted': false},
          ],
        },
        {
          'title': 'Flutter App Development',
          'description': 'Build beautiful mobile apps with Flutter and Dart programming language.',
          'category': 'Mobile Development',
          'level': 'Intermediate',
          'duration': 50,
          'price': 0,
          'instructor': 'Jane Smith',
          'imageUrl': 'https://picsum.photos/seed/flutter/400/300',
          'rating': 4.9,
          'studentsEnrolled': 856,
          'modules': [
            {'title': 'Dart Programming', 'duration': 180, 'isCompleted': false},
            {'title': 'Flutter Widgets', 'duration': 200, 'isCompleted': false},
            {'title': 'State Management', 'duration': 150, 'isCompleted': false},
          ],
        },
      ];

      for (var courseData in courses) {
        final courseId = _uuid.v4();
        
        await _firestore
            .collection(FirebaseCollections.courses)
            .doc(courseId)
            .set({
          'courseId': courseId,
          'title': courseData['title'],
          'description': courseData['description'],
          'category': courseData['category'],
          'level': courseData['level'],
          'duration': courseData['duration'],
          'price': courseData['price'],
          'instructor': courseData['instructor'],
          'imageUrl': courseData['imageUrl'],
          'rating': courseData['rating'],
          'studentsEnrolled': courseData['studentsEnrolled'],
          'modules': courseData['modules'],
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Seeded course: ${courseData['title']}');
      }
      
      print('📚 Courses seeded successfully!');
    } catch (e) {
      print('❌ Error seeding courses: $e');
    }
  }

  /// Seed achievements
  Future<void> seedAchievements() async {
    try {
      print('🏆 Seeding achievements...');
      
      final achievements = [
        {
          'title': 'First Steps',
          'description': 'Complete your first quiz',
          'category': 'Quiz',
          'requirement': 1,
          'rarity': 1, // Common
          'pointsReward': 50,
          'iconName': 'quiz',
        },
        {
          'title': 'Quiz Master',
          'description': 'Complete 10 quizzes',
          'category': 'Quiz',
          'requirement': 10,
          'rarity': 2, // Rare
          'pointsReward': 200,
          'iconName': 'quiz',
        },
        {
          'title': 'Knowledge Seeker',
          'description': 'Enroll in your first course',
          'category': 'Course',
          'requirement': 1,
          'rarity': 1,
          'pointsReward': 50,
          'iconName': 'school',
        },
        {
          'title': 'Point Collector',
          'description': 'Earn 500 points',
          'category': 'Points',
          'requirement': 500,
          'rarity': 2,
          'pointsReward': 100,
          'iconName': 'star',
        },
        {
          'title': 'Streak Champion',
          'description': 'Maintain a 7-day streak',
          'category': 'Streak',
          'requirement': 7,
          'rarity': 3, // Epic
          'pointsReward': 300,
          'iconName': 'local_fire_department',
        },
      ];

      for (var achievementData in achievements) {
        final achievementId = _uuid.v4();
        
        await _firestore
            .collection(FirebaseCollections.achievements)
            .doc(achievementId)
            .set({
          'achievementId': achievementId,
          'title': achievementData['title'],
          'description': achievementData['description'],
          'category': achievementData['category'],
          'requirement': achievementData['requirement'],
          'rarity': achievementData['rarity'],
          'pointsReward': achievementData['pointsReward'],
          'iconName': achievementData['iconName'],
          'createdAt': FieldValue.serverTimestamp(),
        });
        
        print('✅ Seeded achievement: ${achievementData['title']}');
      }
      
      print('🏆 Achievements seeded successfully!');
    } catch (e) {
      print('❌ Error seeding achievements: $e');
    }
  }

  /// Clear all seeded data (for testing)
  Future<void> clearAllData() async {
    try {
      print('🗑️ Clearing all seeded data...');
      
      // Delete quizzes and their questions
      final quizSnapshot = await _firestore
          .collection(FirebaseCollections.quizzes)
          .get();
      
      for (var doc in quizSnapshot.docs) {
        // Delete questions subcollection
        final questionsSnapshot = await doc.reference
            .collection('questions')
            .get();
        
        for (var questionDoc in questionsSnapshot.docs) {
          await questionDoc.reference.delete();
        }
        
        // Delete quiz document
        await doc.reference.delete();
      }
      
      // Delete courses
      final courseSnapshot = await _firestore
          .collection(FirebaseCollections.courses)
          .get();
      
      for (var doc in courseSnapshot.docs) {
        await doc.reference.delete();
      }
      
      // Delete achievements
      final achievementSnapshot = await _firestore
          .collection(FirebaseCollections.achievements)
          .get();
      
      for (var doc in achievementSnapshot.docs) {
        await doc.reference.delete();
      }
      
      print('✅ All seeded data cleared successfully!');
    } catch (e) {
      print('❌ Error clearing data: $e');
    }
  }
}
