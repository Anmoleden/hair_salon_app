import 'package:flutter/material.dart';
import 'package:hair_salon/config/api_config.dart';
import 'package:hair_salon/screens/app_preferences_page.dart';
import 'package:hair_salon/screens/change_password_page.dart';
import 'package:hair_salon/screens/help_support_page.dart';
import 'package:hair_salon/screens/welcome_screen.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hair_salon/screens/gallery_view.dart';
import 'dart:convert';
import 'dart:io';

class ProfilePage extends StatefulWidget {
  // final String username;
  //added part
  String username;
  final secureStorage = FlutterSecureStorage();
  final String gender;

  // const

  ProfilePage({super.key, required this.username, required this.gender});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? _email;
  String? _photoUrl;
  bool _isLoading = true;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }
  
  //added part
  Future<void> _fetchUserProfile() async {
    try {
      final url = ApiConfig.getUserProfileUri(widget.username);
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _email = data['email'];
          _photoUrl = data['photo'];
          _isLoading = false;
        });
      } else {
        // If failed, try from secure storage (Google user fallback)
        await _loadFromStorage();
      }
    } catch (e) {
      print("Error fetching profile from server: $e");
      await _loadFromStorage(); // fallback for Google login
    }
  }

  Future<void> _loadFromStorage() async {
    final email = await widget.secureStorage.read(key: 'email');
    final photo = await widget.secureStorage.read(key: 'photo');
    final username = await widget.secureStorage.read(key: 'username');

    setState(() {
      _email = email ?? 'Not available';
      _photoUrl = photo;
      _isLoading = false;

      // Optional: override widget.username for display
      if (username != null && username.isNotEmpty) {
        widget.username = username;
      }
    });
  }

  //added part
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
        //_photoUrl = null; // Clear previous network image
      });

      try {
        Uri uploadUri;

        if (_email != null && _email!.isNotEmpty) {
          // Google Sign-In users: upload by email
          uploadUri = ApiConfig.getUploadPhotoByEmailUri(_email!);
        } else {
          // Manual login users: upload by username
          uploadUri = ApiConfig.getUploadPhotoUri(widget.username);
        }

        final request = http.MultipartRequest('POST', uploadUri);
        request.files.add(
          await http.MultipartFile.fromPath('photo', pickedFile.path),
        );

        final response = await request.send();

        if (response.statusCode == 200) {
          final respStr = await response.stream.bytesToString();
          final data = json.decode(respStr);

          setState(() {
            _photoUrl = data['photo']; // Update new image URL from backend
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Photo uploaded successfully')),
          );
        } else {
          print("Upload failed: ${response.statusCode}");
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Failed to upload photo. Error ${response.statusCode}',
              ),
            ),
          );
        }
      } catch (e) {
        print("Upload error: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('An error occurred during upload')),
        );
      }
    }
  }

  Future<void> _deleteUserAndLogout() async {
    try {
      final response = await http.delete(
        ApiConfig.getDeleteUserUri(widget.username),
      );

      if (response.statusCode == 200) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const WelcomeScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete user: ${response.body}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred during deletion')),
      );
    }
  }

  Widget buildListTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: Colors.grey[700]),
      title: Text(title),
      trailing: trailing,
      onTap: onTap,
    );
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.username.isNotEmpty ? widget.username : 'Guest User';
    final email = _email ?? 'Guest Mode';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: _pickImage,
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor:
                            Colors
                                .grey[300], // optional: to give a light background
                        backgroundImage:
                            _selectedImage != null
                                ? FileImage(_selectedImage!)
                                : (_photoUrl != null
                                    ? NetworkImage(_photoUrl!)
                                    : null),
                        child: Align(
                          alignment: Alignment.bottomRight,
                          child: CircleAvatar(
                            backgroundColor: Colors.white,
                            radius: 16,
                            child: const Icon(Icons.photo_camera, size: 18),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      email,
                      style: const TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),

                  /// Face & Hair
                  const Text(
                    "Face & Hair",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Card(
                    child: Column(
                      children: [
                        buildListTile(
                          icon: Icons.camera_alt,
                          title: "Detect Face Shape",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            //todo : add navigation to face shape detection screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => GalleryView(
                                      title: 'Gallery',
                                      onImage: (inputImage) {
                                        // You can handle the inputImage here or leave empty if not needed
                                      },
                                      onDetectorViewModeChanged: () {
                                        // Handle mode change if needed
                                      },
                                      isTryHairstyleFlow: false,
                                      gender: widget.gender,
                                    ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        buildListTile(
                          icon: Icons.history,
                          title: "Try-On History",
                          trailing: Text(
                            "2",
                            style: TextStyle(color: Colors.purple),
                          ),
                          onTap: () {
                            // TODO: Navigate to history screen
                          },
                        ),
                        const Divider(height: 1),
                        buildListTile(
                          icon: Icons.favorite,
                          title: "Favorite Hairstyles",
                          trailing: Text(
                            "0",
                            style: TextStyle(color: Colors.red),
                          ),
                          onTap: () {
                            //todo: navigate to favourites screen
                          },
                        ),
                      ],
                    ),
                  ),

                  /// App Settings
                  const SizedBox(height: 20),
                  const Text(
                    "App Settings",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 5),
                  Card(
                    child: Column(
                      children: [
                        buildListTile(
                          icon: Icons.settings,
                          title: "App Preferences",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            //todo: show preferences/settings screen
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const AppPreferencesPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        buildListTile(
                          icon: Icons.lock,
                          title: "Change Password",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (_) => ChangePasswordPage(
                                      username: widget.username,
                                    ),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        buildListTile(
                          icon: Icons.help_outline,
                          title: "Help & Support",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            //todo: navigate to help page
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const HelpSupportPage(),
                              ),
                            );
                          },
                        ),
                        const Divider(height: 1),
                        buildListTile(
                          icon: Icons.refresh,
                          title: "Clear Try-On History",
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                          ),
                          onTap: () {
                            // todo: cler try-on history
                          },
                        ),
                      ],
                    ),
                  ),

                  /// Logout
                  const SizedBox(height: 20),
                  Center(
                    child: TextButton.icon(
                      // Handle logout logic
                      onPressed: () async {
                        final shouldLogout = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Logout"),
                                content: const Text(
                                  "Are you sure you want to logout?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Logout",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldLogout == true) {
                          // Clear user session (if any)
                          // final prefs = await SharedPreferences.getInstance();
                          // await prefs.clear();

                          // Navigate to login page
                          Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const WelcomeScreen(),
                            ),
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        'Logout',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: TextButton.icon(
                      onPressed: () async {
                        final shouldDelete = await showDialog<bool>(
                          context: context,
                          builder:
                              (context) => AlertDialog(
                                title: const Text("Delete Account"),
                                content: const Text(
                                  "This will permanently delete your account. Are you sure?",
                                ),
                                actions: [
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, false),
                                    child: const Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed:
                                        () => Navigator.pop(context, true),
                                    child: const Text(
                                      "Delete",
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ),
                                ],
                              ),
                        );

                        if (shouldDelete == true) {
                          await _deleteUserAndLogout(); // ⬅️ Call your defined method
                        }
                      },
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text(
                        'Delete Account',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Center(
                    child: Text(
                      'Version 1.0.0',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),

      /// Bottom Navigation (optional)
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: 'Trending',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
