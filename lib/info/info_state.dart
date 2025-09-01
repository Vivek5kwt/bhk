class InfoState {
  final bool loading;
  final String? content;
  final String? error;

  const InfoState({this.loading = false, this.content, this.error});

  InfoState copyWith({bool? loading, String? content, String? error}) {
    return InfoState(
      loading: loading ?? this.loading,
      content: content ?? this.content,
      error: error ?? this.error,
    );
  }
}
