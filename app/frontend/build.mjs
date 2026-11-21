import esbuild from 'esbuild';
import fs from 'node:fs';
import { solidPlugin } from 'esbuild-plugin-solid';


// Silver 0.5 does not repaint a text node that is changed in place (`textNode.data = …`), but it does repaint
// when a node is replaced (`parent.textContent = …` / a new text node). Solid's `insert()` has two in-place
// text updates — patch both so every reactive text change shows up on screen. Fails loudly if Solid changes.
const silverTextFix = {
  name: 'silver-text-fix',
  setup(b) {
    b.onLoad({ filter: /solid-js[\\/]web[\\/]dist[\\/](web|dev)\.js$/ }, async args => {
      let s = await fs.promises.readFile(args.path, 'utf8');
      const a = 'current = parent.firstChild.data = value;';
      const re = /if \(node && node\.nodeType === 3\) \{\s*node\.data !== value && \(node\.data = value\);\s*\} else node = document\.createTextNode\(value\);/;
      if (!s.includes(a) || !re.test(s)) throw new Error('silver-text-fix: Solid insertExpression changed — update the patch in build.mjs');
      s = s.replace(a, 'current = parent.textContent = value;').replace(re, 'node = document.createTextNode(value);');
      return { contents: s, loader: 'js' };
    });
  },
};

const watch = process.argv.includes('--watch');

const ctx = await esbuild.context({
  entryPoints: ['src/index.tsx'],
  bundle: true,
  format: 'iife',
  target: 'es2020',
  // Solid's JSX is compiled to real DOM operations by babel-preset-solid.
  plugins: [silverTextFix, solidPlugin()],
  define: { 'process.env.NODE_ENV': watch ? '"development"' : '"production"' },
  minify: !watch,
  sourcemap: watch ? 'inline' : false,
  outfile: 'dist/app.js',
  logLevel: 'info',
});

if (watch) {
  await ctx.watch();
  console.log('watching for changes…');
} else {
  await ctx.rebuild();
  await ctx.dispose();
}
