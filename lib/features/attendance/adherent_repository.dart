import 'adherent.dart';

class AdherentRepository {

  List<Adherent> getAdherentsForCourse() {

    return [
      Adherent(
        firstName: 'Arthur',
        lastName: 'DUPONT',
      ),
      Adherent(
        firstName: 'Emma',
        lastName: 'MARTIN',
      ),
      Adherent(
        firstName: 'Lucas',
        lastName: 'BERNARD',
      ),
      Adherent(
        firstName: 'Léa',
        lastName: 'PETIT',
      ),
    ];

  }
}