import 'package:flutter/material.dart';

class order_tile extends StatefulWidget {
  String name;
  String desc;
  int Quantity;
  
  order_tile({super.key, required this.desc, required this.name, required this.Quantity});

  @override
  State<order_tile> createState() => _order_tileState();
}

class _order_tileState extends State<order_tile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        title: Text(widget.name),
        subtitle: Text(widget.desc),
        trailing: Text(widget.Quantity.toString()),
      ),
    );
  }
}
