// // // // import 'dart:io';

// // // // import 'package:flutter/material.dart';
// // // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // // import 'package:google_fonts/google_fonts.dart';
// // // // import 'package:intl/intl.dart';
// // // // import '../models/hairstyle_model.dart';
// // // // // ignore: unused_import
// // // // import 'try_on_screen.dart';
// // // // import '../services/history_services.dart'; // Adjust path as needed

// // // // class HistoryPage extends StatefulWidget {
// // // //   const HistoryPage({super.key});

// // // //   @override
// // // //   State<HistoryPage> createState() => _HistoryPageState();
// // // // }

// // // // class _HistoryPageState extends State<HistoryPage> {
// // // //   List<Hairstyle> historyList = [];
// // // //   bool isLoading = true;
// // // //   String? error;
// // // //   File? _capturedImage;

// // // //   @override
// // // //   void initState() {
// // // //     super.initState();
// // // //     fetchHistory();
// // // //   }

// // // //   // Future<void> fetchHistory() async {
// // // //   //   try {
// // // //   //     final List<Hairstyle> data = await ApiService.fetchHistory(); // Make sure this method exists
// // // //   //     setState(() {
// // // //   //       historyList = data;
// // // //   //       isLoading = false;
// // // //   //     });
// // // //   //   } catch (e) {
// // // //   //     setState(() {
// // // //   //       error = e.toString();
// // // //   //       isLoading = false;
// // // //   //     });
// // // //   //   }
// // // //   //}
// // // //   Future<void> fetchHistory() async {
// // // //   try {
// // // //     const storage = FlutterSecureStorage();
// // // //     final userId = await storage.read(key: 'userId');

// // // //     if (userId == null) {
// // // //       setState(() {
// // // //         error = "User not logged in.";
// // // //         isLoading = false;
// // // //       });
// // // //       return;
// // // //     }

// // // //     final List<Hairstyle> data = await ApiService.fetchHistory(userId);
// // // //     setState(() {
// // // //       historyList = data;
// // // //       isLoading = false;
// // // //     });
// // // //   } catch (e) {
// // // //     setState(() {
// // // //       error = e.toString();
// // // //       isLoading = false;
// // // //     });
// // // //   }
// // // // }

