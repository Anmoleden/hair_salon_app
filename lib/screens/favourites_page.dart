// // // // // import 'package:flutter/material.dart';
// // // // // import 'package:google_fonts/google_fonts.dart';
// // // // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // // // import '../models/hairstyle_model.dart';
// // // // // import '../services/favorite_services.dart';

// // // // // class FavouritesPage extends StatefulWidget {
// // // // //   const FavouritesPage({super.key});

// // // // //   @override
// // // // //   State<FavouritesPage> createState() => _FavouritesPageState();
// // // // // }

// // // // // class _FavouritesPageState extends State<FavouritesPage> {
// // // // //   final storage = FlutterSecureStorage();
// // // // //   List<Hairstyle> favorites = [];
// // // // //   bool isLoading = true;

// // // // //   @override
// // // // //   void initState() {
// // // // //     super.initState();
// // // // //     _loadFavorites();
// // // // //   }

// // // // //   Future<void> _loadFavorites() async {
// // // // //     final userId = await storage.read(key: 'userId');
// // // // //     print('UerId from storage: $userId');
// // // // //     if (userId == null) return;

// // // // //     try {
// // // // //       final fetched = await FavoriteService.fetchFavorites(userId);
// // // // //       print('Fetched favorites count: ${fetched.length}');
// // // // //       setState(() {
// // // // //         favorites = fetched;
// // // // //         isLoading = false;
// // // // //       });
// // // // //     } catch (e) {
// // // // //       setState(() => isLoading = false);
// // // // //       print('Error loading favorites: $e');
// // // // //     }
// // // // //   }

// // // // //   @override
// // // // //   Widget build(BuildContext context) {
// // // // //     if (isLoading) {
// // // // //       return const Center(child: CircularProgressIndicator());
// // // // //     }

// // // // //     if (favorites.isEmpty) {
// // // // //       return Center(
// // // // //         child: Padding(
// // // // //           padding: const EdgeInsets.all(24.0),
// // // // //           child: Column(
// // // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // // //             children: [
// // // // //               Icon(Icons.favorite_border, size: 80, color: Colors.pinkAccent),
// // // // //               const SizedBox(height: 20),
// // // // //               Text(
// // // // //                 "Your Favorites",
// // // // //                 style: GoogleFonts.poppins(
// // // // //                   fontSize: 22,
// // // // //                   fontWeight: FontWeight.bold,
// // // // //                 ),
// // // // //               ),
// // // // //               const SizedBox(height: 10),
// // // // //               Text(
// // // // //                 "You haven’t added any hairstyles to your favorites yet.",
// // // // //                 textAlign: TextAlign.center,
// // // // //                 style: GoogleFonts.poppins(
// // // // //                   fontSize: 16,
// // // // //                   color: Colors.grey[600],
// // // // //                 ),
// // // // //               ),
// // // // //             ],
// // // // //           ),
// // // // //         ),
// // // // //       );
// // // // //     }

// // // // //     return ListView.builder(
// // // // //       padding: const EdgeInsets.all(16),
// // // // //       itemCount: favorites.length,
// // // // //       itemBuilder: (context, index) {
// // // // //         final hair = favorites[index];
// // // // //         return Card(
// // // // //           child: ListTile(
// // // // //             leading: Image.network(
// // // // //               hair.representingImageUrl,
// // // // //               width: 50,
// // // // //               fit: BoxFit.cover,
// // // // //             ),
// // // // //             title: Text(hair.hairstyleName),
// // // // //             subtitle: Text(hair.category),
// // // // //             trailing: IconButton(
// // // // //               icon: const Icon(Icons.favorite, color: Colors.red),
// // // // //               onPressed: () async {
// // // // //                 final userId = await storage.read(key: 'userId');
// // // // //                 if (userId == null) return;

