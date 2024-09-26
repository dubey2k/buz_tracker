import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/DropdownWidget.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:flutter/material.dart';

class CreateProject extends StatefulWidget {
  const CreateProject({super.key});

  @override
  State<CreateProject> createState() => _CreateProjectState();
}

class _CreateProjectState extends State<CreateProject> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  ProjectStatus _status = ProjectStatus.Pending;

  ScreenStatus _screenStatus = OkStatus();
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      status: _screenStatus,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const TextWidget(
            size: 18,
            text: "Create Project",
            wt: FontWeight.w700,
          ),
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextInput(controller: _titleController, title: "Title"),
              TextInput(
                  controller: _descriptionController, title: "Desctiption"),
              const SizedBox(height: 20),
              const TextWidget(size: 16, text: "Status", wt: FontWeight.w600),
              const SizedBox(height: 5),
              DropdownWidget(
                choices: ProjectStatus.values.map((status) {
                  return status.name;
                }).toList(),
                onChange: (String value) {
                  _status = ProjectStatus.values.byName(value);
                },
              ),
              const Spacer(),
              ElevationButton(
                onTap: () async {
                  try {
                    final title = _titleController.text.trim();
                    final description = _titleController.text.trim();
                    if (title.length < 4) {
                      throw ErrorDescription(
                          "Project name should be greater then 3 characters");
                    }

                    setState(() {
                      _screenStatus = LoadingStatus(toBlur: true);
                    });

                    final user = UserService.getUser();

                    await DBService().createProject(
                      title.trim(),
                      description.trim(),
                      _status,
                      user!.id,
                      user.organisationId!,
                    );

                    Navigator.pop(context);
                    _screenStatus = OkStatus();
                  } catch (e) {
                    showSnakbar(e.toString(), context);
                    _screenStatus = OkStatus();
                  }
                  setState(() {});
                },
                backgroundColor: primaryColor,
                text: const TextWidget(
                  size: 20,
                  text: "Create Project",
                  wt: FontWeight.bold,
                  color: pWhiteColor,
                ),
              ),
              const SizedBox(height: 50),
            ],
          ),
        ),
      ),
    );
  }
}
