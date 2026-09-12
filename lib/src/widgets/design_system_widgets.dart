part of '../../main.dart';

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.trailing,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final Widget? trailing;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        minimumSize: const Size(0, AppControlSizes.button),
        backgroundColor: AppColors.primary,
        disabledBackgroundColor: AppColors.disabled,
        disabledForegroundColor: AppColors.onPrimary.withValues(alpha: .72),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Text(label,
              style: AppTypography.label.copyWith(color: AppColors.onPrimary)),
          if (trailing != null) ...[const SizedBox(width: 8), trailing!],
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.leading,
    this.expand = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final Widget? leading;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size(0, AppControlSizes.button),
        foregroundColor: AppColors.textPrimary,
        side: AppBorders.thin,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Text(label, style: AppTypography.label),
        ],
      ),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    this.controller,
    this.focusNode,
    this.labelText,
    this.hintText,
    this.errorText,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.keyboardType,
    this.obscureText = false,
    this.maxLines = 1,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? labelText;
  final String? hintText;
  final String? errorText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;
  final bool obscureText;
  final int maxLines;

  @override
  Widget build(BuildContext context) => TextField(
        controller: controller,
        focusNode: focusNode,
        onChanged: onChanged,
        keyboardType: keyboardType,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          errorText: errorText,
          prefixIcon: prefixIcon,
          suffixIcon: suffixIcon,
        ),
      );
}

class AppSearchField extends StatelessWidget {
  const AppSearchField({
    super.key,
    this.controller,
    this.hintText = 'Keşfetmek istediğin yeri ara...',
    this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) => AppTextField(
        controller: controller,
        hintText: hintText,
        onChanged: onChanged,
        prefixIcon: const Icon(Icons.search_rounded, size: AppIconSizes.medium),
        suffixIcon: onFilterTap == null
            ? null
            : IconButton(
                tooltip: 'Filtreleri aç',
                onPressed: onFilterTap,
                icon: const Icon(Icons.tune_rounded, size: AppIconSizes.medium),
              ),
      );
}

class AppCategoryChip extends StatelessWidget {
  const AppCategoryChip({
    super.key,
    required this.label,
    required this.icon,
    this.selected = false,
    this.onSelected,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) => Semantics(
        label: label,
        selected: selected,
        button: true,
        child: FilterChip(
          selected: selected,
          onSelected: onSelected,
          showCheckmark: false,
          avatar: Icon(
            icon,
            size: AppIconSizes.small,
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
          label: Text(label, style: AppTypography.label),
          labelStyle: AppTypography.label.copyWith(
            color: selected ? AppColors.onPrimary : AppColors.textPrimary,
          ),
          side: selected ? BorderSide.none : AppBorders.thin,
          backgroundColor: AppColors.surface,
          selectedColor: AppColors.primary,
          disabledColor: AppColors.surfaceMuted,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadii.pill),
          ),
        ),
      );
}

class AppSectionHeader extends StatelessWidget {
  const AppSectionHeader({
    super.key,
    required this.title,
    this.actionLabel,
    this.onAction,
  });

  final String title;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) => Row(
        children: [
          Expanded(
            child: Text(
              title,
              style: AppTypography.heading.copyWith(fontSize: 22),
            ),
          ),
          if (actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right_rounded,
                  size: AppIconSizes.medium),
              label: Text(actionLabel!, style: AppTypography.label),
            ),
        ],
      );
}

class AppPlaceThumbnail extends StatelessWidget {
  const AppPlaceThumbnail({
    super.key,
    required this.place,
    this.radius = AppRadii.medium,
    this.cacheWidth = 900,
  });

  final Place place;
  final double radius;
  final int cacheWidth;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: ColoredBox(
          color: AppColors.surfaceMuted,
          child: Stack(
            fit: StackFit.expand,
            children: [
              PlaceImage(
                place: place,
                cacheWidth: cacheWidth,
                fallback: Center(
                  child: Icon(
                    place.icon,
                    size: AppIconSizes.large,
                    color: AppColors.textTertiary,
                  ),
                ),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Color(0x140F5A35)],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
}

class AppBookmarkButton extends StatelessWidget {
  const AppBookmarkButton({
    super.key,
    this.onPressed,
    this.isSaved = false,
    this.onImage = false,
  });

  final VoidCallback? onPressed;
  final bool isSaved;
  final bool onImage;

  @override
  Widget build(BuildContext context) => Semantics(
        label: isSaved ? 'Kaydedildi' : 'Kaydet',
        button: onPressed != null,
        child: SizedBox(
          width: AppControlSizes.minimumTouchTarget,
          height: AppControlSizes.minimumTouchTarget,
          child: IconButton(
            tooltip: isSaved ? 'Kaydedildi' : 'Kaydet',
            onPressed: onPressed,
            icon: Icon(
              isSaved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              color: onImage
                  ? Colors.white
                  : isSaved
                      ? AppColors.primary
                      : AppColors.textSecondary,
            ),
            style: onImage
                ? IconButton.styleFrom(
                    backgroundColor: const Color(0x66000000),
                    disabledBackgroundColor: const Color(0x55000000),
                  )
                : null,
          ),
        ),
      );
}

class AppPlaceMetadataRow extends StatelessWidget {
  const AppPlaceMetadataRow({
    super.key,
    required this.place,
    this.showDistance = true,
    this.showCategory = true,
    this.compact = false,
  });

  final Place place;
  final bool showDistance;
  final bool showCategory;
  final bool compact;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: compact ? 7 : 10,
        runSpacing: 4,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          if (showDistance && place.distanceKm != null)
            _PlaceMeta(
              icon: Icons.location_on_outlined,
              label:
                  '${place.distanceKm!.toStringAsFixed(1).replaceAll('.', ',')} km',
              compact: compact,
            ),
          if (place.rating > 0)
            _PlaceMeta(
              icon: Icons.star_outline_rounded,
              label: place.rating.toStringAsFixed(1).replaceAll('.', ','),
              compact: compact,
            ),
          if (showCategory) _PlaceKindTag(label: place.kind, compact: compact),
        ],
      );
}

class AppPlaceHeroCard extends StatelessWidget {
  const AppPlaceHeroCard({
    super.key,
    required this.place,
    required this.onTap,
    this.onSave,
    this.isSaved = false,
    this.showDistance = true,
  });

