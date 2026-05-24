abstract class UseCase<R, Params> {
  Future<R> call({Params params});
}
