import 'dart:convert';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:phone_email_auth/phone_email_auth.dart';
import '../widgets/custom_dropdown_field.dart';
import '../widgets/custom_text_field.dart';
import 'package:http/http.dart' as http;
import 'login_page.dart';

class SignUpPageDemo1 extends StatefulWidget {
  const SignUpPageDemo1({Key? key}) : super(key: key);

  @override
  _SignUpPageDemo1State createState() => _SignUpPageDemo1State();
}

class _SignUpPageDemo1State extends State<SignUpPageDemo1> {

  String? userAccessToken;
  String? jwtUserToken;
  bool hasUserLogin = false;
  PhoneEmailUserModel? phoneEmailUserModel;

  final String stateAPIUrl = 'https://z2h.in:8000/api/z2h/utils/state/';
  final String districtAPIUrl = 'https://z2h.in:8000/api/z2h/utils/district/';
  List<Map<String, dynamic>> states = []; // List to store states
  List<Map<String, dynamic>> districts = []; // List to store districts
  final _formKey = GlobalKey<FormState>();
  String? _selectedMaritalStatus;
  String? _selectedGender;
  String? _selectedStateUid;
  String? _selectedState;
  String? _selectedDistrict;
  String? adjustedIndex;
  String uid = '';

  final List<String> maritalStatusOptions = ['Single', 'Married'];
  final List<String> genderOptions = ['Male', 'Female'];
  final TextEditingController _dobController = TextEditingController();

