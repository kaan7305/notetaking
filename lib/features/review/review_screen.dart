import 'package:flutter/material.dart';

import 'package:study_notebook/app/colors.dart';

import 'flashcards/flashcard_screen.dart';
import 'quiz/quiz_screen.dart';

/// Review hub with tabs for flashcards and practice quiz.
class ReviewScreen extends StatelessWidget {
  final String courseId;

  const ReviewScreen({super.key, required this.courseId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Review & Study'),
          bottom: const TabBar(
            labelColor: AppColors.primary,
            indicatorColor: AppColors.primary,
            tabs: [
              Tab(icon: Icon(Icons.style), text: 'Flashcards'),
              Tab(icon: Icon(Icons.quiz), text: 'Practice Quiz'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            FlashcardScreen(courseId: courseId),
            QuizScreen(courseId: courseId),
          ],
        ),
      ),
    );
  }
}
