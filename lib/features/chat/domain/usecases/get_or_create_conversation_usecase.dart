import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../entities/conversation.dart';
import '../repositories/chat_repository.dart';

class GetOrCreateConversationUseCase {
  const GetOrCreateConversationUseCase(this._repository);

  final ChatRepository _repository;

  static const _allowedStatuses = [
    'pending',
    'reviewing',
    'interview',
    'accepted',
  ];

  Future<Either<Failure, Conversation>> call({
    required String seekerId,
    required String jobId,
  }) async {
    final recruiterResult = await _repository.getRecruiterIdForJob(jobId);

    return recruiterResult.fold(Left.new, (recruiterId) async {
      if (recruiterId == null) {
        return const Left(
          DatabaseFailure(message: 'Tin tuyển dụng không hợp lệ.'),
        );
      }

      final existingResult = await _repository.findConversation(
        seekerId: seekerId,
        recruiterId: recruiterId,
        jobId: jobId,
      );

      return existingResult.fold(Left.new, (conversation) async {
        if (conversation != null) return Right(conversation);

        final statusResult = await _repository.getApplicationStatusForChat(
          seekerId: seekerId,
          jobId: jobId,
        );

        return statusResult.fold(Left.new, (status) async {
          if (status == null) {
            return const Left(
              DatabaseFailure(
                message:
                    'Bạn cần ứng tuyển trước khi nhắn tin với Nhà tuyển dụng.',
              ),
            );
          }
          if (!_allowedStatuses.contains(status)) {
            return const Left(
              DatabaseFailure(
                message:
                    'Không thể bắt đầu cuộc trò chuyện ở trạng thái này.',
              ),
            );
          }

          return _repository.createConversation(
            seekerId: seekerId,
            recruiterId: recruiterId,
            jobId: jobId,
          );
        });
      });
    });
  }
}
