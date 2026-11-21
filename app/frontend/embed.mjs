import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const SILVER_VERSION = '0.5.0';
const here = path.dirname(fileURLToPath(import.meta.url));
const dir = here;                                   // frontend/
const out = path.resolve(here, '../src/assets_gen.h#');
const dirLabel = 'frontend';

const SPA_EXCLUDE_NAMES = new Set(['package.json', 'package-lock.json', 'build.mjs', 'pnpm-lock.yaml', 'yarn.lock']);
const isExcludedName = n =>
  n === '.DS_Store' || n === '.silverignore' || n.endsWith('.map') ||
  SPA_EXCLUDE_NAMES.has(n) || /^tsconfig.*\.json$/.test(n) || /^vite\.config\./.test(n) || /^svelte\.config\./.test(n);

const ignore = fs.existsSync(path.join(dir, '.silverignore'))
  ? fs.readFileSync(path.join(dir, '.silverignore'), 'utf8').split('\n').map(l => l.trim()).filter(l => l && !l.startsWith('#'))
  : [];

const files = [];
const walk = (abs, rel) => {
  for (const ent of fs.readdirSync(abs, { withFileTypes: true })) {
    const r = rel ? `${rel}/${ent.name}` : ent.name;
    if (ent.isDirectory()) {
      if (ent.name === 'node_modules' || ent.name === '.git') continue;
      if (r === 'src') continue;                    // sources are bundled into dist/app.js
      if (ignore.some(i => r === i || r.startsWith(i + '/'))) continue;
      walk(path.join(abs, ent.name), r);
    } else if (ent.isFile()) {
      if (isExcludedName(ent.name)) continue;
      if (ignore.some(i => r === i || r.startsWith(i + '/'))) continue;
      files.push(r);
    }
  }
};
walk(dir, '');
files.sort((a, b) => (Buffer.from('./' + a) < Buffer.from('./' + b) ? -1 : 1)); // LC_ALL=C order

let body = '';
for (const rel of files) {
  const b64 = fs.readFileSync(path.join(dir, rel)).toString('base64');
  body += `    app::register_asset("${dirLabel}/${rel}", "${b64}")\n`;
}

const header =
  `;; GENEROWANY przez \`silver embed\` (silver ${SILVER_VERSION}) — nie edytuj ręcznie.\n` +
  `;; Źródło: ${dirLabel}/ (${files.length} plików). Wołaj assets_gen::install() na początku main().\n` +
  `use "bit -> silver" from "silver"\n\n`;
const text = header + `pub fn install() -> int is\n${body}    return app::embedded_count()\nend\n`;

if (fs.existsSync(out) && fs.readFileSync(out, 'utf8') === text) {
  console.log(`[embed] no changes (${files.length} files)`);
} else {
  fs.writeFileSync(out, text);
  console.log(`[embed] ${files.length} files from ${dirLabel}/ → src/assets_gen.h# (${Math.round(text.length / 1024)} KiB)`);
}
