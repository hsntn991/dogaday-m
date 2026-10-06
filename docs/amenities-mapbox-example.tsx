// Reference only. Doğadayım is a Flutter app, so this file is not imported by
// the application. It shows the requested two-layer Mapbox structure for a
// future web client: nature places first, amenities only after a place opens.
import { useEffect, useState } from 'react';
import Map, { Marker } from 'react-map-gl/mapbox';

type Place = { id: number; name: string; latitude: number; longitude: number };
type Amenity = { id: number; name: string; subtype: string; distance_m: number };

export function NatureMap({ places }: { places: Place[] }) {
  const [selected, setSelected] = useState<Place | null>(null);
  const [amenities, setAmenities] = useState<Amenity[]>([]);

  useEffect(() => {
    if (!selected) {
      setAmenities([]);
      return;
    }
    void fetch('/rest/v1/rpc/nearby_amenities', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        p_latitude: selected.latitude,
        p_longitude: selected.longitude,
        p_radius_m: 2000,
      }),
    }).then(async (response) => {
      setAmenities(response.ok ? await response.json() : []);
    });
  }, [selected]);

  return (
    <>
      <Map mapboxAccessToken="YOUR_PUBLIC_MAPBOX_TOKEN" initialViewState={{ latitude: 39, longitude: 35, zoom: 5 }} mapStyle="mapbox://styles/mapbox/outdoors-v12">
        {places.map((place) => (
          <Marker key={place.id} latitude={place.latitude} longitude={place.longitude} onClick={() => setSelected(place)} />
        ))}
      </Map>
      {selected && <aside>
        <h2>Yakınımda ne var?</h2>
        {amenities.map((amenity) => <p key={amenity.id}>{amenity.name} · {amenity.distance_m} m</p>)}
      </aside>}
    </>
  );
}
