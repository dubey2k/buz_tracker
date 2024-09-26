import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Project/CreateProject.dart';
import 'package:buz_tracker/UI/Project/ProjectItem.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/NoData.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/model/ProjectModel.dart';
import 'package:flutter/material.dart';

class ProjectListScreen extends StatefulWidget {
  const ProjectListScreen({super.key});

  @override
  State<ProjectListScreen> createState() => _ProjectListScreenState();
}

class _ProjectListScreenState extends State<ProjectListScreen>
    with AutomaticKeepAliveClientMixin<ProjectListScreen> {
  List<ProjectModel>? projects;
  ScreenStatus _screenStatus = LoadingStatus();
  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<void> fetchData() async {
    try {
      final user = UserService.getUser();
      final data = await DBService().listProject(user!.organisationId!);
      projects = data.map((value) {
        return ProjectModel.fromJson(value);
      }).toList();
      _screenStatus = OkStatus();
    } catch (e) {
      _screenStatus = ErrorStatus(e.toString());
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateProject()));
        },
        icon: const Icon(Icons.add),
        label: const TextWidget(
            size: 16, text: "Create Project", wt: FontWeight.w500),
      ),
      body: ScreenWrapper(
        status: _screenStatus,
        child: RefreshIndicator(
          onRefresh: fetchData,
          child: getProjectList(),
        ),
      ),
    );
  }

  Widget getProjectList() {
    if (projects == null || projects!.isEmpty) {
      return NoData();
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      itemBuilder: (context, index) {
        final project = projects![index];
        return ProjectItem(project: project);
      },
      itemCount: projects == null ? 0 : projects!.length,
    );
  }

  @override
  bool get wantKeepAlive => true;
}
