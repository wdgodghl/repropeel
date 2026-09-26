const fs = require('node:fs');
const file = process.argv[2];
try {
  const data = JSON.parse(fs.readFileSync(file, 'utf8'));
  if (!Array.isArray(data.records)) process.exit(1);
  const seen = new Set();
  for (const row of data.records) {
    if (typeof row?.id !== 'string') continue;
    if (seen.has(row.id)) process.exit(0);
    seen.add(row.id);
  }
  process.exit(1);
} catch (error) {
  process.exit(2);
}
