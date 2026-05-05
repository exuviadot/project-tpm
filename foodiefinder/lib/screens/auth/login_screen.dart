import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../../services/biometric_service.dart'; 
import '../../providers/auth_provider.dart';
import '../../core/constants/app_colors.dart';

class LoginScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final BiometricService _biometricService = BiometricService(); 
  bool _isLoading = false;
  bool _obscureText = true;
  bool _showBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometric();
  }

  Future<void> _checkBiometric() async {
    final storage = const FlutterSecureStorage();
    final token = await storage.read(key: 'jwt_token');
    
    bool isEnabled = await _biometricService.isBiometricEnabled();
    bool isAvailable = await _biometricService.isBiometricAvailable();

    if (token != null && isEnabled && isAvailable && mounted) {
      setState(() {
        _showBiometric = true;
      });
      _biometricLogin();
    }
  }

  Future<void> _biometricLogin() async {
    try {
      final authenticated = await _biometricService.authenticate();
      
      if (authenticated && mounted) {
        Navigator.pushReplacementNamed(context, '/main');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Biometric error')),
      );
    }
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await ref.read(authNotifierProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
      if (mounted) Navigator.pushReplacementNamed(context, '/main');
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Login Gagal. Cek username dan password Anda.'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(
                  labelText: 'Email', 
                  prefixIcon: Icon(Icons.email)
                ),
                validator: (v) => v!.isEmpty ? 'Email diperlukan' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _passCtrl,
                obscureText: _obscureText,
                decoration: InputDecoration(
                  labelText: 'Password',
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureText ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  ),
                ),
                validator: (v) => v!.isEmpty ? 'Password diperlukan' : null,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: _isLoading ? null : _login,
                  child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text('Masuk', style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
              if (_showBiometric) ...[
                const SizedBox(height: 16),
                IconButton(
                  icon: const Icon(Icons.fingerprint, size: 48, color: AppColors.primary),
                  onPressed: _biometricLogin,
                ),
                const Text('Login dengan Sidik Jari')
              ]
            ],
          ),
        ),
      ),
    );
  }
}