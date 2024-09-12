// import 'dart:convert';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
//
// import '../widgets/custom_dropdown_field.dart';
// import '../widgets/custom_text_field.dart';
// import '../widgets/otp_verification.dart';
//
// import 'login_page.dart';
// import 'package:intl/intl.dart';
// import 'package:awesome_dialog/awesome_dialog.dart';
//
// class SignUpPageDemo extends StatefulWidget {
//   const SignUpPageDemo({Key? key}) : super(key: key);
//
//   @override
//   // ignore: library_private_types_in_public_api
//   _SignUpPageState createState() => _SignUpPageState();
// }
//
// class _SignUpPageState extends State<SignUpPageDemo> {
//   final _formKey = GlobalKey<FormState>();
//   bool _isDialogShown = false;
//   List<String> _states = [];
//   List<String> _districts = [];
//   String? _selectedState;
//   String? _selectedGender;
//   String? _selectedMaritalStatus;
//   String? _districtIndex;
//   final List<String> maritalStatusOptions = ['Single', 'Married'];
//   final List<String> genderOptions = ['Male', 'Female'];
//   bool _isAddressExpanded = false;
//   bool _isBankDetailsExpanded = false;
//   bool _isOTPGenerated = false;
//
//   final TextEditingController _otpController = TextEditingController();
//   final TextEditingController _dobController = TextEditingController();
//
//   TextEditingController referredByController = TextEditingController();
//   TextEditingController nameController = TextEditingController();
//   TextEditingController nomineeNameController = TextEditingController();
//   TextEditingController emailidController = TextEditingController();
//   TextEditingController aadharController = TextEditingController();
//   TextEditingController mobileController = TextEditingController();
//   TextEditingController addressController = TextEditingController();
//   TextEditingController pinCodeController = TextEditingController();
//   TextEditingController cityController = TextEditingController();
//   TextEditingController townController = TextEditingController();
//   TextEditingController bankNameController = TextEditingController();
//   TextEditingController bankNameAsInController = TextEditingController();
//   TextEditingController ifscController = TextEditingController();
//   TextEditingController bankBranchController = TextEditingController();
//   TextEditingController accountNumberController = TextEditingController();
//
//   String uid = '';
//   String responseMessage = '';
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchStates();
//     _isDialogShown = false;
//   }
//
//   Future<void> _fetchStates() async {
//     try {
//       List<String> states = await APIService.fetchStates();
//       setState(() {
//         _states = states;
//       });
//     } catch (e) {
//       if (kDebugMode) {
//         debugPrint('Error fetching states: $e');
//       }
//     }
//   }
//
//   Future<void> _fetchDistricts(String stateUid) async {
//     try {
//       List<String> districts = await APIService.fetchDistricts(stateUid);
//       setState(() {
//         _districts = districts;
//       });
//     } catch (e) {
//       if (kDebugMode) {
//         debugPrint('Error fetching districts: $e');
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     referredByController.addListener(() {
//       _showReferrerPopup(referredByController.text);
//     });
//     return Scaffold(
//       body: Padding(
//         padding: const EdgeInsets.fromLTRB(20, 10, 20, 40),
//         child: SingleChildScrollView(
//           child: Form(
//             // Wrap with Form widget
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.stretch,
//               children: [
//                 const SizedBox(height: 20.0),
//                 Container(
//                   width: 150, // Adjust the width as needed
//                   height: 150,
//                   alignment: Alignment.center,
//                   child: Image.asset(
//                       'assets/icons/client_logo.png'), // Replace with your logo image path
//                 ),
//                 CustomTextField(
//                   label: 'Refer ID',
//                   controller: referredByController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select your Refer ID'; // Validation error message
//                     }
//                     // else if (!RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$').hasMatch(value)) {
//                     //   return 'Enter the correct Refer ID';
//                     // }
//                     return null; // Return null if validation passes
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomTextField(
//                   label: 'Name',
//                   controller: nameController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your name';
//                     } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                       return 'Please enter the text only';
//                     } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]')
//                         .hasMatch(value)) {
//                       return 'Name cannot contain special characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomTextField(
//                   label: 'Nominee Name',
//                   controller: nomineeNameController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your Nominee Name';
//                     } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                       return 'Please enter the text only';
//                     } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]')
//                         .hasMatch(value)) {
//                       return 'Name cannot contain special characters';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomTextField(
//                   label: 'Email ID',
//                   controller: emailidController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your Email ID'; // Validation error message
//                     } else if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
//                         .hasMatch(value)) {
//                       return 'Please enter a valid Email ID';
//                     }
//                     return null; // Return null if validation passes
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 TextFormField(
//                   onTap: () => _selectDate(context),
//                   controller: _dobController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please select your Date of Birth'; // Validation error message
//                     }
//                     return null; // Return null if validation passes
//                   },
//                   decoration: const InputDecoration(
//                     hintText: 'Date of Birth',
//                     border: OutlineInputBorder(),
//                   ),
//                   readOnly: true,
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomDropdownField(
//                   label: 'Marital Status',
//                   options: maritalStatusOptions,
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedMaritalStatus = value;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select your Marital Status'; // Validation error message
//                     }
//                     return null; // Return null if validation passes
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomDropdownField(
//                   label: 'Gender',
//                   options: genderOptions,
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedGender = value;
//                     });
//                   },
//                   validator: (value) {
//                     if (value == null) {
//                       return 'Please select your gender'; // Validation error message
//                     }
//                     return null; // Return null if validation passes
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomTextField(
//                   label: 'Aadhar Number',
//                   controller: aadharController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your Aadhar Number'; // Validation error message
//                     } else if (!RegExp(r'^\d{12}$').hasMatch(value)) {
//                       return 'Please enter a valid Aadhar Number';
//                     }
//                     return null; // Return null if validation passes
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 CustomTextField(
//                   label: 'Mobile Number',
//                   controller: mobileController,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter your Mobile number'; // Validation error message
//                     } else if (!RegExp(r'^[0-9]{10}$').hasMatch(value)) {
//                       return 'Please enter a valid 10-digit Mobile number';
//                     }
//                     return null; // Return null if validation passes
//                   },
//                 ),
//                 const SizedBox(height: 10.0),
//                 _isOTPGenerated
//                     ? Column(
//                         children: [
//                           const SizedBox(height: 10.0),
//                           _buildAddressDetails(),
//                           const SizedBox(height: 10.0),
//                           _buildBankDetails(),
//                         ],
//                       )
//                     : ElevatedButton(
//                         onPressed: _generateOTP,
//                         style: ButtonStyle(
//                           backgroundColor: MaterialStateProperty.all<Color>(
//                             const Color(0xFF5cc7e7), // Button background color
//                           ),
//                           // textStyle: MaterialStateProperty.all<TextStyle>(
//                           //   TextStyle(
//                           //     color: Colors.white, // Text color
//                           //     fontWeight: FontWeight.bold, // Text bold
//                           //   ),
//                           // ),
//                         ),
//                         child: const Text(
//                           'Generate OTP',
//                           style: TextStyle(
//                             fontWeight: FontWeight.bold,
//                             color: Colors.white,
//                             fontSize: 15.0,
//                           ),
//                         ),
//                       ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAddressDetails() {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         dividerColor: Colors.transparent,
//       ),
//       child: ExpansionTile(
//         leading: const Icon(Icons.arrow_forward_ios),
//         title: const Text(
//           'Address Details',
//           style: TextStyle(
//               color: Color(0xFF0e5d97),
//               fontSize: 20,
//               fontWeight: FontWeight.w500),
//         ),
//         onExpansionChanged: (value) {
//           setState(() {
//             _isAddressExpanded = value;
//           });
//         },
//         trailing: const SizedBox.shrink(),
//         initiallyExpanded: _isAddressExpanded,
//         children: [
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Address',
//             controller: addressController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your Address'; // Validation error message
//               }
//               return null; // Return null if validation passes
//             },
//           ),
//           const SizedBox(height: 10.0),
//           DropdownButtonFormField<String>(
//             value: _selectedState,
//             items: _states.map((String value) {
//               return DropdownMenuItem<String>(
//                 value: value,
//                 child: Text(value),
//               );
//             }).toList(),
//             onChanged: (String? newValue) {
//               setState(() {
//                 _selectedState = newValue;
//                 _fetchDistricts(
//                     newValue!); // Assuming _fetchDistricts requires a non-null argument
//               });
//             },
//             validator: (value) {
//               if (value == null) {
//                 return 'Please select a state'; // Validation error message
//               }
//               return null; // Return null if validation passes
//             },
//             decoration: const InputDecoration(
//               labelText: 'State',
//               border: OutlineInputBorder(),
//             ),
//           ),
//           const SizedBox(height: 10.0),
//           CustomDropdownField(
//             label: 'District',
//             options: _districts,
//             onChanged: (selectedDistrict) {
//               setState(() {
//                 // Get the index of the selected district
//                 int selectedIndex = _districts.indexOf(selectedDistrict!);
//                 // Increment by 1 to match your requirement
//                 _districtIndex = (selectedIndex + 1).toString();
//               });
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'city',
//             controller: cityController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your City';
//               } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                 return 'Please enter the text only';
//               } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
//                 return 'City cannot contain special characters';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Town',
//             controller: townController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your Town';
//               } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                 return 'Please enter the text only';
//               } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
//                 return 'Town cannot contain special characters';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Pincode',
//             controller: pinCodeController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your Pincode'; // Validation error message
//               } else if (!RegExp(r'^\d{6}$').hasMatch(value)) {
//                 return 'Please enter a valid 6-digit Pincode';
//               }
//               return null; // Return null if validation passes
//             },
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildBankDetails() {
//     return Theme(
//       data: Theme.of(context).copyWith(
//         dividerColor: Colors.transparent,
//       ),
//       child: ExpansionTile(
//         leading: const Icon(Icons.arrow_forward_ios),
//         title: const Text(
//           'Bank Details',
//           style: TextStyle(
//               color: Color(0xFF0e5d97),
//               fontSize: 20,
//               fontWeight: FontWeight.w500),
//         ),
//         onExpansionChanged: (value) {
//           setState(() {
//             _isBankDetailsExpanded = value;
//           });
//         },
//         trailing: const SizedBox.shrink(),
//         initiallyExpanded: _isBankDetailsExpanded,
//         children: [
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Name of the bank',
//             controller: bankNameController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your Bank name';
//               } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                 return 'Please enter the text only';
//               } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
//                 return 'Special characters not allowed!';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'IFSC code',
//             controller: ifscController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your IFSC code'; // Validation error message
//               } else if (!RegExp(r'^[A-Za-z]{4}\d{7}$').hasMatch(value)) {
//                 return 'Please enter a valid IFSC code';
//               }
//               return null; // Return null if validation passes
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Branch name',
//             controller: bankBranchController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter Branch of Bank';
//               } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                 return 'Please enter the text only';
//               } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
//                 return 'Special characters not allowed';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Account Number',
//             controller: accountNumberController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your account number'; // Validation error message
//               } else if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
//                 return 'Please enter a valid account number';
//               }
//               return null; // Return null if validation passes
//             },
//           ),
//           const SizedBox(height: 10.0),
//           CustomTextField(
//             label: 'Name as in Bank',
//             controller: bankNameAsInController,
//             validator: (value) {
//               if (value == null || value.isEmpty) {
//                 return 'Please enter your Name as in the bank';
//               } else if (RegExp(r'[0-9]').hasMatch(value)) {
//                 return 'Please enter the text only';
//               } else if (RegExp(r'[!@#%^&*(),.?":{}|<>]').hasMatch(value)) {
//                 return 'Name cannot contain special characters';
//               }
//               return null;
//             },
//           ),
//           const SizedBox(height: 10.0),
//           ElevatedButton(
//             onPressed: () {
//               if (_formKey.currentState!.validate()) {
//                 // Check form validation
//                 _registerUser();
//               }
//             },
//             style: ButtonStyle(
//               backgroundColor: MaterialStateProperty.all<Color>(
//                 const Color(0xFF5cc7e7),
//               ),
//             ),
//             child: Text(
//               _isOTPGenerated ? 'Register for Free' : 'Generate OTP',
//               style: const TextStyle(
//                 fontWeight: FontWeight.bold,
//                 color: Colors.white,
//                 fontSize: 15.0,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   void _generateOTP() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return OTPVerificationDialog(
//           otpController: _otpController,
//           onResendOTP: () {},
//           onSubmit: () {
//             setState(() {
//               _isOTPGenerated = true;
//             });
//             ScaffoldMessenger.of(context).showSnackBar(
//               const SnackBar(
//                 content: Text(
//                     'Your number is verified! Please fill the below details'),
//                 duration: Duration(seconds: 3),
//               ),
//             );
//             Navigator.of(context).pop();
//           },
//         );
//       },
//     );
//   }
//
//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? pickedDate = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now(),
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//     );
//     if (pickedDate != null) {
//       print('Selected Date: $pickedDate');
//
//       // Format the picked date as "dd-MMM-yyyy" for display to the user
//       String formattedDisplayDate =
//           DateFormat('dd-MMM-yyyy').format(pickedDate);
//
//       // Convert the display date to API date format "yyyy-MM-dd"
//       String formattedApiDate = convertToApiDateFormat(formattedDisplayDate);
//
//       // Print the formatted dates
//
//       setState(() {
//         _dobController.text =
//             formattedDisplayDate; // Set the display date to the text field
//         _apiFormattedDate = formattedApiDate;
//         // Use formattedApiDate for sending the date to the API
//       });
//     }
//   }
//
//   String _apiFormattedDate = '';
//   String convertToApiDateFormat(String displayDate) {
//     final DateTime parsedDate = DateFormat('dd-MMM-yyyy').parse(displayDate);
//     return DateFormat('yyyy-MM-dd').format(parsedDate);
//   }
//
//   void _showReferrerPopup(String referrerUid) async {
//     if (referrerUid.isNotEmpty && !_isDialogShown) {
//       String referrerApiUrl =
//           'https://z2h.in:8000/api/z2h/user/validate_referrer/?referrer_uid=$referrerUid';
//       var referrerResponse = await http.get(Uri.parse(referrerApiUrl));
//       if (referrerResponse.statusCode == 200) {
//         var referrerData = jsonDecode(referrerResponse.body);
//         String referrerName = referrerData['referrer_name'];
//         String referrerCity = referrerData['referrer_city'];
//
//         // Show success dialog using Awesome Dialog
//         AwesomeDialog(
//           context: context,
//           dialogType: DialogType.success, // Set dialog type to success
//           animType: AnimType.bottomSlide,
//           desc: 'Referrer Name: $referrerName\nCity: $referrerCity',
//           btnOkOnPress: () {
//             setState(() {
//               _isDialogShown = true;
//             });
//           },
//         )..show();
//       }
//     }
//   }
//
//   Future<void> _registerUser() async {
//     String url = 'https://z2h.in:8000/api/z2h/user/register/';
//     var payload = {
//       "referred_by": referredByController.text,
//       "marital_status": _selectedMaritalStatus?.toLowerCase(),
//       "name": nameController.text,
//       "nominee_name": nomineeNameController.text,
//       "date_of_birth": _apiFormattedDate,
//       "gender": _selectedGender?.toLowerCase(),
//       "aadhar_number": aadharController.text,
//       "mobile_number": mobileController.text,
//       "pin_code": pinCodeController.text,
//       "name_of_bank": bankNameController.text,
//       "name_as_in_bank": bankNameAsInController.text,
//       "ifsc_code": ifscController.text,
//       "bank_branch": bankBranchController.text,
//       "account_number": accountNumberController.text,
//       "role": 2,
//       "district": _districtIndex, // Use district index instead of district name
//       "city": cityController.text,
//       "town": townController.text,
//       "address": addressController.text,
//       "email_address": emailidController.text,
//     };
//
//     var headers = {'Content-Type': 'application/json'};
//     var response = await http.post(
//       Uri.parse(url),
//       headers: headers,
//       body: jsonEncode(payload),
//     );
//
//     if (response.statusCode == 201) {
//       var data = jsonDecode(response.body);
//       setState(() {
//         uid = data['uid'];
//       });
//       // Show success dialog using Awesome Dialog
//       AwesomeDialog(
//         context: context,
//         dialogType: DialogType.success, // Set dialog type to success
//         animType: AnimType.bottomSlide,
//         title: 'Registration Successful',
//         desc: 'User registered successfully! Thanks for registering with us.',
//         btnOkOnPress: () {
//           // Navigate to login page
//           Navigator.push(
//             context,
//             MaterialPageRoute(builder: (context) => const LoginPage()),
//           );
//         },
//       )..show();
//     } else if (response.statusCode == 400) {
//       // Show error dialog using Awesome Dialog
//       AwesomeDialog(
//         context: context,
//         dialogType: DialogType.warning, // Set dialog type to error
//         animType: AnimType.topSlide,
//         title: 'Enter another mobile number',
//         desc: 'register user with this mobile number already exists.',
//         btnOkOnPress: () {},
//       )..show();
//     } else if (response.statusCode == 403) {
//       // Show error dialog using Awesome Dialog
//       AwesomeDialog(
//         context: context,
//         dialogType: DialogType.warning, // Set dialog type to error
//         animType: AnimType.topSlide,
//         title: 'Refer Id used already',
//         desc:
//             'You do not have permission to use this reffer ID because it is already exist',
//         btnOkOnPress: () {},
//       )..show();
//     }
//   }
// }
//
// class APIService {
//   static Future<List<String>> fetchStates() async {
//     final response =
//         await http.get(Uri.parse('https://z2h.in:8000/api/z2h/utils/state/'));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((state) => state['name'] as String).toList();
//     } else {
//       throw Exception('Failed to load states');
//     }
//   }
//
//   static Future<List<String>> fetchDistricts(String stateUid) async {
//     final response = await http.get(Uri.parse(
//         'https://z2h.in:8000/api/z2h/utils/district/7202475c-553c-497b-98bb-155c05bd773a'));
//     if (response.statusCode == 200) {
//       final List<dynamic> data = json.decode(response.body);
//       return data.map((district) => district['name'] as String).toList();
//     } else {
//       throw Exception('Failed to load districts');
//     }
//   }
// }
