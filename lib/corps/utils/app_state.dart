import 'package:monprof/corps/utils/error_model.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first

enum AppStatus { starting, error, loading, data }

class AppState<T> {
  AppStatus status;
  T? data;
  ErrorModel? errorModel;

  AppState({
    this.status = AppStatus.starting,
    this.data,
    this.errorModel,
  });

  AppState copyWith({
    AppStatus? status,
    dynamic data,
    ErrorModel? errorModel,
  }) {
    return AppState(
      status: status ?? this.status,
      data: data ?? this.data,
      errorModel: errorModel ?? this.errorModel,
    );
  }

  @override
  String toString() =>
      'AppState(status: $status, data: $data, errorModel: $errorModel)';

  @override
  bool operator ==(covariant AppState other) {
    if (identical(this, other)) return true;

    return other.status == status &&
        other.data == data &&
        other.errorModel == errorModel;
  }

  bool get hasError => status == AppStatus.error;
  bool get hasData => status == AppStatus.data;
  bool get isLoading => status == AppStatus.loading;

  @override
  int get hashCode => status.hashCode ^ data.hashCode ^ errorModel.hashCode;
}
