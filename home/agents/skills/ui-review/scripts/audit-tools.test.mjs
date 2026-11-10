import { test } from 'node:test';
import assert from 'node:assert/strict';
import { auditCalls } from './audit-tools.mjs';
const input = '/tmp/sealed';
const exec = text => ({ name: 'exec', text });
const direct = (path, detail = 'original') => ({ name: 'view_image', text: JSON.stringify({ path, detail }) });
test('accepts image-only wrappers with loops, parallel views, and path prefixes', () => {
  for (const text of [
    'const p="/tmp/sealed/"; const a=await tools.view_image({path:p+"1.png",detail:"original"}); image(a.image_url);',
    'const ps=["/tmp/sealed/1.png","/tmp/sealed/2.png"]; for(const p of ps){const r=await tools.view_image({path:p,detail:"original"});image(r.image_url,"original");}',
    'const ps=["/tmp/sealed/1.png"];const rs=await Promise.all(ps.map(path=>tools.view_image({path,detail:"original"})));rs.forEach((r,i)=>{text(`Capture ${i+1}`);image(r.image_url);});',
    'const ps=["/tmp/sealed/1.png"];for(let i=0;i<ps.length;i++){const r=await tools.view_image({path:ps[i],detail:"original"});image(r.image_url);}',
  ]) assert.equal(auditCalls([exec(text)], input).violations.length, 0, text);
});
test('rejects non-image operations regardless of allowed path strings', () => {
  for (const call of [
    exec('text("/tmp/sealed/1.png"); await tools.exec_command({cmd:""});'),
    exec('const t=ALL_TOOLS.filter(x=>/view_image/.test(x.name));text(t);'),
    { name:'js', text:'{"code":"await cua.getState()","path":"/tmp/sealed/1.png"}' },
    { name:'Bash', text:'{"command":"cat /tmp/sealed/1.png"}' },
    exec('await tools["view_image"]({path:"/tmp/sealed/1.png",detail:"original"});'),
  ]) assert.ok(auditCalls([call], input).violations.length > 0);
});
test('rejects escaped paths, nonimages, reduced detail, and repeated views when required', () => {
  for (const call of [direct('/tmp/sealed/../answer.png'), direct('/tmp/sealedness/1.png'), direct('/tmp/sealed/answer.md'), direct('/tmp/sealed/1.png','high')])
    assert.ok(auditCalls([call], input).violations.length > 0);
  assert.ok(auditCalls([direct('/tmp/sealed/1.png'),direct('/tmp/sealed/1.png')],input,{once:true}).violations.length > 0);
  assert.equal(auditCalls([{name:'Read',text:'{"file_path":"/tmp/sealed/1.png"}'}],input).violations.length,0);
});
