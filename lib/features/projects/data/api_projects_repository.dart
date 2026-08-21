import 'package:dio/dio.dart';

import '../../../core/errors/failure.dart';
import '../domain/project.dart';
import '../domain/project_detail.dart';
import '../domain/projects_repository.dart';

/// Real backend implementation — used when USE_MOCK_API=false.
class ApiProjectsRepository implements ProjectsRepository {
  ApiProjectsRepository(this._dio);

  final Dio _dio;

  @override
  Future<List<Project>> getProjects() async {
    final response = await _guard(() => _dio.get<List<dynamic>>('/projects'));
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((json) => Project.fromJson(_normalizeId(json)))
        .toList();
  }

  @override
  Future<Project> createProject({required String name, String? description}) async {
    final response = await _guard(
      () => _dio.post<Map<String, dynamic>>(
        '/projects',
        data: {'name': name, if (description != null) 'description': description},
      ),
    );
    return Project.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<Project> updateProject(Project project) async {
    final response = await _guard(
      () => _dio.patch<Map<String, dynamic>>(
        '/projects/${project.id}',
        data: {
          'name': project.name,
          if (project.description != null) 'description': project.description,
        },
      ),
    );
    return Project.fromJson(_normalizeId(response.data ?? const {}));
  }

  @override
  Future<void> deleteProject(String id) async {
    await _guard(() => _dio.delete<void>('/projects/$id'));
  }

  @override
  Future<ProjectDetail> getProjectDetail(String id) async {
    final response =
        await _guard(() => _dio.get<Map<String, dynamic>>('/projects/$id'));
    return ProjectDetail.fromJson(response.data ?? const {});
  }

  @override
  Future<void> linkNote({required String projectId, required String noteId}) {
    return _setNoteProject(noteId, projectId);
  }

  @override
  Future<void> unlinkNote({required String noteId}) {
    return _setNoteProject(noteId, null);
  }

  @override
  Future<void> linkGoal({required String projectId, required String goalId}) {
    return _setGoalProject(goalId, projectId);
  }

  @override
  Future<void> unlinkGoal({required String goalId}) {
    return _setGoalProject(goalId, null);
  }

  Future<void> _setNoteProject(String noteId, String? projectId) async {
    await _guard(
      () => _dio.patch<void>(
        '/notes/$noteId',
        data: {'projectId': projectId == null ? null : int.tryParse(projectId)},
      ),
    );
  }

  Future<void> _setGoalProject(String goalId, String? projectId) async {
    await _guard(
      () => _dio.patch<void>(
        '/goals/$goalId',
        data: {'projectId': projectId == null ? null : int.tryParse(projectId)},
      ),
    );
  }

  Future<Response<T>> _guard<T>(Future<Response<T>> Function() call) async {
    try {
      return await call();
    } on DioException catch (e) {
      throw AppFailure(_describe(e), cause: e);
    }
  }

  String _describe(DioException e) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout) {
      return 'Could not reach AURA. Check your connection.';
    }
    return 'AURA backend request failed (${e.response?.statusCode ?? 'no response'}).';
  }
}

/// Backend ids are integers; the Dart models use String ids.
Map<String, dynamic> _normalizeId(Map<String, dynamic> json) => {
      ...json,
      'id': json['id'].toString(),
    };
