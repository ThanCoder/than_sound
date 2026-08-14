import 'package:than_sound/ui_platforms/ui/partials/sort_provider.dart';

class AllState {
  final bool isLoading;
  final String errorMessage;
  final SortItem currentSort;
  const AllState({
    required this.isLoading,
    required this.errorMessage,
    required this.currentSort,
  });
  factory AllState.empty() {
    return AllState(
      isLoading: false,
      errorMessage: '',
      currentSort: SortItem.dateSortItem,
    );
  }

  AllState copyWith({
    bool? isLoading,
    String? errorMessage,
    SortItem? currentSort,
  }) {
    return AllState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
      currentSort: currentSort ?? this.currentSort,
    );
  }
}
