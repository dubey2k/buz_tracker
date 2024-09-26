import 'dart:developer';

import 'package:buz_tracker/Service/SupabaseClient.dart';
import 'package:buz_tracker/helper/DBConfig.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:intl/intl.dart';

class DBService {
  static final DBService _pgService = DBService._internal();
  factory DBService() {
    return _pgService;
  }

  DBService._internal();

  final _dbClient = SupabaseInstance().client;

  // User realted Queries˚–

  Future<List<Map<String, dynamic>>> findUserByEmail(String email) async {
    return await _dbClient
        .from(TableNames.users)
        .select(
            'id, created_at, updated_at, name, email, phone, organisation_id, added_by, acc_status, ${TableNames.role_with_permissions}(role, permission, is_disabled)')
        .eq("email", email);
  }

  Future<List<Map<String, dynamic>>> addUserToDB(String email) async {
    return await _dbClient.from(TableNames.users).insert(
        {"email": email, "acc_status": AccStatus.CREATED.name}).select();
  }

  Future<List<Map<String, dynamic>>> markCreatedUserToDB(String email) async {
    return await _dbClient
        .from(TableNames.users)
        .update({"acc_status": AccStatus.CREATED.name})
        .eq("email", email)
        .select();
  }

  Future<List<Map<String, dynamic>>> updateUser(String email,
      {String? username, String? phone}) async {
    var payload = {
      if (username != null) "name": username,
      if (phone != null) "phone": phone
    };
    return await _dbClient
        .from(TableNames.users)
        .update(payload)
        .eq("email", email)
        .select();
  }

  Future<List<Map<String, dynamic>>> fetchOrganisation(int orgId) async {
    return await _dbClient
        .from(TableNames.organisation)
        .select()
        .eq("id", orgId);
  }

  Future<List<Map<String, dynamic>>> addUserToOrganisation(
      String email, String name, String phone) async {
    return await _dbClient
        .from(TableNames.users)
        .update({
          "name": name,
          "phone": phone,
          "acc_status": AccStatus.ONBOARDED.name
        })
        .eq("email", email)
        .select(
            'id, created_at, updated_at, name, email, phone, organisation_id, added_by, acc_status, ${TableNames.role_with_permissions}(role, permission, is_disabled)');
  }

  Future<List<Map<String, dynamic>>> createOrganisation(
      String email,
      String name,
      String phone,
      String orgName,
      String orgEmail,
      String orgAddress,
      String orgCode) async {
    final orgData = await _dbClient.from(TableNames.organisation).insert({
      "name": orgName,
      "address": orgAddress,
      "email": orgEmail,
      "org_code": orgCode,
    }).select();

    final user = await _dbClient
        .from(TableNames.users)
        .update({
          "name": name,
          "phone": phone,
          "organisation_id": orgData.first["id"],
          "acc_status": AccStatus.ONBOARDED.name
        })
        .eq("email", email)
        .select();

    final rwp = await _dbClient.from(TableNames.role_with_permissions).insert({
      "role": UserType.Owner.name,
      "user_id": user.first["id"],
      "org_id": orgData.first["id"],
      "permission": "1111",
    }).select();

    user.first.putIfAbsent(
      "Role_With_Permissions",
      () => [
        {
          "role": rwp.first["role"],
          "permission": rwp.first["permission"],
          "is_disabled": false,
        }
      ],
    );

    return user;
  }

  Future<List<Map<String, dynamic>>> updateOrganisation(int id,
      {String? email, String? address, String? code, String? name}) async {
    final payload = <String, dynamic>{
      if (name != null && name.isEmpty) 'name': name,
      if (address != null && address.isNotEmpty) 'address': address,
      if (code != null && code.isNotEmpty) 'org_code': code,
      if (email != null && email.isValidEmail()) 'email': email,
    };

    log("DATA :: $id \n PAYLOAD :: $payload");

    return await _dbClient
        .from(TableNames.organisation)
        .update(payload)
        .eq("id", id)
        .select();
  }

  Future<List<Map<String, dynamic>>> checkUserForOrganisation(
      String email, String orgCode) async {
    final organisation = await _dbClient
        .from(TableNames.organisation)
        .select()
        .eq("org_code", orgCode);

    if (organisation.isEmpty) return [];

    final user = await _dbClient
        .from(TableNames.users)
        .select()
        .match({"email": email, "organisation_id": organisation.first["id"]});

    return user;
  }

  // Project related Queries
  Future<List<Map<String, dynamic>>> createProject(
      String name,
      String description,
      ProjectStatus status,
      int userId,
      int organisationId) async {
    return await _dbClient.from(TableNames.projects).insert({
      "name": name,
      "status": status.name,
      "description": description,
      "created_by": userId,
      "organisation_id": organisationId
    }).select();
  }

  Future<List<Map<String, dynamic>>> listProject(
    int organisationId,
  ) async {
    return await _dbClient.rpc('list_projects_with_total_expense', params: {});
  }

  Future<List<Map<String, dynamic>>> searchProject(
      int organisationId, String searchChar) async {
    searchChar = searchChar.isEmpty ? "*" : searchChar;
    return await _dbClient
        .from(TableNames.projects)
        .select('id, name')
        .eq("organisation_id", organisationId)
        .ilike('name', '%$searchChar%');
  }