// // // //   @override
// // // //   Widget build(BuildContext context) {
// // // //     return Scaffold(
// // // //       backgroundColor: const Color(0xFFF9F9F9),
// // // //       appBar: AppBar(
// // // //         title: Text(
// // // //           "History",
// // // //           style: GoogleFonts.poppins(
// // // //             fontSize: 22,
// // // //             fontWeight: FontWeight.w600,
// // // //             color: Colors.black,
// // // //           ),
// // // //         ),
// // // //         backgroundColor: Colors.white,
// // // //         elevation: 2,
// // // //       ),
// // // //       body: isLoading
// // // //           ? const Center(child: CircularProgressIndicator())
// // // //           : error != null
// // // //               ? Center(child: Text("Error: $error"))
// // // //               : historyList.isEmpty
// // // //                   ? Center(
// // // //                       child: Column(
// // // //                         mainAxisAlignment: MainAxisAlignment.center,
// // // //                         children: [
// // // //                           const Icon(Icons.history, size: 60, color: Colors.grey),
// // // //                           const SizedBox(height: 10),
// // // //                           Text(
// // // //                             "You haven't tried any hairstyles yet!",
// // // //                             style: GoogleFonts.poppins(
// // // //                               fontSize: 16,
// // // //                               color: Colors.grey,
// // // //                             ),
// // // //                           ),
// // // //                           const SizedBox(height: 20),
// // // //                           ElevatedButton(
// // // //                             onPressed: () => Navigator.pop(context),
// // // //                             style: ElevatedButton.styleFrom(
// // // //                               backgroundColor: Colors.pinkAccent,
// // // //                               padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
// // // //                               shape: RoundedRectangleBorder(
// // // //                                 borderRadius: BorderRadius.circular(20),
// // // //                               ),
// // // //                             ),
// // // //                             child: Text(
// // // //                               "Try Now",
// // // //                               style: GoogleFonts.poppins(
// // // //                                 fontSize: 14,
// // // //                                 color: Colors.white,
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         ],
// // // //                       ),
// // // //                     )
// // // //                   : ListView.builder(
// // // //                       padding: const EdgeInsets.all(12),
// // // //                       itemCount: historyList.length,
// // // //                       itemBuilder: (context, index) {
// // // //                         final style = historyList[index];
// // // //                         return Container(
// // // //                           margin: const EdgeInsets.only(bottom: 14),
// // // //                           decoration: BoxDecoration(
// // // //                             color: Colors.white,
// // // //                             borderRadius: BorderRadius.circular(16),
// // // //                             boxShadow: [
// // // //                               BoxShadow(
// // // //                                 color: Colors.black.withOpacity(0.05),
// // // //                                 blurRadius: 8,
// // // //                                 offset: const Offset(0, 4),
// // // //                               ),
// // // //                             ],
// // // //                           ),
// // // //                           child: ListTile(
// // // //                             contentPadding: const EdgeInsets.all(12),
// // // //                             leading: ClipRRect(
// // // //                               borderRadius: BorderRadius.circular(10),
// // // //                               child: Image.network(
// // // //                                 style.representingImageUrl,
// // // //                                 width: 60,
// // // //                                 height: 60,
// // // //                                 fit: BoxFit.cover,
// // // //                               ),
// // // //                             ),
// // // //                             title: Text(
// // // //                               style.hairstyleName,
// // // //                               style: GoogleFonts.poppins(
// // // //                                 fontSize: 15,
// // // //                                 fontWeight: FontWeight.w600,
// // // //                               ),
// // // //                             ),
// // // //                             subtitle: Column(
// // // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // // //                               children: [
// // // //                                 const SizedBox(height: 4),
// // // //                                 Text(
// // // //                                   '${style.gender} ',
// // // //                                   style: GoogleFonts.poppins(
// // // //                                     fontSize: 12,
// // // //                                     color: Colors.grey[700],
// // // //                                   ),
// // // //                                 ),
// // // //                                 const SizedBox(height: 4),
// // // //                                 Text(
// // // //                                   'Tried on: ${DateFormat.yMMMd().format(style.triedOn ?? DateTime.now())}',
// // // //                                   style: GoogleFonts.poppins(
// // // //                                     fontSize: 12,
// // // //                                     color: Colors.grey[600],
// // // //                                   ),
// // // //                                 ),
// // // //                                 const SizedBox(height: 6),

// // // //                                 Wrap(
// // // //                                   spacing: 6,
// // // //                                   children: (style.tags ?? []).map((tag) {
// // // //                                     return Chip(
// // // //                                       label: Text(tag),
// // // //                                       labelStyle: GoogleFonts.poppins(fontSize: 11),
// // // //                                       backgroundColor: Colors.grey.shade100,
// // // //                                       shape: RoundedRectangleBorder(
// // // //                                         borderRadius: BorderRadius.circular(8),
// // // //                                       ),
// // // //                                     );
// // // //                                   }).toList(),
// // // //                                 ),
// // // //                               ],
// // // //                             ),
// // // //                             trailing: ElevatedButton(
// // // //                               onPressed: () {
// // // //                                 Navigator.push(
// // // //                                   context,
// // // //                                   MaterialPageRoute(
// // // //                                     builder: (_) => TryOnScreenPage(
// // // //                                       hairstyle: style,
// // // //                                       capturedImage: _capturedImage!,
// // // //                                       ),
// // // //                                   ),
// // // //                                 );
// // // //                               },
// // // //                               style: ElevatedButton.styleFrom(
// // // //                                 backgroundColor: Colors.white,
// // // //                                 foregroundColor: Colors.pinkAccent,
// // // //                                 side: const BorderSide(color: Colors.pinkAccent),
// // // //                                 padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
// // // //                                 shape: RoundedRectangleBorder(
// // // //                                   borderRadius: BorderRadius.circular(20),
// // // //                                 ),
// // // //                               ),
// // // //                               child: Text(
// // // //                                 "Try Again",
// // // //                                 style: GoogleFonts.poppins(
// // // //                                   fontSize: 12,
// // // //                                   fontWeight: FontWeight.w500,
// // // //                                 ),
// // // //                               ),
// // // //                             ),
// // // //                           ),
// // // //                         );
// // // //                       },
// // // //                     ),
// // // //     );
// // // //   }
// // // // }

