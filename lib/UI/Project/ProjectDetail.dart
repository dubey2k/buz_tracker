import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Expense/ExpenseScreen.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/DropdownWidget.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/ProjectModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ProjectDetail extends StatelessWidget {
  final ProjectModel project;
  const ProjectDetail({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          actions: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (context) {
                    return ProjectEditModal(project: project);
                  },
                );
              },
              child: const Icon(Icons.edit),
            ),
          ],
          title: TextWidget(
            size: 20,
            text: project.name,
            wt: FontWeight.w700,
          ),
          bottom: const TabBar(
            tabs: [
              Tab(
                icon: Icon(Icons.summarize_sharp),
                text: "Overview",
              ),
              Tab(
                icon: Icon(Icons.view_list),
                text: "Expenses",
              ),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Overview(project: project),
            ExpenseListScreen(projectId: project.id),
          ],
        ),
      ),
    );
  }
}

class Overview extends StatelessWidget {
  final ProjectModel project;
  const Overview({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        rowItem("Name", project.name.toString()),
        rowItem("Status", project.status.toString()),
        rowItem("Description", project.description.toString()),
        if (roleResolver(UserService.getUser()?.rwp?.first,
            PermissionMap["ViewProjectExpense"]["code"])) ...[
          rowItem("Total Expense", project.totalExpense.toString())
        ],
        rowItem(
            "Completed On",
            project.completedOn == null
                ? "Pending"
                : DateFormat('dd/MM/yyyy')
                    .format(DateTime.parse(project.completedOn!))),
        rowItem("Created On",
            DateFormat('dd/MM/yyyy').format(DateTime.parse(project.createdAt))),
      ],
    );
  }

  Widget rowItem(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          SizedBox(width: 20),
          Expanded(
            flex: 4,
            child: TextWidget(
              size: 18,
              text: title,
              wt: FontWeight.w600,
            ),
          ),
          const SizedBox(width: 40),
          Expanded(
            flex: 6,
            child: TextWidget(
              size: 18,
              text: value,
            ),
          ),
        ],
      ),
    );
  }
}

class ProjectEditModal extends StatefulWidget {
  final ProjectModel project;
  const ProjectEditModal({super.key, required this.project});

  @override
  State<ProjectEditModal> createState() => _ProjectEditModalState();
}

class _ProjectEditModalState extends State<ProjectEditModal> {
  late TextEditingController _nameCon, _desCon;

  late ProjectStatus _status;
  ScreenStatus _screenStatus = OkStatus();

  DateTime? _selDate;

  @override
  void initState() {
    super.initState();
    _nameCon = TextEditingController(text: widget.project.name);
    _desCon = TextEditingController(text: widget.project.name);
    _status = ProjectStatus.values.byName(widget.project.status);
    _selDate = widget.project.completedOn != null
        ? DateTime.parse(widget.project.completedOn!)
        : null;
  }

  callEditAPI() async {
    try {
      setState(() {
        _screenStatus = LoadingStatus(toBlur: true);
      });
      String name = _nameCon.text.trim();
      if (name.length < 4) {
        throw ErrorDescription("Provide name of more than 3 characters");
      }
      await DBService().editProject(widget.project.id,
          name: name,
          description: _desCon.text.trim(),
          completedOn: _selDate,
          status: _status);
      setState(() {
        _screenStatus = OkStatus();
      });
      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _screenStatus = OkStatus();
      });
      showToast(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      child: ScreenWrapper(
        status: _screenStatus,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                const Expanded(
                    child: TextWidget(
                        size: 20, text: "Edit Project", wt: FontWeight.bold)),
                GestureDetector(
                  onTap: () async {
                    await callEditAPI();
                  },
                  child: const Icon(Icons.check),
                ),
              ],
            ),
            TextInput(controller: _nameCon, title: "Name"),
            const SizedBox(height: 20),
            const TextWidget(size: 16, text: "Status", wt: FontWeight.w600),
            const SizedBox(height: 5),
            DropdownWidget(
                choices: ProjectStatus.values.map((data) {
                  return data.name;
                }).toList(),
                onChange: (value) {
                  _status = ProjectStatus.values.byName(value);
                }),
            TextInput(controller: _desCon, title: "Description"),
            TextInput(
              controller: null,
              title: "Completed On",
              readOnly: true,
              hint: _selDate == null
                  ? "Select Date"
                  : DateFormat('dd/MM/yyyy hh:mm aa').format(_selDate!),
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 30)),
                  lastDate: DateTime.now(),
                );

                _selDate = date ?? _selDate;
              },
            ),
          ],
        ),
      ),
    );
  }
}
