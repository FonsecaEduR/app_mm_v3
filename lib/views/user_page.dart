import 'package:app_mm_v3/src/add.dart';
import 'package:app_mm_v3/src/app_widget.dart';
import 'package:app_mm_v3/views/home_page.dart';
import 'package:app_mm_v3/views/splash_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;

    void _chooseProfilePicture(BuildContext context) async {
      if (user == null) return;

      final List<String> profilePictures = [
        'assets/images/1.png',
        'assets/images/2.png',
        'assets/images/3.png',
        'assets/images/4.png',
        'assets/images/5.png',
        'assets/images/6.png',
        'assets/images/7.png',
        'assets/images/8.png',
        'assets/images/9.png',
      ];

      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Escolha uma imagem de perfil'),
            content: SingleChildScrollView(
              child: Wrap(
                spacing: 20.0,
                children: profilePictures.map((String imagePath) {
                  return GestureDetector(
                    onTap: () async {
                      // Atualize o URL da imagem de perfil no Firestore
                      await FirebaseFirestore.instance
                          .collection('users')
                          .doc(user.uid)
                          .update({'profilePictureUrl': imagePath});
                      Navigator.of(context).pop();
                    },
                    child: Image.asset(
                      imagePath,
                      width: 40,
                      height: 60,
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    }

    void _editProfile(BuildContext context) async {
      await showDialog<void>(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Editar Perfil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _fullNameController,
                  decoration: const InputDecoration(labelText: 'Nome Completo'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _addressController,
                  decoration: const InputDecoration(labelText: 'Endereço'),
                ),
                const SizedBox(height: 10),
                TextFormField(
                  controller: _phoneController,
                  decoration: const InputDecoration(labelText: 'Telefone'),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancelar'),
              ),
              TextButton(
                onPressed: () {
                  // Salvar as alterações no perfil
                  // Aqui você pode implementar a lógica para salvar os dados no Firestore
                  Navigator.pop(context);
                  setState(() {}); // Atualiza a tela após salvar as alterações
                },
                child: const Text('Salvar'),
              ),
            ],
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Padding(
          padding: const EdgeInsets.only(top: 0.0),
          child: Image.asset(
            'assets/images/logo.png',
            height: 80, // Ajuste a altura conforme necessário
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            color: Colors.grey,
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                    builder: (context) =>
                        const SplashPage() ), // Redireciona para a página de login
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: Container(
        height: MediaQuery.of(context).size.height * 0.07,
        color: const Color(0xFF3F8782),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              icon: const Icon(Icons.chat),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AppWidget(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AddTransactionPage(),
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const HomePage(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Image.asset(
            'assets/images/fundoperfil.png',
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            fit: BoxFit.cover,
          ),
          Positioned.fill(
            top: 100.0,
            child: Padding(
              padding: const EdgeInsets.all(30.0),
              child: StreamBuilder<DocumentSnapshot>(
                stream: user != null
                    ? FirebaseFirestore.instance
                        .collection('users')
                        .doc(user.uid)
                        .snapshots()
                    : const Stream.empty(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Erro: ${snapshot.error}'),
                    );
                  }

                  if (snapshot.hasData && snapshot.data!.exists) {
                    final userData =
                        snapshot.data!.data() as Map<String, dynamic>;
                    final username = userData['username'] ?? '';
                    final email = userData['email'] ?? '';
                    final profilePictureUrl =
                        userData['profilePictureUrl'] ?? 'assets/images/1.png';

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        GestureDetector(
                          onTap: () => _chooseProfilePicture(context),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(profilePictureUrl),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          username,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 10), // Aumenta o espaçamento
                        Text(
                          email,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.grey, // Alterado para cinza
                          ),
                        ),
                        const SizedBox(height: 30),
                        Container(
                          width: 120,
                          height: 35, // Altura definida do container
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(30),
                            gradient: const LinearGradient(
                              colors: [Color(0xFF734B9B), Color(0xFF3F8782)],
                              begin: Alignment.centerRight,
                              end: Alignment.centerLeft,
                            ),
                          ),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              padding:
                                  EdgeInsets.zero, // Remove padding interno
                              backgroundColor: Colors.transparent,
                              shadowColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                            ),
                            onPressed: () {
                              _editProfile(context);
                            },
                            child: const Text(
                              'Editar Perfil',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  }

                  return const Center(
                    child: Text('Dados do usuário não encontrados.',
                        style: TextStyle(color: Colors.white)),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
