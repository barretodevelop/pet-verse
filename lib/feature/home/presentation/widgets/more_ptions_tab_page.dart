import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petverse/core/theme/app_theme.dart';

class MoreOptionsTabPage extends StatelessWidget {
  const MoreOptionsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20.w),
      child: Column(
        children: [
          Text(
            'Mais Opções',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: AppTheme.textPrimary,
            ),
          ),
          SizedBox(height: 20.h),
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.more_horiz,
                    size: 80.sp,
                    color: AppTheme.textSecondary,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Configurações e Mais',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Perfil, configurações, suporte\ne outras funcionalidades',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
