import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:monprof/UI/avantPageScreen.dart';

class Onboarding extends StatefulWidget {
  const Onboarding({super.key});

  @override
  State<Onboarding> createState() => _OnboardingState();
}

class _OnboardingState extends State<Onboarding> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white10.withOpacity(0.9),
      body: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(35),
          color: Colors.white,
        ),
        margin: const EdgeInsets.symmetric(vertical: 50, horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: IntroductionScreen(
          next: TextButton(
            child: const SizedBox(
              height: 20,
              child: Text('Passer',
                  style: TextStyle(
                      fontSize: 17,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold)),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AvantPage()),
              );
            },
          ),
          animationDuration: 100,
          pages: [
            PageViewModel(
              title: 'Bienvenue',
              body:
                  "Bienvenue sur la  plateforme innovante d'apprentissage numérique.",
              image: Image.asset('assets/study1.png'),
              decoration: const PageDecoration(
                  pageColor: Colors.white,
                  bodyTextStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
            PageViewModel(
              title: 'Enseignant',
              body:
                  "Avec son réseau d'enseignants provenant des plus grands lycées et collèges du Cameroun, votre succès est garanti à 100%.",
              image: Image.asset('assets/prof.png'),
              decoration: const PageDecoration(
                  pageColor: Colors.white,
                  bodyTextStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
            PageViewModel(
              title: 'Aucune consommation de MEGA',
              body:
                  "Acceder aux ressources didactiques avec 0 data. Après la validation de votre abonnement, vous y accédez gratuitement si vous disposez d'une puce Orange ou MTN. ",
              image: Image.asset('assets/study2.png'),
              decoration: const PageDecoration(
                  pageColor: Colors.white,
                  bodyTextStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
            PageViewModel(
              title: 'Reussite assurée',
              body:
                  'Avec MonProf osons ensemble pour un succès garanti à votre cursus scolaire',
              image: Image.asset('assets/study3.png'),
              decoration: const PageDecoration(
                  pageColor: Colors.white,
                  bodyTextStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 15,
                      fontWeight: FontWeight.bold)),
            ),
          ],
          showNextButton: true,
          done: const Text(
            'Suivant',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          onDone: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AvantPage()),
            );
          },
        ),
      ),
    );
  }
}
