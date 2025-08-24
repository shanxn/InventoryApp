import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:inventory/firebase.dart';

class seller_ extends StatefulWidget {
  const seller_({super.key});

  @override
  State<seller_> createState() => _seller_State();
}

class _seller_State extends State<seller_> {
  final TextEditingController name_controller = TextEditingController();
  final TextEditingController desc_controller = TextEditingController();
  final TextEditingController stock_controller = TextEditingController();
  final TextEditingController price_controller = TextEditingController();

  final Data DataStock = Data();

  void _opentextbox() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: name_controller,
              decoration: const InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: desc_controller,
              decoration: const InputDecoration(labelText: 'Description'),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                TextField(

                  controller: stock_controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Stock', constraints: BoxConstraints(maxWidth: 70)),
                ),
                const SizedBox(width: 20,),
                TextField(
                  controller: price_controller,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Price', constraints: BoxConstraints(maxWidth: 70)),
                ),
              ],
            ),
            const SizedBox(height: 20,),
            Row(
              children: [
                ElevatedButton(
                  onPressed: () async {
                    // Retrieve the currently authenticated user
                    User? user = FirebaseAuth.instance.currentUser;
                    if (user == null) {
                      // Handle case where user is not authenticated
                      return;
                    }
                    final userId = user.uid; // Get the authenticated user's ID

                    // Generate a reference with an auto-generated ID
                    final docRef = DataStock.getUserStocksCollection(userId).doc();
                    final docId = docRef.id; // Retrieve the generated ID

                    // Add stock with the generated ID
                    await DataStock.addStock(
                      userId, // Use userId from authentication
                      docId,
                      name_controller.text,
                      desc_controller.text,
                      int.parse(stock_controller.text),
                      int.parse(price_controller.text),
                    );

                    // Clear controllers and close the dialog
                    name_controller.clear();
                    desc_controller.clear();
                    stock_controller.clear();
                    price_controller.clear();
                    Navigator.pop(context);
                  },
                  child: const Text('Add'),

                ),
                const SizedBox(width: 20,),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Close'),
                ),
              ],
            ),
          ],
        ),
        actions: const [],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the currently authenticated user
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated.'),
        ),
      );
    }
    final userId = user.uid;




    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(Icons.arrow_back_ios_new),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _opentextbox();
        },
        child: const Icon(Icons.add),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: DataStock.getUserStocks(userId),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            List stockList = snapshot.data!.docs;

            // Display stocks
            return ListView.builder(
              itemCount: stockList.length,
              itemBuilder: (context, index) {
                // Get document
                DocumentSnapshot document = stockList[index];
                String docID = document.id;
                // Get stock data
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;
                String nameText = data['name'];
                String descText = data['description'];
                int stockNum = data['stock'];



                // List tile to display stock
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Container(
                      height: 10,
                      width: 10,
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    title: Text(nameText, style: const TextStyle(fontWeight: FontWeight.bold)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                    subtitle: Text(descText, style: const TextStyle(fontWeight: FontWeight.normal)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          onPressed: () {
                            DataStock.deleteStock(userId, docID);
                          },
                          icon: const Icon(Icons.delete),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text('No Items'));
          }
        },
      ),
    );
  }
}