  Future<List<Map<String, dynamic>>> editProject(
    int projectId, {
    String? name,
    String? description,
    ProjectStatus? status,
    DateTime? completedOn,
  }) async {
    final payload = <String, dynamic>{
      if (name != null && name.isEmpty) 'name': name,
      if (description != null && description.isEmpty)
        'description': description,
      if (status != null) 'status': status.name,
      if (completedOn != null) 'completed_on': completedOn.toString(),
    };
    return await _dbClient
        .from(TableNames.projects)
        .update(payload)
        .eq("id", projectId)
        .select();
  }

  // Expense related Queries
  Future<List<Map<String, dynamic>>> listExpenses(
    bool isAdmin,
    int organisationId,
    int userId, {
    String? searchQuery,
    Map<String, dynamic>? params,
    int page = 1,
    int limit = 10,
  }) async {
    var data = {
      "isadmin": isAdmin,
      "org_id": organisationId,
      "user_id": userId,
      "to_skip": (page - 1) * limit,
      "page_limit": limit,
      "search_text": searchQuery
    };

    if (params != null) {
      data = {
        ...data,
        ...params,
      };
    }
    return await _dbClient.rpc('list_expenses', params: data);
  }

  Future<List<Map<String, dynamic>>> createExpense(
    String title,
    String? description,
    double amount,
    int createdBy,
    int projectId,
    int organisationId,
    DateTime forDate,
  ) async {
    return await _dbClient.from(TableNames.expenses).insert({
      "title": title,
      "amount": amount,
      "description": description,
      "created_by": createdBy,
      "project_id": projectId,
      "organisation_id": organisationId,
      "for_date": forDate.toString()
    }).select();
  }

  Future<List<Map<String, dynamic>>> editExpense(
    int expenseId, {
    String? title,
    String? description,
    double? amount,
    int? createdBy,
    int? projectId,
    DateTime? forDate,
  }) async {
    var payload = <String, dynamic>{
      if (title != null && title.isEmpty) 'title': title,
      if (description != null && description.isNotEmpty)
        'description': description,
      if (amount != null) 'amount': amount,
      if (createdBy != null) 'created_by': createdBy,
      if (projectId != null) 'project_id': projectId,
      if (forDate != null) 'for_date': forDate.toString(),
    };
    return await _dbClient
        .from(TableNames.expenses)
        .update(payload)
        .eq("id", expenseId)
        .select();
  }

  Future<List<Map<String, dynamic>>> dayExpenseDetails(
    bool isAdmin,
    int organisationId,
    int userId,
    DateTime date, {
    Map<String, dynamic>? params,
  }) async {
    var data = {
      "user_id": userId,
      "org_id": organisationId,
      "expense_date": DateFormat("yyyy-MM-dd").format(date),
      "isadmin": isAdmin,
    };

    if (params != null) {
      data = {
        ...data,
        ...params,
      };
    }
    return await _dbClient.rpc('day_expense_stat', params: data);
  }

  Future<List<Map<String, dynamic>>> expenseMonthlyNumber(
    bool isAdmin,
    int organisationId,
    int userId,
    DateTime date, {
    Map<String, dynamic>? params,
  }) async {
    var data = {
      "user_id": userId,
      "org_id": organisationId,
      "expense_date": DateFormat("yyyy-MM-dd").format(date),
      "isadmin": isAdmin,
    };

    if (params != null) {
      data = {
        ...data,
        ...params,
      };
    }
    return await _dbClient.rpc('month_expense_stat', params: data);
  }

  Future<List<Map<String, dynamic>>> expenseYearlyNumber(
    bool isAdmin,
    int organisationId,
    int userId,
    DateTime date, {
    Map<String, dynamic>? params,
  }) async {
    var data = {
      "isadmin": isAdmin,
      "org_id": organisationId,
      "user_id": userId,
      "start_date": DateFormat("yyyy-MM-dd").format(date)
    };

    if (params != null) {
      data = {
        ...data,
        ...params,
      };
    }
    return await _dbClient.rpc('yearly_expense_stat', params: data);
  }

// Organisation Related Queries
  Future<List<Map<String, dynamic>>> getOrganisationDetails(
      bool isAdmin, int organisationId, int userId, int? projectId) async {
    var params = {
      "isadmin": true,
      "org_id": organisationId,
      "user_id": userId,
      "proj_id": projectId,
    };
    return await _dbClient.rpc('list_expenses', params: params);
  }

  Future<List<Map<String, dynamic>>> listMembers(int orgId) async {
    return _dbClient
        .from(TableNames.users)
        .select(
            'id, created_at, updated_at, name, email, phone, organisation_id, added_by, acc_status, ${TableNames.role_with_permissions}(role, permission, is_disabled)')
        .eq("organisation_id", orgId);
  }

  Future<List<Map<String, dynamic>>> removeUserFromOrg(int userId) async {
    return _dbClient
        .from(TableNames.role_with_permissions)
        .update({"is_disabled": true})
        .eq("user_id", userId)
        .select();
  }

  Future registerUserToOrganisation({
    required String name,
    required String email,
    required String phone,
    required int orgId,
    required int userId,
    required UserType role,
    required String permission,
  }) async {
    final user = await _dbClient.from(TableNames.users).insert({
      "name": name,
      "email": email,
      "phone": phone,
      "organisation_id": orgId,
      "added_by": userId,
      "acc_status": AccStatus.ADDED.name,
    }).select();

    await _dbClient.from(TableNames.role_with_permissions).insert({
      "role": role.name,
      "user_id": user.first["id"],
      "org_id": orgId,
      "permission": permission,
    });
  }
}
