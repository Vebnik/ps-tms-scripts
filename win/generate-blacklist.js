const fs = require("node:fs");

(async () => {
  const csvFile = "terminals.csv";
  const txTfile = "terminals.txt";

  const header = "sn;";
  const content = new Array(200)
    .fill(0)
    .map(() => `${(Math.random() * 10e10).toFixed()};`);

  const data = [header, ...content].join("\n");

  fs.writeFile(csvFile, data, (err) => {
    if (err) {
      console.error(err);
    } else {
      console.log("Done -> CSV");
    }
  });

  const txtData = content.map(el => el.replace(";", "")).join("\n")

  fs.writeFile(txTfile, txtData, (err) => {
    if (err) {
      console.error(err);
    } else {
      console.log("Done -> TXT");
    }
  });
})();
