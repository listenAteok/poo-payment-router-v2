// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./token/ERC20/IERC20.sol";
import "./oracle/chainlink/Aggregator.sol";
import "./math/SafeMath.sol";

contract PaymentRouter {
    using SafeMath for uint256;
    
    address payable recipient;
    address public USD_TOKEN;
    address public POO_TOKEN;
    address public ADMIN;
    mapping(uint => mapping(address => uint256)) priceProvider;
    mapping(uint => mapping(uint => uint256)) shareProvider;
    address public ethOracles;
    uint256 ethDecimals = 18;

    constructor(
        address _usd_token, 
        address _poo_token, 
        address _recipient, 
        address _ethOracle, 
        uint256[] memory funcArray,
        address[] memory paymentTokenArray,
        uint256[] memory priceArray,
        uint[] memory role1_array, 
        uint[] memory role2_array, 
        uint256[] memory rate1_array,
        uint256[] memory rate2_array

    ) {
        ADMIN = msg.sender;

        setRecipient(_recipient);
        setEthOracle(_ethOracle);

        setUSDToken(_usd_token);
        setPOOToken(_poo_token);

        setPrice(funcArray, paymentTokenArray, priceArray);

        setShare(funcArray, role1_array, rate1_array);
        setShare(funcArray, role2_array, rate2_array);
    }

    event Payment(address indexed sender, bytes signature, uint func, uint256 priceValue);

    modifier onlyAdmin() {
        require(msg.sender == ADMIN, "caller is not the admin");
        _;
    }
    
    function doPaymentETH(bytes memory signature, uint func, address payable[] memory shareToAddresses)  public payable  {
        uint256 _price = priceETH(func);
        require(_price > 0, "No price defined");
        require(
            msg.value == _price 
         || msg.value >= (_price.sub(_price.mul(5).div(100)))
         || msg.value <= (_price.add(_price.mul(5).div(100)))
        , "Incorrect amount");

        if (shareToAddresses.length == 0) {
            require(shareProvider[func][1] == 0, "MUST_SHARE");
        }

        uint256 totalShareAmount = 0;
        if (shareToAddresses.length > 0) {

            for (uint256 index = 0; index < shareToAddresses.length; index++) {
                
                uint256 shareAmount = calculateShareAmount(func, _price, (index + 1));

                if (shareAmount != 0) {
                    address payable _shareToAddress = shareToAddresses[index];

                    _shareToAddress.transfer(shareAmount);

                    totalShareAmount = totalShareAmount.add(shareAmount);
                }
            }

            _price = _price.sub(totalShareAmount);
        }

        recipient.transfer(_price);

        emit Payment(msg.sender, signature, func, _price + totalShareAmount);
    }

    function doPayment(bytes memory signature, uint func, address paymentToken, address payable[] memory shareToAddresses) public virtual {
        uint256 _price = price(func, paymentToken);
        require(_price > 0, "No price defined");
        
        IERC20 payment = IERC20(paymentToken);
        uint256 allowanceValue = payment.allowance(msg.sender, address(this));
        require(allowanceValue >= _price, "INSUFFICIENT_ALLOWANCE");

        if (shareToAddresses.length == 0) {
            require(shareProvider[func][1] == 0, "MUST_SHARE");
        }
        uint256 totalShareAmount = 0;

        if (shareToAddresses.length > 0) {

            for (uint256 index = 0; index < shareToAddresses.length; index++) {
                
                uint256 shareAmount = calculateShareAmount(func, _price, (index + 1));

                if (shareAmount != 0) {
                    address payable _shareToAddress = shareToAddresses[index];

                    payment.transferFrom(msg.sender, _shareToAddress, shareAmount);

                    totalShareAmount = totalShareAmount.add(shareAmount);
                }
            }

            _price = _price.sub(totalShareAmount);

        }

        require(_price > 0, "Insufficient balance to pay after sharing");

        bool success = payment.transferFrom(msg.sender, recipient, _price);
        require(success, "TRANSFER_FROM_FAILED");

        emit Payment(msg.sender, signature, func, _price + totalShareAmount);
    }

    function calculateShareAmount(uint func, uint256 amount, uint role) public view returns(uint256) {
        uint256 shareRate = shareProvider[func][role];
        if (shareRate != 0) {
            return amount.mul(shareRate).div(100);
        }
        return 0;
    }

    function price(uint func, address paymentToken) public view returns(uint256) {
        return priceProvider[func][paymentToken];
    }

    function share(uint func, uint role) public view returns(uint256) {
        return shareProvider[func][role];
    }

    function viewethUSDPrice() public view returns(uint256) {
        return uint256(AggregatorV2V3Interface(ethOracles).latestAnswer());
    }

    function priceETH(uint func) public view returns(uint256) {
        uint256 ethUSDPrice = calculateETHUSDPrice(func);
        uint256 funcUSDPrice = price(func, USD_TOKEN);
        uint256 tokenDecimals = IERC20(USD_TOKEN).decimals();
        if (ethDecimals > tokenDecimals) {
            funcUSDPrice = funcUSDPrice.mul(10 ** (ethDecimals - tokenDecimals));
        }
        require(funcUSDPrice > 0, "No funcUSDPrice defined");
        require(ethUSDPrice > 0, "No ethUSDPrice defined");
        return funcUSDPrice.mul(10 ** 6).div(ethUSDPrice);
    }

    function calculateETHUSDPrice(uint func) public view returns(uint256) {
      uint256 ethUSDPrice = viewethUSDPrice();
      uint256 oracleDecimal = AggregatorV2V3Interface(ethOracles).decimals();
      if (ethDecimals > oracleDecimal) {
        ethUSDPrice = ethUSDPrice.mul(10 ** (ethDecimals - oracleDecimal));
      }
      return ethUSDPrice;
    }

    function setPrice(uint256[] memory func_array, address[] memory _payment_token_array, uint256[] memory _price_array) public onlyAdmin virtual {
        require(func_array.length == _payment_token_array.length && func_array.length == _price_array.length, 'wrong array length');
        for (uint256 index = 0; index < func_array.length; index++) {

            uint256 _decimals = IERC20(_payment_token_array[index]).decimals();

            priceProvider[func_array[index]][_payment_token_array[index]] = _price_array[index] * (10 ** _decimals);
        }
    }

    function setShare(uint256[] memory _func_array, uint[] memory _role_array, uint256[] memory _rate_array) public onlyAdmin virtual {
        require(_func_array.length == _role_array.length && _func_array.length == _rate_array.length, 'wrong array length');

        for (uint256 index = 0; index < _func_array.length; index++) {

            shareProvider[_func_array[index]][_role_array[index]] = _rate_array[index];

        }
    }

    function setUSDToken(address _token) public onlyAdmin virtual {
        USD_TOKEN = _token;
    }

    function setPOOToken(address _poo_token) public onlyAdmin virtual {
        POO_TOKEN = _poo_token;
    }

    function setAdmin(address _admin) public onlyAdmin virtual {
        ADMIN = _admin;
    }

    function setRecipient(address _recipient) public onlyAdmin virtual {
        recipient = payable(_recipient);
    }

    function setEthOracle(address _ethOracle) public onlyAdmin virtual {
        ethOracles = _ethOracle;
    }

}