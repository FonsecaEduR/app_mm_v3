import 'package:app_mm_v3/auth/sign.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class SignupPage extends StatelessWidget {
  final auth = FirebaseAuth.instance;
  final db = FirebaseFirestore.instance;

  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  SignupPage({super.key});

  Future<bool> _criarUsuario() async {
    bool create = false;

    try {
      await auth
          .createUserWithEmailAndPassword(
              email: emailController.text, password: passwordController.text)
          .then((usuariocriado) {
        db.collection('users').doc(usuariocriado.user!.uid).set({
          "username": usernameController.text,
          "email": emailController.text,
          "uid": usuariocriado.user!.uid
        });
        create = true;
      });
    } on FirebaseAuthException catch (e) {
      print("Erro: ${e.code}");
    }

    return create;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 20,
            color: Colors.black,
          ),
        ),
        title: Image.asset(
          'assets/images/logo.png',
          height: 40,
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40),
          height: MediaQuery.of(context).size.height - 50,
          width: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Column(
                children: <Widget>[
                  const SizedBox(
                    height: 20,
                  ),
                  const Text(
                    "Cadastre-se",
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(
                    "Crie sua conta, é gratuito!",
                    style: TextStyle(fontSize: 15, color: Colors.grey[700]),
                  ),
                ],
              ),
              Column(
                children: <Widget>[
                  inputFile(label: "Nome", textController: usernameController),
                  inputFile(label: "Email", textController: emailController),
                  inputFile(
                      label: "Senha",
                      obscureText: true,
                      textController: passwordController),
                  inputFile(
                      label: "Confirme sua senha",
                      obscureText: true,
                      textController: confirmPasswordController),
                ],
              ),
              Container(
                width: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF734B9B), Color(0xFF3F8782)],
                    begin: Alignment.centerRight,
                    end: Alignment.centerLeft,
                  ),
                ),
                child: MaterialButton(
                  height: 50,
                  onPressed: () async {
                    if (passwordController.text.isNotEmpty &&
                        confirmPasswordController.text.isNotEmpty &&
                        (passwordController.text
                                .compareTo(confirmPasswordController.text)) ==
                            0) {
                      await _criarUsuario()
                          ? Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignPage(),
                              ),
                            )
                          : Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SignupPage(),
                              ),
                            );
                    }
                  },
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    "Cadastrar",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  const Text("já possui uma conta?"),
                  GestureDetector(
                    onTap: () async {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const SignPage(),
                        ),
                      );
                    },
                    child: const Text(
                      " Login",
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 18),
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget inputFile({label, obscureText = false, required textController}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w400, color: Colors.black87),
        ),
        const SizedBox(
          height: 5,
        ),
        TextField(
          controller: textController,
          obscureText: obscureText,
          decoration: const InputDecoration(
              contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 10),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 189, 189, 189),
                ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.all(Radius.circular(30)),
                borderSide: BorderSide(
                  color: Color.fromARGB(255, 189, 189, 189),
                ),
              )),
        ),
        const SizedBox(
          height: 10,
        )
      ],
    );
  }
}
