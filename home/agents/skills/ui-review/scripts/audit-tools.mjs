// Inspect image-viewing wrappers without executing the logged JavaScript.
// Unknown syntax or operations fail closed; this is an audit, not a sandbox.
import { parse } from 'acorn';
import { resolve, relative, isAbsolute, extname } from 'node:path';

export function auditCalls(calls, input, { once = false } = {}) {
  const viewed = [], violations = [];
  function view(args, claude = false) {
    const path = args?.path ?? args?.file_path;
    if (typeof path !== 'string' || !isAbsolute(path)) throw Error('image path is not absolute');
    const rel = relative(resolve(input), resolve(path));
    if (!rel || rel === '..' || rel.startsWith('../') || isAbsolute(rel) || !/\.(png|jpe?g|webp)$/i.test(extname(path)))
      throw Error('image path is outside the input folder or is not an image');
    if (!claude && args.detail !== 'original') throw Error('view_image detail is not original');
    if (claude && Object.keys(args).some(k => !['file_path'].includes(k))) throw Error('non-image Read options');
    viewed.push(resolve(path));
    return { image_url: 'audited-image' };
  }
  for (const call of calls) {
    try {
      if (['view_image', 'functions.view_image'].includes(call.name)) view(JSON.parse(call.text));
      else if (call.name === 'Read') view(JSON.parse(call.text), true);
      else if (['exec', 'functions.exec'].includes(call.name)) inspectWrapper(call.text, view);
      else throw Error(`tool ${call.name} is not an image viewer`);
    } catch (error) { violations.push({ ...call, reason: error.message }); }
  }
  if (!viewed.length) violations.push({ name: 'coverage', text: '', reason: 'no verified image views' });
  if (once && new Set(viewed).size !== viewed.length)
    violations.push({ name: 'coverage', text: '', reason: 'an image was viewed more than once' });
  return { viewed, violations };
}

function inspectWrapper(source, view) {
  const ast = parse(source, { ecmaVersion: 'latest', sourceType: 'module', allowAwaitOutsideFunction: true });
  const root = new Map();
  let steps = 0, count = 0;
  const fail = n => { throw Error(`unapproved wrapper operation: ${n.type}`); };
  const get = (scope, name) => { if (!scope.has(name)) throw Error(`unapproved wrapper name: ${name}`); return scope.get(name); };
  const run = (n, scope = root) => {
    if (++steps > 10000) throw Error('wrapper audit step limit');
    switch (n.type) {
      case 'Program': case 'BlockStatement': for (const s of n.body) run(s, scope); return;
      case 'EmptyStatement': return;
      case 'ExpressionStatement': return run(n.expression, scope);
      case 'VariableDeclaration': for (const d of n.declarations) { if (d.id.type !== 'Identifier') return fail(d); scope.set(d.id.name, run(d.init, scope)); } return;
      case 'Literal': if (n.regex || n.bigint) return fail(n); return n.value;
      case 'Identifier': return get(scope, n.name);
      case 'ArrayExpression': return n.elements.map(x => run(x, scope));
      case 'ObjectExpression': return Object.fromEntries(n.properties.map(p => {
        if (p.type !== 'Property' || p.computed || p.method || p.kind !== 'init') return fail(p);
        const key = p.key.name ?? p.key.value;
        if (!['path', 'detail'].includes(key)) return fail(p);
        return [key, run(p.value, scope)];
      }));
      case 'AwaitExpression': return run(n.argument, scope);
      case 'ArrowFunctionExpression': return { callback: n, scope: new Map(scope) };
      case 'TemplateLiteral': return n.quasis.map((q, i) => q.value.cooked + (n.expressions[i] ? run(n.expressions[i], scope) : '')).join('');
      case 'MemberExpression': {
        const obj = run(n.object, scope), key = n.computed ? run(n.property, scope) : n.property.name;
        if (Array.isArray(obj) && (key === 'length' || (Number.isInteger(key) && key >= 0))) return obj[key];
        if (obj?.image_url === 'audited-image' && key === 'image_url') return obj.image_url;
        return fail(n);
      }
      case 'BinaryExpression': {
        const a = run(n.left, scope), b = run(n.right, scope);
        if (n.operator === '+' && ['string', 'number'].includes(typeof a) && ['string', 'number'].includes(typeof b)) return a + b;
        if (typeof a !== 'number' || typeof b !== 'number') return fail(n);
        switch (n.operator) { case '<': return a < b; case '<=': return a <= b; case '-': return a - b; default: return fail(n); }
      }
      case 'UpdateExpression': {
        if (n.operator !== '++' || n.argument.type !== 'Identifier') return fail(n);
        const a = get(scope, n.argument.name); if (typeof a !== 'number') return fail(n);
        scope.set(n.argument.name, a + 1); return n.prefix ? a + 1 : a;
      }
      case 'ForOfStatement': {
        if (n.left.type !== 'VariableDeclaration' || n.left.declarations.length !== 1 || n.left.declarations[0].id.type !== 'Identifier') return fail(n);
        const items = run(n.right, scope); if (!Array.isArray(items) || items.length > 100) return fail(n);
        for (const item of items) { const child = new Map(scope); child.set(n.left.declarations[0].id.name, item); run(n.body, child); } return;
      }
      case 'ForStatement': {
        const child = new Map(scope); run(n.init, child);
        let i = 0; while (run(n.test, child)) { if (++i > 100) return fail(n); run(n.body, child); run(n.update, child); } return;
      }
      case 'CallExpression': {
        const c = n.callee;
        if (c.type === 'Identifier' && ['image', 'text'].includes(c.name)) { for (const a of n.arguments) run(a, scope); return; }
        if (c.type !== 'MemberExpression' || c.computed) return fail(n);
        if (c.object.type === 'Identifier' && c.object.name === 'tools' && c.property.name === 'view_image') {
          if (n.arguments.length !== 1) return fail(n);
          count++; return view(run(n.arguments[0], scope));
        }
        if (c.object.type === 'Identifier' && c.object.name === 'Promise' && c.property.name === 'all' && n.arguments.length === 1) return run(n.arguments[0], scope);
        if (!['map', 'forEach'].includes(c.property.name) || n.arguments.length !== 1) return fail(n);
        const items = run(c.object, scope), fn = run(n.arguments[0], scope);
        if (!Array.isArray(items) || items.length > 100 || !fn?.callback) return fail(n);
        return items.map((item, i) => {
          const child = new Map(fn.scope);
          fn.callback.params.forEach((p, j) => { if (p.type !== 'Identifier' || j > 1) return fail(p); child.set(p.name, j === 0 ? item : i); });
          return run(fn.callback.body, child);
        });
      }
      default: return fail(n);
    }
  };
  run(ast);
  if (!count) throw Error('wrapper has no image-viewing calls');
}