// // // import 'dart:io';
// // // import 'package:flutter/material.dart';
// // // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // // import 'package:google_fonts/google_fonts.dart';
// // // import '../models/hairstyle_model.dart';
// // // import '../services/history_services.dart';
// // // import 'try_on_screen.dart';

// // // class HistoryPage extends StatefulWidget {
// // //   const HistoryPage({super.key});

// // //   @override
// // //   State<HistoryPage> createState() => _HistoryPageState();
// // // }

// // // class _HistoryPageState extends State<HistoryPage> {
// // //   List<Hairstyle> historyHairstyles = [];
// // //   bool isLoading = true;
// // //   File? _capturedImage;

// // //   @override
// // //   void initState() {
// // //     super.initState();
// // //     _fetchHistory();
// // //   }

// // //   Future<void> _fetchHistory() async {
// // //     final userId = await const FlutterSecureStorage().read(key: 'userId');
// // //     if (userId == null) return;

// // //     try {
// // //       final history = await HistoryService.fetchHistory(userId);
// // //       print('Feteched history count:${history.length}');
// // //       setState(() {
// // //         historyHairstyles = history;
// // //         isLoading = false;
// // //       });
// // //     } catch (e) {
// // //       setState(() => isLoading = false);
// // //       ScaffoldMessenger.of(
// // //         context,
// // //       ).showSnackBar(SnackBar(content: Text('Failed to load history: $e')));
// // //     }
// // //   }

// // //   void _tryOnHairstyle(Hairstyle style) {
// // //     if (_capturedImage == null) {
// // //       ScaffoldMessenger.of(context).showSnackBar(
// // //         const SnackBar(content: Text('Please capture a photo first')),
// // //       );
// // //       return;
// // //     }

// // //     Navigator.push(
// // //       context,
// // //       MaterialPageRoute(
// // //         builder:
// // //             (_) => TryOnScreenPage(
// // //               hairstyle: style,
// // //               capturedImage: _capturedImage!,
// // //             ),
// // //       ),
// // //     );
// // //   }

// // //   @override
// // //   Widget build(BuildContext context) {
// // //     return Scaffold(
// // //       appBar: AppBar(
// // //         title: Text(
// // //           "History",
// // //           style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
// // //         ),
// // //       ),
// // //       body:
// // //           isLoading
// // //               ? const Center(
// // //                 child: CircularProgressIndicator(color: Colors.pinkAccent),
// // //               )
// // //               : historyHairstyles.isEmpty
// // //               ? Center(
// // //                 child: Text("No history yet!", style: GoogleFonts.poppins()),
// // //               )
// // //               : GridView.builder(
// // //                 padding: const EdgeInsets.all(12),
// // //                 itemCount: historyHairstyles.length,
// // //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// // //                   crossAxisCount: 2,
// // //                   crossAxisSpacing: 12,
// // //                   mainAxisSpacing: 12,
// // //                   childAspectRatio: 0.72,
// // //                 ),
// // //                 itemBuilder: (context, index) {
// // //                   final style = historyHairstyles[index];
// // //                   return Material(
// // //                     elevation: 6,
// // //                     borderRadius: BorderRadius.circular(16),
// // //                     clipBehavior: Clip.hardEdge,
// // //                     child: Stack(
// // //                       children: [
// // //                         Positioned.fill(
// // //                           child: Image.network(
// // //                             style.representingImageUrl,
// // //                             fit: BoxFit.cover,
// // //                             errorBuilder:
// // //                                 (_, __, ___) => const Icon(Icons.broken_image),
// // //                           ),
// // //                         ),
// // //                         Positioned(
// // //                           bottom: 0,
// // //                           left: 0,
// // //                           right: 0,
// // //                           child: Container(
// // //                             padding: const EdgeInsets.all(10),
// // //                             decoration: BoxDecoration(
// // //                               gradient: LinearGradient(
// // //                                 begin: Alignment.topCenter,
// // //                                 end: Alignment.bottomCenter,
// // //                                 colors: [
// // //                                   Colors.transparent,
// // //                                   Colors.black.withAlpha(180),
// // //                                 ],
// // //                               ),
// // //                             ),
// // //                             child: Column(
// // //                               crossAxisAlignment: CrossAxisAlignment.start,
// // //                               children: [
// // //                                 Text(
// // //                                   style.hairstyleName,
// // //                                   overflow: TextOverflow.ellipsis,
// // //                                   style: GoogleFonts.poppins(
// // //                                     color: Colors.white,
// // //                                     fontWeight: FontWeight.bold,
// // //                                   ),
// // //                                 ),
// // //                                 Text(
// // //                                   style.gender,
// // //                                   style: GoogleFonts.poppins(
// // //                                     fontSize: 12,
// // //                                     color: Colors.white70,
// // //                                   ),
// // //                                 ),
// // //                                 const SizedBox(height: 6),
// // //                                 ElevatedButton(
// // //                                   onPressed: () => _tryOnHairstyle(style),
// // //                                   style: ElevatedButton.styleFrom(
// // //                                     backgroundColor: Colors.white,
// // //                                     foregroundColor: Colors.pinkAccent,
// // //                                     padding: const EdgeInsets.symmetric(
// // //                                       horizontal: 10,
// // //                                       vertical: 6,
// // //                                     ),
// // //                                     shape: RoundedRectangleBorder(
// // //                                       borderRadius: BorderRadius.circular(20),
// // //                                     ),
// // //                                   ),
// // //                                   child: Text(
// // //                                     "Try Again",
// // //                                     style: GoogleFonts.poppins(
// // //                                       fontWeight: FontWeight.w600,
// // //                                     ),
// // //                                   ),
// // //                                 ),
// // //                               ],
// // //                             ),
// // //                           ),
// // //                         ),
// // //                       ],
// // //                     ),
// // //                   );
// // //                 },
// // //               ),
// // //     );
// // //   }
// // // }

