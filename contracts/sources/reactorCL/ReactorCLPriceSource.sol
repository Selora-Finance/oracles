pragma solidity ^0.8.0;

import '../../PriceSource.sol';
import './interfaces/ICLFactory.sol';
import './interfaces/ICLPoolConstants.sol';
import '@openzeppelin/contracts/token/ERC20/ERC20.sol';

contract ReactorCLPriceSource is PriceSource {
    ICLFactory public immutable factory;

    constructor(
        ICLFactory _factory,
        address _usdt,
        address _usdc,
        address _weth
    ) PriceSource('Reactor Finance CL', _usdt, _usdc, _weth) {
        factory = _factory;
    }

    function _deriveAmountOut(
        address token0,
        address token1,
        uint256 _amountIn
    ) internal view returns (uint256 amountOut) {
        if (_amountIn == 0) return 0;
        if (token0 == token1) return _amountIn;

        int24[] memory tickSpacings = factory.tickSpacings();
        uint256 token1Price;
        uint256 divisor = 1;

        // Iterate through all tick spacings
        for (uint i = 0; i < tickSpacings.length; i++) {
            address pair = factory.getPool(token0, token1, tickSpacings[i]);
            if (pair != address(0)) {
                address _token0 = ICLPoolConstants(pair).token0();
                address _token1 = ICLPoolConstants(pair).token1();
                // Balances
                uint256 _balance0 = ERC20(_token0).balanceOf(pair);
                uint256 _balance1 = ERC20(_token1).balanceOf(pair);
                if (_balance0 == 0 || _balance1 == 0) continue; // We don't need 0 balances
                if (i > 0) divisor += 1;
                // Find ratio
                if (_token0 == token0) {
                    uint8 decimals = ERC20(_token0).decimals();
                    token1Price += (_balance1 * 10 ** decimals) / _balance0;
                } else {
                    uint8 decimals = ERC20(_token1).decimals();
                    token1Price += (_balance0 * 10 ** decimals) / _balance1;
                }
            }
        }

        uint256 averagePrice = (token1Price * 10000) / divisor; // Handle in a way that captures floating points
        uint8 token0Decimals = ERC20(token0).decimals();
        amountOut = (averagePrice * _amountIn) / (10 ** (token0Decimals + 4));
    }

    function _getUnitValueInETH(address token) internal view override returns (uint256 amountOut) {
        uint8 _decimals = ERC20(token).decimals();
        uint256 _amountIn = 1 * 10 ** _decimals;
        amountOut = _deriveAmountOut(token, weth, _amountIn);
    }

    function _getUnitValueInUSDC(address token) internal view override returns (uint256) {
        uint256 _valueInETH = _getUnitValueInETH(token);
        uint256 _ethUSDCAmountOut = _deriveAmountOut(weth, usdc, _valueInETH);

        if (_ethUSDCAmountOut > 0) {
            return _ethUSDCAmountOut;
        } else {
            uint8 _tokenDecimals = ERC20(token).decimals();
            uint256 _amountIn = 1 * 10 ** _tokenDecimals;
            uint256 amountOut = _deriveAmountOut(token, usdc, _amountIn);
            return amountOut;
        }
    }

    function _getUnitValueInUSDT(address token) internal view override returns (uint256) {
        uint256 _valueInETH = _getUnitValueInETH(token);
        uint256 _ethUSDTAmountOut = _deriveAmountOut(weth, usdt, _valueInETH);

        if (_ethUSDTAmountOut > 0) {
            return _ethUSDTAmountOut;
        } else {
            uint8 _tokenDecimals = ERC20(token).decimals();
            uint256 _amountIn = 1 * 10 ** _tokenDecimals;
            uint256 amountOut = _deriveAmountOut(token, usdt, _amountIn);
            return amountOut;
        }
    }
}
