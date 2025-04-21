import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TestScreen extends StatelessWidget {
  TestScreen({super.key});

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Data')),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection('Parents').snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No parents data found.'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              var parentDoc = snapshot.data!.docs[index];
              var parentData = parentDoc.data() as Map<String, dynamic>;

              return Card(
                margin: EdgeInsets.all(8.0),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Parent ID: ${parentDoc.id}',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 8),
                      if (parentData['name'] != null)
                        Text('Parent Name: ${parentData['name']}'),
                      if (parentData['child'] != null)
                        Text('Child Name: ${parentData['child']}'),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