// // // // //                 try {
// // // // //                   await FavoriteService.addFavorite(
// // // // //                     userId,
// // // // //                     hair.hairstyleId,
// // // // //                   ); // toggle
// // // // //                   ScaffoldMessenger.of(
// // // // //                     context,
// // // // //                   ).showSnackBar(SnackBar(content: Text('Added to favorites')));
// // // // //                   _loadFavorites(); // Refresh list
// // // // //                 } catch (e) {
// // // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // // //                     SnackBar(content: Text('Failed to update favorite')),
// // // // //                   );
// // // // //                 }
// // // // //               },
// // // // //             ),
// // // // //           ),
// // // // //         );
// // // // //       },
// // // // //     );
// // // // //   }
// // // // // }

// // // // import 'package:flutter/material.dart';
// // // // import 'package:google_fonts/google_fonts.dart';
// // // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // // import '../models/hairstyle_model.dart';
// // // // import '../services/favorite_services.dart';

// // // // class FavouritesPage extends StatefulWidget {
// // // //   const FavouritesPage({super.key});

// // // //   @override
// // // //   State<FavouritesPage> createState() => _FavouritesPageState();
// // // // }

// // // // class _FavouritesPageState extends State<FavouritesPage> {
// // // //   final storage = FlutterSecureStorage();
// // // //   List<Hairstyle> favorites = [];
// // // //   bool isLoading = true;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     // Call the test function instead of _loadFavorites() temporarily
// // // //     testFetchFavorites();
// // // //     // When debugging done, replace with _loadFavorites();
// // // //   }

// // // //   // Temporary test function to check if fetching favorites works
// // // //   Future<void> testFetchFavorites() async {
// // // //     final userId = await storage.read(key: 'userId');
// // // //     if (userId == null) {
// // // //       print('No userId found in storage');
// // // //       setState(() {
// // // //         isLoading = false;
// // // //       });
// // // //       return;
// // // //     }

// // // //     try {
// // // //       final favoritesList = await FavoriteService.fetchFavorites(userId);
// // // //       print('Favorites fetched count: ${favoritesList.length}');
// // // //       for (var f in favoritesList) {
// // // //         print('Favorite Hairstyle: ${f.hairstyleName}');
// // // //       }

// // // //       setState(() {
// // // //         favorites = favoritesList;
// // // //         isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       print('Error fetching favorites in test: $e');
// // // //       setState(() {
// // // //         isLoading = false;
// // // //       });
// // // //     }
// // // //   }

// // // //   Future<void> _loadFavorites() async {
// // // //     final userId = await storage.read(key: 'userId');
// // // //     if (userId == null) return;

// // // //     try {
// // // //       final fetched = await FavoriteService.fetchFavorites(userId);
// // // //       setState(() {
// // // //         favorites = fetched;
// // // //         isLoading = false;
// // // //       });
// // // //     } catch (e) {
// // // //       setState(() => isLoading = false);
// // // //       print('Error loading favorites: $e');
// // // //     }
// // // //   }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     if (isLoading) {
// // // //       return const Center(child: CircularProgressIndicator());
// // // //     }

// // // //     if (favorites.isEmpty) {
// // // //       return Center(
// // // //         child: Padding(
// // // //           padding: const EdgeInsets.all(24.0),
// // // //           child: Column(
// // // //             mainAxisAlignment: MainAxisAlignment.center,
// // // //             children: [
// // // //               Icon(Icons.favorite_border, size: 80, color: Colors.pinkAccent),
// // // //               const SizedBox(height: 20),
// // // //               Text(
// // // //                 "Your Favorites",
// // // //                 style: GoogleFonts.poppins(
// // // //                   fontSize: 22,
// // // //                   fontWeight: FontWeight.bold,
// // // //                 ),
// // // //               ),
// // // //               const SizedBox(height: 10),
// // // //               Text(
// // // //                 "You haven’t added any hairstyles to your favorites yet.",
// // // //                 textAlign: TextAlign.center,
// // // //                 style: GoogleFonts.poppins(
// // // //                   fontSize: 16,
// // // //                   color: Colors.grey[600],
// // // //                 ),
// // // //               ),
// // // //             ],
// // // //           ),
// // // //         ),
// // // //       );
// // // //     }

