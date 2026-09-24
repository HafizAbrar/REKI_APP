"""Read-only Phase 6 audit; never creates accounts, announcements or redemptions."""
from pathlib import Path
from concurrent.futures import ThreadPoolExecutor
import json, urllib.request, urllib.error, datetime
root = Path(__file__).resolve().parents[1]
base = 'https://api.reki.uk'
def get(path):
    try:
        with urllib.request.urlopen(base + path, timeout=20) as response:
            return response.status, json.load(response)
    except urllib.error.HTTPError as error:
        return error.code, None
    except Exception as error:
        return str(error), None
status, spec = get('/api/docs-json')
if status != 200:
    raise RuntimeError(f'OpenAPI unavailable: {status}')
(root / 'tool/phase6-live-openapi.json').write_text(json.dumps(spec, indent=2), encoding='utf-8')
_, cities = get('/cities')
city_list = cities if isinstance(cities, list) else []
_, venues = get('/venues?city=manchester&limit=1')
venue_list = venues.get('venues', []) if isinstance(venues, dict) else []
checks = ['/health', '/cities', '/cities/manchester', '/cities/detect?lat=53.4808&lng=-2.2426', '/users/location/city', '/business/venues', '/worker/venues', '/worker/staff', '/live/snapshot?city=london']
for city in city_list:
    checks.extend([f"/cities/id/{city['id']}", f"/venues?city={city['slug']}&limit=1", f"/offers?city={city['slug']}"])
if venue_list:
    venue_id = venue_list[0]['id']
    checks.extend([f'/venues/{venue_id}/whats-on', f'/worker/venues/{venue_id}/live-info'])
def check(path):
    code, data = get(path)
    row = {'method': 'GET', 'path': path, 'status': code}
    if isinstance(data, dict):
        if isinstance(data.get('pagination'), dict): row['total'] = data['pagination'].get('total')
        if path.startswith('/offers'): row['count'] = len(data.get('offers', []))
    if isinstance(data, list): row['count'] = len(data)
    return row
with ThreadPoolExecutor(max_workers=4) as pool:
    records = list(pool.map(check, checks))
required = [
 ('GET','/cities'), ('GET','/cities/{slug}'), ('GET','/cities/id/{id}'), ('GET','/cities/detect'),
 ('PUT','/users/city'), ('PUT','/users/locale'), ('GET','/users/location/city'),
 ('GET','/worker/staff'), ('POST','/worker/staff'), ('DELETE','/worker/staff/{staffId}'),
 ('GET','/worker/venues'), ('POST','/worker/venues/{venueId}/assignments'), ('DELETE','/worker/venues/{venueId}/assignments/{businessUserId}'),
 ('POST','/worker/venues/{venueId}/status'), ('GET','/worker/venues/{venueId}/live-info'), ('POST','/worker/venues/{venueId}/live-info'),
 ('POST','/worker/venues/{venueId}/redemptions/scan'), ('GET','/venues/{id}/whats-on'), ('PUT','/business/venues/{id}/whats-on'),
 ('GET','/venues'), ('GET','/offers'), ('GET','/live/snapshot')
]
report = {
 'checkedAtUtc': datetime.datetime.now(datetime.timezone.utc).isoformat(),
 'baseUrl': base, 'openapiUrl': base + '/api/docs-json',
 'methodology': 'Live OpenAPI contract inspection and unauthenticated GET requests only. No production mutations. 401 indicates authentication required, not successful role authorization. Response schemas are incomplete for protected operations.',
 'cities': [{'id': c['id'], 'slug': c['slug'], 'isActive': c['isActive']} for c in city_list],
 'readOnlyChecks': records,
 'requiredContracts': [{'method': m, 'path': p, 'documented': m.lower() in spec['paths'].get(p, {})} for m,p in required]
}
(root / 'tool/phase6-backend-audit.json').write_text(json.dumps(report, indent=2), encoding='utf-8')
print(json.dumps(report, indent=2))
