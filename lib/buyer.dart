import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:inventory/History.dart';
import 'package:inventory/Orders.dart';

import 'package:inventory/cart.dart';
import 'package:inventory/firebase.dart';
import 'package:inventory/sell.dart';
import 'package:inventory/ExpandableTile.dart';

class buyer_ extends StatefulWidget {
  const buyer_({super.key});

  @override
  State<buyer_> createState() => _buyer_State();
}

class _buyer_State extends State<buyer_> {
  final Data DataStock = Data();


  void logout() {
    FirebaseAuth.instance.signOut();
  }

  void showToast(BuildContext context, String message) {
    final overlay = Overlay.of(context);
    final overlayEntry = OverlayEntry(
      builder: (context) => Center(
        child: Material(
          color: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            margin: const EdgeInsets.only(bottom: 100),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.primary, fontSize: 16),
            ),
          ),
        ),
      ),
    );

    overlay.insert(overlayEntry);

    // Fade out the notification after a delay
    Future.delayed(const Duration(milliseconds: 400), () {
      overlayEntry.remove();
    });
  }


  /*void productSub(String stockNum, String userId, String stockId) async {
    int currentStock = int.tryParse(stockNum) ?? 0;

    if (currentStock >= 0) {
      // Get the total stock value (e.g., from a 'total_stock' field)
      int initialStock = await getInitialStock(userId, stockId);

      if (currentStock < initialStock) {
        int newStockValue = currentStock + 1;
        await DataStock.addProduct(userId, stockId, newStockValue.toString());
        print("Stock updated successfully");
      } else {
        print("Cannot exceed the initial stock value");
      }
    } else {
      print("Stock value is invalid");
    }
  }*/

  @override
  Widget build(BuildContext context) {
    User? user = FirebaseAuth.instance.currentUser;

    if (user == null) {
      return const Scaffold(
        body: Center(
          child: Text('User not authenticated.'),
        ),
      );
    }

    final currUser = user.uid;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              Scaffold.of(context).openDrawer();
            },
          ),
        ),
        actions: [
           IconButton(onPressed: () {
             Navigator.push(context, MaterialPageRoute(builder: (context) => const order_by()));

           },icon: const Icon(Icons.local_shipping_outlined),),
        ],
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      drawer: Drawer(child: ListView(

        children: [

          const DrawerHeader(child: Center(child: Icon(Icons.inventory_2_outlined,size: 40,))),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.sell),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const seller_()));

              },
              title: const Center(child: Text('S E L L ')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.add_shopping_cart_outlined),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const Cart()));

              },
              title: const Center(child: Text('C A R T')),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.history_rounded),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context, MaterialPageRoute(builder: (context) => const history()));

              },
              title: const Center(child: Text('H I S T O R Y')),
            ),
          ),
         
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.logout),
              onTap: () {
                logout();
              },
              title: const Center(child: Text('L O G O U T')),
            ),
          )
        ],
      ),),
      body: StreamBuilder<QuerySnapshot>(
        stream: DataStock.getAllStocks(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No Items'));
          } else {
            List<DocumentSnapshot> stockList = snapshot.data!.docs;

            return ListView.builder(
              itemCount: stockList.length,
              itemBuilder: (context, index) {
                DocumentSnapshot document = stockList[index];
                String docId = document.id;
                Map<String, dynamic> data = document.data() as Map<String, dynamic>;

                String nameText = data['name'] ?? 'No Name';
                String descText = data['description'] ?? 'No Description';
                String priceNum = data['price'].toString();
                String userId = data['user']; // Assuming this field exists
                final docRef = DataStock.getUserStocksCollection(currUser).doc();
                final docid = docRef.id;

                return Padding(
                  padding: const EdgeInsets.only(left: 8,right: 8,top: 8),
                  child: CustomExpansionTile(
                    name: nameText,
                    description: descText,
                    stock: int.tryParse(priceNum) ?? 0,
                    onAddPressed: () {
                          if(currUser != userId)
                            {
                              DataStock.purchaseAdd(currUser, docId, docId, userId, 0);
                            }
                          else{
                            showToast(context, 'Unable to add');
                          }
                    }

                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
