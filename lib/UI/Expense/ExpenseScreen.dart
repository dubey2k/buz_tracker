import 'package:buz_tracker/UI/Expense/CreateExpense.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/ProjectModel.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/Widget/ExpenseItem.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/model/ExpenseModel.dart';
import 'package:list_manager/APIResponse/Result.dart';
import 'package:list_manager/Components/FilterView.dart';
import 'package:list_manager/Components/SearchWidget.dart';
import 'package:list_manager/list_manager.dart';
import 'package:list_manager/utils/FilterUtils/FilterController.dart';
import 'package:list_manager/utils/FilterUtils/FilterData.dart';
import 'package:list_manager/utils/PagingUtils/PagingController.dart';
import 'package:list_manager/utils/PagingUtils/PagingHelper.dart';

class ExpenseListScreen extends StatefulWidget {
  final int? projectId;
  const ExpenseListScreen({
    Key? key,
    this.projectId,
  }) : super(key: key);

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen>
    with AutomaticKeepAliveClientMixin<ExpenseListScreen> {
  late PagingController<ExpenseModel> controller;
  late FilterController<ExpenseModel> filterController;

  @override
  void initState() {
    super.initState();
    controller = PagingController(
      pagingHelper: PagingHelper.init(error: error, loader: loader()),
      loadData: fetch,
    );
    filterController = FilterController(
      loadFilters: loadFilters,
      pagingController: PagingController(
        pagingHelper: PagingHelper.init(error: filterError, loader: loader()),
        loadData: fetch,
      ),
      applyFilter: ({selFilters, query, helper}) async {
        final user = UserService.getUser()!;
        int page = (helper?.page ?? 1);

        final data = await DBService().listExpenses(
          roleResolver(
              user.rwp?.first, PermissionMap["ViewOtherExpenses"]["code"]),
          user.organisationId!,
          user.id,
          page: page,
          params: selFilters,
        );

        List<ExpenseModel> expenses = data.map((value) {
          return ExpenseModel.fromJson(value);
        }).toList();

        controller.setPagingConfig(
          helper?.copyWith(
                hasNext: expenses.isNotEmpty,
                loadNext: expenses.isNotEmpty,
                page: (page + 1),
              ) ??
              PagingHelper.init(),
        );
        return Success(data: expenses);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => const CreateExpense()));
        },
        icon: const Icon(Icons.add),
        label: const TextWidget(
            size: 16, text: "Create Expense", wt: FontWeight.w500),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        child: RefreshIndicator(
          onRefresh: () => fetch(null),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: SearchWidget(
                      filterController: filterController,
                      inputBorder: const OutlineInputBorder(),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.filter_alt),
                    onPressed: () async {
                      showFilterBottomSheet();
                    },
                  ),
                ],
              ),
              Expanded(
                child: ListManager<ExpenseModel>(
                  itemBuilder:
                      (BuildContext context, ExpenseModel data, int index) {
                    final role = UserService.getUser()?.rwp?.first.role;
                    return ExpenseItem(
                        isAdmin: [UserType.Owner.name, UserType.Admin.name]
                            .contains(role),
                        expense: data);
                  },
                  pagingController: controller,
                  filterController: filterController,
                  loader: const Center(
                    child: Text(
                      "Loading",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  error: (context, error) {
                    return Center(
                      child: Text(
                        "$error => at Page 1 itself",
                        style: const TextStyle(color: Colors.red),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Result<List<ExpenseModel>>> fetch(PagingHelper? helper) async {
    final user = UserService.getUser()!;
    int page = (helper?.page ?? 1);
    final data = await DBService().listExpenses(
      roleResolver(user.rwp?.first, PermissionMap["ViewOtherExpenses"]["code"]),
      user.organisationId!,
      user.id,
      page: page,
    );

    List<ExpenseModel> expenses = data.map((value) {
      return ExpenseModel.fromJson(value);
    }).toList();

    controller.setPagingConfig(
      helper?.copyWith(
            hasNext: expenses.isNotEmpty,
            loadNext: expenses.isNotEmpty,
            page: (page + 1),
          ) ??
          PagingHelper.init(),
    );
    return Success(data: expenses);
  }

  void showFilterBottomSheet() async {
    filterController.startLoadingFilters();
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      showDragHandle: true,
      scrollControlDisabledMaxHeightRatio: 0.8,
      builder: (context) {
        return FilterComponent(
          title: "Filters",
          controller: filterController,
          apply: ElevationButton(
            onTap: () {},
            backgroundColor: backgroundColor,
            text: const TextWidget(
              size: 16,
              text: "Continue with Google",
              wt: FontWeight.w600,
              color: Color.fromARGB(255, 77, 77, 77),
            ),
          ),
        );
      },
    );
  }

  Widget loader() {
    return const Center(
      child: Text(
        "Loading",
        style: TextStyle(
          color: Colors.blue,
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget error(context, error) {
    return Center(
      child: Text(
        error,
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget filterError(context, error) {
    return Center(
      child: Text(
        "filter: $error",
        style: const TextStyle(
          color: Colors.blue,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Future<Result<List<FilterData>>> loadFilters() async {
    final user = UserService.getUser();

    final list = [
      if (roleResolver(
          user?.rwp?.first, PermissionMap["ViewOtherExpenses"]["code"]))
        FDropdownData(
          title: "User",
          key: "filter_user_id",
          onChange: () {},
          isFilterOnline: true,
          showSearchBox: true,
          searchData: (filter) async {
            final membersRes =
                await DBService().listMembers(user!.organisationId!);
            final members = membersRes.map((ele) {
              final user = UserModel.fromJson(ele);
              return FilterOptionData(id: user.id.toString(), name: user.name);
            }).toList();
            return members;
          },
          options: [],
        ),
      FDropdownData(
        title: "Project",
        key: "filter_project_id",
        onChange: () {},
        options: [],
        isFilterOnline: true,
        showSearchBox: true,
        searchData: (filter) async {
          final projectsRes =
              await DBService().listProject(user!.organisationId!);
          final projects = projectsRes.map((ele) {
            final user = ProjectModel.fromJson(ele);
            return FilterOptionData(id: user.id.toString(), name: user.name);
          }).toList();
          return projects;
        },
      ),
      FSliderData(
        title: "Amount Range",
        minKey: "filter_amount_more_than",
        maxKey: "filter_amount_less_than",
        labels: const RangeLabels("0", "20000"),
        values: const RangeValues(0, 20000),
        min: 0,
        max: 100000,
      ),
      FDateData(
        title: "Date",
        startDateKey: "start_date",
        endDateKey: "end_date",
        start: DateTime.now(),
        end: DateTime.now().add(const Duration(days: 34)),
      ),
      FRadioData(
        title: "Sort by Amount",
        key: "sort_by_amount",
        options: [
          FilterOptionData(id: "ASC", name: "Ascending"),
          FilterOptionData(id: "DESC", name: "Descending"),
        ],
      ),
      FRadioData(title: "Sort by Date", key: "sort_by_date", options: [
        FilterOptionData(id: "ASC", name: "Ascending"),
        FilterOptionData(id: "DESC", name: "Descending"),
      ]),
    ];
    return Success(data: list);
  }

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
    filterController.dispose();
  }

  @override
  bool get wantKeepAlive => true;
}
