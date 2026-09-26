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
        foregroundColor: AppColors.textPrimaryOf(context),
        side: AppBorders.thinOf(context),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.medium),
        ),
      ),
      child: Row(
        mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 8)],
          Text(label, style: AppTypography.labelOf(context)),
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
    this.hintText,
    this.onChanged,
    this.onFilterTap,
  });

  final TextEditingController? controller;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onFilterTap;

  @override
  Widget build(BuildContext context) => AppTextField(
        controller: controller,
        hintText: hintText ?? AppStrings.get('home_search_hint'),
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
            color: selected
                ? AppColors.onPrimary
                : AppColors.textPrimaryOf(context),
          ),
          label: Text(label, style: AppTypography.labelOf(context)),
          labelStyle: AppTypography.label.copyWith(
            color: selected
                ? AppColors.onPrimary
                : AppColors.textPrimaryOf(context),
          ),
          side: selected ? BorderSide.none : AppBorders.thinOf(context),
          backgroundColor: AppColors.surfaceOf(context),
          selectedColor: AppColors.primary,
          disabledColor: AppColors.surfaceMutedOf(context),
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
              style: AppTypography.headingOf(context)
                  .copyWith(fontSize: AppFontSizes.heading),
            ),
          ),
          if (actionLabel != null)
            TextButton.icon(
              onPressed: onAction,
              iconAlignment: IconAlignment.end,
              icon: const Icon(Icons.chevron_right_rounded,
                  size: AppIconSizes.medium),
              label: Text(actionLabel!, style: AppTypography.labelOf(context)),
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
          color: AppColors.surfaceMutedOf(context),
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
                    color: AppColors.textTertiaryOf(context),
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      AppColors.primary.withValues(alpha: 0.08),
                    ],
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
                      ? (AppColors.isDark(context)
                          ? AppColors.darkPrimaryLight
                          : AppColors.primary)
                      : AppColors.textSecondaryOf(context),
            ),
            style: onImage
                ? IconButton.styleFrom(
                    backgroundColor: AppColors.shadow40,
                    disabledBackgroundColor: AppColors.shadow33,
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
      color: AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(AppRadii.large),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.large),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.large),
            border: Border.all(color: AppColors.borderOf(context)),
            boxShadow: AppShadows.softOf(context),
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
                          left: 6,
                          top: 6,
                          child: AppPlaceTrustBadge(
                            place: place,
                            compact: true,
                          ),
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
                            style: AppTypography.headingOf(context)
                                .copyWith(fontSize: AppFontSizes.body),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppTypography.metadataOf(context).copyWith(
                              fontSize: AppFontSizes.caption,
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
      color: AppColors.surfaceOf(context),
      borderRadius: BorderRadius.circular(AppRadii.medium),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadii.medium),
        child: Container(
          height: cardHeight,
          padding: const EdgeInsets.all(AppSpacing.small),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadii.medium),
            border: Border.all(color: AppColors.borderOf(context)),
            boxShadow: AppShadows.softOf(context),
          ),
          child: Row(
            children: [
              SizedBox(
                width: imageWidth,
                height: double.infinity,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    AppPlaceThumbnail(place: place, cacheWidth: 200),
                    Positioned(
                      left: 4,
                      top: 4,
                      child: AppPlaceTrustBadge(
                        place: place,
                        compact: true,
                      ),
                    ),
                  ],
                ),
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
                      style: AppTypography.headingOf(context).copyWith(
                        fontSize: AppFontSizes.title,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.metadataOf(context).copyWith(
                        fontSize: AppFontSizes.caption,
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
          Icon(icon,
              size: compact ? 13 : 15,
              color: AppColors.textSecondaryOf(context)),
          const SizedBox(width: 3),
          Text(label,
              style: AppTypography.metadataOf(context)
                  .copyWith(fontSize: AppFontSizes.caption)),
        ],
      );
}

class _PlaceKindTag extends StatelessWidget {
  const _PlaceKindTag({required this.label, this.compact = false});

  final String label;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    return Container(
      constraints: const BoxConstraints(maxWidth: 96),
      padding: EdgeInsets.symmetric(
          horizontal: compact ? 6 : 7, vertical: compact ? 2 : 3),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
        borderRadius: BorderRadius.circular(AppRadii.small),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTypography.labelOf(context).copyWith(
          color: isDark ? AppColors.darkPrimaryLight : AppColors.primary,
          fontSize: AppFontSizes.caption,
        ),
      ),
    );
  }
}

