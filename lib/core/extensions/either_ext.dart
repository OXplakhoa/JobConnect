import '../utils/either.dart';

extension EitherExt<L, R> on Either<L, R> {
  Either<L, T> map<T>(T Function(R right) fn) {
    return fold(
      (left) => Left(left),
      (right) => Right(fn(right)),
    );
  }

  R getOrElse(R Function() orElse) {
    return fold(
      (left) => orElse(),
      (right) => right,
    );
  }

  bool get isLeft => fold((_) => true, (_) => false);
  bool get isRight => fold((_) => false, (_) => true);
}
