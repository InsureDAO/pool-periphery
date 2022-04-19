pragma solidity 0.8.13;

import "@insuredao/pool-contracts/contracts/interfaces/IPoolTemplate.sol";
import "@insuredao/pool-contracts/contracts/interfaces/IRegistry.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Referral {

    mapping(address => uint256) public rebates;
    mapping(address => uint256) public lps;

    mapping(address => bool) private pools;

    IRegistry public registry;
    address immutable public usdc;

    uint256 public maxRebateRate;
    uint256 private constant RATE_DENOMINATOR = 1000000;


    constructor(address _registry, address _usdc){
        registry = IRegistry(_registry);
        usdc = _usdc;
    }

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
        require(registry.isListed(_pool), "invalid pool");
        require(_rebateRate <= maxRebateRate, "exceed max rabate rate");

        //get premium + calc rebate
        uint256 _premium = IPoolTemplate(_pool).getPremium(_amount, _span);
        _premium += _premium * _rebateRate / RATE_DENOMINATOR;


        //transfer USDC from msg.sender to here
        IERC20(usdc).transferFrom(msg.sender, address(this), _premium);

        if(!pools[_pool]){
           IERC20(usdc).approve(_pool, type(uint256).max);
        }

        uint256 totalBefore = IERC20(_pool).balanceOf(address(this));

        //insure()
        IPoolTemplate(_pool).insure(
            _amount,
            _maxCost,
            _span,
            _target,
            _for,
            _agent
        );

        //take USDC diff and sub from transferred USDC. this is actual rebate.
        uint256 totalAfter = IERC20(_pool).balanceOf(address(this));
        unchecked {
            uint256 rebate = totalBefore - totalAfter;
        }

        //increment referrer
        rebates[_referrer] += rebate;
    }


    function deposit(address _pool, uint256 _amount)external{
        require(registry.isListed(_pool), "invalid pool");
        require(rebates[msg.sender] >= _amount, "insufficient balance");

        uint256 _mint = IPoolTemplate(_pool).deposit(_amount);

        unchecked{
            rebates[msg.sender] -= _amount;
            lps[msg.sender] += _mint; //can underflow
        }
        
    }

    /**
    * @dev requestWithdraw can be done only once per pool within the entire withdraw period.
    * option1. waiting list
    * option2. 
    *
    */
    function requestWithdraw()external{
        require(registry.isListed(_pool), "invalid pool");

    }

    function withdraw()external{
        require(registry.isListed(_pool), "invalid pool");

    }

    function withdrawRebate()external{
        require(registry.isListed(_pool), "invalid pool");

    }
    
}