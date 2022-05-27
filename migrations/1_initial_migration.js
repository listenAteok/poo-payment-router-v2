const PaymentRouter = artifacts.require("PaymentRouter");

module.exports = function (deployer, network) {
  var _token = null;
  var _recipient = null;
  var _oracle = null;
  if (network == 'eth') {
    _token = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
    _recipient = '0x8c143a43AB69D6deB939328Fbc7fe67751052a3D';
    _oracle = '	0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
  } else if (network == 'bnb') {
    _token = '0xe9e7cea3dedca5984780bafc599bd69add087d56';
    _recipient = '0xA31e17c2bf978794b861A06bcD71c88748d32D02';
    _oracle = '0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE';
  }  else if (network == 'avax') {
    _token = '0xc7198437980c041c805a1edcba50c1ce5db95118';
    _recipient = '0x8c143a43AB69D6deB939328Fbc7fe67751052a3D';
    _oracle = '0x0A77230d17318075983913bC2145DB16C7366156';
  }  else if (network == 'harmony') {
    _token = '0x985458E523dB3d53125813eD68c274899e9DfAb4';
    _recipient = '0x68ec74dc5c971041d4b530a228e79e2562ca794c';
    _oracle = '0xdCD81FbbD6c4572A69a534D8b8152c562dA8AbEF';
  }
  deployer.deploy(PaymentRouter, _token, _recipient, _oracle);
};
