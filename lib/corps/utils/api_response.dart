/// Wrapper générique pour ApiResponseFormat du backend.
/// { statusCode, success, error, data }
class ApiResponse<T> {
  final int? statusCode;
  final bool success;
  final String? error;
  final T? data;

  const ApiResponse({
    this.statusCode,
    required this.success,
    this.error,
    this.data,
  });

  bool get hasData => success && data != null;
  bool get hasError => !success || error != null;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) fromJsonT,
  ) {
    return ApiResponse(
      statusCode: json['statusCode'] as int?,
      success: json['success'] as bool? ?? false,
      error: json['error'] as String?,
      data: json['data'] != null ? fromJsonT(json['data']) : null,
    );
  }
}

/// Wrapper pour PageResponse du backend.
/// { content, page, size, totalElements, totalPages, last }
class PageResponse<T> {
  final List<T> content;
  final int page;
  final int size;
  final int totalElements;
  final int totalPages;
  final bool last;

  const PageResponse({
    required this.content,
    required this.page,
    required this.size,
    required this.totalElements,
    required this.totalPages,
    required this.last,
  });

  bool get isFirst => page == 0;
  bool get hasMore => !last;

  factory PageResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PageResponse(
      content: (json['content'] as List? ?? [])
          .map((e) => fromJsonT(e as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int? ?? 0,
      size: json['size'] as int? ?? 0,
      totalElements: (json['totalElements'] as num?)?.toInt() ?? 0,
      totalPages: json['totalPages'] as int? ?? 0,
      last: json['last'] as bool? ?? false,
    );
  }
}