// // import 'dart:io';
// // import 'package:flutter/material.dart';
// // import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// // import 'package:google_fonts/google_fonts.dart';
// // import 'package:intl/intl.dart'; // for date formatting
// // import '../models/hairstyle_model.dart';
// // import '../services/history_services.dart';
// // import 'try_on_screen.dart';

// // class HistoryPage extends StatefulWidget {
// //   const HistoryPage({super.key});

// //   @override
// //   State<HistoryPage> createState() => _HistoryPageState();
// // }

// // class _HistoryPageState extends State<HistoryPage> {
// //   List<Hairstyle> historyHairstyles = [];
// //   bool isLoading = true;
// //   File? _capturedImage;

// //   @override
// //   void initState() {
// //     super.initState();
// //     _fetchHistory();
// //   }

// //   Future<void> _fetchHistory() async {
// //     final userId = await const FlutterSecureStorage().read(key: 'userId');
// //     if (userId == null) return;

// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       final history = await HistoryService.fetchHistory(userId);
// //       print('Fetched history count: ${history.length}');
// //       setState(() {
// //         historyHairstyles = history;
// //         isLoading = false;
// //       });
// //     } catch (e) {
// //       setState(() => isLoading = false);
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to load history: $e')),
// //       );
// //     }
// //   }

// //   Future<void> _clearHistory() async {
// //     final userId = await const FlutterSecureStorage().read(key: 'userId');
// //     if (userId == null) return;

// //     setState(() {
// //       isLoading = true;
// //     });

// //     try {
// //       await HistoryService.clearHistory(userId);
// //       setState(() {
// //         historyHairstyles.clear();
// //         isLoading = false;
// //       });
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('History cleared')),
// //       );
// //     } catch (e) {
// //       setState(() => isLoading = false);
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         SnackBar(content: Text('Failed to clear history: $e')),
// //       );
// //     }
// //   }

// //   void _tryOnHairstyle(Hairstyle style) {
// //     if (_capturedImage == null) {
// //       ScaffoldMessenger.of(context).showSnackBar(
// //         const SnackBar(content: Text('Please capture a photo first')),
// //       );
// //       return;
// //     }

// //     Navigator.push(
// //       context,
// //       MaterialPageRoute(
// //         builder: (_) => TryOnScreenPage(
// //           hairstyle: style,
// //           capturedImage: _capturedImage!,
// //         ),
// //       ),
// //     );
// //   }

