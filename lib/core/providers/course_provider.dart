import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import 'package:study_notebook/core/models/models.dart';
import 'package:study_notebook/core/storage/storage.dart';
import 'package:study_notebook/features/auth/auth_provider.dart';
import 'package:study_notebook/features/auth/auth_state.dart';

/// Manages the list of [Course]s for the current user.
class CourseNotifier extends StateNotifier<AsyncValue<List<Course>>> {
  final CourseDao _dao;
  final String _userId;

  CourseNotifier(this._dao, this._userId) : super(const AsyncValue.loading()) {
    loadCourses();
  }

  /// Fetches all courses for the current user from the local database.
  Future<void> loadCourses() async {
    state = const AsyncValue.loading();
    final result = await _dao.getAll(_userId);
    switch (result) {
      case Success(data: final courses):
        state = AsyncValue.data(courses);
      case Failure(message: final msg):
        state = AsyncValue.error(msg, StackTrace.current);
    }
  }

  /// Creates a new course and prepends it to the current list.
  Future<Result<Course>> createCourse(String name, String? color) async {
    final now = DateTime.now();
    final course = Course(
      id: const Uuid().v4(),
      userId: _userId,
      name: name,
      color: color,
      createdAt: now,
      updatedAt: now,
    );
    final result = await _dao.insert(course);
    switch (result) {
      case Success():
        state.whenData((courses) {
          state = AsyncValue.data([course, ...courses]);
        });
        return Success(course);
      case Failure(message: final msg, error: final err):
        return Failure(msg, err);
    }
  }

  /// Updates an existing course and patches the in-memory list.
  Future<Result<void>> updateCourse(Course course) async {
    final updated = course.copyWith(updatedAt: DateTime.now());
    final result = await _dao.update(updated);
    if (result is Success) {
      state.whenData((courses) {
        state = AsyncValue.data(
          courses.map((c) => c.id == updated.id ? updated : c).toList(),
        );
      });
    }
    return result;
  }

  /// Deletes a course by its ID and removes it from the in-memory list.
  Future<Result<void>> deleteCourse(String courseId) async {
    final result = await _dao.delete(courseId);
    if (result is Success) {
      state.whenData((courses) {
        state =
            AsyncValue.data(courses.where((c) => c.id != courseId).toList());
      });
    }
    return result;
  }
}

/// Provides the list of courses for the currently authenticated user.
final courseProvider =
    StateNotifierProvider<CourseNotifier, AsyncValue<List<Course>>>((ref) {
  final authState = ref.watch(authProvider);
  final userId = switch (authState) {
    AuthAuthenticated(user: final u) => u.id,
    _ => '',
  };
  return CourseNotifier(CourseDao(), userId);
});
