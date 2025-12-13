import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/validators.dart';
import '../data/auth_provider.dart';
import '../../../app/routes.dart';
import '../../../app/app_colors.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  final _emailNode = FocusNode();
  final _passwordNode = FocusNode();

  bool _obscure = true;

  late final AnimationController _ac;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();

    _ac = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _fade = CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic);
    _slide = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ac, curve: Curves.easeOutCubic));

    _ac.forward();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    _emailNode.dispose();
    _passwordNode.dispose();
    _ac.dispose();
    super.dispose();
  }

  Future<void> _showResultDialog({
    required bool success,
    required String message,
  }) async {
    final title = success ? 'Berhasil masuk' : 'Gagal masuk';
    final iconData = success ? Icons.check_circle : Icons.error;
    final Color accentColor = success
        ? AppColors.greenArrow
        : Colors.red.shade500;

    return showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        final textTheme = Theme.of(context).textTheme;

        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 12),
          actionsPadding: const EdgeInsets.only(bottom: 8),
          actionsAlignment: MainAxisAlignment.center,
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(iconData, color: accentColor, size: 26),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: textTheme.titleMedium?.copyWith(
                  fontFamily: 'StackSansHeadline',
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium?.copyWith(
                  color: AppColors.navy.withOpacity(0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                foregroundColor: accentColor,
                textStyle: const TextStyle(
                  fontFamily: 'StackSansText',
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final authProvider = context.read<AuthProvider>();
    final success = await authProvider.signIn(
      email: _email.text.trim(),
      password: _password.text,
    );

    if (!mounted) return;

    if (success) {
      // Berhasil login, arahkan sesuai role
      if (authProvider.isDosenOrMentor) {
        Navigator.pushReplacementNamed(context, Routes.dosenHome);
      } else {
        Navigator.pushReplacementNamed(context, Routes.home);
      }
    } else if (authProvider.error != null) {
      // gagal login, tampilkan dialog error
      await _showResultDialog(success: false, message: authProvider.error!);
      authProvider.clearError();
    }
  }

  OutlineInputBorder _outline(Color c) {
    return OutlineInputBorder(
      borderSide: BorderSide(color: c),
      borderRadius: BorderRadius.circular(12),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;

    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: FadeTransition(
                    opacity: _fade,
                    child: SlideTransition(
                      position: _slide,
                      child: Card(
                        color: AppColors.surfaceLight,
                        elevation: 10,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 28,
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                // logo dan judul
                                Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    TweenAnimationBuilder<double>(
                                      tween: Tween(begin: 0.9, end: 1.0),
                                      duration: const Duration(
                                        milliseconds: 700,
                                      ),
                                      curve: Curves.easeOutBack,
                                      builder: (context, value, child) {
                                        return Transform.scale(
                                          scale: value,
                                          child: child,
                                        );
                                      },
                                      child: SizedBox(
                                        height: 120,
                                        child: Image.asset(
                                          'assets/images/logo.png',
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Masuk ke akun Kamu',
                                      textAlign: TextAlign.center,
                                      style: t.bodyMedium?.copyWith(
                                        color: AppColors.navy.withOpacity(0.75),
                                      ),
                                    ),
                                  ],
                                ),

                                const SizedBox(height: 24),

                                // email
                                TextFormField(
                                  controller: _email,
                                  focusNode: _emailNode,
                                  textInputAction: TextInputAction.next,
                                  onFieldSubmitted: (_) =>
                                      _passwordNode.requestFocus(),
                                  style: const TextStyle(color: AppColors.navy),
                                  cursorColor: AppColors.navy,
                                  decoration: InputDecoration(
                                    hintText: 'nama@kampus.ac.id',
                                    hintStyle: TextStyle(
                                      color: AppColors.navy.withOpacity(0.35),
                                    ),
                                    border: _outline(
                                      AppColors.navy.withOpacity(0.15),
                                    ),
                                    enabledBorder: _outline(
                                      AppColors.navy.withOpacity(0.15),
                                    ),
                                    focusedBorder: _outline(AppColors.blueBook),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                  ),
                                  keyboardType: TextInputType.emailAddress,
                                  validator: Validators.email,
                                  autofillHints: const [AutofillHints.username],
                                ),

                                const SizedBox(height: 16),

                                // password
                                TextFormField(
                                  controller: _password,
                                  focusNode: _passwordNode,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _submit(),
                                  style: const TextStyle(color: AppColors.navy),
                                  cursorColor: AppColors.navy,
                                  decoration: InputDecoration(
                                    hintText: 'Password',
                                    hintStyle: TextStyle(
                                      color: AppColors.navy.withOpacity(0.35),
                                    ),
                                    border: _outline(
                                      AppColors.navy.withOpacity(0.15),
                                    ),
                                    enabledBorder: _outline(
                                      AppColors.navy.withOpacity(0.15),
                                    ),
                                    focusedBorder: _outline(AppColors.blueBook),
                                    filled: true,
                                    fillColor: Colors.white.withOpacity(0.9),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 16,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () =>
                                          setState(() => _obscure = !_obscure),
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility
                                            : Icons.visibility_off,
                                        color: AppColors.navy.withOpacity(0.7),
                                      ),
                                      tooltip: _obscure
                                          ? 'Tampilkan'
                                          : 'Sembunyikan',
                                    ),
                                  ),
                                  obscureText: _obscure,
                                  validator: Validators.password,
                                  autofillHints: const [AutofillHints.password],
                                ),

                                const SizedBox(height: 20),

                                // tombol masuk
                                Consumer<AuthProvider>(
                                  builder: (context, auth, _) {
                                    return SizedBox(
                                      height: 50,
                                      child: ElevatedButton(
                                        onPressed: auth.isLoading
                                            ? null
                                            : _submit,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.blueBook,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              16,
                                            ),
                                          ),
                                        ),
                                        child: AnimatedSwitcher(
                                          duration: const Duration(
                                            milliseconds: 200,
                                          ),
                                          transitionBuilder: (child, anim) =>
                                              FadeTransition(
                                                opacity: anim,
                                                child: child,
                                              ),
                                          child: auth.isLoading
                                              ? const SizedBox(
                                                  key: ValueKey('loading'),
                                                  height: 20,
                                                  width: 20,
                                                  child: CircularProgressIndicator(
                                                    strokeWidth: 2,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                          Color
                                                        >(Colors.white),
                                                  ),
                                                )
                                              : const Text(
                                                  'Masuk',
                                                  key: ValueKey('text'),
                                                ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
