// lib/features/pairing/screens/pairing_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/constants/colors.dart';
import '../../../core/constants/routes.dart';
import '../../../core/utils/localization.dart';
import '../bloc/pairing_bloc.dart';
import '../bloc/pairing_event.dart';
import '../bloc/pairing_state.dart';

class PairingScreen extends StatefulWidget {
  const PairingScreen({Key? key}) : super(key: key);

  @override
  State<PairingScreen> createState() => _PairingScreenState();
}

class _PairingScreenState extends State<PairingScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _codeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PairingBloc>().add(LoadPairingInfo());
  }

  @override
  void dispose() {
    _tabController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PairingBloc, PairingState>(
      listener: (context, state) {
        if (state is PairingSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.translate('pairing.success_connected')),
              backgroundColor: EmoraColors.moodColors['Calm'],
            ),
          );
          Navigator.pushReplacementNamed(context, EmoraRoutes.dashboard);
        } else if (state is PairingFailure) {
          // Handle localization error messages or raw errors
          final errMsg = state.errorMessage.startsWith('pairing.') 
              ? context.translate(state.errorMessage)
              : state.errorMessage;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(errMsg),
              backgroundColor: EmoraColors.primary,
            ),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: Stack(
            children: [
              // Animated Gradient Background
              Container(
                decoration: const BoxDecoration(
                  gradient: EmoraColors.bgGradient,
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Header
                      Text(
                        context.translate('pairing.title'),
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: EmoraColors.textDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 30),
                      // Control TabBar with soft peach background
                      Container(
                        decoration: BoxDecoration(
                          color: EmoraColors.secondary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(28),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          indicator: BoxDecoration(
                            color: EmoraColors.primary,
                            borderRadius: BorderRadius.circular(28),
                          ),
                          labelColor: EmoraColors.textLight,
                          unselectedLabelColor: EmoraColors.textDark,
                          tabs: [
                            Tab(icon: const Icon(Icons.share), text: context.translate('pairing.tab_my_code')),
                            Tab(icon: const Icon(Icons.link), text: context.translate('pairing.tab_input_code')),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Content TabView
                      Expanded(
                        child: TabBarView(
                          controller: _tabController,
                          children: [
                            _buildMyCodeTab(state),
                            _buildInputCodeTab(state),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // My pairing code display interface (Tab 1)
  Widget _buildMyCodeTab(PairingState state) {
    if (state is PairingLoading) {
      return const Center(child: CircularProgressIndicator(color: EmoraColors.primary));
    }

    String code = '------';
    if (state is PairingInfoLoaded) {
      code = state.myCode;
    }

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: EmoraColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.translate('pairing.desc_your_code'),
            style: const TextStyle(fontSize: 16, color: EmoraColors.textMuted),
          ),
          const SizedBox(height: 16),
          // Large 6-digit Code
          Text(
            code,
            style: const TextStyle(
              fontSize: 54,
              fontWeight: FontWeight.bold,
              color: EmoraColors.primary,
              letterSpacing: 8,
            ),
          ),
          const SizedBox(height: 30),
          // QR Code Area with warm rounded borders
          Container(
            width: 160,
            height: 160,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: EmoraColors.secondary, width: 2),
            ),
            child: const Center(
              child: Icon(
                Icons.qr_code_2,
                size: 130,
                color: EmoraColors.textDark,
              ),
            ),
          ),
          const SizedBox(height: 30),
          // Share Button
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: EmoraColors.primary,
              foregroundColor: EmoraColors.textLight,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              elevation: 0,
            ),
            onPressed: () {
              // Trigger copy code and simulated sharing feature
              Clipboard.setData(ClipboardData(text: code));
              final shareMsg = context.translate('pairing.share_message', {'code': code});
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Copied code and share link: $shareMsg')),
              );
            },
            icon: const Icon(Icons.share),
            label: Text(context.translate('pairing.share_btn')),
          ),
        ],
      ),
    );
  }

  // Input connection code interface (Tab 2)
  Widget _buildInputCodeTab(PairingState state) {
    final isConnecting = state is PairingConnecting;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: EmoraColors.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: EmoraColors.primary.withOpacity(0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            context.translate('pairing.desc_input_code'),
            style: const TextStyle(fontSize: 16, color: EmoraColors.textMuted),
          ),
          const SizedBox(height: 24),
          // Code input field
          TextField(
            controller: _codeController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            style: const TextStyle(
              fontSize: 28,
              letterSpacing: 10,
              color: EmoraColors.textDark,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
            decoration: InputDecoration(
              counterText: "",
              hintText: context.translate('pairing.input_placeholder'),
              hintStyle: const TextStyle(fontSize: 16, letterSpacing: 1, color: EmoraColors.textMuted),
              filled: true,
              fillColor: EmoraColors.background,
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: EmoraColors.secondary, width: 1.5),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: const BorderSide(color: EmoraColors.tertiary, width: 2.0),
              ),
            ),
          ),
          const SizedBox(height: 30),
          if (isConnecting)
            const CircularProgressIndicator(color: EmoraColors.primary)
          else ...[
            // Connect button
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: EmoraColors.primary,
                foregroundColor: EmoraColors.textLight,
                padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(28),
                ),
                elevation: 0,
              ),
              onPressed: () {
                final code = _codeController.text.trim();
                if (code.length == 6) {
                  context.read<PairingBloc>().add(ConnectRequested(code));
                }
              },
              child: Text(
                context.translate('pairing.connect_btn'),
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            // Scan QR Code button
            TextButton.icon(
              style: TextButton.styleFrom(
                foregroundColor: EmoraColors.tertiary,
              ),
              onPressed: () {
                // Simulate successful QR Code scanning and retrieving code
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('QR Code scanner camera feature is connecting...')),
                );
              },
              icon: const Icon(Icons.qr_code_scanner),
              label: Text(context.translate('pairing.or_scan_qr')),
            ),
          ],
        ],
      ),
    );
  }
}
