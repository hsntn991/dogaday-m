part of '../../main.dart';

class PlaceImage extends StatelessWidget {
  const PlaceImage({
    super.key,
    required this.place,
    required this.fallback,
    this.fit = BoxFit.cover,
    this.cacheWidth = 900,
  });

  final Place place;
  final Widget fallback;
  final BoxFit fit;
  final int cacheWidth;

  static ImageProvider<Object>? resolveProvider(Place place) {
    final value = place.image?.trim();
    if (value == null || value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return NetworkImage(value);
    }
    if (value.startsWith('data:image/')) {
      final comma = value.indexOf(',');
      if (comma < 0) return null;
      try {
        return MemoryImage(base64Decode(value.substring(comma + 1)));
      } catch (_) {
        return null;
      }
    }
    return localPlaceImageProvider(value);
  }

  @override
  Widget build(BuildContext context) {
    final provider = resolveProvider(place);
    if (provider == null) return fallback;
    return Image(
      image: ResizeImage.resizeIfNeeded(cacheWidth, null, provider),
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (_, __, ___) => fallback,
    );
  }
}

class NatureArt extends StatelessWidget {
  const NatureArt({
    super.key,
    required this.place,
    this.radius = AppRadii.large,
    this.showKind = true,
  });
  final Place place;
  final double radius;
  final bool showKind;
  @override
  Widget build(BuildContext context) => Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(radius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: place.colors,
          ),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            PlaceImage(
              place: place,
              fallback: Center(
                child: Icon(
                  place.icon,
                  size: 70,
                  color: Colors.white.withValues(alpha: .42),
                ),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0x55000000)],
                ),
              ),
            ),
            if (showKind)
              Positioned(
                left: 18,
                top: 18,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .9),
                    borderRadius: BorderRadius.circular(AppRadii.pill),
                  ),
                  child: Text(
                    place.kind,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: green,
                    ),
                  ),
                ),
              ),
          ],
        ),
      );
}

class CompactPlaceCard extends StatelessWidget {
  const CompactPlaceCard({
    super.key,
    required this.place,
    required this.onTap,
  });
  final Place place;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) => Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadii.medium),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                SizedBox(
                  width: 94,
                  height: 82,
                  child: NatureArt(place: place, radius: AppRadii.medium),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        place.name,
                        maxLines: 2,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        '${place.kind} • ${place.location}',
                        style: const TextStyle(color: Colors.black54),
                      ),
                      const SizedBox(height: 5),
                      Row(
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 17,
                            color: Color(0xFFF5A623),
                          ),
                          Text('${place.rating}'),
                        ],
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.black38),
              ],
            ),
          ),
        ),
      );
}
