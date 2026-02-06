import 'package:flutter/material.dart';
import 'package:dp_canteen/config/theme.dart';
import 'package:dp_canteen/models/canteen.dart';

class CanteenCard extends StatelessWidget {
  final Canteen canteen;
  final bool isSelected;
  final VoidCallback onTap;

  const CanteenCard({
    super.key,
    required this.canteen,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 140,
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryOrange : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryOrange : AppColors.grey200,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primaryOrange.withOpacity(0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Canteen icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withOpacity(0.2)
                    : AppColors.primaryOrange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: canteen.image != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        canteen.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Icon(
                          Icons.restaurant,
                          color: isSelected ? Colors.white : AppColors.primaryOrange,
                          size: 28,
                        ),
                      ),
                    )
                  : Icon(
                      Icons.restaurant,
                      color: isSelected ? Colors.white : AppColors.primaryOrange,
                      size: 28,
                    ),
            ),
            const SizedBox(height: 10),
            // Canteen name
            Text(
              canteen.name,
              style: TextStyle(
                
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : AppColors.grey800,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            // Status
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: canteen.isOpen
                        ? (isSelected ? Colors.white : Colors.green)
                        : (isSelected ? Colors.white60 : Colors.red),
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  canteen.isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    
                    fontSize: 11,
                    color: isSelected
                        ? Colors.white.withOpacity(0.9)
                        : (canteen.isOpen ? Colors.green : Colors.red),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
