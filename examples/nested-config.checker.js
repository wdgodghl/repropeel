const fs = require('node:fs');
try {
  const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
  if (!Array.isArray(data.pipeline?.stages)) process.exit(1);
  for (const stage of data.pipeline.stages) {
    if (stage?.kind === 'transform' && stage.config?.retry === -1) process.exit(0);
  }
  process.exit(1);
} catch (error) {
  process.exit(2);
}