// //   String _formatDate(DateTime date) {
// //     return DateFormat('MMM d, yyyy – h:mm a').format(date);
// //   }

// @override
// Widget build(BuildContext context) {
//   return Scaffold(
//     appBar: AppBar(
//       title: Text(
//         "History",
//         style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
//       ),
//       actions: [
//         if (historyHairstyles.isNotEmpty)
//           IconButton(
//             tooltip: 'Clear All History',
//             icon: const Icon(Icons.delete_forever),
//             onPressed: () async {
//               final confirmed = await showDialog<bool>(
//                 context: context,
//                 builder: (_) => AlertDialog(
//                   title: const Text('Clear History'),
//                   content: const Text('Are you sure you want to clear all history?'),
//                   actions: [
//                     TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
//                     TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Clear')),
//                   ],
//                 ),
//               );

//               if (confirmed == true) {
//                 _clearHistory();
//               }
//             },
//           )
//       ],
//     ),
// //       body: isLoading
// //           ? const Center(child: CircularProgressIndicator(color: Colors.pinkAccent))
// //           : historyHairstyles.isEmpty
// //               ? Center(child: Text("No history yet!", style: GoogleFonts.poppins()))
// //               : GridView.builder(
// //                   padding: const EdgeInsets.all(12),
// //                   itemCount: historyHairstyles.length,
// //                   gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
// //                     crossAxisCount: 2,
// //                     crossAxisSpacing: 12,
// //                     mainAxisSpacing: 12,
// //                     childAspectRatio: 0.72,
// //                   ),
// //                   itemBuilder: (context, index) {
// //                     final style = historyHairstyles[index];

// //                     // For date tried, you need to have this info in Hairstyle or pass alongside
// //                     // Assuming Hairstyle model has a field DateTime triedAt (if not, adjust accordingly)
// //                     // Otherwise, you might have to keep a parallel list of triedAt timestamps or wrap Hairstyle + triedAt

// //                     final triedAt = style.triedOn ?? DateTime.now();

// //                     return Material(
// //                       elevation: 6,
// //                       borderRadius: BorderRadius.circular(16),
// //                       clipBehavior: Clip.hardEdge,
// //                       child: Stack(
// //                         children: [
// //                           Positioned.fill(
// //                             child: Image.network(
// //                               style.representingImageUrl,
// //                               fit: BoxFit.cover,
// //                               errorBuilder: (_, __, ___) => const Icon(Icons.broken_image),
// //                             ),
// //                           ),
// //                           Positioned(
// //                             bottom: 0,
// //                             left: 0,
// //                             right: 0,
// //                             child: Container(
// //                               padding: const EdgeInsets.all(10),
// //                               decoration: BoxDecoration(
// //                                 gradient: LinearGradient(
// //                                   begin: Alignment.topCenter,
// //                                   end: Alignment.bottomCenter,
// //                                   colors: [Colors.transparent, Colors.black.withAlpha(180)],
// //                                 ),
// //                               ),
// //                               child: Column(
// //                                 crossAxisAlignment: CrossAxisAlignment.start,
// //                                 mainAxisSize: MainAxisSize.min,
// //                                 children: [
// //                                   Text(
// //                                     style.hairstyleName,
// //                                     overflow: TextOverflow.ellipsis,
// //                                     style: GoogleFonts.poppins(
// //                                       color: Colors.white,
// //                                       fontWeight: FontWeight.bold,
// //                                     ),
// //                                   ),
// //                                   Text(
// //                                     style.gender,
// //                                     style: GoogleFonts.poppins(fontSize: 12, color: Colors.white70),
// //                                   ),
// //                                   Text(
// //                                     _formatDate(triedAt),
// //                                     style: GoogleFonts.poppins(fontSize: 10, color: Colors.white54),
// //                                   ),
// //                                   const SizedBox(height: 6),
// //                                   ElevatedButton(
// //                                     onPressed: () => _tryOnHairstyle(style),
// //                                     style: ElevatedButton.styleFrom(
// //                                       backgroundColor: Colors.white,
// //                                       foregroundColor: Colors.pinkAccent,
// //                                       padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
// //                                       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
// //                                     ),
// //                                     child: Text(
// //                                       "Try Again",
// //                                       style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
// //                                     ),
// //                                   ),
// //                                 ],
// //                               ),
// //                             ),
// //                           ),
// //                         ],
// //                       ),
// //                     );
// //                   },
// //                 ),
// //     );
// //   }
// // }

// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:google_fonts/google_fonts.dart';
// import 'package:intl/intl.dart'; // for date formatting
// import '../models/hairstyle_model.dart';
// import '../services/history_services.dart';
// import 'try_on_screen.dart';

// class HistoryPage extends StatefulWidget {
//   const HistoryPage({super.key});

//   @override
//   State<HistoryPage> createState() => _HistoryPageState();
// }

// class _HistoryPageState extends State<HistoryPage> {
//   List<Hairstyle> historyHairstyles = [];
//   bool isLoading = true;
//   File? _capturedImage;

//   @override
//   void initState() {
//     super.initState();
//     _fetchHistory();
//   }

//   // Future<void> _fetchHistory() async {
//   //   final userId = await const FlutterSecureStorage().read(key: 'userId');
//   //   if (userId == null) return;

//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   try {
//   //     final history = await HistoryService.fetchHistory(userId);
//   //     print('Fetched history count: ${history.length}');
//   //     setState(() {
//   //       historyHairstyles = history;
//   //       isLoading = false;
//   //     });
//   //   } catch (e) {
//   //     setState(() => isLoading = false);
//   //     ScaffoldMessenger.of(context).showSnackBar(
//   //       SnackBar(content: Text('Failed to load history: $e')),
//   //     );
//   //   }
//   // }

//   Future<void> _fetchHistory() async {
//     final userId = await const FlutterSecureStorage().read(key: 'userId');
//     if (userId == null) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       final history = await HistoryService.fetchHistory(userId);

//       // ✅ Remove duplicates based on hairstyleId
//       final uniqueHairstyles = <String, Hairstyle>{};
//       for (final h in history) {
//         uniqueHairstyles[h.hairstyleId] = h; // This keeps the latest entry
//       }

//       setState(() {
//         historyHairstyles = uniqueHairstyles.values.toList();
//         isLoading = false;
//       });
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to load history: $e')));
//     }
//   }

//   Future<void> _clearHistory() async {
//     final userId = await const FlutterSecureStorage().read(key: 'userId');
//     if (userId == null) return;

// final confirmed = await showDialog<bool>(
//   context: context,
//   builder:
//       (_) => AlertDialog(
//         title: const Text('Clear History'),
//         content: const Text('Are you sure you want to clear all history?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.pop(context, false),
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.pop(context, true),
//             child: const Text('Clear'),
//           ),
//         ],
//       ),
// );

// if (confirmed != true) return;

//     setState(() {
//       isLoading = true;
//     });

