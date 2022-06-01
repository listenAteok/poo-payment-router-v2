const PaymentRouter = artifacts.require("PaymentRouter");

module.exports = function (deployer, network) {
  var _usd_token = null;
  var _poo_token = null;
  var _recipient = null;
  var _oracle = null;
  var funcArray = [];
  var paymentTokenArray = [];
  var priceArray = [];
  var role1_array = [];
  var role2_array = [];
  var rate1_array = [];
  var rate2_array = [];
  if (network == 'eth') {
    _usd_token = '0xdAC17F958D2ee523a2206206994597C13D831ec7';
    _poo_token = '0x0000000000000000000000000000000000000000';
    _recipient = '0x8c143a43AB69D6deB939328Fbc7fe67751052a3D';
    _oracle = '	0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419';
    funcArray = [1, 2, 3, 4, 5, 6];
    paymentTokenArray = [_usd_token, _usd_token, _usd_token, _usd_token, _usd_token, _usd_token];
    priceArray = [30000, 10000, 5000, 1000, 500, 100];
    role1_array = [1, 1, 1, 1, 1, 1];
    role2_array = [2, 2, 2, 2, 2, 2];
    rate1_array = [20, 20, 20, 20, 20, 20];
    rate2_array = [10, 10, 10, 10, 10, 10];
  } else if (network == 'bnb') {
    _usd_token = '0xe9e7cea3dedca5984780bafc599bd69add087d56';
    _poo_token = '0x396552fB1ae4d3E4A658F367d7f85D7bf8faC323';
    _recipient = '0x7d58Ca749AFC18dcA661eEE5Cce52Cb348E8e7DF';
    _oracle = '0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE';
    funcArray = [1, 2, 3, 1001, 1002, 1003, 1004, 1005, 1006];
    paymentTokenArray = [_usd_token, _usd_token, _usd_token, _poo_token, _poo_token, _poo_token, _poo_token, _poo_token, _poo_token];
    priceArray = [30000, 10000, 5000, 10000000000, 1000000000, 50000000, 10000000, 5000000, 1000000];
    role1_array = [1, 1, 1, 1, 1, 1, 1, 1, 1];
    role2_array = [2, 2, 2, 2, 2, 2, 2, 2, 2];
    rate1_array = [20, 20, 20, 20, 20, 20, 20, 20, 20];
    rate2_array = [10, 10, 10, 10, 10, 10, 10, 10, 10];
  } else if (network == 'avax') {
    _usd_token = '0xc7198437980c041c805a1edcba50c1ce5db95118';
    _poo_token = '0x0000000000000000000000000000000000000000';
    _recipient = '0x8c143a43AB69D6deB939328Fbc7fe67751052a3D';
    _oracle = '0x0A77230d17318075983913bC2145DB16C7366156';
    funcArray = [1, 2, 3, 4, 5, 6];
    paymentTokenArray = [_usd_token, _usd_token, _usd_token, _usd_token, _usd_token, _usd_token];
    priceArray = [30000, 10000, 5000, 1000, 500, 100];
    role1_array = [1, 1, 1, 1, 1, 1];
    role2_array = [2, 2, 2, 2, 2, 2];
    rate1_array = [20, 20, 20, 20, 20, 20];
    rate2_array = [10, 10, 10, 10, 10, 10];
  }  else if (network == 'harmony') {
    _usd_token = '0x985458E523dB3d53125813eD68c274899e9DfAb4';
    _poo_token = '0x0000000000000000000000000000000000000000';
    _recipient = '0x68ec74dc5c971041d4b530a228e79e2562ca794c';
    _oracle = '0xdCD81FbbD6c4572A69a534D8b8152c562dA8AbEF';
    funcArray = [1, 2, 3, 4, 5, 6];
    paymentTokenArray = [_usd_token, _usd_token, _usd_token, _usd_token, _usd_token, _usd_token];
    priceArray = [30000, 10000, 5000, 1000, 500, 100];
    role1_array = [1, 1, 1, 1, 1, 1];
    role2_array = [2, 2, 2, 2, 2, 2];
    rate1_array = [20, 20, 20, 20, 20, 20];
    rate2_array = [10, 10, 10, 10, 10, 10];
  } 
  deployer.deploy(PaymentRouter, 
    _usd_token, _poo_token, _recipient, _oracle, 
    funcArray, paymentTokenArray, priceArray, role1_array, role2_array, rate1_array, rate2_array
  );
};
