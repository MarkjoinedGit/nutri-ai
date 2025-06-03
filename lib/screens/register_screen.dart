import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../providers/localization_provider.dart';
import '../utils/app_strings.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isDoctor = false;
  String? _errorMessage;

  static const Color customOrange = Color(0xFFE07E02);

  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: customOrange,
    letterSpacing: 0.5,
  );

  static const TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: Colors.black54,
  );

  static const TextStyle buttonTextStyle = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
  );

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  String? _validateName(String? value, dynamic strings) {
    if (value == null || value.isEmpty) {
      return strings.pleaseEnterName;
    }
    return null;
  }

  String? _validateEmail(String? value, dynamic strings) {
    if (value == null || value.isEmpty) {
      return strings.pleaseEnterEmail;
    }
    final emailRegExp = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    if (!emailRegExp.hasMatch(value)) {
      return strings.pleaseEnterValidEmail;
    }
    return null;
  }

  String? _validatePassword(String? value, dynamic strings) {
    if (value == null || value.isEmpty) {
      return strings.pleaseEnterPassword;
    }
    if (value.length < 6) {
      return strings.passwordMinLength;
    }
    return null;
  }

  String? _validateConfirmPassword(String? value, dynamic strings) {
    if (value == null || value.isEmpty) {
      return strings.pleaseConfirmPassword;
    }
    if (value != _passwordController.text) {
      return strings.passwordsDoNotMatch;
    }
    return null;
  }

  void _showSuccessDialog(dynamic strings) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
            insetPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 24,
            ),
            title: Wrap(
              spacing: 10,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                const Icon(Icons.check_circle, color: customOrange, size: 28),
                Flexible(
                  child: Text(
                    strings.registrationSuccessful,
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            content: Text(
              strings.accountCreatedSuccessfully,
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  Navigator.pushReplacementNamed(context, '/login');
                },
                child: Text(
                  strings.signIn,
                  style: const TextStyle(
                    color: customOrange,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _register() async {
    final localizationProvider = Provider.of<LocalizationProvider>(
      context,
      listen: false,
    );
    final strings = AppStrings.getStrings(localizationProvider.currentLanguage);

    if (!_formKey.currentState!.validate()) return;

    if (mounted) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
    }

    try {
      final authService = AuthService();
      await authService.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _isDoctor,
      );

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      _showSuccessDialog(strings);
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<LocalizationProvider>(
      builder: (context, localizationProvider, child) {
        final strings = AppStrings.getStrings(
          localizationProvider.currentLanguage,
        );

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black87),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: CustomScrollView(
                  slivers: [
                    SliverList(
                      delegate: SliverChildListDelegate([
                        const SizedBox(height: 10),
                        Text(strings.createAccount, style: headingStyle),
                        const SizedBox(height: 8),
                        Text(strings.signUpToStart, style: subtitleStyle),
                        const SizedBox(height: 30),
                        if (_errorMessage != null) _buildErrorMessage(),
                        if (_errorMessage != null) const SizedBox(height: 20),
                        _buildNameField(strings),
                        const SizedBox(height: 16),
                        _buildEmailField(strings),
                        const SizedBox(height: 16),
                        _buildPasswordField(strings),
                        const SizedBox(height: 16),
                        _buildConfirmPasswordField(strings),
                        const SizedBox(height: 20),
                        _buildDoctorSwitch(strings),
                        const SizedBox(height: 30),
                        _buildRegisterButton(strings),
                        const SizedBox(height: 30),
                        _buildLoginRow(strings),
                      ]),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _errorMessage!,
              style: TextStyle(color: Colors.red.shade700),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNameField(dynamic strings) {
    return TextFormField(
      controller: _nameController,
      decoration: InputDecoration(
        labelText: strings.fullName,
        hintText: strings.enterYourFullName,
        prefixIcon: const Icon(Icons.person_outline),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: customOrange),
        ),
      ),
      validator: (value) => _validateName(value, strings),
    );
  }

  Widget _buildEmailField(dynamic strings) {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        labelText: strings.email,
        hintText: strings.enterYourEmail,
        prefixIcon: const Icon(Icons.email_outlined),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: customOrange),
        ),
      ),
      validator: (value) => _validateEmail(value, strings),
    );
  }

  Widget _buildPasswordField(dynamic strings) {
    return TextFormField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        labelText: strings.password,
        hintText: strings.enterYourPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isPasswordVisible = !_isPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: customOrange),
        ),
      ),
      validator: (value) => _validatePassword(value, strings),
    );
  }

  Widget _buildConfirmPasswordField(dynamic strings) {
    return TextFormField(
      controller: _confirmPasswordController,
      obscureText: !_isConfirmPasswordVisible,
      decoration: InputDecoration(
        labelText: strings.confirmPassword,
        hintText: strings.confirmYourPassword,
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed: () {
            setState(() {
              _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
            });
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(15),
          borderSide: const BorderSide(color: customOrange),
        ),
      ),
      validator: (value) => _validateConfirmPassword(value, strings),
    );
  }

  Widget _buildDoctorSwitch(dynamic strings) {
    return SwitchListTile(
      title: Text(
        strings.registerAsDoctor,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      subtitle: Text(
        strings.turnOnIfHealthcareProfessional,
        style: const TextStyle(fontSize: 14),
      ),
      value: _isDoctor,
      onChanged: (value) {
        setState(() {
          _isDoctor = value;
        });
      },
      activeColor: customOrange,
      contentPadding: const EdgeInsets.symmetric(horizontal: 4),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
        side: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }

  Widget _buildRegisterButton(dynamic strings) {
    return SizedBox(
      width: double.infinity,
      height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _register,
        style: ElevatedButton.styleFrom(
          backgroundColor: customOrange,
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade300,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
        ),
        child:
            _isLoading
                ? const SizedBox(
                  height: 24,
                  width: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
                : Text(strings.register, style: buttonTextStyle),
      ),
    );
  }

  Widget _buildLoginRow(dynamic strings) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          strings.alreadyHaveAccount,
          style: const TextStyle(color: Colors.black54, fontSize: 16),
        ),
        TextButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, '/login');
          },
          child: Text(
            strings.signIn,
            style: const TextStyle(
              color: customOrange,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ),
      ],
    );
  }
}
