var Elm = require('../elm/Main');
var crypto = require('./utils/crypto');
var container = document.getElementById('container');
var app = Elm.Main.embed(container);

app.ports.encrypt.subscribe(function(plaintext) {
  let key = new crypto();
  const modulusBase16 = '9e60bec68ea009bd73f4e8338c232a9431af888bf3c5781e287a9fd0ccc9615e94a0e53391657e17488017c1646c53da9223602308a7edad80100c2e72040878c5381d09f7d9c4e4d7071090daf25ec0440f4c95386f6ab185e01aa3ce09df861cdd89fd61f71d628e05e8857f9d6dfe5d2b9e31f79b8a0961d2117322b98cb4ad8b13d97e937646a509b88fb56e1add0e90bbaf18454d68508e25100dee9e0a6aa623b99aeeabaf88963d3ed32f48bf623d486fe1c675f7d17d40d9614eddac42fd28c9f0c537cb08f56e2e35e276c04548661a455deba7c60ffb2f03286545c501be9c322dc0198ec27df190e794c7f84a4a6ce01023fcd8d5ce13c4648fc5';
  const exponent = '65537';

  key.setPublic(modulusBase16, Number(exponent).toString(16));
  const hardPass = key.encrypt_b64(plaintext);

  app.ports.encrypted.send(hardPass);
})
