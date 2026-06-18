import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/ai_model.dart';
import '../repositories/chat_repository.dart';

class GetModelsUseCase {
  final ChatRepository repository;
  GetModelsUseCase(this.repository);

  Future<Either<Failure, List<AiModel>>> call() => repository.getModels();
}
