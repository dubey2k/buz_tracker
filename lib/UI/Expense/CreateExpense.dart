import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class CreateExpense extends StatefulWidget {
  const CreateExpense({super.key});

  @override
  State<CreateExpense> createState() => _CreateExpenseState();
}

class _CreateExpenseState extends State<CreateExpense> {
  final TextEditingController _titleCon = TextEditingController();
  final TextEditingController _amountCon = TextEditingController();
  final TextEditingController _descriptionCon = TextEditingController();

  DateTime? _selDate;

  ProjectDropdownModel? _selProject;

  ScreenStatus _screenStatus = OkStatus();

  final user = UserService.getUser();

  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      status: _screenStatus,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: const TextWidget(
            size: 18,
            text: "Create Expense",
            wt: FontWeight.w700,
          ),
          leading: const BackButton(),
          actions: [
            GestureDetector(
              onTap: () async {
                try {
                  String title = _titleCon.text.trim();
                  String description = _descriptionCon.text.trim();
                  double amount = double.parse(_amountCon.text.trim());

                  if (title.length < 4 ||
                      _selDate == null ||
                      _selProject == null ||
                      amount <= 0) {
                    showToast("Invalid inputs!");
                  } else {
                    setState(() {
                      _screenStatus = LoadingStatus(toBlur: true);
                    });
                    await DBService().createExpense(
                      title,
                      description,
                      amount,
                      user!.id,
                      _selProject!.id,
                      user!.organisationId!,
                      _selDate!,
                    );
                    _screenStatus = OkStatus();
                    Navigator.pop(context);
                  }
                } catch (e) {
                  showToast(e.toString());
                  _screenStatus = OkStatus();
                }
                setState(() {});
              },
              child: const Icon(Icons.check),
            )
          ],
        ),
        body: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 10),
              TextInput(
                controller: _titleCon,
                title: "Title",
                hint: "Enter title of Expense",
              ),
              TextInput(
                controller: _amountCon,
                title: "Amount",
                hint: "Enter amount of Expense",
              ),
              TextInput(
                controller: null,
                title: "Date",
                readOnly: true,
                hint: _selDate == null
                    ? "Select date for Expense"
                    : DateFormat('dd/MM/yyyy').format(_selDate!),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate:
                        DateTime.now().subtract(const Duration(days: 30)),
                    lastDate: DateTime.now(),
                  );

                  setState(() {
                    _selDate = date ?? _selDate;
                  });
                },
              ),
              const SizedBox(height: 20),
              const TextWidget(size: 16, text: "Project", wt: FontWeight.w600),
              const SizedBox(height: 5),
              DropdownSearch<ProjectDropdownModel>(
                filterFn: (item, filter) {
                  return item.name.contains(filter);
                },
                popupProps: const PopupProps.menu(showSearchBox: true),
                itemAsString: (ProjectDropdownModel u) => u.name,
                selectedItem: _selProject,
                asyncItems: (String filter) async {
                  if (user != null) {
                    final res = await DBService()
                        .searchProject(user!.organisationId!, filter);
                    return res.map((json) {
                      return ProjectDropdownModel.fromJson(json);
                    }).toList();
                  } else {
                    return const [];
                  }
                },
                dropdownButtonProps: const DropdownButtonProps(
                  icon: Icon(Icons.keyboard_arrow_down),
                ),
                dropdownDecoratorProps: DropDownDecoratorProps(
                  dropdownSearchDecoration: InputDecoration(
                    filled: true,
                    fillColor: textBackColor,
                    hintStyle: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                    hintText: "Select Project",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                onChanged: (value) {
                  _selProject = value;
                },
              ),
              TextInput(
                controller: _descriptionCon,
                title: "Description",
                hint: "Enter desciption of Expense (optional)",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDropdownModel {
  String name;
  int id;
  ProjectDropdownModel({
    required this.name,
    required this.id,
  });
  factory ProjectDropdownModel.fromJson(Map<String, dynamic> json) =>
      ProjectDropdownModel(id: json["id"], name: json["name"]);
}
