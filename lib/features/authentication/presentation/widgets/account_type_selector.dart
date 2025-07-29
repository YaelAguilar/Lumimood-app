import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/presentation/theme.dart';
import '../../domain/entities/user_entity.dart';
import '../bloc/auth_bloc.dart';

class AccountTypeSelector extends StatelessWidget {
  const AccountTypeSelector({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    
    return BlocBuilder<AuthBloc, AuthState>(
      buildWhen: (p, c) => p.accountType != c.accountType,
      builder: (context, state) {
        if (isSmallScreen) {
          return Container(
            decoration: BoxDecoration(
              color: AppTheme.alternate,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _AccountTypeButton(
                    text: 'Paciente',
                    isSelected: state.accountType == AccountType.patient,
                    onTap: () => context.read<AuthBloc>().add(
                      AuthAccountTypeChanged(AccountType.patient),
                    ),
                  ),
                ),
                Expanded(
                  child: _AccountTypeButton(
                    text: 'Especialista',
                    isSelected: state.accountType == AccountType.specialist,
                    onTap: () => context.read<AuthBloc>().add(
                      AuthAccountTypeChanged(AccountType.specialist),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
        
        return CupertinoSlidingSegmentedControl<AccountType>(
          backgroundColor: AppTheme.alternate,
          thumbColor: AppTheme.primaryColor,
          groupValue: state.accountType,
          children: {
            AccountType.patient: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Text(
                'Soy Paciente',
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            AccountType.specialist: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              child: Text(
                'Soy Especialista',
                style: const TextStyle(color: Colors.white),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          },
          onValueChanged: (value) {
            if (value != null) {
              context.read<AuthBloc>().add(AuthAccountTypeChanged(value));
            }
          },
        );
      },
    );
  }
}

class _AccountTypeButton extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeButton({
    required this.text,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: Colors.white,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 14,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}