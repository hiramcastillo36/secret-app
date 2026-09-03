// Barrel for the couple feature's application layer. Presentation imports this,
// never the repository: the create/join actions live in [CoupleController] and
// the bootstrap read is [coupleMeProvider].
export 'couple_controller.dart';
export '../data/couple_repository.dart' show coupleMeProvider;
