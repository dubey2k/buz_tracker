import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/YearlyExpenseModel.dart';
import 'package:buz_tracker/provider/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class YearlyView extends StatefulWidget {
  const YearlyView({super.key});

  @override
  State<YearlyView> createState() => _YearlyViewState();
}

class _YearlyViewState extends State<YearlyView> {
  ScreenStatus _status = OkStatus();

  DateTime selDay = DateTime.now();
  List<YearlyExpenseModel> yearList = [];

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    try {
      final pro = context.read<HomeProvider>();
      if (pro.yearlyKeyExists(selDay)) {
        final data = pro.getFromYearlyMap(selDay);
        if (data != null) {
          yearList = data;
        } else {
          _status = ErrorStatus("No Data");
        }
      } else {
        setState(() {
          _status = LoadingStatus(toBlur: true);
        });
        final user = UserService.getUser();
        final res = await DBService().expenseYearlyNumber(
          [UserType.Admin.name, UserType.Owner.name]
              .contains(user?.rwp?.first.role),
          user!.organisationId!,
          user.id,
          selDay,
        );

        if (res.isNotEmpty) {
          yearList =
              res.map((ele) => YearlyExpenseModel.fromJson(ele)).toList();
          pro.addIntoYearlyMap(selDay, yearList);
        } else {
          yearList = [];
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
                      selDay = selDay.subtract(const Duration(days: 365));
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
                    text: DateFormat("yyyy").format(selDay),
                    wt: FontWeight.bold,
                    align: TextAlign.center,
                  )),
                  GestureDetector(
                    onTap: () async {
                      if (selDay.year < DateTime.now().year) {
                        _status = LoadingStatus(toBlur: true);
                        selDay = selDay.add(const Duration(days: 365));
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
            SingleChildScrollView(
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
                rows: yearList
                    .map(
                      (ele) => DataRow(
                        cells: [
                          DataCell(TextWidget(
                              size: 16,
                              text: DateFormat("dd/MM/yyyy")
                                  .format(ele.yearMonth))),
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
          ],
        ),
      ),
    );
  }
}
