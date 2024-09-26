import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/DailyExpenseModel.dart';
import 'package:buz_tracker/provider/HomeProvider.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class DailyView extends StatefulWidget {
  const DailyView({super.key});

  @override
  State<DailyView> createState() => _DailyViewState();
}

class _DailyViewState extends State<DailyView> {
  ScreenStatus _status = OkStatus();

  DailyExpenseModel dailyModel =
      DailyExpenseModel(userExpense: 0, orgExpense: 0);
  DateTime selDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    fetch();
  }

  fetch() async {
    try {
      final pro = context.read<HomeProvider>();
      if (pro.dailyKeyExists(selDay)) {
        final data = pro.getFromDailyMap(selDay);
        if (data != null) {
          dailyModel = data;
        } else {
          _status = ErrorStatus("No Data");
        }
      } else {
        setState(() {
          _status = LoadingStatus(toBlur: true);
        });
        final user = UserService.getUser();
        final res = await DBService().dayExpenseDetails(
          [UserType.Admin.name, UserType.Owner.name]
              .contains(user?.rwp?.first.role),
          user!.organisationId!,
          user.id,
          selDay,
        );

        if (res.isNotEmpty) {
          dailyModel = DailyExpenseModel.fromJson(res.first);
          pro.addIntoDailyMap(selDay, dailyModel);
        } else {
          _status = EmptyStatus("Something went wrong!");
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
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
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
                    selDay = selDay.subtract(const Duration(days: 1));
                    await fetch();
                  },
                  child: Container(
                    padding: const EdgeInsets.only(right: 12),
                    child: const Center(
                      child: Icon(Icons.keyboard_arrow_left),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    children: [
                      RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          text: "${DateFormat("dd MMM").format(selDay)}\n",
                          style: GoogleFonts.montserrat(
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                              color: Colors.black),
                          children: [
                            TextSpan(
                              text: DateFormat("yyyy").format(selDay),
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w900,
                                fontSize: 28,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Column(
                                children: [
                                  const TextWidget(
                                    size: 12,
                                    text: "Your Expense",
                                    wt: FontWeight.w700,
                                  ),
                                  const SizedBox(height: 5),
                                  TextWidget(
                                    size: 18,
                                    text: "₹ ${dailyModel.userExpense}",
                                    align: TextAlign.center,
                                  ),
                                ],
                              ),
                            ),
                            if ([UserType.Admin.name, UserType.Owner.name]
                                .contains(user?.rwp?.first.role)) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  children: [
                                    const TextWidget(
                                        size: 12,
                                        text: "Org. Expense",
                                        wt: FontWeight.w700),
                                    const SizedBox(height: 5),
                                    TextWidget(
                                      size: 18,
                                      text: "₹ ${dailyModel.orgExpense}",
                                      align: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () async {
                    _status = LoadingStatus(toBlur: true);
                    if (!selDay.isAfter(DateTime.now())) {
                      selDay = selDay.add(const Duration(days: 1));
                      await fetch();
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.only(left: 12),
                    child: const Center(
                      child: Icon(Icons.keyboard_arrow_right),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
