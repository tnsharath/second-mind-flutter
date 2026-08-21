import 'project.dart';
import 'project_detail.dart';

abstract class ProjectsRepository {
  Future<List<Project>> getProjects();

  Future<Project> createProject({required String name, String? description});

  Future<Project> updateProject(Project project);

  Future<void> deleteProject(String id);

  Future<ProjectDetail> getProjectDetail(String id);

  /// PATCH /notes/{noteId} {projectId}
  Future<void> linkNote({required String projectId, required String noteId});

  /// PATCH /goals/{goalId} {projectId}
  Future<void> linkGoal({required String projectId, required String goalId});

  /// PATCH /notes/{noteId} {projectId: null}
  Future<void> unlinkNote({required String noteId});

  /// PATCH /goals/{goalId} {projectId: null}
  Future<void> unlinkGoal({required String goalId});
}
