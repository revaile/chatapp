import 'package:flutter/material.dart';
import 'package:minimalchat/components/drawer.dart';
import 'package:minimalchat/pages/chat_page.dart';
import 'package:minimalchat/services/auth/auth_services.dart';
import 'package:minimalchat/services/auth/chatservices/chat_service.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();
  String _searchQuery = ''; // Query pencarian
  bool _isSearching = false; // Mode pencarian

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _isSearching
            ? _buildSearchField() // Jika searching, tampilkan TextField
            : const Text(
                'Chat with your friends',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
        centerTitle: true,
        backgroundColor: Colors.blue,
        elevation: 0,
        actions: [
          if (!_isSearching) // Tampilkan ikon pencarian jika tidak searching
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                setState(() {
                  _isSearching = true; // Aktifkan mode pencarian
                });
              },
            ),
        ],
        leading: _isSearching
            ? IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  setState(() {
                    _isSearching = false; // Matikan mode pencarian
                    _searchQuery = ''; // Reset query pencarian
                  });
                },
              )
            : null,
      ),
      drawer: const CustomDrawer(),
      body: Column(
        children: [
          _buildTopAvatarList(),
          Expanded(child: _buildUserList()),
        ],
      ),
    );
  }

  Widget _buildSearchField() {
    return TextField(
      autofocus: true,
      decoration: InputDecoration(
        hintText: 'Search users...',
        border: InputBorder.none,
        hintStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
      ),
      style: const TextStyle(color: Colors.white),
      onChanged: (value) {
        setState(() {
          _searchQuery = value.toLowerCase(); // Perbarui query pencarian
        });
      },
    );
  }

  Widget _buildTopAvatarList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('Error loading avatars'));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapshot.data!;

        // Filter users berdasarkan query pencarian
        var filteredUsers = users.where((user) {
          var username = user['username']?.toLowerCase() ?? '';
          return username.contains(_searchQuery);
        }).toList();

        return ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(40), // Radius kiri bawah
            bottomRight: Radius.circular(40), // Radius kanan bawah
          ),
          child: Container(
            height: 130,
            color: Colors.blue,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: filteredUsers.length,
              itemBuilder: (context, index) {
                var user = filteredUsers[index];
                if (user['email'] == _authService.getCurrentUser()!.email) {
                  return Container(); // Jangan tampilkan pengguna yang sama dengan yang login
                }
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8.0, vertical: 10.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatPage(
                                recieverUsername: user['username'],
                                receiverId: user['uid'],
                              ),
                            ),
                          );
                        },
                        child: CircleAvatar(
                          radius: 30,
                          backgroundImage: user['avatarUrl'] != null
                              ? NetworkImage(user['avatarUrl'])
                              : null,
                          backgroundColor: user['avatarUrl'] == null
                              ? Colors.grey.shade200
                              : Colors.transparent,
                          child: user['avatarUrl'] == null
                              ? Text(
                                  user['username'] != null &&
                                          user['username'].isNotEmpty
                                      ? user['username'][0].toUpperCase()
                                      : '?',
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        user['username'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
      builder: (context, snapShot) {
        if (snapShot.hasError) {
          return const Center(child: Text('Error loading users'));
        }
        if (snapShot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        var users = snapShot.data!;
        var filteredUsers = users.where((user) {
          var username = user['username']?.toLowerCase() ?? '';
          return username.contains(_searchQuery);
        }).toList();

        return ListView(
          children: filteredUsers
              .map<Widget>((userData) => _buildUserTile(userData, context))
              .toList(),
        );
      },
    );
  }

 Widget _buildUserTile(Map<String, dynamic> userData, BuildContext context) {
  if (userData['email'] != _authService.getCurrentUser()!.email) {
    return Column(
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Stack(
            alignment: Alignment.bottomRight,
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: Colors.grey.shade200,
                child: userData['avatarUrl'] == null || userData['avatarUrl'].isEmpty
                    ? Text(
                        userData['username'] != null && userData['username'].isNotEmpty
                            ? userData['username'][0].toUpperCase() // Huruf pertama username
                            : '?', // Fallback jika username kosong
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      )
                    : ClipOval(
                        child: Image.network(
                          userData['avatarUrl'],
                          fit: BoxFit.cover,
                          width: 56,
                          height: 56,
                        ),
                      ),
              ),
         
            ],
          ),
          title: Text(
            userData['username'],
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        
          trailing: Icon(
            Icons.chat,
            color: Colors.blue,
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  recieverUsername: userData['username'],
                  receiverId: userData['uid'],
                ),
              ),
            );
          },
        ),
        Divider(
          color: Colors.grey.shade300,
          thickness: 1,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  } else {
    return Container();
  }
}


}
