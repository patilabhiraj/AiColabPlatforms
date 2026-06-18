import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/assistant.dart';
import '../repositories/chat_repository.dart';

class GetAssistantsUseCase {
  final ChatRepository repository;
  GetAssistantsUseCase(this.repository);

  Future<Either<Failure, List<Assistant>>> call() => repository.getAssistants();
}