// // // //     return ListView.builder(
// // // //       padding: const EdgeInsets.all(16),
// // // //       itemCount: favorites.length,
// // // //       itemBuilder: (context, index) {
// // // //         final hair = favorites[index];
// // // //         return Card(
// // // //           child: ListTile(
// // // //             leading: Image.network(
// // // //               hair.representingImageUrl,
// // // //               width: 50,
// // // //               fit: BoxFit.cover,
// // // //             ),
// // // //             title: Text(hair.hairstyleName),
// // // //             subtitle: Text(hair.category),
// // // //             trailing: IconButton(
// // // //               icon: const Icon(Icons.favorite, color: Colors.red),
// // // //               onPressed: () async {
// // // //                 final userId = await storage.read(key: 'userId');
// // // //                 if (userId == null) return;

// // // //                 try {
// // // //                   await FavoriteService.addFavorite(
// // // //                     userId,
// // // //                     hair.hairstyleId,
// // // //                   ); // toggle
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     const SnackBar(content: Text('Added to favorites')),
// // // //                   );
// // // //                   _loadFavorites(); // Refresh list
// // // //                 } catch (e) {
// // // //                   ScaffoldMessenger.of(context).showSnackBar(
// // // //                     const SnackBar(content: Text('Failed to update favorite')),
// // // //                   );
// // // //                 }
// // // //               },
// // // //             ),
// // // //           ),
// // // //         );
// // // //       },
// // // //     );
// // // //   }
// // // // }

// // // import 'package:flutter/material.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // import '../models/hairstyle_model.dart';
// // // import '../services/favorite_services.dart';

// // // class FavouritesPage extends StatefulWidget {
// // //   const FavouritesPage({super.key});

// // //   @override
// // //   State<FavouritesPage> createState() => _FavouritesPageState();
// // // }

// // // class _FavouritesPageState extends State<FavouritesPage> {
// // //   final storage = FlutterSecureStorage();
// // //   List<Hairstyle> favorites = [];
// // //   bool isLoading = true;

// // //   // Add the test method here inside the state class
// // //   Future<void> testFetchFavorites() async {
// // //     final userId = await storage.read(key: 'userId');
// // //     if (userId == null) {
// // //       print('No userId found in storage');
// // //       return;
// // //     }
// // //     try {
// // //       final favoritesList = await FavoriteService.fetchFavorites(userId);
// // //       print('Favorites fetched count: ${favoritesList.length}');
// // //       for (var f in favoritesList) {
// // //         print('Favorite Hairstyle: ${f.hairstyleName}');
// // //       }
// // //     } catch (e) {
// // //       print('Error fetching favorites in test: $e');
// // //     }
// // //   }


// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     testFetchFavorites();
// // //    // _loadFavorites();
// // //   }

// // //   Future<void> _loadFavorites() async {
// // //     final userId = await storage.read(key: 'userId');
// // //     if (userId == null) {
// // //       print('No userId found in storage');
// // //       setState(() {
// // //         favorites = [];
// // //         isLoading = false;
// // //       });
// // //       return;
// // //     }

