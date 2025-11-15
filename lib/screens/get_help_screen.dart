import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class GetHelpScreen extends StatelessWidget {
  const GetHelpScreen({super.key});

  Future<void> _launchEmail(String email) async {
    try {
      final Uri emailUri = Uri(
        scheme: 'mailto',
        path: email,
        query: 'subject=47 Market Support Request',
      );
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      }
    } catch (e) {
      // Handle error silently or show a message
      print('Error launching email: $e');
    }
  }

  Future<void> _launchPhone(String phone) async {
    try {
      final Uri phoneUri = Uri(scheme: 'tel', path: phone);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    } catch (e) {
      // Handle error silently or show a message
      print('Error launching phone: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
     appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.inverseSurface,
        elevation: 0,
        forceMaterialTransparency: true,
        toolbarHeight: 100,
        leadingWidth: 100,
        primary: true,
        centerTitle: true,
        title: Text(
          "Get Help ",
          style: GoogleFonts.chakraPetch(fontSize: 25),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const ImageIcon(
            size: 30,
            AssetImage("assets/icons/back_arrow.png"),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            // Container(
            //   padding: const EdgeInsets.all(20),
            //   decoration: BoxDecoration(
            //     color: isDark
            //         ? Colors.red.shade900.withOpacity(0.2)
            //         : Colors.red.shade50,
            //     borderRadius: BorderRadius.circular(16),
            //     border: Border.all(
            //       color: Colors.red.shade200.withOpacity(0.5),
            //       width: 1,
            //     ),
            //   ),
            //   child: Row(
            //     children: [
            //       Container(
            //         padding: const EdgeInsets.all(12),
            //         decoration: BoxDecoration(
            //           color: Colors.red.shade400,
            //           borderRadius: BorderRadius.circular(12),
            //         ),
            //         child: const Icon(
            //           Icons.help_outline,
            //           color: Colors.white,
            //           size: 28,
            //         ),
            //       ),
            //       const SizedBox(width: 16),
            //       Expanded(
            //         child: Column(
            //           crossAxisAlignment: CrossAxisAlignment.start,
            //           children: [
            //             Text(
            //               'Need Help?',
            //               style: GoogleFonts.chakraPetch(
            //                 fontSize: 18,
            //                 fontWeight: FontWeight.bold,
            //                 color: colorScheme.onSurface,
            //               ),
            //             ),
            //             const SizedBox(height: 4),
            //             Text(
            //               'We\'re here to assist you',
            //               style: GoogleFonts.chakraPetch(
            //                 fontSize: 14,
            //                 color: colorScheme.onSurface.withOpacity(0.7),
            //               ),
            //             ),
            //           ],
            //         ),
            //       ),
            //     ],
            //   ),
            // ),
            // const SizedBox(height: 32),

            // Contact Support Section
            Text(
              'Contact Support',
              style: GoogleFonts.chakraPetch(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            // Email Support
            _buildContactCard(
              context,
              icon: Icons.email_outlined,
              title: 'Email Support',
              subtitle: 'stepboomz@gmail.com',
              onTap: () => _launchEmail('stepboomz@gmail.com'),
            ),
            const SizedBox(height: 12),

            // Phone Support
            _buildContactCard(
              context,
              icon: Icons.phone_outlined,
              title: 'Phone Support',
              subtitle: '0957728931',
              onTap: () => _launchPhone('0957728931'),
            ),
            const SizedBox(height: 32),

            // FAQ Section
            Text(
              'Frequently Asked Questions',
              style: GoogleFonts.chakraPetch(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildFAQItem(
              context,
              question: 'How do I place an order?',
              answer:
                  'Browse our products, add items to your cart, and proceed to checkout. Make sure your profile is complete with shipping address.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              context,
              question: 'What payment methods do you accept?',
              answer:
                  'We accept PromptPay QR code payments. You will receive a QR code during checkout to complete your payment.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              context,
              question: 'How long does shipping take?',
              answer:
                  'Shipping is free for all orders',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              context,
              question: 'Can I cancel my order?',
              answer:
                  'You can cancel your order before it is processed. Please contact support immediately if you need to cancel.',
            ),
            const SizedBox(height: 12),
            _buildFAQItem(
              context,
              question: 'How do I track my order?',
              answer:
                  'You can view your order status in the Order History',
            ),
            const SizedBox(height: 32),

            // Additional Help Section
            Text(
              'Additional Resources',
              style: GoogleFonts.chakraPetch(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 16),

            _buildResourceCard(
              context,
              icon: Icons.info_outline,
              title: 'About 47 Market',
              subtitle: 'Learn more about our store',
            ),
            const SizedBox(height: 12),
            _buildResourceCard(
              context,
              icon: Icons.privacy_tip_outlined,
              title: 'Privacy Policy',
              subtitle: 'How we protect your data',
            ),
            const SizedBox(height: 12),
            _buildResourceCard(
              context,
              icon: Icons.description_outlined,
              title: 'Terms & Conditions',
              subtitle: 'Read our terms of service',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildContactCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: colorScheme.onSurface.withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDark
                    ? colorScheme.surfaceVariant
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: Colors.red.shade400,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.chakraPetch(
                      fontSize: 14,
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: colorScheme.onSurface.withOpacity(0.4),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAQItem(
    BuildContext context, {
    required String question,
    required String answer,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            question,
            style: GoogleFonts.chakraPetch(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            answer,
            style: GoogleFonts.chakraPetch(
              fontSize: 14,
              color: colorScheme.onSurface.withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: colorScheme.onSurface.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: isDark
                  ? colorScheme.surfaceVariant
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: Colors.red.shade400,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: GoogleFonts.chakraPetch(
                    fontSize: 14,
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: colorScheme.onSurface.withOpacity(0.4),
          ),
        ],
      ),
    );
  }
}

