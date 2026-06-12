import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/failure.dart';
import '../../../../core/utils/either.dart';
import '../../../recruiter/data/models/company_model.dart';
import '../../../recruiter/data/models/job_location_model.dart';
import '../../../recruiter/data/models/job_post_model.dart';
import '../../../recruiter/data/models/job_required_skill_model.dart';
import '../../domain/entities/job_filter.dart';
import '../../domain/entities/job_search_result.dart';

abstract class JobSearchDatasource {
  Future<Either<Failure, List<JobSearchResult>>> searchJobs({
    String? searchQuery,
    required JobFilter filter,
    String? cursor,
    int limit,
  });
}

class JobSearchDatasourceImpl implements JobSearchDatasource {
  const JobSearchDatasourceImpl(this._supabase);

  final SupabaseClient _supabase;

  @override
  Future<Either<Failure, List<JobSearchResult>>> searchJobs({
    String? searchQuery,
    required JobFilter filter,
    String? cursor,
    int limit = 20,
  }) async {
    try {
      var query = _supabase
          .from('job_posts')
          .select('''
            *,
            companies(
              id,
              recruiter_id,
              name,
              logo_url,
              description,
              website,
              size,
              province,
              created_at,
              updated_at
            ),
            job_locations!inner(
              id,
              job_id,
              province,
              district,
              address,
              is_remote,
              created_at
            ),
            job_required_skills(
              job_id,
              skill_id,
              is_required,
              skills(name)
            ),
            job_categories(name)
          ''')
          .eq('status', 'active');

      // Cursor-based pagination (filter before ordering)
      if (cursor != null) {
        query = query.lt('created_at', cursor);
      }

      // Search across title and description (ILIKE)
      // Note: company name search via or() with embedded table is not supported
      // by PostgREST in this format. Keep title+description only.
      if (searchQuery != null && searchQuery.isNotEmpty) {
        query = query.or(
          'title.ilike.%$searchQuery%,description.ilike.%$searchQuery%',
        );
      }

      // Category filter
      if (filter.categoryIds.isNotEmpty) {
        query = query.inFilter('category_id', filter.categoryIds);
      }

      // Province filter (on embedded job_locations)
      if (filter.provinces.isNotEmpty) {
        query = query.inFilter('job_locations.province', filter.provinces);
      }

      // Job type filter
      if (filter.jobTypes.isNotEmpty) {
        query = query.inFilter('type', filter.jobTypes);
      }

      // Remote filter (on embedded job_locations)
      if (filter.isRemote != null) {
        query = query.eq('job_locations.is_remote', filter.isRemote!);
      }

      // Salary range filter — match jobs whose [salary_min, salary_max] band
      // OVERLAPS the selected [min, max] band, not just those fully contained
      // inside it. Two ranges overlap when job.salary_max >= filter.min AND
      // job.salary_min <= filter.max. (e.g. a 13–19M job matches a 15–20M
      // filter.) An open-ended filter (max == null) only needs the lower bound.
      if (filter.salaryRange != null) {
        query = query.gte('salary_max', filter.salaryRange!.min);
        if (filter.salaryRange!.max != null) {
          query = query.lte('salary_min', filter.salaryRange!.max!);
        }
      }

      // Ordering and limiting (must come after all filters)
      final data = await query
          .order('created_at', ascending: false)
          .limit(limit);

      final results = (data as List).map((json) {
        final map = json as Map<String, dynamic>;
        return _parseSearchResult(map);
      }).toList();

      return Right(results);
    } on PostgrestException catch (e) {
      return Left(DatabaseFailure(message: e.message));
    } catch (e) {
      return Left(UnexpectedFailure(message: e.toString()));
    }
  }

  JobSearchResult _parseSearchResult(Map<String, dynamic> json) {
    final jobPost = JobPostModel.fromJson(_extractJobPostFields(json));

    final companyData = json['companies'] as Map<String, dynamic>?;
    final company = companyData != null
        ? CompanyModel.fromJson(companyData)
        : CompanyModel(
            id: json['company_id'] as String,
            recruiterId: '',
            name: 'Không xác định',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );

    // job_locations returns as List<dynamic> from PostgREST join
    final locationList = json['job_locations'] as List<dynamic>? ?? [];
    final locationData = locationList.isNotEmpty
        ? locationList.first as Map<String, dynamic>?
        : null;
    final location = locationData != null
        ? JobLocationModel.fromJson(locationData)
        : JobLocationModel(
            id: '',
            jobId: jobPost.id,
            isRemote: false,
            createdAt: DateTime.now(),
          );

    final skillsData = json['job_required_skills'] as List<dynamic>? ?? [];
    final skills = skillsData.map((skillJson) {
      final s = skillJson as Map<String, dynamic>;
      final skillNested = s['skills'] as Map<String, dynamic>?;
      final skillName = skillNested?['name'] as String?;
      return JobRequiredSkillModel.fromJson({
        'job_id': s['job_id'] as String? ?? jobPost.id,
        'skill_id': s['skill_id'] as String,
        'is_required': s['is_required'] as bool,
        'skill_name': skillName,
      });
    }).toList();

    final categoryData = json['job_categories'] as Map<String, dynamic>?;
    final categoryName = categoryData?['name'] as String?;

    return JobSearchResult(
      jobPost: jobPost.toEntity(),
      company: company.toEntity(),
      location: location.toEntity(),
      skills: skills.map((s) => s.toEntity()).toList(),
      categoryName: categoryName,
    );
  }

  /// Extract only the job_post fields from the joined response.
  Map<String, dynamic> _extractJobPostFields(Map<String, dynamic> json) {
    return {
      'id': json['id'],
      'company_id': json['company_id'],
      'title': json['title'],
      'description': json['description'],
      'requirements': json['requirements'],
      'salary_min': json['salary_min'],
      'salary_max': json['salary_max'],
      'is_salary_visible': json['is_salary_visible'],
      'type': json['type'],
      'category_id': json['category_id'],
      'status': json['status'],
      'expires_at': json['expires_at'],
      'created_at': json['created_at'],
      'updated_at': json['updated_at'],
    };
  }
}
