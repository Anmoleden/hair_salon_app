import 'package:hair_salon/screens/detectfaceshape.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required String loginMethod});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  final List<Map<String, String>> _trendingStyles = [
    {
      'imageUrl': "https://i.imgur.com/3yNCE0N.jpg",
      'title': "Classic Bob",
      'gender': "Female",
      'length': "medium",
    },
    {
      'imageUrl': "https://i.imgur.com/xvw3VZk.jpg",
      'title': "Textured Crop",
      'gender': "Male",
      'length': "short",
    },
    {
      'imageUrl': "https://i.imgur.com/KO5WzwP.jpg",
      'title': "Wavy Shag",
      'gender': "Female",
      'length': "long",
    },
  ];

  void _onBottomNavTap(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        currentIndex: _selectedIndex,
        onTap: _onBottomNavTap,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.trending_up), label: "Trending"),
          BottomNavigationBarItem(icon: Icon(Icons.favorite_border), label: "Favorites"),
          BottomNavigationBarItem(icon: Icon(Icons.person_outline), label: "Profile"),
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
                "Home",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.055,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: screenHeight * 0.01),
              Text(
                "Hello, Beautiful!",
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
                          builder: (context) => const DetectFaceShapeScreen(),
                        ),
                      );
                    },
                  ),
                  _FeatureIcon(icon: Icons.content_cut, text: "Try\nHairstyles", color: Colors.cyan),
                  _FeatureIcon(icon: Icons.trending_up, text: "Trending", color: Colors.purple),
                  _FeatureIcon(icon: Icons.history, text: "History", color: Colors.green),
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
                        backgroundColor: const Color.fromARGB(255, 255, 64, 191),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.04,
                          vertical: screenHeight * 0.015,
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt, color: Colors.white),
                      label: const Text("Detect Face Shape", style: TextStyle(color: Colors.white)),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const DetectFaceShapeScreen()),
                        );
                      },
                    ),
                  ],
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Trending Hairstyles",
                    style: GoogleFonts.poppins(
                      fontWeight: FontWeight.w600,
                      fontSize: screenWidth * 0.042,
                    ),
                  ),
                  Text("See All", style: GoogleFonts.poppins(color: Colors.pinkAccent)),
                ],
              ),
              SizedBox(height: screenHeight * 0.015),
              SizedBox(
                height: screenHeight * 0.25,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _trendingStyles.length,
                  itemBuilder: (context, index) {
                    final style = _trendingStyles[index];
                    return _TrendingCard(
                      imageUrl: style['imageUrl']!,
                      title: style['title']!,
                      gender: style['gender']!,
                      length: style['length']!,
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
          Text(text, textAlign: TextAlign.center, style: GoogleFonts.poppins(fontSize: screenWidth * 0.03)),
        ],
      ),
    );
  }
}

class _TrendingCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String gender;
  final String length;
  final double width;

  const _TrendingCard({
    required this.imageUrl,
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
            child: Image.network(imageUrl, height: double.infinity, width: double.infinity, fit: BoxFit.cover),
          ),
          Positioned(
            top: 8,
            left: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(color: Colors.pinkAccent, borderRadius: BorderRadius.circular(10)),
              child: const Text("Trending", style: TextStyle(color: Colors.black, fontSize: 10)),
            ),
          ),
          Positioned(
            bottom: 28,
            left: 8,
            child: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          Positioned(
            bottom: 10,
            left: 8,
            child: Text("$gender · $length", style: const TextStyle(color: Colors.white70, fontSize: 12)),
          ),
          Positioned(
            bottom: 10,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: const Text("Try On", style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
            ),
          ),
        ],
      ),
    );
  }
}
