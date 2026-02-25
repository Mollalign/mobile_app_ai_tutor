import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/quiz_remote_datasource.dart';

// ============================================================
// Data source provider
// ============================================================

final quizDataSourceProvider = Provider<QuizRemoteDataSource>((ref) {
  return QuizRemoteDataSource();
});

// ============================================================
// Quiz List State
// ============================================================

class QuizListState {
  final bool isLoading;
  final List<Map<String, dynamic>> quizzes;
  final int total;
  final String? error;

  const QuizListState({
    this.isLoading = false,
    this.quizzes = const [],
    this.total = 0,
    this.error,
  });

  QuizListState copyWith({
    bool? isLoading,
    List<Map<String, dynamic>>? quizzes,
    int? total,
    String? error,
  }) {
    return QuizListState(
      isLoading: isLoading ?? this.isLoading,
      quizzes: quizzes ?? this.quizzes,
      total: total ?? this.total,
      error: error,
    );
  }
}

// ============================================================
// Quiz List Notifier (per project)
// ============================================================

class QuizListNotifier extends ChangeNotifier {
  final QuizRemoteDataSource _dataSource;
  final String projectId;
  QuizListState state = const QuizListState(isLoading: true);

  QuizListNotifier(this._dataSource, this.projectId) {
    loadQuizzes();
  }

  Future<void> loadQuizzes({bool refresh = false}) async {
    state = state.copyWith(isLoading: true, error: null);
    notifyListeners();

    try {
      final data = await _dataSource.listQuizzes(projectId);
      final quizzes = (data['quizzes'] as List? ?? [])
          .cast<Map<String, dynamic>>();
      state = QuizListState(
        quizzes: quizzes,
        total: data['total'] as int? ?? quizzes.length,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
    notifyListeners();
  }

  void addQuiz(Map<String, dynamic> quiz) {
    state = state.copyWith(
      quizzes: [quiz, ...state.quizzes],
      total: state.total + 1,
    );
    notifyListeners();
  }

  Future<void> deleteQuiz(String quizId) async {
    try {
      await _dataSource.deleteQuiz(quizId);
      state = state.copyWith(
        quizzes: state.quizzes.where((q) => q['id'] != quizId).toList(),
        total: state.total - 1,
      );
      notifyListeners();
    } catch (e) {
      debugPrint('Failed to delete quiz: $e');
    }
  }
}

final quizListNotifierProvider =
    Provider.family.autoDispose<QuizListNotifier, String>((ref, projectId) {
  final notifier =
      QuizListNotifier(ref.watch(quizDataSourceProvider), projectId);
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

// ============================================================
// Generate Quiz State
// ============================================================

class GenerateQuizNotifier extends ChangeNotifier {
  final QuizRemoteDataSource _dataSource;
  bool isGenerating = false;
  String? error;
  Map<String, dynamic>? generatedQuiz;

  GenerateQuizNotifier(this._dataSource);

  Future<Map<String, dynamic>?> generateQuiz(
    String projectId, {
    int numQuestions = 5,
    String difficulty = 'medium',
    List<String> questionTypes = const ['multiple_choice', 'true_false'],
    String? topicFocus,
  }) async {
    isGenerating = true;
    error = null;
    generatedQuiz = null;
    notifyListeners();

    try {
      final quiz = await _dataSource.generateQuiz(
        projectId,
        numQuestions: numQuestions,
        difficulty: difficulty,
        questionTypes: questionTypes,
        topicFocus: topicFocus,
      );
      generatedQuiz = quiz;
      isGenerating = false;
      notifyListeners();
      return quiz;
    } catch (e) {
      error = e.toString();
      isGenerating = false;
      notifyListeners();
      return null;
    }
  }
}

final generateQuizNotifierProvider =
    Provider.autoDispose<GenerateQuizNotifier>((ref) {
  final notifier = GenerateQuizNotifier(ref.watch(quizDataSourceProvider));
  ref.onDispose(() => notifier.dispose());
  return notifier;
});

// ============================================================
// Take Quiz State
// ============================================================

class TakeQuizNotifier extends ChangeNotifier {
  final QuizRemoteDataSource _dataSource;
  bool isLoading = false;
  bool isSubmitting = false;
  Map<String, dynamic>? quiz;
  Map<String, dynamic>? result;
  String? error;
  final Map<String, dynamic> answers = {};
  DateTime? _startTime;

  TakeQuizNotifier(this._dataSource);

  Future<void> loadQuiz(String quizId) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      quiz = await _dataSource.getQuiz(quizId);
      _startTime = DateTime.now();
      isLoading = false;
      notifyListeners();
    } catch (e) {
      error = e.toString();
      isLoading = false;
      notifyListeners();
    }
  }

  void setAnswer(String questionId, dynamic answer) {
    answers[questionId] = answer;
    notifyListeners();
  }

  int get answeredCount => answers.length;

  int get totalQuestions {
    final questions = quiz?['questions'] as List?;
    return questions?.length ?? 0;
  }

  Future<Map<String, dynamic>?> submitQuiz(String quizId) async {
    isSubmitting = true;
    error = null;
    notifyListeners();

    final timeTaken = _startTime != null
        ? DateTime.now().difference(_startTime!).inSeconds
        : null;

    final answerList = answers.entries.map((e) {
      return {
        'question_id': e.key,
        'user_answer': e.value,
      };
    }).toList();

    try {
      result = await _dataSource.submitQuiz(
        quizId,
        answers: answerList,
        timeTakenSeconds: timeTaken,
      );
      isSubmitting = false;
      notifyListeners();
      return result;
    } catch (e) {
      error = e.toString();
      isSubmitting = false;
      notifyListeners();
      return null;
    }
  }

  void reset() {
    quiz = null;
    result = null;
    error = null;
    answers.clear();
    _startTime = null;
    isLoading = false;
    isSubmitting = false;
    notifyListeners();
  }
}

final takeQuizNotifierProvider =
    Provider.autoDispose<TakeQuizNotifier>((ref) {
  final notifier = TakeQuizNotifier(ref.watch(quizDataSourceProvider));
  ref.onDispose(() => notifier.dispose());
  return notifier;
});
