import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:propertypal/utils/appvalidator.dart';
import '../screens/notification/notification.dart';
import '../services/db.dart';
import 'dart:async';
import 'auth_gate.dart';


class AddUnitForm extends StatefulWidget {
  final String propertyId;
  final String? unitId;
  final Map<String, dynamic>? initialData;

  const AddUnitForm({Key? key, required this.propertyId, this.unitId, this.initialData}) : super(key: key);

  @override
  State<AddUnitForm> createState() => _AddUnitFormState();
}

class _AddUnitFormState extends State<AddUnitForm> {
  final _unitName = TextEditingController();
  final _tenantName = TextEditingController();
  final _tenantPhone = TextEditingController();
  final _tenantEmail = TextEditingController();
  final _tenantRent = TextEditingController();
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();
  final FocusNode _propertyAddressFocus = FocusNode();


  final _notifications = Notifications();
  var db = Db();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  int? _selectedDuration;

  var isLoader = false;
  var appValidator = AppValidator();

  @override
  void initState() {
    super.initState();
    if (widget.unitId != null) {
      _loadUnitDetails();
    }
  }

  void _loadUnitDetails() async {
    var unitDetails = await db.getUnitDetails(widget.propertyId, widget.unitId!);
    _unitName.text = unitDetails['unitName'];
    _tenantName.text = unitDetails['tenantName'];
    _tenantPhone.text = unitDetails['tenantPhone'];
    _tenantEmail.text = unitDetails['tenantEmail'];
    _tenantRent.text = unitDetails['tenantRent'];
    _startDateController.text = unitDetails['startDate'];
    _selectedDuration = unitDetails['duration'];
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoader = true;
      });

      var data = {
        'unitName': _unitName.text,
        'tenantName': _tenantName.text,
        'tenantPhone': _tenantPhone.text,
        'tenantEmail': _tenantEmail.text,
        'tenantRent': _tenantRent.text,
        'startDate': _startDateController.text,
        'endDate': _calculateEndDate(_startDateController.text, _selectedDuration),
      };

      if (widget.unitId != null) {
        await db.editUnit(widget.propertyId, widget.unitId!, data);
      } else {
        await db.addUnit(widget.propertyId, data);
      }

      setState(() {
        isLoader = false;
      });

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => AuthGate()),
            (route) => false,
      );
    }
  }

  DateTime? _startDate;



  Future<void> _selectDuration(BuildContext context) async {
    final int? selected = await showDialog<int>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Select Duration (Months)'),
          content: DropdownButton<int>(
            items: List.generate(
              12,
                  (index) => DropdownMenuItem<int>(
                value: index + 1,
                child: Text((index + 1).toString()),
              ),
            ),
            onChanged: (value) {
              Navigator.pop(context, value);
            },
            value: _selectedDuration,
          ),
        );
      },
    );

    if (selected != null) {
      setState(() {
        _selectedDuration = selected;
        _updateEndDate();
      });
    }
  }

  String _calculateEndDate(String? startDate, int? duration) {
    if (startDate != null && duration != null) {
      final daysInMonth = 30.44;
      final DateTime startDateTime = DateFormat.yMMMd().parse(startDate);
      final endDate = startDateTime.add(Duration(days: (duration * daysInMonth).round()));
      return DateFormat.yMMMd().format(endDate);
    } else if (widget.initialData != null) {
      return widget.initialData!['endDate'];
    } else {
      return '';
    }
  }


  @override
  Widget build(BuildContext context) {
    _updateEndDate();
    _notifications.init();
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.unitId != null ? 'Edit Apartment Unit' : 'Add Apartment Unit'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [

                TextFormField(
                  controller: _unitName,
                  validator: appValidator.isEmptyCheck,
                  decoration: InputDecoration(
                      labelText: 'Unit\'s name'
                  ),
                ),
                TextFormField(
                  controller: _tenantName,
                  validator: appValidator.isEmptyCheck,
                  decoration: InputDecoration(
                      labelText: 'Tenant\'s name'
                  ),
                ),
                TextFormField(
                  controller: _tenantPhone,
                  validator: appValidator.isEmptyCheck,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                      labelText: 'Tenant\'s Phone number'
                  ),
                ),
                TextFormField(
                  controller: _tenantEmail,
                  validator: appValidator.isEmptyCheck,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                      labelText: 'Tenant\'s Email'
                  ),
                ),
                TextFormField(
                  controller: _tenantRent,
                  validator: appValidator.isEmptyCheck,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                      labelText: 'Tenant\'s Rent'
                  ),
                ),
                TextFormField(
                  validator: appValidator.isEmptyCheck,
                  onTap: () {
                    _selectDate(context);
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Start Date',
                  ),
                  controller: _startDateController,
                ),
                TextFormField(
                  validator: (value) {
                    if (_selectedDuration == null) {
                      return 'Select duration';
                    }
                    return null;
                  },
                  readOnly: true,
                  decoration: InputDecoration(
                    labelText: 'Duration (Months)',
                  ),
                  onTap: () {
                    _selectDuration(context);
                  },
                  controller: TextEditingController(
                    text: _selectedDuration != null
                        ? _selectedDuration.toString()
                        : '',
                  ),
                ),
                SizedBox(
                  height: 12,
                ),
                ElevatedButton(
                  onPressed: (){
                    if (isLoader == false){
                      _notificationNow();
                      _notificationLater();
                      _submitForm();
                    }
                  },
                  child: isLoader
                      ? Center(child: CircularProgressIndicator())
                      : Text(widget.unitId != null ? 'Save Changes' : 'Add Apartment Unit'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime currentDate = DateTime.now();
    final DateTime lastDate = DateTime(2040, 12, 31);

    DateTime initialDate = currentDate;


    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: lastDate,
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
        _startDateController.text = DateFormat.yMMMd().format(picked);
        _updateEndDate();
      });
    }
  }

  void _updateEndDate() {
    _endDateController.text = _calculateEndDate(_startDateController.text, _selectedDuration);
  }

  void _notificationNow() async{
    _notifications.sendNotificationNow("${_tenantName.text}\'s Apartment Added",
        "We will notify you 5 days before the end date.", _startDateController.text);
  }
  void _notificationLater() async {
    final daysInMonth = 30.44;
    String currentMonth = DateFormat('MMMM').format(DateTime.now());
    for (int i = 1; i <= _selectedDuration!; i++) {
      int delayDays = (daysInMonth).round();
      await Future.delayed(Duration(days: delayDays-5));
      _notifications.sendNotificationNow("Payment Update","${_tenantName.text}'s payment is due in 5 days for $currentMonth","" );
    }
  }
}