// ignore_for_file: public_member_api_docs, sort_constructors_first
class AllState {
  final bool isLoading;
  final String errorMessage;
  const AllState({this.isLoading = false, this.errorMessage = ''});

  AllState copyWith({
    bool? isLoading,
    String? errorMessage,
  }) {
    return AllState(
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}
