const fs = require('fs');
const dir = process.argv[2] || '.';
const html = fs.readFileSync(dir + '/index.html', 'utf8');
const css = fs.readFileSync(dir + '/styles.css', 'utf8');
const js = fs.readFileSync(dir + '/app.js', 'utf8');
if (/<\/script/i.test(js)) { console.error('app.js contains a closing script tag — cannot inline safely'); process.exit(1); }
let out = html.replace(/<link rel="stylesheet" href="styles\.css">/, '<style>\n' + css + '\n</style>');
out = out.replace(/<script src="app\.js" defer><\/script>/, '<script>\n' + js + '\n</script>');
if (out.includes('styles.css') || out.includes('src="app.js"')) { console.error('injection failed'); process.exit(1); }
fs.writeFileSync(dir + '/arch-hub-standalone.html', out);
console.log('standalone bytes', out.length);
