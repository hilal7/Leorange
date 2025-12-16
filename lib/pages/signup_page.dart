// pages/signup_page.dart  (senin dosya adı register_page.dart idi, ben signup_page.dart dedim; eğer adını register_page.dart yapmak istersen dosya adını değiştir)
import 'package:flutter/material.dart';
import '../services/api_service.dart';



class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nicknameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController verificationCodeController = TextEditingController();

  final ApiService apiService = ApiService();
  bool isLoading = false;

  bool emailValid = false;
  final RegExp emailRegex = RegExp(r'^[A-Za-z0-9._%+-]+@gmail\.com$');

  @override
  void initState() {
    super.initState();
    emailController.addListener(() {
      setState(() {
        emailValid = emailRegex.hasMatch(emailController.text.trim());
      });
    });
  }

  Future<void> _register() async {
    setState(() => isLoading = true);

    String firstName = firstNameController.text.trim();
    String lastName = lastNameController.text.trim();
    String nickname = nicknameController.text.trim();
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty || nickname.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Tüm alanları doldurun")),
      );
      setState(() => isLoading = false);
      return;
    }

    if (!emailValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lütfen geçerli bir Gmail adresi girin.")),
      );
      setState(() => isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Şifreler eşleşmiyor")),
      );
      setState(() => isLoading = false);
      return;
    }

    try {
      var result = await apiService.registerUser(firstName, lastName, nickname, email, password);
      setState(() => isLoading = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result["message"] ?? "Bilinmeyen hata")),
      );

      if (result["success"] == true) {
        // Kayıt başarılı -> doğrulama kodu girme dialogu aç
        _showVerificationDialog(email);
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Kayıt sırasında hata oluştu: $e")),
      );
    }
  }

  void _showVerificationDialog(String email) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          title: const Text('Doğrulama Kodu'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('E-postana gönderilen 6 haneli kodu gir.'),
              const SizedBox(height: 10),
              TextField(
                controller: verificationCodeController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Kod'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                String code = verificationCodeController.text.trim();
                if (code.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Lütfen kodu girin.')),
                  );
                  return;
                }
                var res = await apiService.verifyCode(email, code);
                if (res['success'] == true) {
                  Navigator.of(context).pop(); // dialog kapansın
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Doğrulandı')),
                  );
                  Navigator.pop(context); // kayıt ekranından çık (login'e dön)
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(res['message'] ?? 'Kod hatalı')),
                  );
                }
              },
              child: const Text('Doğrula'),
            ),
          ],
        );
      },
    );
  }

  OutlineInputBorder _buildBorder(bool isValid) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: isValid ? Colors.green : Colors.red, width: 2),
      borderRadius: BorderRadius.circular(8),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Yeni Hesap Oluştur")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: firstNameController,
              decoration: const InputDecoration(labelText: "Ad"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: lastNameController,
              decoration: const InputDecoration(labelText: "Soyad"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: nicknameController,
              decoration: const InputDecoration(labelText: "Nickname"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: InputDecoration(
                labelText: "Email",
                enabledBorder: _buildBorder(emailValid),
                focusedBorder: _buildBorder(emailValid),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Şifre"),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "Şifre Tekrar"),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                backgroundColor: Colors.orange[900],
              ),
              child: const Text(
                "Kayıt Ol",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
