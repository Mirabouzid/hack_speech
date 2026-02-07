import 'package:flutter/material.dart';
import 'package:hack_speech/presentation/screens/home/home_screen.dart';
import '../../../core/constants/app_colors.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  bool _acceptedTerms = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) {
      return; // Si invalide, arrête ici
    }

    if (!_acceptedTerms) {
      _showMessage('Veuillez accepter les conditions d\'utilisation');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));

      final name = _nameController.text.trim();
      final email = _emailController.text.trim();
      final password = _passwordController.text;

      debugPrint('INSCRIPTION ');
      debugPrint('Nom: $name');
      debugPrint('Email: $email');
      debugPrint('Mot de passe: ${password.length} caractères');

      if (!mounted) return;

      _showMessage('Compte créé avec succès ! 🎉', isSuccess: true);

      await Future.delayed(const Duration(seconds: 1));

      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } catch (e) {
      if (!mounted) return;

      _showMessage('Erreur: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _signUpWithGoogle() async {
    _showMessage('Inscription Google: À implémenter');
  }

  void _showMessage(String message, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.darkGray),
          onPressed: () => Navigator.pop(context),
        ),
      ),

      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(),

              const SizedBox(height: 32),

              _buildSocialButtons(),

              const SizedBox(height: 24),

              _buildDivider(),

              const SizedBox(height: 24),

              _buildForm(),

              const SizedBox(height: 16),

              _buildTermsCheckbox(),

              const SizedBox(height: 24),

              _buildSignUpButton(),

              const SizedBox(height: 24),

              _buildLoginPrompt(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        // Container(
        //   width: 80,
        //   height: 80,
        //   decoration: BoxDecoration(
        //     gradient: AppColors.primaryGradient,
        //     borderRadius: BorderRadius.circular(20),
        //   ),
        //   child: const Center(child: Text('✨', style: TextStyle(fontSize: 40))),
        // ),
        const Text(
          'Créer un compte',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: AppColors.darkGray,
          ),
        ),
        const SizedBox(height: 8),

        const Text(
          'Rejoins la communauté maintenant',
          style: TextStyle(fontSize: 15, color: AppColors.mediumGray),
        ),
      ],
    );
  }

  Widget _buildSocialButtons() {
    return Column(
      children: [
        _SocialButton(
          onPressed: _isLoading ? null : _signUpWithGoogle,
          icon: Image.asset('assets/images/google.png', width: 20, height: 20),
          label: 'S\'inscrire avec Google',
          backgroundColor: Colors.white,
          textColor: AppColors.darkGray,
        ),

        // _SocialButton(
        //   onPressed: _isLoading ? null : _signUpWithFacebook,
        //   icon: '📘',
        //   label: 'S\'inscrire avec Facebook',
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
            controller: _nameController,
            keyboardType: TextInputType.name,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Nom complet',
              hintText: 'Ex: Ahmed Ben Salem',
              prefixIcon: Icon(Icons.person_outline),
            ),

            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le nom est requis';
              }
              if (value.length < 3) {
                return 'Minimum 3 caractères';
              }
              return null; // null = valide
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email',
              hintText: 'exemple@email.com',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'L\'email est requis';
              }

              if (!value.contains('@') || !value.contains('.')) {
                return 'Email invalide';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword, // Masque le texte
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              hintText: 'Minimum 8 caractères',
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
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Le mot de passe est requis';
              }
              if (value.length < 8) {
                return 'Minimum 8 caractères';
              }
              if (!value.contains(RegExp(r'[A-Z]'))) {
                return 'Au moins une majuscule requise';
              }

              if (!value.contains(RegExp(r'[0-9]'))) {
                return 'Au moins un chiffre requis';
              }
              return null;
            },
          ),

          const SizedBox(height: 16),

          TextFormField(
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            decoration: InputDecoration(
              labelText: 'Confirmer le mot de passe',
              hintText: 'Retapez le mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureConfirmPassword
                      ? Icons.visibility
                      : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscureConfirmPassword = !_obscureConfirmPassword;
                  });
                },
              ),
            ),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Veuillez confirmer le mot de passe';
              }

              if (value != _passwordController.text) {
                return 'Les mots de passe ne correspondent pas';
              }
              return null;
            },
          ),

          // const Text(
          //   '• Minimum 8 caractères\n'
          //   '• Au moins une majuscule\n'
          //   '• Au moins un chiffre',
          //   style: TextStyle(
          //     fontSize: 12,
          //     color: AppColors.mediumGray,
          //     height: 1.5,
          //   ),
          // ),
        ],
      ),
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptedTerms,
          onChanged: (value) {
            setState(() {
              _acceptedTerms = value ?? false;
            });
          },
          activeColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        ),

        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _acceptedTerms = !_acceptedTerms;
                });
              },
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.darkGray,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'J\'accepte les '),
                    TextSpan(
                      text: 'Conditions d\'utilisation',
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                    const TextSpan(text: ' et la '),
                    TextSpan(
                      text: 'Politique de confidentialité',
                      style: const TextStyle(
                        color: AppColors.primaryPurple,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _signUp,
        child: _isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text('Créer mon compte'),
      ),
    );
  }

  Widget _buildLoginPrompt() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Déjà un compte ? ',
          style: TextStyle(color: AppColors.mediumGray),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text(
            'Se connecter',
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
          shadowColor: Colors.black.withValues(alpha: 0.1),
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
