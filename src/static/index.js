var Elm = require('../elm/Main');
var crypto = require('./utils/crypto');
var container = document.getElementById('container');
var app = Elm.Main.embed(container);

app.ports.encrypt.subscribe(function(package) {
  const [publicKey, plaintext] = package;
  const { modulusBase16, exponent } = JSON.parse(publicKey);
  let key = new crypto();

  key.setPublic(modulusBase16, Number(exponent).toString(16));
  const hardPass = key.encrypt_b64(plaintext);

  app.ports.encrypted.send(hardPass);
})