class AppPlaceTrustBadge extends StatelessWidget {
  const AppPlaceTrustBadge({
    super.key,
    required this.place,
    this.compact = false,
  });

  final Place place;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final status = place.verificationStatus;

    final (String label, IconData icon, Color color, Color bg) =
        switch (status) {
      VerificationStatus.verified => (
          AppStrings.get('trust_verified'),
          Icons.verified_rounded,
          isDark ? AppColors.darkPrimaryLight : AppColors.primary,
          isDark ? AppColors.darkPrimarySoft : AppColors.primarySoft,
        ),
      VerificationStatus.community => (
          AppStrings.get('trust_community'),
          Icons.people_outline_rounded,
          AppColors.categoryRoute,
          isDark
              ? AppColors.darkSurfaceMuted
              : AppColors.categoryRoute.withValues(alpha: 0.12),
        ),
      VerificationStatus.unverified => (
          AppStrings.get('trust_unverified'),
          Icons.help_outline_rounded,
          isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
          isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
        ),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 5 : 7,
        vertical: compact ? 2 : 3,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadii.small),
        border: Border.all(
          color: color.withValues(alpha: 0.28),
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: compact ? 11 : 13, color: color),
          const SizedBox(width: 3),
          Text(
            label,
            style: AppTypography.labelOf(context).copyWith(
              fontSize: AppFontSizes.caption,
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class AppPlaceTrustSummary extends StatelessWidget {
  const AppPlaceTrustSummary({
    super.key,
    required this.place,
    this.compact = false,
  });

  final Place place;
  final bool compact;

  static ({String label, IconData icon, Color color})? secondaryTrustItem(
    BuildContext context,
    Place place,
  ) {
    final isDark = AppColors.isDark(context);
    final fac = place.facilities.values;

    if (fac['drinking_water'] == true) {
      return (
        label: AppStrings.facility('drinking_water'),
        icon: Icons.water_drop_outlined,
        color: AppColors.categoryWater,
      );
    }
    if (fac['toilets'] == true) {
      return (
        label: AppStrings.facility('toilets'),
        icon: Icons.wc_outlined,
        color: isDark ? AppColors.darkTextPrimary : AppColors.textSecondary,
      );
    }
    if (fac['parking'] == true) {
      return (
        label: AppStrings.facility('parking'),
        icon: Icons.local_parking_rounded,
        color: AppColors.categoryDiscovery,
      );
    }
    if (fac['picnic_allowed'] == true || fac['picnic_facility'] == true) {
      return (
        label: AppStrings.facility('picnic_facility'),
        icon: Icons.deck_outlined,
        color: AppColors.categoryNature,
      );
    }
    if (place.updatedAt != null) {
      return (
        label: '${place.updatedAt!.year}',
        icon: Icons.history_rounded,
        color: isDark ? AppColors.darkTextSecondary : AppColors.textTertiary,
      );
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = AppColors.isDark(context);
    final secondary = secondaryTrustItem(context, place);

    return Wrap(
      spacing: compact ? 5 : 7,
      runSpacing: 3,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        AppPlaceTrustBadge(place: place, compact: compact),
        if (secondary != null)
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 5 : 7,
              vertical: compact ? 2 : 3,
            ),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurface : AppColors.surfaceMuted,
              borderRadius: BorderRadius.circular(AppRadii.small),
              border: Border.all(
                color: secondary.color.withValues(alpha: 0.25),
                width: 0.8,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(secondary.icon,
                    size: compact ? 11 : 13, color: secondary.color),
                const SizedBox(width: 3),
                Text(
                  secondary.label,
                  style: AppTypography.labelOf(context).copyWith(
                    fontSize: AppFontSizes.caption,
                    color: secondary.color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class GlassContainer extends StatelessWidget {
  const GlassContainer({
    super.key,
    required this.child,
    this.borderRadius,
    this.blur = 16.0,
    this.color,
    this.darkColor,
    this.border,
    this.borderColor,
    this.darkBorderColor,
    this.borderWidth = 1.2,
    this.boxShadow,
    this.darkBoxShadow,
    this.padding,
    this.margin,
    this.width,
    this.height,
    this.clipBehavior = Clip.antiAlias,
  });

  final Widget child;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final Color? color;
  final Color? darkColor;
  final BoxBorder? border;
  final Color? borderColor;
  final Color? darkBorderColor;
  final double borderWidth;
  final List<BoxShadow>? boxShadow;
  final List<BoxShadow>? darkBoxShadow;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final double? width;
  final double? height;
  final Clip clipBehavior;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final effectiveRadius =
        borderRadius ?? BorderRadius.circular(AppRadii.large);
    final isWhiteLike =
        color != null && color!.r > 0.82 && color!.g > 0.82 && color!.b > 0.82;
    final effectiveColor = isDark
        ? (darkColor ??
            (color != null && !isWhiteLike
                ? color!.withValues(alpha: (color!.a * 0.7).clamp(0.12, 0.45))
                : AppColors.darkGlassTint))
        : (color ?? Colors.white.withValues(alpha: 0.32));
    final effectiveBorder = border ??
        Border.all(
          color: isDark
              ? (darkBorderColor ?? Colors.white.withValues(alpha: 0.14))
              : (borderColor ?? Colors.white.withValues(alpha: 0.85)),
          width: borderWidth,
        );
    final effectiveShadow = isDark
        ? (darkBoxShadow ??
            boxShadow ??
            const [
              BoxShadow(
                color: AppColors.shadow20,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ])
        : (boxShadow ??
            const [
              BoxShadow(
                color: AppColors.shadow08,
                blurRadius: 16,
                offset: Offset(0, 4),
              ),
            ]);

    Widget content = Container(
      width: width,
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveColor,
        borderRadius: effectiveRadius,
        border: effectiveBorder,
      ),
      child: child,
    );

    if (blur > 0) {
      content = BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: content,
      );
    }

    content = ClipRRect(
      borderRadius: effectiveRadius,
      clipBehavior: clipBehavior,
      child: content,
    );

    if (effectiveShadow.isNotEmpty) {
      content = DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: effectiveRadius,
          boxShadow: effectiveShadow,
        ),
        child: content,
      );
    }

    if (margin != null) {
      content = Padding(padding: margin!, child: content);
    }

    return content;
  }
}

class GlassIconButton extends StatelessWidget {
  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.tooltip,
    this.size = 43,
    this.iconSize = 20,
    this.color,
    this.darkColor,
    this.iconColor,
    this.darkIconColor,
    this.borderColor,
    this.darkBorderColor,
    this.borderWidth = 1.2,
    this.borderRadius,
    this.blur = 10,
    this.boxShadow,
    this.darkBoxShadow,
  });

  final IconData icon;
  final VoidCallback onTap;
  final String? tooltip;
  final double size;
  final double iconSize;
  final Color? color;
  final Color? darkColor;
  final Color? iconColor;
  final Color? darkIconColor;
  final Color? borderColor;
  final Color? darkBorderColor;
  final double borderWidth;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final List<BoxShadow>? boxShadow;
  final List<BoxShadow>? darkBoxShadow;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = borderRadius ?? BorderRadius.circular(AppRadii.medium);
    final resolvedIconColor = isDark
        ? (darkIconColor ?? iconColor ?? AppColors.darkPrimaryLight)
        : (iconColor ?? AppColors.primary);
    final button = Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius is BorderRadius ? radius : null,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(
            icon,
            size: iconSize,
            color: resolvedIconColor,
          ),
        ),
      ),
    );

    final glass = GlassContainer(
      width: size,
      height: size,
      borderRadius: radius,
      blur: blur,
      color: color ?? Colors.white.withValues(alpha: 0.35),
      darkColor: darkColor ?? AppColors.darkGlassTint,
      borderColor: borderColor ?? Colors.white.withValues(alpha: 0.85),
      darkBorderColor: darkBorderColor ?? Colors.white.withValues(alpha: 0.14),
      borderWidth: borderWidth,
      boxShadow: boxShadow,
      darkBoxShadow: darkBoxShadow,
      child: button,
    );

    Widget result = glass;
    if (size < AppControlSizes.minimumTouchTarget) {
      result = ConstrainedBox(
        constraints: const BoxConstraints(
          minWidth: AppControlSizes.minimumTouchTarget,
          minHeight: AppControlSizes.minimumTouchTarget,
        ),
        child: Center(child: glass),
      );
    }

    if (tooltip != null) {
      return Tooltip(message: tooltip!, child: result);
    }
    return result;
  }
}
