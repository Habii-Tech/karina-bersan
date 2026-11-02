# Dra. Karina Bersan — landing page

<!-- Habii template. Keep it under 80 lines. Comments like this one do not reach the context. -->

Static landing page for Dra. Karina Bersan's dental office in Juiz de Fora/MG (pt-BR audience).

Always respond to the user in Brazilian Portuguese (pt-BR); code, identifiers and commits in English.

## Commands
- Install: none (no package manager; plain static files)
- Dev: `python3 -m http.server` → open http://localhost:8000/
- Full verification: `.claude/verify.sh` (asset refs exist, inline script parses, structure intact)

## Architecture
- `index.html` IS the production site — edit it directly. The README (which mentions `Main.dc.html` and calls it a "mockup") is outdated.
- `support.js` and `vendor/react*.js` are a generated runtime (renders the `<x-dc>` template). Never edit them.
- Page logic lives in `class Component extends DCLogic` inside `<script type="text/x-dc" data-dc-script>` at the end of `index.html`; `renderVals()` returns the values the template interpolates.
- Styling: inline `style="…"` attributes plus the `<helmet><style>` block. Fonts: Cormorant Garamond + Montserrat (Google Fonts).

## Pitfalls
- `SEU-DOMINIO.com.br` placeholders (canonical, og:*, twitter:*, JSON-LD in `<head>`, `robots.txt`, `sitemap.xml`) must be replaced with the real domain before going live: `grep -rl SEU-DOMINIO .`
- Top-level sections are `<header>/<section>/<footer>`; CSS targets them via `.page > :is(div, section, footer):not(.nav)`. Keep that list in sync if you change a section's tag.
- Keep the JSON-LD (`Dentist` + `Person`) NAP identical to the Google Business Profile; never add `aggregateRating`/`review` there (self-serving reviews violate Google's policy).
- Asset files in `assets/` are named by content hash; reference new images as `./assets/<file>`.
- The page does not render over `file://` (scripts blocked) — always serve it over HTTP.

## When compacting
Preserve the list of modified files and the test commands used.
