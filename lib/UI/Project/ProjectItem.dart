import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Project/ProjectDetail.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/ProjectModel.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';

class ProjectItem extends StatelessWidget {
  final ProjectModel project;
  const ProjectItem({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProjectDetail(project: project),
          ),
        )
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 8),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              project.status == ProjectStatus.Completed.name
                  ? "assets/svgs/completed_icon.svg"
                  : project.status == ProjectStatus.Ongoing.name
                      ? "assets/svgs/processing.svg"
                      : "assets/svgs/pending_icon.svg",
              height: 50,
              width: 50,
            ),
            // const Icon(Icons.check_circle, size: 50),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextWidget(
                    size: 20,
                    text: project.name,
                    wt: FontWeight.bold,
                  ),
                  TextWidget(
                      size: 18, text: project.status, wt: FontWeight.w500),
                  TextWidget(
                      size: 14,
                      text: DateFormat('dd/MM/yyyy')
                          .format(DateTime.parse(project.createdAt)))
                ],
              ),
            ),
            if (roleResolver(UserService.getUser()?.rwp?.first,
                PermissionMap["ViewProjectExpense"]["code"])) ...[
              const SizedBox(width: 5),
              Column(
                children: [
                  const SizedBox(height: 30),
                  const TextWidget(
                      size: 18, text: "Expense", wt: FontWeight.w600),
                  TextWidget(
                      size: 20,
                      text: project.totalExpense == null
                          ? "0.0"
                          : project.totalExpense.toString(),
                      wt: FontWeight.bold),
                ],
              ),
            ]
          ],
        ),
      ),
    );
  }
}
