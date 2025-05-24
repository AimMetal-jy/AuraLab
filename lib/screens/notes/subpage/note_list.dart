import 'package:flutter/material.dart';
import 'package:auralab/screens/notes/note_display_page.dart';

class NoteListPage extends StatelessWidget {
  const NoteListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('全部'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NoteDisplayPage(title: "测试"),
                ),
              );
            },
            child: const Text('查看批注'),
          ),
        ],
      ),
    );
  }
}
