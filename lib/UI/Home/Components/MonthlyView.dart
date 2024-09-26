import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/MonthlyExpenseModel.dart';
import 'package:buz_tracker/provider/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class MonthlyView extends StatefulWidget {
  const MonthlyView({super.key});

  @override
  State<MonthlyView> createState() => _MonthlyViewState();
}

class _MonthlyViewState extends State<MonthlyView> {
  ScreenStatus _status = OkStatus();

  DateTime selDay = DateTime.now();
  List<MonthlyExpenseModel> monthList = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    try {
      final pro = context.read<HomeProvider>();
      if (pro.monthlyKeyExists(selDay)) {
        final data = pro.getFromMonthlyMap(selDay);
        if (data != null) {
          monthList = data;
        } else {
          _status = ErrorStatus("No Data");
        }
      } else {
        setState(() {
          _status = LoadingStatus(toBlur: true);
        });
        final user = UserService.getUser();
        final res = await DBService().expenseMonthlyNumber(
          [UserType.Admin.name, UserType.Owner.name]
              .contains(user?.rwp?.first.role),
          user!.organisationId!,
          user.id,
          selDay,
        );

        if (res.isNotEmpty) {
          monthList =
              res.map((ele) => MonthlyExpenseModel.fromJson(ele)).toList();
          pro.addIntoMonthlyMap(selDay, monthList);
        } else {
          monthList = [];
        }
      }
    } catch (e) {
      showSnakbar(e.toString(), context);
    }
    setState(() {
      _status = OkStatus();
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = UserService.getUser();
    return ScreenWrapper(
      status: _status,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
              decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(2, 2),
                      color: Color.fromARGB(255, 238, 238, 238),
                      blurRadius: 5,
                      spreadRadius: 2,
                    )
                  ]),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () async {
                      _status = LoadingStatus(toBlur: true);
                      selDay = selDay.subtract(const Duration(days: 30));
                      await fetch();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: const Center(
                        child: Icon(Icons.keyboard_arrow_left),
                      ),
                    ),
                  ),
                  Expanded(
                      child: TextWidget(
                    size: 20,
                    text: DateFormat("MMM, yyyy").format(selDay),
                    wt: FontWeight.bold,
                    align: TextAlign.center,
                  )),
                  GestureDetector(
                    onTap: () async {
                      if (selDay.year <= DateTime.now().year &&
                          selDay.month < DateTime.now().month) {
                        _status = LoadingStatus(toBlur: true);
                        selDay = selDay.add(const Duration(days: 30));
                        await fetch();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 20, horizontal: 10),
                      child: const Center(
                        child: Icon(Icons.keyboard_arrow_right),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                child: DataTable(
                  dataRowMaxHeight: 35,
                  dataRowMinHeight: 35,
                  columnSpacing: 35,
                  border: TableBorder.all(
                    borderRadius: BorderRadius.circular(10),
                    width: 1,
                    color: Colors.grey,
                  ),
                  columns: [
                    const DataColumn(
                      label: Expanded(
                        child: TextWidget(
                          size: 16,
                          text: "Date",
                          wt: FontWeight.w700,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                    const DataColumn(
                      label: Expanded(
                        child: TextWidget(
                          size: 16,
                          text: "Your Expense",
                          wt: FontWeight.w700,
                          align: TextAlign.center,
                        ),
                      ),
                    ),
                    if ([UserType.Admin.name, UserType.Owner.name]
                        .contains(user?.rwp?.first.role)) ...[
                      const DataColumn(
                        label: Expanded(
                          child: TextWidget(
                            size: 16,
                            text: "Org. Expense",
                            wt: FontWeight.w700,
                          ),
                        ),
                      ),
                    ]
                  ],
                  rows: monthList
                      .map(
                        (ele) => DataRow(
                          cells: [
                            DataCell(TextWidget(
                                size: 16,
                                text: DateFormat("dd/MM/yyyy")
                                    .format(ele.forDate))),
                            DataCell(TextWidget(
                                size: 16, text: "₹ ${ele.userExpense}")),
                            if ([UserType.Admin.name, UserType.Owner.name]
                                .contains(user?.rwp?.first.role)) ...[
                              DataCell(TextWidget(
                                  size: 16, text: "₹ ${ele.orgExpense}")),
                            ]
                          ],
                        ),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
