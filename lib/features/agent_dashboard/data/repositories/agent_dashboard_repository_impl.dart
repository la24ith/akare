import "package:akare/core/error/failures.dart";
import "package:dartz/dartz.dart";
import "package:postgrest/postgrest.dart";
import "package:supabase_flutter/supabase_flutter.dart";
import "../../domain/entities/dashboard_stats_entity.dart";
import "../../domain/repositories/agent_dashboard_repository.dart";
import "../datasources/agent_dashboard_remote_datasource.dart";

class AgentDashboardRepositoryImpl implements AgentDashboardRepository {
  final AgentDashboardRemoteDataSource remoteDataSource;
  AgentDashboardRepositoryImpl(this.remoteDataSource);

  Future<Either<Failure, T>> _guard<T>(Future<T> Function() action) async {
    try {
      final result = await action();
      return Right(result);
    } on PostgrestException catch (e) {
      return Left(ServerFailure(_mapPostgrestError(e)));
    } on AuthException catch (_) {
      return const Left(
        ServerFailure("انتهت الجلسة، الرجاء تسجيل الدخول من جديد"),
      );
    } catch (_) {
      return const Left(ServerFailure("حدث خطأ غير متوقع، حاول مرة أخرى"));
    }
  }

  String _mapPostgrestError(PostgrestException e) {
    if (e.code == "PGRST116") return "لا يوجد حساب وكيل مرتبط بهذا المستخدم";
    return "تعذّر تحميل بيانات لوحة التحكم، تحقق من اتصالك بالإنترنت";
  }

  @override
  Future<Either<Failure, DashboardStatsEntity>> getDashboardStats() {
    return _guard(() => remoteDataSource.getDashboardStats());
  }
}