  Future<void> fetchStates() async {
    try {
      final response = await http.get(Uri.parse(stateAPIUrl));
      if (response.statusCode == 200) {
        setState(() {
          states = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to fetch states');
      }
    } catch (e) {
      print('Error fetching states: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    fetchStates(); // Fetch states on initialization
    PhoneEmail.initializeApp(clientId: '16995501200085907886');
  }
  void getUserInfo() {
    if (userAccessToken != null) {
      PhoneEmail.getUserInfo(
        accessToken: userAccessToken!,
        clientId: '16995501200085907886',
        onSuccess: (userData) {
          setState(() {
            phoneEmailUserModel = userData;
            var countryCode = phoneEmailUserModel?.countryCode;
            var phoneNumber = phoneEmailUserModel?.phoneNumber;
            // Use this verified phone number to register user and create your session
          });
        },
      );
    }
  }

  Future<void> fetchDistricts(String? stateUid) async {
    if (stateUid == null) return; // Return if state UID is null
    try {
      final response = await http.get(Uri.parse('$districtAPIUrl$stateUid/'));
      if (response.statusCode == 200) {
        setState(() {
          districts = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        });
      } else {
        throw Exception('Failed to fetch districts');
      }
    } catch (e) {
      print('Error fetching districts: $e');
    }
  }

  Future<void> _registerUser() async {
    String url = 'https://z2h.in:8000/api/z2h/user/register/';
    int districtIndex = districts.indexWhere((district) => district['name'] == _selectedDistrict);

    var payload = {
      "referred_by": referIdController.text,
      "marital_status": _selectedMaritalStatus?.toLowerCase(),
      "name": nameController.text,
      "nominee_name": nomineeNameController.text,
      "date_of_birth": _apiFormattedDate,
      "gender": _selectedGender?.toLowerCase(),
      "aadhar_number": aadharController.text,
      "mobile_number": phoneEmailUserModel!.phoneNumber,
      "pin_code": pincodeController.text,
      "name_of_bank": bankNameController.text,
      "name_as_in_bank": accountNameController.text,
      "ifsc_code": ifscController.text,
      "bank_branch": branchController.text,
      "account_number": accountNumberController.text,
      "role": 2,
      "district": districtIndex + 1, // Use district index instead of district name
      "city": cityController.text,
      "town": townController.text,
      "address": addressController.text,
      "email_address": emailController.text,
    };

    print('payload: $payload');

    var headers = {'Content-Type': 'application/json'};
    var response = await http.post(
      Uri.parse(url),
      headers: headers,
      body: jsonEncode(payload),
    );

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      setState(() {
        uid = data['uid'];
      });
      // Show success dialog using Awesome Dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.success, // Set dialog type to success
        animType: AnimType.bottomSlide,
        title: 'Registration Successful',
        desc: 'User registered successfully! Thanks for registering with us.',
        btnOkOnPress: () {
          // Navigate to login page
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LoginPage()),
          );
        },
      )..show();
    } else if (response.statusCode == 400) {
      // Show error dialog using Awesome Dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning, // Set dialog type to error
        animType: AnimType.topSlide,
        title: 'Enter another mobile number',
        desc: 'register user with this mobile number already exists.',
        btnOkOnPress: () {},
      )..show();
    } else if (response.statusCode == 403) {
      // Show error dialog using Awesome Dialog
      AwesomeDialog(
        context: context,
        dialogType: DialogType.warning, // Set dialog type to error
        animType: AnimType.topSlide,
        title: 'Refer Id used already',
        desc: 'You do not have permission to use this refer ID because it already exists',
        btnOkOnPress: () {},
      )..show();
    }
  }

  int _activeStepIndex = 0;

  TextEditingController referIdController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController nomineeNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController maritalStatusController = TextEditingController();
  TextEditingController genderController = TextEditingController();
  TextEditingController aadharController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController districtController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController townController = TextEditingController();
  TextEditingController pincodeController = TextEditingController();
  TextEditingController bankNameController = TextEditingController();
  TextEditingController ifscController = TextEditingController();
  TextEditingController branchController = TextEditingController();
  TextEditingController accountNumberController = TextEditingController();
  TextEditingController accountNameController = TextEditingController();
  String _apiFormattedDate = '';

  List<String> stepTitles = [
    'User Details',
    'Address Details',
    'Bank Details',
  ];

  List<Step> stepList() => [
    Step(
      state: _activeStepIndex == 0 ? StepState.editing : StepState.complete,
      isActive: _activeStepIndex >= 0,
      title: const Text('User Details'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                key: Key('referId'),
                label: 'Refer ID',
                controller: referIdController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Refer ID';
                  } else if (RegExp(r'^[A-Z]{6}\d{4}$').hasMatch(value)) {
                    return 'Enter a valid Refer ID';
                  }
                  return null;
                },
                onChanged: (value) {
                  setState(() {});
                  _showReferrerPopup(value); // Call method to show referral popup
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                key: Key('Name'),
                label: 'Name',
                controller: nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  } else if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Please enter text only';
                  } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Name cannot contain special characters';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                key: Key('Nominee Name'),
                label: 'Nominee Name',
                controller: nomineeNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Nominee Name';
                  } else if (RegExp(r'[0-9]').hasMatch(value)) {
                    return 'Please enter text only';
                  } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
                    return 'Name cannot contain special characters';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Email ID',
                controller: emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Email ID'; // Validation error message
                  } else if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                    return 'Please enter a valid email address'; // Validation error message
                  }
                  return null; // Return null if validation passes
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomDropdownField(
                label: 'Marital Status',
                options: maritalStatusOptions,
                value: _selectedMaritalStatus,
                onChanged: (value) {
                  setState(() {
                    _selectedMaritalStatus = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your Marital Status'; // Validation error message
                  }
                  return null; // Return null if validation passes
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Date of Birth',
                controller: _dobController,
                readOnly: true,
                onTap: () => _selectDate(context),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your date of birth';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomDropdownField(
                label: 'Gender',
                options: genderOptions,
                value: _selectedGender,
                onChanged: (value) {
                  setState(() {
                    _selectedGender = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your gender'; // Validation error message
                  }
                  return null; // Return null if validation passes
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Aadhar Number',
                controller: aadharController,
                keyboardType: TextInputType.number,
                maxLength: 12,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your Aadhar Number';
                  } else if (!RegExp(r'^\d{12}$').hasMatch(value)) {
                    return 'Please enter a valid 12-digit Aadhar Number';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              // CustomTextField(
              //   label: 'Mobile Number',
              //   controller: mobileController,
              //   keyboardType: TextInputType.phone,
              //   maxLength: 10,
              //   validator: (value) {
              //     if (value == null || value.isEmpty) {
              //       return 'Please enter your mobile number';
              //     } else if (!RegExp(r'^[6-9]\d{9}$').hasMatch(value)) {
              //       return 'Please enter a valid 10-digit mobile number';
              //     }
              //     return null;
              //   },
              //   onChanged: (value) => setState(() {}),
              // ),
              const SizedBox(height: 8),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (!hasUserLogin)
                      PhoneLoginButton(
                        borderRadius: 10,
                        buttonColor: Colors.teal,
                        label: 'Verify OTP',
                        onSuccess: (String accessToken, String jwtToken) {
                          if (accessToken.isNotEmpty) {
                            setState(() {
                              userAccessToken = accessToken;
                              jwtUserToken = jwtToken;
                              hasUserLogin = true;
                            });
                            getUserInfo();
                          }
                        },
                      )
                    else
                      ElevatedButton(
                        onPressed: _checkUserDetailsCompletion()
                            ? () {
                          setState(() {
                            _activeStepIndex = 1; // Move to the Bank Details step
                          });
                        }
                            : null, // Set onPressed to null if form validation fails
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF5cc7e7),
                        ),
                        child: const Text(
                          'Next',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                      ),
                    if (hasUserLogin) ...[
                      Text('Mobile Number Verified successfully'),
                      if (phoneEmailUserModel != null)
                        Text('Phone Number: ${phoneEmailUserModel!.phoneNumber}')
                    ]
                  ],
                ),
              )


            ],
          ),
        ),
      ),
    ),
    Step(
      state: _activeStepIndex <= 1 ? StepState.editing : StepState.complete,
      isActive: _activeStepIndex >= 1,
      title: const Text('Address Details'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Address',
                controller: addressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomDropdownField(
                label: 'State',
                options: states.map<String>((state) => state['name']).toList(),
                value: _selectedState,
                onChanged: (value) {
                  setState(() {
                    _selectedState = value;
                    _selectedStateUid = states.firstWhere((state) => state['name'] == value)['uid'];
                    fetchDistricts(_selectedStateUid); // Fetch districts for the selected state
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your state';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CustomDropdownField(
                label: 'District',
                options: districts.map<String>((district) => district['name']).toList(),
                value: _selectedDistrict,
                onChanged: (value) {
                  setState(() {
                    _selectedDistrict = value;
                  });
                },
                validator: (value) {
                  if (value == null) {
                    return 'Please select your district';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'City',
                controller: cityController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your city';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                key: Key('Town'),
                label: 'Town',
                controller: townController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your town';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                key: Key('Pincode'),
                label: 'Pin Code',
                controller: pincodeController,
                keyboardType: TextInputType.number,
                maxLength: 6,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your pin code';
                  }
                  // } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                  //   return 'Please enter a valid 6-digit pin code';
                  // }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _checkAddressDetailsCompletion()
                      ? () {
                    setState(() {
                      _activeStepIndex = 2; // Move to the Bank Details step
                    });
                  }
                      : null, // Set onPressed to null if form validation fails
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5cc7e7),
                  ),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    ),
    Step(
      state: StepState.complete,
      isActive: _activeStepIndex >= 2,
      title: const Text('Bank Details'),
      content: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CustomTextField(
                label: 'Name of Bank',
                controller: bankNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name of your bank';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Name as in Bank',
                controller: accountNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the name as in bank';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'IFSC Code',
                controller: ifscController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank IFSC code';
                  }
                  else if (!RegExp(r'^[A-Za-z]{4}\d{7}$').hasMatch(value)) {
                    return 'Please enter a valid IFSC code';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Branch',
                controller: branchController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bank branch';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              CustomTextField(
                label: 'Account Number',
                controller: accountNumberController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your account number';
                  } else if (!RegExp(r'^\d{9,18}$').hasMatch(value)) {
                    return 'Please enter a valid account number';
                  }
                  return null;
                },
                onChanged: (value) => setState(() {}),
              ),
              const SizedBox(height: 8),
              Center(
                child: ElevatedButton(
                  onPressed: _checkBankDetailsCompletion() ? _registerUser : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5cc7e7),
                  ),
                  child: const Text(
                    'Register',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    ),
  ];

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime(2021),
    );
    if (picked != null) {
      final DateFormat formatter = DateFormat('dd-MM-yyyy');
      final DateFormat apiFormatter = DateFormat('yyyy-MM-dd');
      setState(() {
        _dobController.text = formatter.format(picked);
        _apiFormattedDate = apiFormatter.format(picked); // Format for API
      });
    }
  }

  bool _checkUserDetailsCompletion() {
    return referIdController.text.isNotEmpty &&
        nameController.text.isNotEmpty &&
        nomineeNameController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        _selectedMaritalStatus != null &&
        _dobController.text.isNotEmpty &&
        _selectedGender != null &&
        aadharController.text.isNotEmpty;
        // mobileController.text.isNotEmpty;
  }
  bool _checkAddressDetailsCompletion() {
    return addressController.text.isNotEmpty &&
        _selectedState != null &&
        _selectedDistrict != null &&
        cityController.text.isNotEmpty &&
        townController.text.isNotEmpty &&
        pincodeController.text.isNotEmpty;
  }
  bool _checkBankDetailsCompletion() {
    return bankNameController.text.isNotEmpty &&
        accountNameController .text.isNotEmpty &&
        ifscController .text.isNotEmpty &&
        branchController .text.isNotEmpty &&
        accountNumberController .text.isNotEmpty ;

  }
  void _showReferrerPopup(String referrerUid) async {
    if (referrerUid.isNotEmpty) {
      String referrerApiUrl =
          'https://z2h.in:8000/api/z2h/user/validate_referrer/?referrer_uid=$referrerUid';
      var referrerResponse = await http.get(Uri.parse(referrerApiUrl));
      if (referrerResponse.statusCode == 200) {
        var referrerData = jsonDecode(referrerResponse.body);
        String referrerName = referrerData['referrer_name'];
        String referrerCity = referrerData['referrer_city'];

        // Show success dialog using Awesome Dialog
        AwesomeDialog(
          context: context,
          dialogType: DialogType.success, // Set dialog type to success
          animType: AnimType.bottomSlide,
          desc: 'Referrer Name: $referrerName\nCity: $referrerCity',
          btnOkOnPress: () {},
        )..show();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 80.0,
        backgroundColor: const Color(0xFFDCFFFF),
        automaticallyImplyLeading: false,
        title: Center(
          child: Image.asset(
            'assets/icons/client_logo.png',
            fit: BoxFit.contain,
            height: 200,
            width: 200,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: Container(
            color: Colors.blue[900],
            height: 4.0,
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Container(
              height: 100,
              color: Colors.blue[50],
              child: Stack(
                children: [

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(stepList().length, (index) {
                      return Column(
                        children: [
                          GestureDetector(
                            onTap: _activeStepIndex == index
                                ? () {
                              setState(() {
                                _activeStepIndex = index;
                              });
                            }
                                : null, // Disable onTap if not active step
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: CircleAvatar(
                                backgroundColor: _activeStepIndex == index
                                    ? Colors.blue
                                    : Colors.white,
                                child: _activeStepIndex > index
                                    ? const Icon(Icons.check, color: Colors.green)
                                    : Text(
                                  '${index + 1}',
                                  style: const TextStyle(color: Colors.black),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(stepTitles[index]),
                        ],
                      );
                    }),
                  ),

                ],
              ),
            ),
          ),
          Expanded(
            child: stepList()[_activeStepIndex].content,
          ),
        ],
      ),
    );
  }
}