// // //     try {
// // //       final fetched = await FavoriteService.fetchFavorites(userId);
// // //       print('Fetched favorites count in page: ${fetched.length}');
// // //       for (var fav in fetched) {
// // //         print('Fav Hairstyle in page: ${fav.hairstyleName}');
// // //       }
// // //       setState(() {
// // //         favorites = fetched;
// // //         isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => isLoading = false);
// // //       print('Error loading favorites: $e');
// // //     }
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     if (isLoading) {
// // //       return const Center(child: CircularProgressIndicator());
// // //     }

// // //     if (favorites.isEmpty) {
// // //       return Center(
// // //         child: Padding(
// // //           padding: const EdgeInsets.all(24.0),
// // //           child: Column(
// // //             mainAxisAlignment: MainAxisAlignment.center,
// // //             children: [
// // //               Icon(Icons.favorite_border, size: 80, color: Colors.pinkAccent),
// // //               const SizedBox(height: 20),
// // //               Text(
// // //                 "Your Favorites",
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 22,
// // //                   fontWeight: FontWeight.bold,
// // //                 ),
// // //               ),
// // //               const SizedBox(height: 10),
// // //               Text(
// // //                 "You haven’t added any hairstyles to your favorites yet.",
// // //                 textAlign: TextAlign.center,
// // //                 style: GoogleFonts.poppins(
// // //                   fontSize: 16,
// // //                   color: Colors.grey[600],
// // //                 ),
// // //               ),
// // //             ],
// // //           ),
// // //         ),
// // //       );
// // //     }

// // //     return ListView.builder(
// // //       padding: const EdgeInsets.all(16),
// // //       itemCount: favorites.length,
// // //       itemBuilder: (context, index) {
// // //         final hair = favorites[index];
// // //         return Card(
// // //           child: ListTile(
// // //             leading: Image.network(
// // //               hair.representingImageUrl,
// // //               width: 50,
// // //               fit: BoxFit.cover,
// // //               errorBuilder: (context, error, stackTrace) {
// // //                 return const Icon(Icons.broken_image);
// // //               },
// // //             ),
// // //             title: Text(hair.hairstyleName),
// // //             subtitle: Text(hair.category),
// // //             trailing: IconButton(
// // //               icon: const Icon(Icons.favorite, color: Colors.red),
// // //               onPressed: () async {
// // //                 final userId = await storage.read(key: 'userId');
// // //                 if (userId == null) return;

// // //                 try {
// // //                   await FavoriteService.addFavorite(
// // //                     userId,
// // //                     hair.hairstyleId,
// // //                   ); // toggle
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(content: Text('Added to favorites')),
// // //                   );
// // //                   _loadFavorites(); // Refresh list
// // //                 } catch (e) {
// // //                   ScaffoldMessenger.of(context).showSnackBar(
// // //                     const SnackBar(content: Text('Failed to update favorite')),
// // //                   );
// // //                 }
// // //               },
// // //             ),
// // //           ),
// // //         );
// // //       },
// // //     );
// // //   }
// // // }

// // // favorites_page.dart
// // import 'package:flutter/material.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import '../models/hairstyle_model.dart';
// // import '../services/favorite_services.dart';
// // import 'hairstyle_details_screen.dart';

// // class FavoritesPage extends StatefulWidget {
// //   const FavoritesPage({super.key});

// //   @override
// //   State<FavoritesPage> createState() => _FavoritesPageState();
// // }

// // class _FavoritesPageState extends State<FavoritesPage> {
// //   List<Hairstyle> favorites = [];
// //   bool isLoading = true;
// //   String? errorMessage;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadFavorites();
// //   }

// //   Future<void> _loadFavorites() async {
// //     final userId = await const FlutterSecureStorage().read(key: 'userId');
// //     if (userId == null) {
// //       setState(() {
// //         errorMessage = 'User not logged in.';
// //         isLoading = false;
// //       });
// //       return;
// //     }

// //     try {
// //       final fetchedFavorites = await FavoriteService.fetchFavorites(userId);
// //       setState(() {
// //         favorites = fetchedFavorites;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() {
// //         errorMessage = 'Failed to load favorites.';
// //         isLoading = false;
// //       });
// //     }
// //   }

// //   @override
// //   Widget build(BuildContext context) {
// //     return Scaffold(
// //       backgroundColor: const Color(0xFFF9F9F9),
// //       appBar: AppBar(
// //         title: Text(
// //           'Favorites',
// //           style: GoogleFonts.poppins(
// //             fontSize: 22,
// //             fontWeight: FontWeight.w600,
// //             color: Colors.black,
// //           ),
// //         ),
// //         backgroundColor: Colors.white,
// //         elevation: 2,
// //       ),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
// //           : errorMessage != null
// //               ? Center(child: Text(errorMessage!, style: GoogleFonts.poppins(fontSize: 16)))
// //               : favorites.isEmpty
// //                   ? Center(
// //                       child: Text(
// //                         "No favorite hairstyles yet.",
// //                         style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey),
// //                       ),
// //                     )
// //                   : ListView.builder(
// //                       itemCount: favorites.length,
// //                       itemBuilder: (context, index) {
// //                         final style = favorites[index];
// //                         return ListTile(
// //                           leading: CircleAvatar(
// //                             backgroundImage: NetworkImage(style.representingImageUrl),
// //                           ),
// //                           title: Text(style.hairstyleName),
// //                           subtitle: Text(style.gender),
// //                           onTap: () {
// //                             Navigator.push(
// //                               context,
// //                               MaterialPageRoute(
// //                                 builder: (_) => HairstyleDetailsScreen(hairstyle: style),
// //                               ),
// //                             );
// //                           },
// //                         );
// //                       },
// //                     ),
// //     );
// //   }
// // }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import '../models/hairstyle_model.dart';
// import '../services/favorite_services.dart';
// import 'try_on_screen.dart';

// class FavoritesPage extends StatefulWidget {
//   const FavoritesPage({super.key});

//   @override
//   State<FavoritesPage> createState() => _FavoritesPageState();
// }

// class _FavoritesPageState extends State<FavoritesPage> {
//   List<Hairstyle> favoriteHairstyles = [];
//   bool isLoading = true;
//   File? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchFavorites();
//   }

//   Future<void> _fetchFavorites() async {
//     final userId = await const FlutterSecureStorage().read(key: 'userId');
//     if (userId == null) return;

//     try {
//       final favorites = await FavoriteService.fetchFavorites(userId);
//       setState(() {
//         favoriteHairstyles = favorites;
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() {
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Failed to load favorites: $e')),
//       );
//     }
//   }

//   void _tryOnHairstyle(Hairstyle style) {
//     if (_capturedImage == null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please capture a photo first')),
//       );
//       return;
//     }

//     Navigator.push(
//       context,
//       MaterialPageRoute(
//         builder: (_) => TryOnScreenPage(
//           hairstyle: style,
//           capturedImage: _capturedImage!,
//         ),
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "My Favorites",
//           style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body: isLoading
//           ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
//           : favoriteHairstyles.isEmpty
//               ? Center(child: Text("No favorites yet!", style: GoogleFonts.poppins()))
//               : GridView.builder(
//                   padding: const EdgeInsets.all(12),
//                   itemCount: favoriteHairstyles.length,
//                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//                     crossAxisCount: 2, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 0.72,
//                   ),
//                   itemBuilder: (context, index) {
//                     final style = favoriteHairstyles[index];
//                     return Material(
//                       elevation: 6,
//                       borderRadius: BorderRadius.circular(16),
//                       clipBehavior: Clip.hardEdge,
//                       child: Stack(
//                         children: [
//                           Positioned.fill(
//                             child: Image.network(
//                               style.representingImageUrl,
//                               fit: BoxFit.cover,
//                               errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
//                             ),
//                           ),
//                           Positioned(
//                             top: 8,
//                             right: 8,
//                             child: CircleAvatar(
//                               radius: 16,
//                               backgroundColor: Colors.white.withOpacity(0.9),
//                               child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
//                             ),
//                           ),
//                           Positioned(
//                             bottom: 0,
//                             left: 0,
//                             right: 0,
//                             child: Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: BoxDecoration(
//                                 gradient: LinearGradient(
//                                   begin: Alignment.topCenter,
//                                   end: Alignment.bottomCenter,
//                                   colors: [Colors.transparent, Colors.black.withAlpha(180)],
//                                 ),
//                               ),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   Text(
//                                     style.hairstyleName,
//                                     overflow: TextOverflow.ellipsis,
//                                     style: GoogleFonts.poppins(color: Colors.white, fontWeight: FontWeight.bold),
//                                   ),
//                                   Text(
//                                     style.gender,
//                                     style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
//                                   ),
//                                   const SizedBox(height: 6),
//                                   ElevatedButton(
//                                     onPressed: () => _tryOnHairstyle(style),
//                                     style: ElevatedButton.styleFrom(
//                                       backgroundColor: Colors.white,
//                                       foregroundColor: Colors.pinkAccent,
//                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
//                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
//                                     ),
//                                     child: Text("Try On", style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../classifiers/hairstyle_model.dart';
import '../classifiers/filters_model.dart';
import '../services/favorite_services.dart';
import '../widgets/filter_bottom_sheet.dart';
import 'try_on_screen.dart';
import '../config/api_config.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  List<Hairstyle> favoriteHairstyles = [];
  List<Hairstyle> filteredFavorites = [];
  Filters currentFilters = Filters();
  bool isLoading = true;
  File? _capturedImage;

  @override
  void initState() {
    super.initState();
    _fetchFavorites();
  }

  // Future<void> _fetchFavorites() async {
  //   final userId = await const FlutterSecureStorage().read(key: 'userId');
  //   if (userId == null) return;

  //   try {
  //     final favorites = await FavoriteService.fetchFavorites(userId);
  //     setState(() {
  //       favoriteHairstyles = favorites;
  //       isLoading = false;
  //     });
  //     _applyFilters();
  //   } catch (e) {
  //     setState(() {
  //       isLoading = false;
  //     });
  //     ScaffoldMessenger.of(context).showSnackBar(
  //       SnackBar(content: Text('Failed to load favorites: $e')),
  //     );
  //   }
  // }
  Future<void> _fetchFavorites() async {
  final userId = await const FlutterSecureStorage().read(key: 'userId');
  if (userId == null) return;

  try {
    final favorites = await FavoriteService.fetchFavorites(userId);

    // Remove duplicates by hairstyle id
    final uniqueFavoritesMap = <String, Hairstyle>{};
    for (var style in favorites) {
      uniqueFavoritesMap[style.id] = style;
    }
    final uniqueFavorites = uniqueFavoritesMap.values.toList();

    setState(() {
      favoriteHairstyles = uniqueFavorites;
      isLoading = false;
    });

    _applyFilters();
  } catch (e) {
    setState(() {
      isLoading = false;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to load favorites: $e')),
    );
  }
}

  void _applyFilters() {
    setState(() {
      filteredFavorites = favoriteHairstyles.where((style) {
        return currentFilters.apply(style.gender, style.category ?? '');
      }).toList();
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      builder: (_) {
        return FilterBottomSheet(
          currentFilters: currentFilters,
          onApply: (filters) {
            currentFilters = filters;
            _applyFilters();
          }, 
          showGenderFilter: false,
        );
      },
    );
  }

  void _tryOnHairstyle(Hairstyle style) {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo first')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TryOnScreenPage(
          hairstyle: style,
          capturedImage: _capturedImage!,
          isMale: style.gender.toLowerCase() == 'male',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "My Favorites",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_alt_outlined, color: Colors.black),
            onPressed: _showFilterSheet,
          )
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
          : filteredFavorites.isEmpty
              ? Center(
                  child: Text("No favorites matching filters!",
                      style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey)))
              : GridView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: filteredFavorites.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                    childAspectRatio: 0.72,
                  ),
                  itemBuilder: (context, index) {
                    final style = filteredFavorites[index];
                    return Material(
                      elevation: 6,
                      borderRadius: BorderRadius.circular(16),
                      clipBehavior: Clip.hardEdge,
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Image.network(
                                    "${ApiConfig.baseUrl}/public/images/hairstyles/${style.representingImageUrl}",
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: CircleAvatar(
                              radius: 16,
                              backgroundColor: Colors.white.withOpacity(0.9),
                              child: const Icon(Icons.favorite, color: Colors.pinkAccent, size: 18),
                            ),
                          ),
                          Positioned(
                            bottom: 0,
                            left: 0,
                            right: 0,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [Colors.transparent, Colors.black.withAlpha(180)],
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    style.hairstyleName,
                                    overflow: TextOverflow.ellipsis,
                                    style: GoogleFonts.poppins(
                                        color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                    style.gender,
                                    style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
                                  ),
                                  const SizedBox(height: 6),
                                  ElevatedButton(
                                    onPressed: () => _tryOnHairstyle(style),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.pinkAccent,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                    ),
                                    child: Text("Try On",
                                        style: GoogleFonts.poppins(fontWeight: FontWeight.w600)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
    );
  }
}
