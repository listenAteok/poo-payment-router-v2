// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./token/ERC20/IERC20.sol";
import "./oracle/chainlink/Aggregator.sol";
import "./math/SafeMath.sol";

contract PaymentRouter {
    using SafeMath for uint256;
    
    address payable recipient;
    address public TOKEN;
    address public ADMIN;
    mapping(address => mapping(uint => uint256)) priceProvider;
    address public ethOracles;
    uint256 ethDecimals = 18;

    constructor(address _token, address _recipient, address _ethOracle) {
        ADMIN = msg.sender;

        setToken(_token);
        setRecipient(_recipient);
        setEthOracle(_ethOracle);

        uint256 _decimals = IERC20(_token).decimals();
        setPrice(1, 30000 * (10 ** _decimals));
        setPrice(2, 10000 * (10 ** _decimals));
        setPrice(3, 5000 * (10 ** _decimals));

    }

    event Payment(address indexed sender, bytes signature, uint func);

    modifier onlyAdmin() {
        require(msg.sender == ADMIN, "caller is not the admin");
        _;
    }
    
    function doPaymentETH(bytes memory signature, uint func)  public payable  {
        uint256 _price = priceETH(func);
        require(_price > 0, "No price defined");
        require(
            msg.value == _price 
         || msg.value >= (_price.sub(_price.mul(5).div(100)))
         || msg.value <= (_price.add(_price.mul(5).div(100)))
        , "Incorrect amount");
        recipient.transfer(msg.value);
        emit Payment(msg.sender, signature, func);
    }

    function doPayment(bytes memory signature, uint func) public virtual {
        uint256 _price = price(func);
        require(_price > 0, "No price defined");
        uint256 allowanceValue = IERC20(TOKEN).allowance(msg.sender, address(this));
        require(allowanceValue >= _price, "INSUFFICIENT_ALLOWANCE");
        bool success = IERC20(TOKEN).transferFrom(msg.sender, recipient, _price);
        require(success, "TRANSFER_FROM_FAILED");
        emit Payment(msg.sender, signature, func);
    }

    function price(uint func) public view returns(uint256) {
        return priceProvider[TOKEN][func];
    }

    function viewethUSDPrice() public view returns(uint256) {
        return uint256(AggregatorV2V3Interface(ethOracles).latestAnswer());
    }

    function priceETH(uint func) public view returns(uint256) {
        uint256 ethUSDPrice = uint256(AggregatorV2V3Interface(ethOracles).latestAnswer());
        uint256 funcUSDPrice = price(func);
        require(funcUSDPrice > 0 && ethUSDPrice > 0, "No price defined");
        uint256 oracleDecimal = AggregatorV2V3Interface(ethOracles).decimals();
        uint256 tokenDecimals = IERC20(TOKEN).decimals();
        if (ethDecimals > oracleDecimal) {
            ethUSDPrice = ethUSDPrice.mul(10 ** (ethDecimals - oracleDecimal)).div(10 ** ethDecimals);
        }
        if (ethDecimals > tokenDecimals) {
            funcUSDPrice = funcUSDPrice.mul(10 ** (ethDecimals - tokenDecimals));
        }
        return funcUSDPrice / ethUSDPrice;
    }
    
    function setPrice(uint func, uint256 _price) public onlyAdmin virtual {
        priceProvider[TOKEN][func] = _price;
    }

    function setToken(address _token) public onlyAdmin virtual {
        TOKEN = _token;
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