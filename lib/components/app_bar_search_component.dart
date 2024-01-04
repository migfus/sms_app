import 'package:flutter/material.dart';

class AppBarSearchComponent extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  const AppBarSearchComponent({super.key, required this.title});

  @override
  State<AppBarSearchComponent> createState() => _AppBarSearchComponentState();
  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _AppBarSearchComponentState extends State<AppBarSearchComponent> {
  bool onSearch = false;
  String title = "";

  void _searchToggle() {
    setState(() {
      if(onSearch == true) {
        onSearch = false;
      }
      else {
        onSearch = true;
      }
    });
  } 

  @override
  Widget build(BuildContext context) {
    return onSearch ? 
    // Search Button Toggle
    AppBar(
      elevation: 4,
      backgroundColor: Colors.white,
      shadowColor: Colors.grey[50],
      title: Container(
        margin: const EdgeInsets.symmetric(vertical: 29),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Search',
            border: InputBorder.none,
            contentPadding: const EdgeInsets.only(top: 15, left: 15),

            suffixIcon: IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: () {
                _searchToggle();
              },
            ),
          ),
          onChanged: (searchText) {
              
          },
        ),
      ),
    ) :
    // Search Bar
    AppBar(
      elevation: 4,
      shadowColor: Colors.grey[50],
      title: Text(widget.title),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              _searchToggle();
            },
          ),
        ),
      ],
    );
  }
}