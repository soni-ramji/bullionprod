import 'package:bullionprod/screen/bottombar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


/// A focused support screen that can be opened from any part of the app.
class ContactUs extends StatelessWidget {
  const ContactUs({super.key});

  static const _supportNumber = '+91 88006 34100';

  void _copyNumber(BuildContext context) {
    Clipboard.setData(const ClipboardData(text: _supportNumber));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Support number copied to clipboard')),
    );
  }

  @override
  Widget build(BuildContext context) {
    const ink = Color(0xFF102D38);
    const gold = Color(0xFFD39743);
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth >= 700 ? 40.0 : 20.0;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F5EF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF5C4300),
        foregroundColor: Colors.white,
        elevation: 2,
        title: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'THE TD',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 16,
                fontWeight: FontWeight.bold,
                letterSpacing: 2,
              ),
            ),
            Text(
              'JEWELS',
              style: TextStyle(
                color: Color(0xFFD4AF37),
                fontSize: 12,
                fontWeight: FontWeight.w300,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Bottombar(),
      body: SafeArea(
        child: Stack(
          children: [
            // const Positioned(
            //   top: -120,
            //   right: -90,
            //   child: _GlowCircle(size: 290, color: Color(0xFFDDEDE7)),
            // ),
            CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.fromLTRB(
                      horizontalPadding,
                      16,
                      horizontalPadding,
                      40,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 760),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // IconButton(
                            //   onPressed: () => Navigator.maybePop(context),
                            //   icon: const Icon(Icons.arrow_back_rounded),
                            //   tooltip: 'Back',
                            //   color: ink,
                            //   style: IconButton.styleFrom(
                            //     backgroundColor: const Color(0xB8FFFFFF),
                            //   ),
                            // ),
                            // const SizedBox(height: 44),
                            const Text(
                              'TD JEWELLERY  ·  Contact Us',
                              style: TextStyle(
                                color: gold,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.6,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Your jewellery journey,\nbeautifully supported.',
                              style: TextStyle(
                                color: ink,
                                fontSize: 42,
                                height: .98,
                                fontWeight: FontWeight.w700,
                                letterSpacing: -1.5,
                              ),
                            ),
                            const SizedBox(height: 18),
                            const SizedBox(
                              width: 520,
                              child: Text(
                                'Need help choosing a piece, checking availability, or following an order? Our jewellery concierge is ready to assist you.',
                                style: TextStyle(
                                  color: Color(0xFF5F7078),
                                  fontSize: 16,
                                  height: 1.55,
                                ),
                              ),
                            ),
                            const SizedBox(height: 38),
                            const _AvailabilityPill(),
                            const SizedBox(height: 22),
                            _ContactActionCard(
                              isPrimary: true,
                              icon: Icons.phone_in_talk_outlined,
                              overline: 'CALL OUR JEWELLERY DESK',
                              title: _supportNumber,
                              actionLabel: 'Copy support number',
                              onTap: () => _copyNumber(context),
                            ),
                            const SizedBox(height: 14),
                            _ContactActionCard(
                              icon: Icons.chat_bubble_outline_rounded,
                              overline: 'MESSAGE US',
                              title: 'WhatsApp concierge',
                              actionLabel: 'Copy support number',
                              onTap: () => _copyNumber(context),
                            ),

                            _ContactActionCard(
                              isPrimary: true,
                              icon: Icons.location_on_outlined,
                              overline: 'Visit US',
                              title:
                                  'THE TD Complex, Kot Bazar, Rath, Hamirpur, UP 210431',
                              actionLabel: '',
                              onTap: () => {},
                            ),
                            const SizedBox(height: 38),
                            const Divider(color: Color(0xFFDCD5C7)),
                            const SizedBox(height: 24),
                            const _SupportPromise(),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ContactActionCard extends StatelessWidget {
  const _ContactActionCard({
    required this.icon,
    required this.overline,
    required this.title,
    required this.actionLabel,
    required this.onTap,
    this.isPrimary = false,
  });

  final IconData icon;
  final String overline;
  final String title;
  final String actionLabel;
  final VoidCallback onTap;
  final bool isPrimary;

  @override
  Widget build(BuildContext context) {
    final background = isPrimary ? const Color(0xFF163F4A) : Colors.white;
    final foreground = isPrimary ? Colors.white : const Color(0xFF102D38);
    final faded = isPrimary ? const Color(0xFFC3D3D4) : const Color(0xFF6A7B82);

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color:
                  isPrimary ? const Color(0xFF163F4A) : const Color(0xFFE0D9CB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: isPrimary
                      ? const Color(0xFFF1C56D)
                      : const Color(0xFFFFE6B6),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF173E49)),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      overline,
                      style: TextStyle(
                        color: faded,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.25,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: TextStyle(
                        color: foreground,
                        fontSize: 19,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      actionLabel,
                      style: TextStyle(color: faded, fontSize: 12),
                    ),
                  ],
                ),
              ),
              // Icon(Icons.arrow_outward_rounded,
              //     color: isPrimary
              //         ? const Color(0xFFF1C56D)
              //         : const Color(0xFFD39743)),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvailabilityPill extends StatelessWidget {
  const _AvailabilityPill();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFDDEDE7),
        borderRadius: BorderRadius.circular(100),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(radius: 4, backgroundColor: Color(0xFF3B866B)),
          SizedBox(width: 8),
          Text(
            'JEWELLERY CONCIERGE AVAILABLE',
            style: TextStyle(
              color: Color(0xFF315C50),
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: .7,
            ),
          ),
        ],
      ),
    );
  }
}

class _SupportPromise extends StatelessWidget {
  const _SupportPromise();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: 28,
      runSpacing: 20,
      children: [
        _Promise(
            number: '01',
            title: 'Personal assistance',
            text: 'Speak directly with our jewellery team.'),
        _Promise(
            number: '02',
            title: 'Order & product help',
            text: 'Clear answers for every purchase.'),
        _Promise(
            number: '03',
            title: 'A trusted jeweller',
            text: 'Thoughtful service from TD Jewellery.'),
      ],
    );
  }
}

class _Promise extends StatelessWidget {
  const _Promise(
      {required this.number, required this.title, required this.text});

  final String number;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 190,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(number,
              style: const TextStyle(
                  color: Color(0xFFD39743),
                  fontSize: 11,
                  fontWeight: FontWeight.w800)),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(
                    color: Color(0xFF63747B), fontSize: 12, height: 1.5),
                children: [
                  TextSpan(
                      text: '$title\n',
                      style: const TextStyle(
                          color: Color(0xFF102D38),
                          fontWeight: FontWeight.w700)),
                  TextSpan(text: text),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
