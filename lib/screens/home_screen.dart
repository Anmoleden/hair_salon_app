// import 'package:hair_salon/screens/detectfaceshape.dart';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hair_salon/screens/profile.dart';

//added part
import 'package:hair_salon/screens/gallery_view.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';

//added part
import '../classifiers/hairstyle_model.dart';
import '../config/api_config.dart';
import '../services/trending_services.dart';
import 'gallery_view_direct.dart';
import 'trending_page.dart';
import 'history_page.dart';
// ignore: unused_import
import 'favourites_page.dart';

class HomeScreen extends StatefulWidget {
  //add part
  final String username;
  final String loginMethod;
  final String gender;

  const HomeScreen({
    super.key,
    required this.username,
    required this.loginMethod,
    required this.gender,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ignore: unused_field
  final int _selectedIndex = 0;

  // Trending styles from backend
  List<Hairstyle> _trendingStyles = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTrendingHairstyles(); // <-- Fetch trending hairstyles here
  }

  // Function to fetch trending hairstyles from backend
  Future<void> _loadTrendingHairstyles() async {
    try {
      setState(() {
        _isLoading = true;
      });
      
      final trending = await ApiService.fetchTrendingHairstyles();
      print('Home Screen: Fetched ${trending.length} trending hairstyles');
      print('First hairstyle: ${trending.isNotEmpty ? trending.first.hairstyleName : 'No hairstyles'}');
      print('First image URL: ${trending.isNotEmpty ? trending.first.representingImageUrl : 'No URL'}');
      
      setState(() {
        _trendingStyles = trending;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading trending hairstyles: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  //  Trending styles UI
  Widget buildTrendingStyles() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_trendingStyles.isEmpty) {
      return const Center(child: Text('No trending styles found.'));
    }

    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _trendingStyles.length,
        itemBuilder: (context, index) {
          final style = _trendingStyles[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    "${ApiConfig.baseUrl}/public/hairstyles/${style.representingImageUrl}",
                    width: 100,
                    height: 120,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(style.hairstyleName),
              ],
            ),
          );
        },
      ),
    );
  }

  void _onBottomNavTap(int index) {
    switch (index) {
      case 1: // Trending
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TrendingPage()),
        );
        break;
      case 2: // Favorites
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const FavoritesPage()),
        );
        break;
      case 3: // Profile
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => ProfilePage(
                  username: widget.username,
                  gender: widget.gender,
                ),
          ),
        );
        break;
      default:
        // index 0 = Home (do nothing)
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    // final helloText = 'Hello, ${widget.username}!';
    // ① Extract and format the name here:
    final fullName = widget.username;
    final firstName = fullName.split(' ').first;
    final capitalizedFirstName =
        '${firstName[0].toUpperCase()}${firstName.substring(1)}';
    final helloText = 'Hello, $capitalizedFirstName!';

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        // currentIndex: _selectedIndex,
        currentIndex: 0,
        onTap: _onBottomNavTap,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.trending_up),
            label: "Trending",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            label: "Favorites",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            label: "Profile",
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.04,
            vertical: screenHeight * 0.015,
          ),
          child: ListView(
            children: [
              Text(
                helloText,
                // "Hello, Beautiful!",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.05,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                "Find your perfect hairstyle today",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  color: Colors.grey[600],
                ),
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _FeatureIcon(
                    icon: Icons.camera_alt,
                    text: "Detect\nFace Shape",
                    color: Colors.pinkAccent,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GalleryView(
                                title: 'Gallery',
                                onImage: (InputImage inputImage) async {
                                  // This will be filled in the next step
                                },
                                onDetectorViewModeChanged: () {},
                                isTryHairstyleFlow: false,
                                gender: widget.gender,
                              ),
                        ),
                      );
                    },
                  ),
                  _FeatureIcon(
                    icon: Icons.content_cut,
                    text: "Try\nHairstyles",
                    color: Colors.cyan,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => GalleryViewDirect(
                                title: 'Gallery',
                                onImage: (InputImage inputImage) async {
                                  // This will be filled in the next step
                                },
                                onDetectorViewModeChanged: () {},
                                isTryHairstyleFlow: true,
                                gender: widget.gender,
                              ),
                        ),
                      );
                    },
                  ),
                  _FeatureIcon(
                    icon: Icons.trending_up,
                    text: "Trending",
                    color: Colors.purple,
                    //added part
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const TrendingPage(),
                        ),
                      );
                    },
                  ),
                  _FeatureIcon(
                    icon: Icons.history,
                    text: "History",
                    color: Colors.green,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const HistoryPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.03),
              Container(
                padding: EdgeInsets.all(screenWidth * 0.04),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Discover Your Perfect Hairstyle",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.042,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.008),
                    Text(
                      "Take a selfie to detect your face shape and get personalized hairstyle recommendations.",
                      style: GoogleFonts.poppins(
                        fontSize: screenWidth * 0.035,
                        color: Colors.grey[700],
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(
                          255,
                          255,
                          64,
                          191,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text(
                        "Detect Face Shape",
                        style: TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        // Navigator.push(
                        //   context,
                        //   MaterialPageRoute(
                        //     builder: (context) => const DetectFaceShapeScreen(),
                        //   ),
                        // );
                        //added part
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
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Trending Hairstyles",
                      style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w600,
                        fontSize: screenWidth * 0.042,
                      ),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => const TrendingPage(
                                  // showFavoritesOnly: false,
                                ),
                          ),
                        );
                      },
                      child: Text(
                        "See All",
                        style: GoogleFonts.poppins(
                          color: Colors.pinkAccent,
                          fontWeight: FontWeight.w500,
                          fontSize: screenWidth * 0.035,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: screenHeight * 0.030),
              SizedBox(
                height: screenHeight * 0.25,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingStyles.length,
                  itemBuilder: (context, index) {
                    final style = _trendingStyles[index];
                    final imageUrl = "${ApiConfig.baseUrl}/public/hairstyles/${style.representingImageUrl}";
                    print('Constructed image URL for ${style.hairstyleName}: $imageUrl');
                    return _TrendingCard(
                      representingImageUrl: style.representingImageUrl,
                      title: style.hairstyleName,
                      gender: style.gender,
                      length: style.category,
                      width: screenWidth * 0.4,
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
}

class _FeatureIcon extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;
  final VoidCallback? onTap;

  const _FeatureIcon({
    required this.icon,
    required this.text,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: screenWidth * 0.06,
            backgroundColor: color.withOpacity(0.1),
            child: Icon(icon, color: color, size: screenWidth * 0.06),
          ),
          SizedBox(height: screenWidth * 0.015),
          Text(
            text,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(fontSize: screenWidth * 0.03),
          ),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  //final String imageUrl;
  final String representingImageUrl;
  final String title;
  final String gender;
  final String length;
  final double width;

  const _TrendingCard({
    // required this.imageUrl,
    required this.representingImageUrl,
    required this.title,
    required this.gender,
    required this.length,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(14),
            child: Image.network(
              "${ApiConfig.baseUrl}/public/hairstyles/$representingImageUrl",
              height: double.infinity,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                print('Error loading image: ${ApiConfig.baseUrl}/public/hairstyles/$representingImageUrl');
                print('Error: $error');
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.broken_image, color: Colors.grey),
                      const SizedBox(height: 4),
                      Text(
                        'Image Error',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                );
              },
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: double.infinity,
                  width: double.infinity,
                  color: Colors.grey[200],
                  child: Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded / 
                            loadingProgress.expectedTotalBytes!
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.pinkAccent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Text(
                "Trending",
                style: TextStyle(color: Colors.black, fontSize: 10),
              ),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 8,
            child: Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: 8,
            child: Text(
              "$gender · $length",
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
          ),
          Positioned(
            bottom: 10,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Text(
                "Try On",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
