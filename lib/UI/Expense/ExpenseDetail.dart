import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/Expense/CreateExpense.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/ExpenseModel.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ExpenseDetail extends StatefulWidget {
  final ExpenseModel expense;
  const ExpenseDetail({super.key, required this.expense});

  @override
  State<ExpenseDetail> createState() => _ExpenseDetailState();
}

class _ExpenseDetailState extends State<ExpenseDetail> {
  late final TextEditingController _titleCon;
  late final TextEditingController _amountCon;
  late final TextEditingController _descriptionCon;

  @override
  void initState() {
    super.initState();
    _titleCon = TextEditingController(text: widget.expense.title);
    _amountCon = TextEditingController(text: widget.expense.amount.toString());
    _descriptionCon = TextEditingController(text: widget.expense.description);
  }

  DateTime _selDate = DateTime.now();

  ProjectDropdownModel? _selProject;

  bool editMode = false;

  ScreenStatus _screenStatus = OkStatus();

  final user = UserService.getUser();
  @override
  Widget build(BuildContext context) {
    return ScreenWrapper(
      status: _screenStatus,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: TextWidget(
            size: 18,
            text: widget.expense.title,
            wt: FontWeight.w700,
          ),
          leading: const BackButton(),
          actions: [
            GestureDetector(
              onTap: () async {
                if (editMode) {
                  setState(() {
                    _screenStatus = LoadingStatus(toBlur: true);
                  });
                  try {
                    String title = _titleCon.text.trim();
                    String description = _descriptionCon.text.trim();
                    double? amount = _amountCon.text.trim() == ""
                        ? null
                        : double.parse(_amountCon.text.trim());

                    if ((title.length > 4 && title != widget.expense.title) ||
                        (_selProject != null &&
                            _selProject!.name != widget.expense.projectName) ||
                        (amount != null &&
                            amount >= 0 &&
                            amount != widget.expense.amount) ||
                        (description != widget.expense.description) ||
                        (_selDate
                                .difference(
                                    DateTime.parse(widget.expense.forDate))
                                .inDays) !=
                            0) {
                      await DBService().editExpense(
                        widget.expense.id,
                        title: title,
                        description: description,
                        amount: amount,
                        createdBy: user!.id,
                        projectId: _selProject?.id,
                        forDate: _selDate,
                      );

                      showSnakbar("Updated!", context);
                      Navigator.pop(context);
                    } else {
                      showSnakbar("Provide valid inputs", context);
                    }
                    setState(() {
                      _screenStatus = OkStatus();
                    });
                  } catch (e) {
                    showSnakbar(e.toString(), context);
                    setState(() {
                      _screenStatus = OkStatus();
                    });
                  }
                } else {
                  setState(() {
                    editMode = !editMode;
                  });
                }
              },
              child: Icon(editMode ? Icons.check : Icons.edit),
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
                hint: widget.expense.title,
                readOnly: !editMode,
              ),
              TextInput(
                controller: _amountCon,
                title: "Amount",
                hint: widget.expense.amount.toString(),
                readOnly: !editMode,
              ),
              TextInput(
                controller: null,
                title: "Date",
                readOnly: true,
                hint: DateFormat('dd/MM/yyyy hh:mm aa').format(_selDate),
                onTap: editMode
                    ? () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate:
                              DateTime.now().subtract(const Duration(days: 30)),
                          lastDate: DateTime.now(),
                        );

                        _selDate = date ?? _selDate;
                      }
                    : null,
              ),
              const SizedBox(height: 20),
              const TextWidget(size: 16, text: "Project", wt: FontWeight.w600),
              const SizedBox(height: 5),
              IgnorePointer(
                ignoring: !editMode,
                child: DropdownSearch<ProjectDropdownModel>(
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
                      hintText: widget.expense.projectName,
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
              ),
              TextInput(
                controller: _descriptionCon,
                title: "Description",
                hint: widget.expense.description,
                readOnly: !editMode,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
