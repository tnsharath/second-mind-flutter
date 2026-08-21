import '../domain/project.dart';
import '../domain/project_detail.dart';
import '../domain/projects_repository.dart';

/// Serves local dummy projects until the backend /projects endpoint exists.
class MockProjectsRepository implements ProjectsRepository {
  static final List<Project> _projects = [
    Project(
      id: '1',
      name: 'AURA launch',
      description: 'Everything for the public release',
      createdAt: DateTime(2026, 7, 1),
      notesCount: 2,
      goalsCount: 1,
    ),
    Project(
      id: '2',
      name: 'Health reset',
      createdAt: DateTime(2026, 7, 10),
      notesCount: 1,
      goalsCount: 1,
    ),
  ];

  static final Map<String, ProjectDetail> _details = {
    '1': ProjectDetail(
      id: '1',
      name: 'AURA launch',
      description: 'Everything for the public release',
      createdAt: DateTime(2026, 7, 1),
      notes: [
        ProjectNote(id: 'n1', text: 'Draft launch announcement', createdAt: DateTime(2026, 7, 2)),
        ProjectNote(id: 'n2', text: 'Collect beta feedback', kind: 'reminder', done: true),
      ],
      goals: [
        ProjectGoal(id: 'g1', title: 'Ship v1.0 to the store', progress: 60),
      ],
    ),
    '2': ProjectDetail(
      id: '2',
      name: 'Health reset',
      createdAt: DateTime(2026, 7, 10),
      notes: [
        ProjectNote(id: 'n3', text: 'Book a dental check-up', createdAt: DateTime(2026, 7, 11)),
      ],
      goals: [
        ProjectGoal(id: 'g2', title: 'Sleep before midnight', isCompleted: true, progress: 100),
      ],
    ),
  };

  static int _nextId = 3;

  @override
  Future<List<Project>> getProjects() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    return List.unmodifiable(_projects);
  }

  @override
  Future<Project> createProject({required String name, String? description}) async {
    await Future<void>.delayed(const Duration(milliseconds: 200));
    final project = Project(
      id: '${_nextId++}',
      name: name,
      description: description,
      createdAt: DateTime.now(),
    );
    _projects.add(project);
    _details[project.id] = ProjectDetail(
      id: project.id,
      name: project.name,
      description: project.description,
      createdAt: project.createdAt,
    );
    return project;
  }

  @override
  Future<Project> updateProject(Project project) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final index = _projects.indexWhere((p) => p.id == project.id);
    if (index >= 0) _projects[index] = project;
    final detail = _details[project.id];
    if (detail != null) {
      _details[project.id] = detail.copyWith(
        name: project.name,
        description: project.description,
      );
    }
    return project;
  }

  @override
  Future<void> deleteProject(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _projects.removeWhere((p) => p.id == id);
    _details.remove(id);
  }

  @override
  Future<ProjectDetail> getProjectDetail(String id) async {
    await Future<void>.delayed(const Duration(milliseconds: 250));
    final detail = _details[id];
    if (detail == null) {
      throw Exception('Project $id not found');
    }
    return detail;
  }

  @override
  Future<void> linkNote({required String projectId, required String noteId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> linkGoal({required String projectId, required String goalId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> unlinkNote({required String noteId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }

  @override
  Future<void> unlinkGoal({required String goalId}) async {
    await Future<void>.delayed(const Duration(milliseconds: 100));
  }
}
