"""Staging-only Phase 6 acceptance runner. Secrets are read from environment only."""
import argparse
import datetime as dt
import json
import os
from pathlib import Path
import time
import urllib.error
import urllib.parse
import urllib.request
import uuid

class NoRedirect(urllib.request.HTTPRedirectHandler):
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None

def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--mutate-test-records', action='store_true', help='Claim/redeem one designated test offer and publish a one-minute test notice.')
    args = parser.parse_args()
    required = ['REKI_STAGING_URL', 'REKI_STAGING_CUSTOMER_TOKEN', 'REKI_STAGING_OWNER_TOKEN', 'REKI_STAGING_WORKER_TOKEN', 'REKI_STAGING_VENUE_ID']
    if args.mutate_test_records:
        required.append('REKI_STAGING_OFFER_ID')
    missing = [key for key in required if not os.environ.get(key)]
    if missing:
        parser.error('Missing local configuration: ' + ', '.join(missing))
    base = os.environ['REKI_STAGING_URL'].rstrip('/')
    parsed = urllib.parse.urlsplit(base)
    if parsed.scheme != 'https' or not parsed.hostname or parsed.hostname.lower() in {'api.reki.uk', 'reki.uk', 'www.reki.uk'} or parsed.username or parsed.password or parsed.query or parsed.fragment:
        parser.error('Provide a dedicated HTTPS staging URL, never production or a URL containing credentials.')
    venue = urllib.parse.quote(os.environ['REKI_STAGING_VENUE_ID'], safe='')
    opener = urllib.request.build_opener(NoRedirect())
    results = []
    def request(label, method, path, role=None, payload=None, expected=(200,)):
        headers = {'Accept': 'application/json'}
        if role:
            headers['Authorization'] = 'Bearer ' + os.environ[f'REKI_STAGING_{role}_TOKEN']
        encoded = None if payload is None else json.dumps(payload).encode()
        if encoded is not None:
            headers['Content-Type'] = 'application/json'
        start = time.perf_counter()
        try:
            with opener.open(urllib.request.Request(base + path, data=encoded, headers=headers, method=method), timeout=15) as response:
                code, raw = response.status, response.read()
        except urllib.error.HTTPError as error:
            code, raw = error.code, error.read()
        except (urllib.error.URLError, TimeoutError):
            results.append({'check': label, 'passed': False, 'error': 'network_or_timeout'})
            return None
        try:
            body = json.loads(raw)
        except (ValueError, UnicodeDecodeError):
            body = None
        results.append({'check': label, 'status': code, 'passed': code in expected, 'httpElapsedMs': round((time.perf_counter()-start)*1000)})
        return body if code in expected else None
    def entries(body):
        if isinstance(body, dict):
            body = body.get('data', body.get('venues', body.get('items', body)))
        return body if isinstance(body, list) else []
    def unwrap(body):
        value = body.get('data', body) if isinstance(body, dict) else {}
        return value if isinstance(value, dict) else {}
    def check(label, passed):
        results.append({'check': label, 'passed': bool(passed)})

    request('owner can list staff', 'GET', '/worker/staff', 'OWNER')
    assigned = request('worker can list assigned venues', 'GET', '/worker/venues', 'WORKER')
    check('designated venue is assigned', any(str(v.get('id', (v.get('venue') or {}).get('id'))) == os.environ['REKI_STAGING_VENUE_ID'] for v in entries(assigned) if isinstance(v, dict)))
    request('customer cannot list worker venues', 'GET', '/worker/venues', 'CUSTOMER', expected=(403,))
    request('worker cannot manage staff', 'GET', '/worker/staff', 'WORKER', expected=(403,))
    request('worker can read live info', 'GET', f'/worker/venues/{venue}/live-info', 'WORKER')
    request('customer can read announcements', 'GET', f'/venues/{venue}/whats-on', 'CUSTOMER')
    if args.mutate_test_records and all(result['passed'] for result in results):
        offer = urllib.parse.quote(os.environ['REKI_STAGING_OFFER_ID'], safe='')
        claim = unwrap(request('customer claims test offer', 'POST', f'/offers/{offer}/claim', 'CUSTOMER', expected=(200,201)))
        payload = {'qrCodeData': claim['qrCodeData']} if claim.get('qrCodeData') else {'voucherCode': claim['voucherCode']} if claim.get('voucherCode') else None
        check('claim contains supported QR or voucher', payload is not None)
        if payload:
            confirmation = unwrap(request('assigned worker redeems test voucher', 'POST', f'/worker/venues/{venue}/redemptions/scan', 'WORKER', payload, expected=(200,201)))
            check('response satisfies app transaction confirmation', confirmation.get('transactionId') is not None and confirmation.get('success') is not False)
            if confirmation.get('transactionId') is not None:
                request('duplicate voucher is rejected', 'POST', f'/worker/venues/{venue}/redemptions/scan', 'WORKER', payload, expected=(400,409,422))
        title = 'Phase 6 staging check ' + uuid.uuid4().hex[:8]
        notice = {'type':'notice','title':title,'isActive':True,'endsAt':(dt.datetime.now(dt.timezone.utc)+dt.timedelta(minutes=1)).isoformat()}
        published = request('worker publishes expiring test notice', 'POST', f'/worker/venues/{venue}/live-info', 'WORKER', notice, expected=(200,201))
        if published is not None:
            public = request('public announcement readback', 'GET', f'/venues/{venue}/whats-on')
            check('published title visible to customers', any(item.get('title') == title for item in entries(public) if isinstance(item, dict)))
    report = {'checkedAtUtc':dt.datetime.now(dt.timezone.utc).isoformat(),'mutationsRequested':args.mutate_test_records,'results':results,'limits':'HTTP latency excludes camera acquisition and app rendering. Assignment/revocation, wrong-venue, expired-voucher, city parity and physical-device checks remain separate.'}
    output = Path(__file__).resolve().parent / 'phase6-staging-results.json'
    output.write_text(json.dumps(report, indent=2), encoding='utf-8')
    print(json.dumps(report, indent=2))
    return 0 if all(result['passed'] for result in results) else 1

if __name__ == '__main__':
    raise SystemExit(main())
