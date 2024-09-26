import 'package:buz_tracker/UI/Expense/ExpenseDetail.dart';
import 'package:buz_tracker/model/ExpenseModel.dart';
import 'package:flutter/material.dart';
import 'package:buz_tracker/Widget/DashedPaitner.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:intl/intl.dart';

class ExpenseItem extends StatelessWidget {
  final bool isAdmin;
  final ExpenseModel expense;
  const ExpenseItem({Key? key, required this.isAdmin, required this.expense})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ExpenseDetail(
              expense: expense,
            ),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(10),
        ),
        margin: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  width: 100,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                      color: randomColor(),
                      borderRadius: BorderRadius.circular(10)),
                  child: Center(
                      child: TextWidget(
                          size: 32,
                          text: expense.title.characters.first,
                          color: pWhiteColor)),
                ),
                Positioned(
                  bottom: 0,
                  child: Container(
                    width: 100,
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(100),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      children: [
                        TextWidget(
                          size: 12,
                          text: DateFormat('dd/MM/yyyy')
                              .format(DateTime.parse(expense.createdAt)),
                          wt: FontWeight.bold,
                          color: pWhiteColor,
                        ),
                        TextWidget(
                          size: 10,
                          text: DateFormat('hh:mm aa')
                              .format(DateTime.parse(expense.createdAt)),
                          wt: FontWeight.bold,
                          color: pWhiteColor,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              TextWidget(
                                size: 20,
                                text: expense.title,
                                wt: FontWeight.bold,
                                maxLine: 2,
                              ),
                              TextWidget(
                                size: 16,
                                text: expense.projectName,
                                wt: FontWeight.w600,
                                maxLine: 2,
                              )
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 5),
                      Column(
                        children: [
                          const SizedBox(height: 20),
                          const TextWidget(
                              size: 16, text: "Paid", wt: FontWeight.w600),
                          TextWidget(
                              size: 18,
                              text: expense.amount.toString(),
                              wt: FontWeight.bold),
                        ],
                      )
                    ],
                  ),
                  ClipRRect(
                    clipBehavior: Clip.hardEdge,
                    child: CustomPaint(
                      painter: DashedLinePainter(),
                      child: Container(height: 1),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 2),
                    child: Row(
                      children: [
                        const Spacer(),
                        TextWidget(
                          size: 12,
                          text: "by ${expense.createdBy}",
                          wt: FontWeight.bold,
                          style: FontStyle.italic,
                        ),
                        const Spacer(),
                        if (isAdmin) ...[
                          const Icon(Icons.edit, size: 16),
                          TextWidget(
                            size: 12,
                            text: expense.noOfEdits.toString(),
                            wt: FontWeight.bold,
                            style: FontStyle.italic,
                          ),
                          const SizedBox(width: 20),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
