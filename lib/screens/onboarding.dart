import 'package:flutter/material.dart';

class OnboardingScreen extends StatelessWidget {
  final VoidCallback onDone;

  OnboardingScreen({required this.onDone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView(
                children: [
                  _page('welcome', 'welcome_text'),
                  _page('gameify', 'gameify_text'),
                  _page('social', 'social_text'),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: onDone,
                  child: Text('start'),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget _page(String titleKey, String subtitleKey) {
    final locale = Localizations.localeOf(context);
    final strings = {
      'en': {'welcome': 'Welcome', 'gameify': 'Gameify', 'social': 'Social', 'welcome_text': 'Build micro-habits in 1–2 minutes a day.', 'gameify_text': 'Earn points and badges for consistency.', 'social_text': 'Invite friends and join small challenges.', 'start': 'Get started'},
      'tr': {'welcome': 'Hoşgeldin', 'gameify': 'Oyunlaştır', 'social': 'Sosyal', 'welcome_text': 'Günde 1–2 dakikalık mikro alışkanlıklar oluştur.', 'gameify_text': 'Tutarlılık için puan ve rozet kazan.', 'social_text': 'Arkadaşlarını davet et ve küçük meydan okumalara katıl.', 'start': 'Başla'},
      'es': {'welcome': 'Bienvenido', 'gameify': 'Gamificar', 'social': 'Social', 'welcome_text': 'Crea microhábitos en 1–2 minutos al día.', 'gameify_text': 'Gana puntos e insignias por constancia.', 'social_text': 'Invita a amigos y participa en pequeños desafíos.', 'start': 'Comenzar'},
      'fr': {'welcome': 'Bienvenue', 'gameify': 'Jeu', 'social': 'Social', 'welcome_text': 'Créez des micro-habitudes en 1 à 2 minutes par jour.', 'gameify_text': 'Gagnez des points et des badges grâce à la régularité.', 'social_text': 'Invitez des amis et rejoignez de petits défis.', 'start': 'Commencer'},
    };

    final section = strings[locale.languageCode] ?? strings['en']!;
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.emoji_events, size: 96, color: Colors.teal),
          SizedBox(height: 24),
          Text(section[titleKey]!, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
          SizedBox(height: 12),
          Text(section[subtitleKey]!, textAlign: TextAlign.center, style: TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
