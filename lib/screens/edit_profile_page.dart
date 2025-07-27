// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:hair_salon/config/api_config.dart';
// import 'package:http/http.dart' as http;
// import 'package:image_picker/image_picker.dart';

// class EditProfilePage extends StatefulWidget {
//   final String username;
//   final String? email;
//   final String? photoUrl;

//   const EditProfilePage({
//     super.key,
//     required this.username,
//     this.email,
//     this.photoUrl,
//   });

//   @override
//   State<EditProfilePage> createState() => _EditProfilePageState();
// }

// class _EditProfilePageState extends State<EditProfilePage> {
//   late TextEditingController _usernameController;
//   late TextEditingController _emailController;
//   late TextEditingController _currentPasswordController;
//   late TextEditingController _newPasswordController;
//   late TextEditingController _confirmPasswordController;

//   File? _selectedImage;
//   String? _uploadedPhotoUrl;
//   bool _isSaving = false;
//   bool _isCurrentPasswordVisible = false;
//   bool _isNewPasswordVisible = false;
//   bool _isConfirmPasswordVisible = false;

//   @override
//   void initState() {
//     super.initState();
//     _usernameController = TextEditingController(text: widget.username);
//     _emailController = TextEditingController(text: widget.email ?? '');
//     _currentPasswordController = TextEditingController();
//     _newPasswordController = TextEditingController();
//     _confirmPasswordController = TextEditingController();
//     _uploadedPhotoUrl = widget.photoUrl;
//   }

//   Future<void> _pickImage() async {
//     final ImagePicker picker = ImagePicker();
//     final XFile? pickedFile = await picker.pickImage(
//       source: ImageSource.gallery,
//     );

//     if (pickedFile != null) {
//       setState(() {
//         _selectedImage = File(pickedFile.path);
//       });

//       try {
//         final request = http.MultipartRequest(
//           'POST',
//           ApiConfig.getUploadPhotoUri(widget.username),
//         );
//         request.files.add(
//           await http.MultipartFile.fromPath('photo', pickedFile.path),
//         );

//         final response = await request.send();

//         if (response.statusCode == 200) {
//           final respStr = await response.stream.bytesToString();
//           final data = json.decode(respStr);
//           setState(() {
//             _uploadedPhotoUrl = data['photo'];
//           });
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Photo uploaded successfully')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Failed to upload image')),
//           );
//         }
//       } catch (e) {
//         print("Upload error: $e");
//         ScaffoldMessenger.of(
//           context,
//         ).showSnackBar(const SnackBar(content: Text('Upload failed')));
//       }
//     }
//   }

//   Future<void> _saveChanges() async {
//     setState(() => _isSaving = true);

//     final url = ApiConfig.getUpdateProfileUri(widget.username);
//     final body = json.encode({'photo': _uploadedPhotoUrl});

//     try {
//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Profile updated successfully')),
//         );
//         Navigator.pop(context, true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Failed to update profile')),
//         );
//       }
//     } catch (e) {
//       print("Update error: $e");
//     }

//     setState(() => _isSaving = false);
//   }

//   Future<void> _changePassword() async {
//     print("Change password button clicked");
//     final current = _currentPasswordController.text.trim();
//     final newPass = _newPasswordController.text.trim();
//     final confirm = _confirmPasswordController.text.trim();

//     if (newPass != confirm) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("New passwords do not match")),
//       );
//       return;
//     }

//     if (newPass.length < 6) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("Password must be at least 6 characters")),
//       );
//       return;
//     }

//     final url = ApiConfig.getChangePasswordUri(widget.username);
//     final body = json.encode({
//       'currentPassword': current,
//       'newPassword': newPass,
//     });

//     try {
//       final response = await http.put(
//         url,
//         headers: {'Content-Type': 'application/json'},
//         body: body,
//       );
//       print("Response code: ${response.statusCode}");
//       print("Response body: ${response.body}");

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Password changed successfully")),
//         );
//         _currentPasswordController.clear();
//         _newPasswordController.clear();
//         _confirmPasswordController.clear();
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text("Failed to change password")),
//         );
//       }
//     } catch (e) {
//       print("Password change error: $e");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Edit Profile'), centerTitle: true),
//       body:
//           _isSaving
//               ? const Center(child: CircularProgressIndicator())
//               : SingleChildScrollView(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   children: [
//                     GestureDetector(
//                       onTap: _pickImage,
//                       child: Stack(
//                         children: [
//                           CircleAvatar(
//                             radius: 50,
//                             backgroundImage:
//                                 _selectedImage != null
//                                     ? FileImage(_selectedImage!)
//                                     : _uploadedPhotoUrl != null
//                                     ? NetworkImage(_uploadedPhotoUrl!)
//                                     : null,
//                             child:
//                                 _selectedImage == null &&
//                                         _uploadedPhotoUrl == null
//                                     ? const Icon(
//                                       Icons.person,
//                                       size: 50,
//                                       color: Colors.grey,
//                                     )
//                                     : null,
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             right: 0,
//                             child: CircleAvatar(
//                               backgroundColor: Colors.white,
//                               radius: 16,
//                               child: const Icon(Icons.camera_alt, size: 18),
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _usernameController,
//                       decoration: const InputDecoration(
//                         labelText: 'Username',
//                         border: OutlineInputBorder(),
//                       ),
//                       enabled: false,
//                     ),
//                     const SizedBox(height: 15),
//                     TextField(
//                       controller: _emailController,
//                       decoration: const InputDecoration(
//                         labelText: 'Email',
//                         border: OutlineInputBorder(),
//                       ),
//                       enabled: false,
//                     ),
//                     const SizedBox(height: 25),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _saveChanges,
//                         child: const Text('Save Profile'),
//                       ),
//                     ),
//                     const SizedBox(height: 40),
//                     const Divider(),
//                     const SizedBox(height: 10),
//                     const Text(
//                       "Change Password",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     TextField(
//                       controller: _currentPasswordController,
//                       obscureText: !_isCurrentPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'Current Password',
//                         border: const OutlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isCurrentPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isCurrentPasswordVisible =
//                                   !_isCurrentPasswordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     TextField(
//                       controller: _newPasswordController,
//                       obscureText: !_isNewPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'New Password',
//                         border: const OutlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isNewPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isNewPasswordVisible = !_isNewPasswordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 15),
//                     TextField(
//                       controller: _confirmPasswordController,
//                       obscureText: !_isConfirmPasswordVisible,
//                       decoration: InputDecoration(
//                         labelText: 'Confirm New Password',
//                         border: const OutlineInputBorder(),
//                         suffixIcon: IconButton(
//                           icon: Icon(
//                             _isConfirmPasswordVisible
//                                 ? Icons.visibility
//                                 : Icons.visibility_off,
//                           ),
//                           onPressed: () {
//                             setState(() {
//                               _isConfirmPasswordVisible =
//                                   !_isConfirmPasswordVisible;
//                             });
//                           },
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton(
//                         onPressed: _changePassword,
//                         child: const Text('Change Password'),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//     );
//   }
// }
