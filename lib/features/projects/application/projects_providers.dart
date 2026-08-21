import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/env.dart';
import '../../../core/providers/providers.dart';
import '../data/api_projects_repository.dart';
import '../data/mock_projects_repository.dart';
import '../domain/project.dart';
import '../domain/project_detail.dart';
import '../domain/projects_repository.dart';

final projectsRepositoryProvider = Provider<ProjectsRepository>(
  (ref) => Env.useMockApi
      ? MockProjectsRepository()
      : ApiProjectsRepository(ref.watch(dioProvider)),
);

final projectsProvider = AsyncNotifierProvider<ProjectsController, List<Project>>(
  ProjectsController.new,
);

class ProjectsController extends AsyncNotifier<List<Project>> {
  ProjectsRepository get _repository => ref.read(projectsRepositoryProvider);

  @override
  Future<List<Project>> build() => _repository.getProjects();

  Future<void> createProject(String name, String? description) async {
    final created = await _repository.createProject(
      name: name,
      description: description,
    );
    state = AsyncData([...state.valueOrNull ?? const <Project>[], created]);
  }

  Future<void> updateProject(Project project) async {
    final updated = await _repository.updateProject(project);
    final current = state.valueOrNull ?? const <Project>[];
    state = AsyncData([
      for (final p in current)
        if (p.id == updated.id) updated else p,
    ]);
  }

  /// Optimistic delete with rollback on failure.
  Future<void> deleteProject(Project project) async {
    final current = state.valueOrNull ?? const <Project>[];
    state = AsyncData(current.where((p) => p.id != project.id).toList());
    try {
      await _repository.deleteProject(project.id);
    } catch (_) {
      state = AsyncData(current);
    }
  }
}

final projectDetailProvider =
    FutureProvider.family<ProjectDetail, String>(
  (ref, id) => ref.watch(projectsRepositoryProvider).getProjectDetail(id),
);
