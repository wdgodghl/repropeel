const fs = require('node:fs');
try {
  const data = JSON.parse(fs.readFileSync(process.argv[2], 'utf8'));
  if (!Array.isArray(data.items)) process.exit(1);
  const oldTotal = data.items.reduce((sum, item) => sum + Math.round((item.quantity || 0) * (item.unitPrice || 0) * 100), 0);
  const newTotal = Math.round(data.items.reduce((sum, item) => sum + (item.quantity || 0) * (item.unitPrice || 0), 0) * 100);
  process.exit(oldTotal !== newTotal ? 0 : 1);
} catch (error) {
  process.exit(2);
}
