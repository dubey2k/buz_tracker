import 'package:buz_tracker/Service/DBService.dart';
import 'package:buz_tracker/Service/UserService.dart';
import 'package:buz_tracker/UI/ScreenWrapper.dart';
import 'package:buz_tracker/Widget/ElevationButton.dart';
import 'package:buz_tracker/Widget/TextInput.dart';
import 'package:buz_tracker/Widget/TextWidget.dart';
import 'package:buz_tracker/helper/helper.dart';
import 'package:buz_tracker/model/OrganisationModel.dart';
import 'package:flutter/material.dart';

class OrganisationDetail extends StatefulWidget {
  const OrganisationDetail({super.key});

  @override
  State<OrganisationDetail> createState() => _OrganisationDetailState();
}

class _OrganisationDetailState extends State<OrganisationDetail> {
  ScreenStatus _status = OkStatus();
  late OrganisationModel _organisationModel;

  late final TextEditingController _nameCon, _emailCon, _codeCon, _addCon;
  final user = UserService.getUser();

  late final bool canEdit;

  @override
  void initState() {
    super.initState();
    _nameCon = TextEditingController();
    _emailCon = TextEditingController();
    _codeCon = TextEditingController();
    _addCon = TextEditingController();
    canEdit = user?.rwp?.first.role == UserType.Owner.name;
    fetchOrganisation();
  }

  fetchOrganisation() async {
    try {
      _status = LoadingStatus(toBlur: true);
      final user = UserService.getUser();
      final res = await DBService().fetchOrganisation(user!.organisationId!);

      _organisationModel = OrganisationModel.fromJson(res.first);
      _nameCon.text = _organisationModel.name;
      _emailCon.text = _organisationModel.email;
      _codeCon.text = _organisationModel.code;
      _addCon.text = _organisationModel.address;
      _status = OkStatus();
    } catch (e) {
      _status = ErrorStatus(e.toString());
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
          text: "Your Organisation",
          wt: FontWeight.w700,
        ),
      ),
      body: ScreenWrapper(
        status: _status,
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              vertical: 10,
              horizontal: 15,
            ),
            child: Column(
              children: [
                TextInput(controller: _nameCon, title: "Organisation Name"),
                TextInput(controller: _codeCon, title: "Organisation Code"),
                TextInput(controller: _emailCon, title: "Organisation Email"),
                TextInput(controller: _addCon, title: "Organisation Address"),
                const Spacer(),
                ElevationButton(
                  onTap: () async {
                    setState(() {
                      _status = LoadingStatus(toBlur: true);
                    });
                    try {
                      final name = _nameCon.text.trim();
                      final email = _emailCon.text.trim();
                      final code = _codeCon.text.trim();
                      final address = _addCon.text.trim();

                      if (user == null) {
                        throw ErrorDescription("Error while updating profile");
                      }

                      final updatedOrganistaion = await DBService()
                          .updateOrganisation(user!.organisationId!,
                              name: name != _organisationModel.name &&
                                      name.isValidName()
                                  ? name
                                  : null,
                              email: email != _organisationModel.email &&
                                      email.isValidEmail()
                                  ? email
                                  : null,
                              code: code != _organisationModel.code &&
                                      code.isValidOrgCode()
                                  ? code
                                  : null,
                              address: address != _organisationModel.address &&
                                      address.isNotEmpty
                                  ? address
                                  : null);

                      _organisationModel =
                          OrganisationModel.fromJson(updatedOrganistaion.first);

                      showSnakbar("User profile Updated!!", context);
                    } catch (e) {
                      showSnakbar(e.toString(), context);
                    }
                    setState(() {
                      _status = OkStatus();
                    });
                  },
                  backgroundColor: primaryColor,
                  text: const TextWidget(
                    size: 20,
                    text: "Update",
                    wt: FontWeight.bold,
                    color: pWhiteColor,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
