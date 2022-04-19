pragma solidity 0.8.13;

import "@insuredao/pool-contracts/contracts/interfaces/IPoolTemplate.sol";
import "@insuredao/pool-contracts/contracts/interfaces/IOwnership.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Referral {

    mapping(address => uint256) public maxRebateRates;

    address public immutable ownership;
    address public immutable usdc;
    uint256 private constant RATE_DENOMINATOR = 1000000;

    modifier onlyOwner() {
        require(
            IOwnership(ownership).owner() == msg.sender,
            "Caller is not allowed to operate"
        );
        _;
    }

    constructor(address _usdc, address _ownership, address _vault, uint256 _defaultMaxRebateRate){
        require(_usdc != address(0), "zero address");
        require(_ownership != address(0), "zero address");
        require(_vault != address(0), "zero address");
        require(_defaultMaxRebateRate != 0, "zero");

        usdc = _usdc;
        ownership = _ownership;
        IERC20(usdc).approve(_vault, type(uint256).max);

        maxRebateRates[address(0)] = _defaultMaxRebateRate;
    }

    /**
    * @notice
    */
    function insure(
        address _pool,
        address _referrer,
        uint256 _rebateRate,

        uint256 _amount,
        uint256 _maxCost,
        uint256 _span,
        bytes32 _target,
        address _for,
        address _agent
    )external{
        require(_rebateRate <= _getMaxRebateRate(_pool), "exceed max rabate rate");

        //transfer premium
        uint256 _premium = IPoolTemplate(_pool).getPremium(_amount, _span);
        _premium += _premium * _rebateRate / RATE_DENOMINATOR;
        IERC20(usdc).transferFrom(msg.sender, address(this), _premium);

        //buy insurance
        IPoolTemplate(_pool).insure(
            _amount,
            _maxCost,
            _span,
            _target,
            _for,
            _agent
        );

        //deposit actual rebate, then transfer LP token to referrer
        uint256 _rebate = IERC20(usdc).balanceOf(address(this));
        uint256 _lp = IPoolTemplate(_pool).deposit(_rebate);
        IERC20(_pool).transfer(_referrer, _lp);
    }

    
    function getMaxRebateRate(address _pool)external{
        return _getMaxRebateRate(_pool);
    }

    function _getMaxRebateRate(address _pool)internal view returns(uint256){
        uint256 _maxRebateRate = maxRebateRates[_pool];

        if (_maxRebateRate == 0) {
            return maxRebateRates[address(0)];
        } else {
            return _maxRebateRate;
        }
    }

    function setMaxRebateRate(address _pool, uint256 _maxRebateRate)external onlyOwner{
        maxRebateRates[_pool] = _maxRebateRate;
    }
}