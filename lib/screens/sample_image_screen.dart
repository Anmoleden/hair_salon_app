// import 'package:flutter/material.dart';

// class SampleImagesPage extends StatelessWidget {
//   final List<String> assets;
//   final Function(String path) onImageSelected;

//   const SampleImagesPage({
//     Key? key,
//     required this.assets,
//     required this.onImageSelected,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Choose a Sample Image'),
//         backgroundColor: Colors.teal,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(12.0),
//         child: ListView.builder(
//           itemCount: assets.length,
//           itemBuilder: (context, index) {
//             final path = assets[index];
//             return _buildStyledPreview(context, path);
//           },
//         ),
//       ),
//     );
//   }

//   Widget _buildStyledPreview(BuildContext context, String path) {
//     return GestureDetector(
//       onTap: () => onImageSelected(path),
//       child: Container(
//         margin: const EdgeInsets.only(bottom: 16),
//         decoration: BoxDecoration(
//           borderRadius: BorderRadius.circular(24),
//           color: Colors.grey[100],
//           boxShadow: [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 6,
//               offset: Offset(2, 3),
//             ),
//           ],
//         ),
//         child: ClipRRect(
//           borderRadius: BorderRadius.circular(24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               Image.asset(
//                 path,
//                 fit: BoxFit.cover,
//                 height: 220,
//               ),
//               Container(
//                 padding: const EdgeInsets.all(12),
//                 alignment: Alignment.centerLeft,
//                 color: Colors.black.withOpacity(0.05),
//                 child: Text(
//                   path.split('/').last,
//                   style: const TextStyle(
//                     fontSize: 14,
//                     fontWeight: FontWeight.w500,
//                   ),
//                 ),
//               )
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';

class SampleImagesPage extends StatelessWidget {
  final List<String> assets;
  final Function(String path) onImageSelected;

  const SampleImagesPage({
    super.key,
    required this.assets,
    required this.onImageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose a Sample Image'),
        backgroundColor: Colors.teal,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          itemCount: assets.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,          // Two columns
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 3 / 4,     // Adjust for better height/width
          ),
          itemBuilder: (context, index) {
            final path = assets[index];
            return _buildGridItem(context, path);
          },
        ),
      ),
    );
  }

  Widget _buildGridItem(BuildContext context, String path) {
    return GestureDetector(
      onTap: () => onImageSelected(path),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey[200],
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(2, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Image.asset(
            path,
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
