import 'package:flutter_test/flutter_test.dart';
import 'package:study_notebook/core/models/models.dart';

void main() {
  group('Search filtering', () {
    final courses = [
      Course(
        id: '1',
        userId: 'u1',
        name: 'Mathematics',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      Course(
        id: '2',
        userId: 'u1',
        name: 'Physics',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      Course(
        id: '3',
        userId: 'u1',
        name: 'Computer Science',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ];

    final notebooks = [
      Notebook(
        id: 'n1',
        courseId: '1',
        userId: 'u1',
        title: 'Algebra Notes',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      Notebook(
        id: 'n2',
        courseId: '1',
        userId: 'u1',
        title: 'Calculus Homework',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
      Notebook(
        id: 'n3',
        courseId: '2',
        userId: 'u1',
        title: 'Quantum Physics',
        createdAt: DateTime(2024),
        updatedAt: DateTime(2024),
      ),
    ];

    test('empty query returns all courses', () {
      const query = '';
      final filtered = query.isEmpty
          ? courses
          : courses
              .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
              .toList();
      expect(filtered.length, 3);
    });

    test('filters courses by name (case-insensitive)', () {
      const query = 'math';
      final filtered = courses
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Mathematics');
    });

    test('filters courses with partial match', () {
      const query = 'sci';
      final filtered = courses
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.name, 'Computer Science');
    });

    test('no match returns empty list', () {
      const query = 'biology';
      final filtered = courses
          .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
          .toList();
      expect(filtered, isEmpty);
    });

    test('empty query returns all notebooks', () {
      const query = '';
      final filtered = query.isEmpty
          ? notebooks
          : notebooks
              .where(
                  (n) => n.title.toLowerCase().contains(query.toLowerCase()))
              .toList();
      expect(filtered.length, 3);
    });

    test('filters notebooks by title (case-insensitive)', () {
      const query = 'algebra';
      final filtered = notebooks
          .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      expect(filtered.length, 1);
      expect(filtered.first.title, 'Algebra Notes');
    });

    test('filters notebooks with partial match across multiple results', () {
      const query = 'a';
      final filtered = notebooks
          .where((n) => n.title.toLowerCase().contains(query.toLowerCase()))
          .toList();
      // 'Algebra Notes', 'Calculus Homework', 'Quantum Physics'
      expect(filtered.length, 3);
    });
  });
}
