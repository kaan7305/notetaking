import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:study_notebook/app/colors.dart';
import 'package:study_notebook/app/route_names.dart';
import 'package:study_notebook/core/models/models.dart';

/// Displays source reference chips that link to document pages.
class SourceReferenceChips extends StatelessWidget {
  final List<SourceReference> references;
  final String courseId;

  const SourceReferenceChips({
    super.key,
    required this.references,
    required this.courseId,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 4,
      runSpacing: 4,
      children: references.map((ref) {
        return ActionChip(
          avatar: const Icon(
            Icons.description_outlined,
            size: 14,
            color: AppColors.primary,
          ),
          label: Text(
            '${ref.documentName}, p.${ref.pageNumber}',
            style: const TextStyle(fontSize: 11, color: AppColors.primary),
          ),
          backgroundColor: AppColors.primary.withValues(alpha: 0.08),
          side: BorderSide.none,
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          visualDensity: VisualDensity.compact,
          onPressed: () {
            final queryParams = <String, String>{
              'page': ref.pageNumber.toString(),
              if (ref.snippet != null && ref.snippet!.isNotEmpty)
                'snippet': ref.snippet!,
            };
            context.pushNamed(
              RouteNames.documentViewer,
              pathParameters: {
                'courseId': courseId,
                'documentId': ref.documentId,
              },
              queryParameters: queryParams,
            );
          },
        );
      }).toList(),
    );
  }
}
