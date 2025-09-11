import 'package:brand_store_app/providers/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class Onboarding extends ConsumerWidget {
  const Onboarding({super.key});

  @override
  Widget build(BuildContext context, ref) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            flex: 6,
            child: Stack(
              children: [
                Container(
                  width: double.infinity,
                  decoration: const BoxDecoration(
                      image: DecorationImage(
                          image: AssetImage("assets/images/cover.jpeg"),
                          fit: BoxFit.cover),
                      borderRadius: BorderRadius.only(
                        bottomRight: Radius.circular(50),
                        bottomLeft: Radius.circular(50),
                      )),
                ),
                Positioned(
                  top: 50,
                  right: 20,
                  child: ShadSwitch(
                    value: ref.watch(themeModeProvider) == ThemeMode.dark,
                    onChanged: (value) {
                      ref.read(themeModeProvider.notifier).toggleTheme();
                    },
                    label: Icon(
                      ref.watch(themeModeProvider) == ThemeMode.dark
                          ? Icons.dark_mode
                          : Icons.light_mode,
                      color: Theme.of(context).colorScheme.surface,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
              flex: 4,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Spacer(),
                    Text(
                      "Find The\nBest Collections",
                      style: GoogleFonts.imprima(
                          height: 1.2,
                          color: Theme.of(context).colorScheme.inverseSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: MediaQuery.textScalerOf(context).scale(35)),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Text(
                      "Get your dream item easily with FashionHub\nand get other interesting offer",
                      style: GoogleFonts.imprima(
                          fontSize: MediaQuery.textScalerOf(context).scale(12),
                          fontWeight: FontWeight.w300,
                          color: Theme.of(context)
                              .colorScheme
                              .inverseSurface
                              .withOpacity(0.7)),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/signup',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              side: BorderSide(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .inverseSurface),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Sign Up",
                                style: GoogleFonts.imprima(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .inverseSurface),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(
                                context,
                                '/login',
                              );
                            },
                            style: OutlinedButton.styleFrom(
                              backgroundColor: Colors.orange,
                              side: const BorderSide(
                                  width: 1, color: Colors.orange),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: Text(
                                "Sign In",
                                style: GoogleFonts.imprima(color: Colors.white),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Spacer(
                      flex: 2,
                    )
                  ],
                ),
              ))
        ],
      ),
    );
  }
}
