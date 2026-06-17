// Bootstrap de Flutter personalizado: carga Flutter SIN service worker.
// Llamamos a loader.load() sin serviceWorkerSettings, así el loader nunca
// registra el service worker de Flutter (deprecado), que en un deploy anterior
// cacheo un bundle roto. Junto con el script de limpieza de index.html, el
// cliente siempre recibe la version recien desplegada.
//
// Nota: este archivo es una plantilla; flutter build web inserta el cargador y
// la configuracion del build en las dos lineas de abajo. No pongas tokens de
// plantilla dentro de comentarios: el reemplazo es textual y los expandiria.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load();