  final Place place;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaved;
  final bool showDistance;

  @override
  Widget build(BuildContext context) {
    final description = place.description.trim().isEmpty
        ? place.kind
        : place.description.trim();
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final imageHeight = constraints.maxHeight.isFinite
                  ? constraints.maxHeight * .55
                  : 126.0;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: imageHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        AppPlaceThumbnail(
                          place: place,
                          radius: 0,
                          cacheWidth: 380,
                        ),
                        Positioned(
                          right: 6,
                          top: 6,
                          child: AppBookmarkButton(
                            onPressed: onSave,
                            isSaved: isSaved,
                            onImage: true,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.compact),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            place.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.heading.copyWith(fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.metadata.copyWith(
                              fontSize: 12,
                              height: 1.25,
                            ),
                          ),
                          const Spacer(),
                          AppPlaceMetadataRow(
                            place: place,
                            showDistance: showDistance,
                            compact: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class AppMapPreviewCard extends StatelessWidget {
  const AppMapPreviewCard({
    super.key,
    required this.place,
    required this.onTap,
    this.onSave,
    this.isSaved = false,
    this.showDistance = true,
    this.prominent = false,
  });

  final Place place;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaved;
  final bool showDistance;
  final bool prominent;

  @override
  Widget build(BuildContext context) {
    final description = place.description.trim().isEmpty
        ? place.kind
        : place.description.trim();
    final cardHeight = prominent ? 128.0 : 108.0;
    final imageWidth = prominent ? 136.0 : 88.0;
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: Container(
          height: cardHeight,
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: AppColors.border),
            boxShadow: AppShadows.soft,
          ),
          child: Row(
            children: [
              SizedBox(
                width: imageWidth,
                height: double.infinity,
                child: AppPlaceThumbnail(place: place, cacheWidth: 200),
              ),
              const SizedBox(width: AppSpacing.small),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      place.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.heading.copyWith(
                        fontSize: prominent ? 17 : 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.metadata.copyWith(
                        fontSize: prominent ? 12.5 : 12,
                      ),
                    ),
                    const Spacer(),
                    AppPlaceMetadataRow(
                      place: place,
                      showDistance: showDistance,
                      compact: true,
                    ),
                  ],
                ),
              ),
              AppBookmarkButton(onPressed: onSave, isSaved: isSaved),
            ],
          ),
        ),
      ),
    );
  }
}

class AppCompactPlaceCard extends StatelessWidget {
  const AppCompactPlaceCard({
    super.key,
    required this.place,
    required this.onTap,
    this.onSave,
    this.isSaved = false,
  });

  final Place place;
  final VoidCallback onTap;
  final VoidCallback? onSave;
  final bool isSaved;

  @override
  Widget build(BuildContext context) => AppMapPreviewCard(
        place: place,
        onTap: onTap,
        onSave: onSave,
        isSaved: isSaved,
      );
}

class _PlaceMeta extends StatelessWidget {
  const _PlaceMeta({
    required this.icon,
    required this.label,
    this.compact = false,
  });

  final IconData icon;
  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 13 : 15, color: AppColors.textSecondary),
          const SizedBox(width: 3),
          Text(label,
              style:
                  AppTypography.metadata.copyWith(fontSize: compact ? 11 : 12)),
        ],
      );
}

class _PlaceKindTag extends StatelessWidget {
  const _PlaceKindTag({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
        constraints: const BoxConstraints(maxWidth: 96),
        padding: EdgeInsets.symmetric(
            horizontal: compact ? 6 : 7, vertical: compact ? 2 : 3),
        decoration: BoxDecoration(
          color: AppColors.primarySoft,
          borderRadius: BorderRadius.circular(AppRadii.small),
        ),
        child: Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.label.copyWith(
            color: AppColors.primary,
            fontSize: compact ? 10 : 11,
          ),
        ),
      );
}
