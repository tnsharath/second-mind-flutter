import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/providers.dart';
import '../domain/search_results.dart';

class SearchState {
  const SearchState({
    this.query = '',
    this.results = const AsyncData(SearchResults()),
  });

  final String query;
  final AsyncValue<SearchResults> results;

  /// Queries shorter than this are treated as idle — no request is made.
  static const int minQueryLength = 2;

  bool get isIdle => query.trim().length < minQueryLength;

  SearchState copyWith({
    String? query,
    AsyncValue<SearchResults>? results,
  }) {
    return SearchState(
      query: query ?? this.query,
      results: results ?? this.results,
    );
  }
}

final searchProvider = NotifierProvider<SearchController, SearchState>(
  SearchController.new,
);

/// Debounced universal search against GET /search.
class SearchController extends Notifier<SearchState> {
  static const Duration _debounceDelay = Duration(milliseconds: 300);

  Timer? _debounce;

  @override
  SearchState build() {
    ref.onDispose(() => _debounce?.cancel());
    return const SearchState();
  }

  void setQuery(String raw) {
    _debounce?.cancel();
    final query = raw.trim();
    if (query.length < SearchState.minQueryLength) {
      state = state.copyWith(
        query: raw,
        results: const AsyncData(SearchResults()),
      );
      return;
    }
    state = state.copyWith(query: raw);
    _debounce = Timer(_debounceDelay, () => _search(query));
  }

  Future<void> _search(String query) async {
    state = state.copyWith(results: const AsyncLoading());
    final results = await AsyncValue.guard(() async {
      final response = await ref.read(apiClientProvider).get<Map<String, dynamic>>(
        '/search',
        query: {'q': query},
      );
      return SearchResults.fromJson(response.data ?? const {});
    });
    // A newer query may have arrived while the request was in flight.
    if (state.query.trim() == query) {
      state = state.copyWith(results: results);
    }
  }
}
