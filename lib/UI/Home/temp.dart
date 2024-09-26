// import 'package:buz_tracker/Service/DBService.dart';
// import 'package:buz_tracker/Service/UserService.dart';
// import 'package:buz_tracker/UI/ScreenWrapper.dart';
// import 'package:buz_tracker/helper/helper.dart';
// import 'package:buz_tracker/model/ExpenseModel.dart';
// import 'package:buz_tracker/model/ProjectModel.dart';
// import 'package:buz_tracker/model/UserModel.dart';
// import 'package:flutter/material.dart';
// import 'package:list_manager/APIResponse/Result.dart';
// import 'package:list_manager/Components/FilterView.dart';
// import 'package:list_manager/utils/FilterUtils/FilterController.dart';
// import 'package:list_manager/utils/FilterUtils/FilterData.dart';

// class HomeScreen extends StatefulWidget {
//   const HomeScreen({super.key});

//   @override
//   State<HomeScreen> createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   ScreenStatus _status = OkStatus();

//   late FilterController<ExpenseModel> filterController;

//   @override
//   void initState() {
//     super.initState();
//     filterController = FilterController(
//       loadFilters: loadFilters,
//       applyFilter: ({selFilters, query, helper}) async {
//         final user = UserService.getUser()!;
//         int page = (helper?.page ?? 1);

//         final data = await DBService().listExpenses(
//           roleResolver(
//               user.rwp?.first, PermissionMap["ViewOtherExpenses"]["code"]),
//           user.organisationId!,
//           user.id,
//           page: page,
//           params: selFilters,
//         );

//         List<ExpenseModel> expenses = data.map((value) {
//           return ExpenseModel.fromJson(value);
//         }).toList();

//         return Success(data: expenses);
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return ScreenWrapper(
//       status: _status,
//       child: Column(
//         children: [
//           FilterComponent(title: "Filters", controller: filterController)
//         ],
//       ),
//     );
//   }

//   Widget loader() {
//     return const Center(
//       child: Text(
//         "Loading",
//         style: TextStyle(
//           color: Colors.blue,
//           fontSize: 22,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget error(context, error) {
//     return Center(
//       child: Text(
//         error,
//         style: const TextStyle(
//           color: Colors.blue,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Widget filterError(context, error) {
//     return Center(
//       child: Text(
//         "filter: $error",
//         style: const TextStyle(
//           color: Colors.blue,
//           fontSize: 24,
//           fontWeight: FontWeight.bold,
//         ),
//       ),
//     );
//   }

//   Future<Result<List<FilterData>>> loadFilters() async {
//     final user = UserService.getUser();

//     final list = [
//       if (roleResolver(
//           user?.rwp?.first, PermissionMap["ViewOtherExpenses"]["code"]))
//         FDropdownData(
//           title: "User",
//           key: "filter_user_id",
//           onChange: () {},
//           isFilterOnline: true,
//           showSearchBox: true,
//           searchData: (filter) async {
//             final membersRes =
//                 await DBService().listMembers(user!.organisationId!);
//             final members = membersRes.map((ele) {
//               final user = UserModel.fromJson(ele);
//               return FilterOptionData(id: user.id.toString(), name: user.name);
//             }).toList();
//             return members;
//           },
//           options: [],
//         ),
//       FDropdownData(
//         title: "Project",
//         key: "filter_project_id",
//         onChange: () {},
//         options: [],
//         isFilterOnline: true,
//         showSearchBox: true,
//         searchData: (filter) async {
//           final projectsRes =
//               await DBService().listProject(user!.organisationId!);
//           final projects = projectsRes.map((ele) {
//             final user = ProjectModel.fromJson(ele);
//             return FilterOptionData(id: user.id.toString(), name: user.name);
//           }).toList();
//           return projects;
//         },
//       ),
//       FSliderData(
//         title: "Amount Range",
//         minKey: "filter_amount_more_than",
//         maxKey: "filter_amount_less_than",
//         labels: const RangeLabels("0", "20000"),
//         values: const RangeValues(0, 20000),
//         min: 0,
//         max: 100000,
//       ),
//       FDateData(
//         title: "Date",
//         startDateKey: "start_date",
//         endDateKey: "end_date",
//         start: DateTime.now(),
//         end: DateTime.now().add(const Duration(days: 34)),
//       ),
//       FRadioData(
//         title: "Sort by Amount",
//         key: "sort_by_amount",
//         options: [
//           FilterOptionData(id: "ASC", name: "Ascending"),
//           FilterOptionData(id: "DESC", name: "Descending"),
//         ],
//       ),
//       FRadioData(title: "Sort by Date", key: "sort_by_date", options: [
//         FilterOptionData(id: "ASC", name: "Ascending"),
//         FilterOptionData(id: "DESC", name: "Descending"),
//       ]),
//     ];
//     return Success(data: list);
//   }
// }
