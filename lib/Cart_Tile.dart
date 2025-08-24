import 'package:flutter/material.dart';
class CartTile extends StatefulWidget {
  final String name;
  final String description;
  final int stock;
  final int order;
  final VoidCallback onAddPressed;
  final VoidCallback onDelPressed;
  final VoidCallback onBuyPressed;

  const CartTile({super.key, 
    required this.name,
    required this.description,
    required this.stock,
    required this.onAddPressed,
    required this.onDelPressed,
    required this.onBuyPressed,
    required this.order
    ,
  });

  @override
  State<CartTile> createState() => _CartTileState();
}

class _CartTileState extends State<CartTile> {
  bool _isExpanded = false;

  void _toggleExpand() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _toggleExpand,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  IconButton(
                      onPressed:
                        widget.onDelPressed,
                      icon: const Icon(Icons.remove)),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(widget.name,
                            style:
                            const TextStyle(fontWeight: FontWeight.bold)),
                        Text(widget.description,
                            style:
                            const TextStyle(fontWeight: FontWeight.normal)),
                      ],
                    ),
                  ),
                  Text(widget.stock.toString()),
                  const SizedBox(
                    width: 16,
                  ),
                  Icon(
                    _isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            firstChild: Container(),
            secondChild: Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(widget.order.toString()),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      IconButton(
                        onPressed:
                          widget.onBuyPressed,

                        icon: const Icon(Icons.shopping_bag),
                      ),
                      IconButton(
                        onPressed:
                          widget.onAddPressed, // Call the onUpdate callback to update the order count
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  )
                ],
              ),
            ),
            crossFadeState: _isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
          ),
        ],
      ),
    );
  }
}
