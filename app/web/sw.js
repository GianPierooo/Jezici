// Jezici · Service Worker (PWA) — update-safe.
// Estrategia: la app (index/JS) va NETWORK-FIRST para no servir versiones
// viejas (el bug de "no carga" del deploy anterior fue un SW cacheando algo
// roto); los assets estáticos van stale-while-revalidate; navegación offline
// cae al index cacheado. skipWaiting + claim para que las actualizaciones
// tomen efecto al instante. También maneja Web Push (Matix).
const VERSION = 'jezici-v3'; // bump: refetch del font de íconos (GA10: nuevos glifos en mapa/estados)
const SHELL = [
  './', 'index.html', 'flutter_bootstrap.js', 'manifest.json',
  'favicon.png', 'icons/Icon-192.png', 'icons/Icon-512.png',
];

self.addEventListener('install', (e) => {
  self.skipWaiting();
  e.waitUntil(caches.open(VERSION).then((c) => c.addAll(SHELL).catch(() => {})));
});

self.addEventListener('activate', (e) => {
  e.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter((k) => k !== VERSION).map((k) => caches.delete(k)));
    await self.clients.claim();
  })());
});

const NETWORK_FIRST = /(?:\/$|index\.html|flutter_bootstrap\.js|main\.dart\.js|flutter\.js)$/;

self.addEventListener('fetch', (e) => {
  const req = e.request;
  if (req.method !== 'GET') return;
  const url = new URL(req.url);
  // Cross-origin (Supabase API/Storage): pasar directo a la red.
  if (url.origin !== self.location.origin) return;

  if (req.mode === 'navigate' || NETWORK_FIRST.test(url.pathname)) {
    e.respondWith(
      fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(VERSION).then((c) => c.put(req, copy)).catch(() => {});
        return res;
      }).catch(() => caches.match(req).then((r) => r || caches.match('index.html')))
    );
    return;
  }
  // Estáticos: stale-while-revalidate.
  e.respondWith(
    caches.match(req).then((cached) => {
      const net = fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(VERSION).then((c) => c.put(req, copy)).catch(() => {});
        return res;
      }).catch(() => cached);
      return cached || net;
    })
  );
});

// ── Web Push (Matix) ────────────────────────────────────────────────────────
self.addEventListener('push', (e) => {
  let data = {};
  try { data = e.data ? e.data.json() : {}; } catch (_) { data = { body: e.data && e.data.text() }; }
  const title = data.title || 'Matix · Jezici';
  const body = data.body || '¡Sigue tu racha! 🦜';
  e.waitUntil(self.registration.showNotification(title, {
    body,
    icon: 'icons/Icon-192.png',
    badge: 'icons/Icon-192.png',
    data: { url: data.url || './' },
    tag: data.tag || 'matix',
  }));
});

self.addEventListener('notificationclick', (e) => {
  e.notification.close();
  const target = (e.notification.data && e.notification.data.url) || './';
  e.waitUntil((async () => {
    const all = await self.clients.matchAll({ type: 'window', includeUncontrolled: true });
    for (const c of all) { if ('focus' in c) return c.focus(); }
    if (self.clients.openWindow) return self.clients.openWindow(target);
  })());
});
