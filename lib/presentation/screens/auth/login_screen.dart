import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hack_speech/presentation/screens/auth/signup_screen.dart';
import 'package:hack_speech/presentation/screens/home/home_screen.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/providers/api_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signInWithEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bienvenue ${user.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signInWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      // 1. Se connecter avec Google
      final googleAuthService = ref.read(googleAuthServiceProvider);
      final googleAccount = await googleAuthService.signIn();

      if (googleAccount == null) {
        throw Exception('Connexion Google annulée');
      }

      // 2. Obtenir le token ID Google
      final idToken = await googleAuthService.getIdToken();

      // 3. Envoyer les infos au backend MongoDB
      final authRepo = ref.read(authRepositoryProvider);
      final user = await authRepo.loginWithGoogle(
        idToken ?? '',
        email: googleAccount.email,
        name: googleAccount.displayName ?? googleAccount.email.split('@')[0],
        avatar: googleAccount.photoUrl,
        googleId: googleAccount.id,
      );

      if (!mounted) return;

      // 4. Navigation vers home
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Bienvenue ${user.name}!'),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erreur Google: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              _buildHeader(),
              const SizedBox(height: 40),
              _buildSocialButtons(),
              const SizedBox(height: 32),
              _buildDivider(),
              const SizedBox(height: 32),
              _buildForm(),
              const SizedBox(height: 24),
              _buildSignInButton(),
              const SizedBox(height: 24),
              _buildSignUpPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Center(
            child: Text('👋', style: TextStyle(fontSize: 40)),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Bienvenue!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Connecte-toi pour continuer',
          style: TextStyle(fontSize: 15, color: AppColors.mediumGray),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _SocialButton(
          onPressed: _isLoading ? null : _signInWithGoogle,
          icon: Image.asset('assets/images/google.png', width: 20, height: 20),
          label: 'Continuer avec Google',
          backgroundColor: Colors.white,
          textColor: AppColors.darkGray,
        ),

        // _SocialButton(
        //   onPressed: _isLoading ? null : _signInWithFacebook,
        //   icon: '📘',
        //   label: 'Continuer avec Facebook',
        //   backgroundColor: const Color(0xFF1877F2),
        //   textColor: Colors.white,
        // ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: AppColors.lightGray)),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'OU',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: AppColors.mediumGray,
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: AppColors.lightGray)),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'L\'email est requis';
              }
              if (!value.contains('@')) {
                return 'Email invalide';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: const OutlineInputBorder(),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe est requis';
              }
              if (value.length < 6) {
                return 'Minimum 6 caractères';
              }
              return null;
            },
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Fonctionnalité bientôt disponible'),
                  ),
                );
              },
              child: const Text(
                'Mot de passe oublié ?',
                style: TextStyle(
                  color: AppColors.primaryPurple,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signInWithEmail,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Se connecter',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }

  Widget _buildSignUpPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Pas encore de compte ? ',
          style: TextStyle(color: AppColors.mediumGray),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const SignupScreen()),
            );
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Écran d\'inscription: À créer')),
            );
          },
          child: const Text(
            'S\'inscrire',
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;
  final Color backgroundColor;
  final Color textColor;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
    required this.backgroundColor,
    required this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: textColor,
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: backgroundColor == Colors.white
                  ? AppColors.lightGray
                  : Colors.transparent,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              label,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
