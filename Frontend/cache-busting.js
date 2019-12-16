#!/usr/bin/env node

const fs = require('fs');
const path = require('path');
const cheerio = require('cheerio');
const revHash = require('rev-hash');

const hashFile = file => {
  const fileName = file.replace(/\.[^/.]+$/, "");
  const fileExtReg = /(?:\.([^.]+))?$/;
  const fileExtension = fileExtReg.exec(file)[1];

  const filePath = path.join(buildDir, file);
  const fileHash = revHash(fs.readFileSync(filePath));
  const fileNewName = `${fileName}.${fileHash}.${fileExtension}`;
  const fileNewPath = path.join(buildDir, fileNewName);
  const fileNewRelativePath = path.join('build', fileNewName);

  fs.renameSync(filePath, fileNewPath);

  return fileNewRelativePath;
};

const rootDir = path.resolve(__dirname, './');
const wwwRootDir = path.resolve(rootDir, 'www');
const buildDir = path.join(wwwRootDir, 'build');
const indexPath = path.join(wwwRootDir, 'index.html');
$ = cheerio.load(fs.readFileSync(indexPath, 'utf-8'));

$('head link[href="build/main.css"]').attr('href', hashFile('main.css'));
$('body script[src="build/main.js"]').attr('src', hashFile('main.js'));
$('body script[src="build/polyfills.js"]').attr('src', hashFile('polyfills.js'));
$('body script[src="build/vendor.js"]').attr('src', hashFile('vendor.js'));

fs.writeFileSync(indexPath, $.html());