//     try {
//       await HistoryService.clearHistory(userId);
//       setState(() {
//         historyHairstyles.clear();
//         isLoading = false;
//       });
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(const SnackBar(content: Text('History cleared')));
//     } catch (e) {
//       setState(() => isLoading = false);
//       ScaffoldMessenger.of(
//         context,
//       ).showSnackBar(SnackBar(content: Text('Failed to clear history: $e')));
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
//         builder:
//             (_) => TryOnScreenPage(
//               hairstyle: style,
//               capturedImage: _capturedImage!,
//             ),
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return DateFormat('MMM d, yyyy – h:mm a').format(date);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(
//           "History",
//           style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
//         ),
//       ),
//       body:
//           isLoading
//               ? const Center(
//                 child: CircularProgressIndicator(color: Colors.pinkAccent),
//               )
//               : historyHairstyles.isEmpty
//               ? Center(
//                 child: Text("No history yet!", style: GoogleFonts.poppins()),
//               )
//               : Column(
//                 children: [
//                   Expanded(
//                     child: GridView.builder(
//                       padding: const EdgeInsets.all(12),
//                       itemCount: historyHairstyles.length,
//                       gridDelegate:
//                           const SliverGridDelegateWithFixedCrossAxisCount(
//                             crossAxisCount: 2,
//                             crossAxisSpacing: 12,
//                             mainAxisSpacing: 12,
//                             childAspectRatio: 0.72,
//                           ),
//                       itemBuilder: (context, index) {
//                         final style = historyHairstyles[index];
//                         final triedAt = style.triedOn ?? DateTime.now();

//                         return Material(
//                           elevation: 6,
//                           borderRadius: BorderRadius.circular(16),
//                           clipBehavior: Clip.hardEdge,
//                           child: Stack(
//                             children: [
//                               Positioned.fill(
//                                 child: Image.network(
//                                   style.representingImageUrl,
//                                   fit: BoxFit.cover,
//                                   errorBuilder:
//                                       (_, __, ___) =>
//                                           const Icon(Icons.broken_image),
//                                 ),
//                               ),
//                               Positioned(
//                                 bottom: 0,
//                                 left: 0,
//                                 right: 0,
//                                 child: Container(
//                                   padding: const EdgeInsets.all(10),
//                                   decoration: BoxDecoration(
//                                     gradient: LinearGradient(
//                                       begin: Alignment.topCenter,
//                                       end: Alignment.bottomCenter,
//                                       colors: [
//                                         Colors.transparent,
//                                         Colors.black.withAlpha(180),
//                                       ],
//                                     ),
//                                   ),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     mainAxisSize: MainAxisSize.min,
//                                     children: [
//                                       Text(
//                                         style.hairstyleName,
//                                         overflow: TextOverflow.ellipsis,
//                                         style: GoogleFonts.poppins(
//                                           color: Colors.white,
//                                           fontWeight: FontWeight.bold,
//                                         ),
//                                       ),
//                                       Text(
//                                         style.gender,
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 12,
//                                           color: Colors.white70,
//                                         ),
//                                       ),
//                                       Text(
//                                         _formatDate(triedAt),
//                                         style: GoogleFonts.poppins(
//                                           fontSize: 10,
//                                           color: Colors.white54,
//                                         ),
//                                       ),
//                                       const SizedBox(height: 6),
//                                       ElevatedButton(
//                                         onPressed: () => _tryOnHairstyle(style),
//                                         style: ElevatedButton.styleFrom(
//                                           backgroundColor: Colors.white,
//                                           foregroundColor: Colors.pinkAccent,
//                                           padding: const EdgeInsets.symmetric(
//                                             horizontal: 10,
//                                             vertical: 6,
//                                           ),
//                                           shape: RoundedRectangleBorder(
//                                             borderRadius: BorderRadius.circular(
//                                               20,
//                                             ),
//                                           ),
//                                         ),
//                                         child: Text(
//                                           "Try Again",
//                                           style: GoogleFonts.poppins(
//                                             fontWeight: FontWeight.w600,
//                                           ),
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//                   ),

//                   // Clear History Button below grid
//                   if (historyHairstyles.isNotEmpty)
//                     Padding(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 12,
//                         horizontal: 24,
//                       ),
//                       child: SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton.icon(
//                           icon: const Icon(Icons.delete_forever),
//                           label: const Text('Clear All History'),
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.redAccent,
//                             foregroundColor: Colors.white,
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(30),
//                             ),
//                           ),
//                           onPressed: _clearHistory,
//                         ),
//                       ),
//                     ),
//                 ],
//               ),
//     );
//   }
// }

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import '../classifiers/hairstyle_model.dart';
import '../services/history_services.dart';
import 'try_on_screen.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<Hairstyle> historyHairstyles = [];
  bool isLoading = true;
  File? _capturedImage;

  final Map<String, List<Hairstyle>> groupedHistory = {};

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    final userId = await const FlutterSecureStorage().read(key: 'userId');
    if (userId == null) return;

    setState(() => isLoading = true);

    try {
      final history = await HistoryService.fetchHistory(userId);

      final uniqueHistory = _removeDuplicates(history);
      final grouped = _groupByTime(uniqueHistory);

      setState(() {
        historyHairstyles = uniqueHistory;
        groupedHistory.clear();
        groupedHistory.addAll(grouped);
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load history: $e')));
    }
  }

  Future<void> _clearHistory() async {
    final userId = await const FlutterSecureStorage().read(key: 'userId');
    if (userId == null) return;

    //added part
    final confirmed = await showDialog<bool>(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Clear History'),
            content: const Text('Are you sure you want to clear all history?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Clear'),
              ),
            ],
          ),
    );

    if (confirmed != true) return;

    setState(() => isLoading = true);

    try {
      await HistoryService.clearHistory(userId);
      setState(() {
        historyHairstyles.clear();
        groupedHistory.clear();
        isLoading = false;
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('History cleared')));
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to clear history: $e')));
    }
  }

  List<Hairstyle> _removeDuplicates(List<Hairstyle> list) {
    final seen = <String>{};
    return list.where((item) => seen.add(item.hairstyleId ?? '')).toList();
  }

  Map<String, List<Hairstyle>> _groupByTime(List<Hairstyle> styles) {
    final now = DateTime.now();
    final today = now.subtract(const Duration(days: 1));
    final lastWeek = now.subtract(const Duration(days: 7));
    final lastMonth = now.subtract(const Duration(days: 30));
    final lastYear = now.subtract(const Duration(days: 365));

    final Map<String, List<Hairstyle>> grouped = {
      'Recently': [],
      'Last Week': [],
      'Last Month': [],
      'Last Year': [],
    };

    for (final style in styles) {
      final tried = style.triedOn ?? now;
      if (tried.isAfter(today)) {
        grouped['Recently']!.add(style);
      } else if (tried.isAfter(lastWeek)) {
        grouped['Last Week']!.add(style);
      } else if (tried.isAfter(lastMonth)) {
        grouped['Last Month']!.add(style);
      } else {
        grouped['Last Year']!.add(style);
      }
    }

    return grouped;
  }

  void _tryOnHairstyle(Hairstyle style) async {
    if (_capturedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please capture a photo first')),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => TryOnScreenPage(
              hairstyle: style,
              capturedImage: _capturedImage!,
              isMale: style.gender.toLowerCase() == 'male',
            ),
      ),
    );
  }

  //added part
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "History",
          style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w600),
        ),
        actions: [
          // if (groupedHistory.values.expand((list) => list).isNotEmpty)
          if (!isLoading &&
              groupedHistory.values.expand((list) => list).isNotEmpty)
            IconButton(
              tooltip: 'Clear All History',
              icon: const Icon(Icons.delete_forever, color: Colors.red),
              onPressed: () async {
                final confirmed = await showDialog<bool>(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: const Text('Clear History'),
                        content: const Text(
                          'Are you sure you want to clear all history?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context, false),
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(context, true),
                            child: const Text('Clear'),
                          ),
                        ],
                      ),
                );
                if (confirmed == true) {
                  _clearHistory();
                }
              },
            ),
        ],
      ),
      body: isLoading
              ? const Center(
                child: CircularProgressIndicator(color: Colors.pinkAccent),
              )
              : historyHairstyles.isEmpty
              ? Center(
                child: Text("No history yet!", style: GoogleFonts.poppins()),
              )
              : ListView(
                padding: const EdgeInsets.all(12),
                children:
                    groupedHistory.entries
                        .where((e) => e.value.isNotEmpty)
                        .map(
                          (entry) =>
                              _buildGroupedSection(entry.key, entry.value),
                        )
                        .toList(),
              ),
    );
  }

  Widget _buildGroupedSection(String title, List<Hairstyle> styles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: styles.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemBuilder: (context, index) {
            final style = styles[index];
            return Material(
              elevation: 6,
              borderRadius: BorderRadius.circular(16),
              clipBehavior: Clip.hardEdge,
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Image.network(
                      style.representingImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder:
                          (_, __, ___) => const Icon(Icons.broken_image),
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
                          colors: [
                            Colors.transparent,
                            Colors.black.withAlpha(180),
                          ],
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            style.hairstyleName,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            style.gender,
                            style: GoogleFonts.poppins(
                              fontSize: 12,
                              color: Colors.white70,
                            ),
                          ),
                          // Text(
                          //   _formatDate(style.triedOn ?? DateTime.now()),
                          //   style: GoogleFonts.poppins(
                          //     fontSize: 10,
                          //     color: Colors.white54,
                          //   ),
                          // ),
                          const SizedBox(height: 6),
                          ElevatedButton(
                            onPressed: () => _tryOnHairstyle(style),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.pinkAccent,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                            ),
                            child: Text(
                              "Try Again",
                              style: GoogleFonts.poppins(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
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
        const SizedBox(height: 24),
      ],
    );
  }
}
