import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/UI/Settings/Organisation/AddMember.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/UserModel.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ManageMembers extends StatefulWidget {
  const ManageMembers({super.key});

  @override
  State<ManageMembers> createState() => _ManageMembersState();
}

class _ManageMembersState extends State<ManageMembers> {
  ScreenStatus _status = LoadingStatus(toBlur: true);

  late List<UserModel> members = [];

  final UserModel? _user = UserService.getUser();
  bool canAdd = false;

  @override
  void initState() {
    super.initState();
    fetchMembers();
    canAdd = _user?.rwp?.first.role == UserType.Owner.name;
  }

  fetchMembers() async {
    try {
      final res = await DBService().listMembers(_user!.organisationId!);
      members = res.map((ele) {
        return UserModel.fromJson(ele);
      }).toList();

      _status = OkStatus();
    } catch (e) {
      _status = OkStatus();
      showSnakbar(e.toString(), context);
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: pWhiteColor,
      appBar: AppBar(
        title: const TextWidget(
          size: 18,
          text: "Manage Members",
          wt: FontWeight.w700,
        ),
        actions: [
          IconButton(
            onPressed: () async {
              if (canAdd) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddMember(),
                  ),
                );
              } else {
                showSnakbar("Only owners can add new members", context);
              }
            },
            icon: const Icon(Icons.add),
          ),
        ],
      ),
      body: ScreenWrapper(
        status: _status,
        child: SafeArea(
          child: ListView.builder(
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              return Container(
                decoration: BoxDecoration(
                  color: pWhiteColor,
                  boxShadow: const [
                    BoxShadow(
                      offset: Offset(2, 3),
                      color: Color.fromARGB(10, 0, 0, 0),
                      blurRadius: 10,
                      spreadRadius: 3,
                    ),
                  ],
                  borderRadius: BorderRadius.circular(10),
                ),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                child: Row(
                  children: [
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        color: randomColor(),
                      ),
                      child:
                          const Center(child: TextWidget(size: 20, text: "U")),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          TextWidget(
                              size: 18,
                              text: member.name ?? "User Name",
                              wt: FontWeight.w600),
                          TextWidget(size: 16, text: member.email),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              TextWidget(
                                size: 16,
                                text: member.rwp?.first.role ?? "Worker",
                                wt: FontWeight.w600,
                              ),
                              const SizedBox(width: 20),
                              TextWidget(
                                size: 14,
                                text: member.phoneNumber ?? "Phone Number",
                              ),
                            ],
                          ),
                          TextWidget(
                              size: 12,
                              text: DateFormat('dd/MM/yyyy hh:mm aa')
                                  .format(DateTime.parse(member.createdAt))),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    PopupMenuButton<String>(
                      itemBuilder: (BuildContext context) {
                        return <PopupMenuEntry<String>>[
                          const PopupMenuItem<String>(
                            value: 'remove',
                            child: ListTile(
                              leading: Icon(Icons.delete),
                              title: Text('Remove User'),
                            ),
                          ),
                        ];
                      },
                      onSelected: (String value) async {
                        try {
                          _status = LoadingStatus(toBlur: true);
                          await DBService().removeUserFromOrg(member.id);
                          members.removeWhere((ele) => ele.id == member.id);
                        } catch (e) {
                          showSnakbar(e.toString(), context);
                        }
                        setState(() {
                          _status = OkStatus();
                        });
                      },
                    )
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
