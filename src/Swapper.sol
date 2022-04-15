// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC20Mintable {
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address to, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(
        address from,
        address to,
        uint256 amount
   ) external returns (bool);
   function mint(address receiver, uint256 amount) external;
}

interface IUniswapV2Factory {
    event PairCreated(address indexed token0, address indexed token1, address pair, uint);
    function feeTo() external view returns (address);
    function feeToSetter() external view returns (address);
    function getPair(address tokenA, address tokenB) external view returns (address pair);
    function allPairs(uint) external view returns (address pair);
    function allPairsLength() external view returns (uint);
    function createPair(address tokenA, address tokenB) external returns (address pair);
    function setFeeTo(address) external;
    function setFeeToSetter(address) external;
}

interface IUniswapV2Router {
    function addLiquidity(
        address tokenA,
        address tokenB,
        uint amountADesired,
        uint amountBDesired,
        uint amountAMin,
        uint amountBMin,
        address to,
        uint deadline
    ) external;
    function swapExactTokensForTokens(
        uint amountIn,
        uint amountOutMin,
        address[] calldata path,
        address to,
        uint deadline
    ) external;
}

contract Swapper {

    IUniswapV2Factory _uniV2Factory;
    IUniswapV2Router _uniV2Router;
    IERC20Mintable _tokenA;
    IERC20Mintable _tokenB;
    address _pair;

    function init(
        address uniV2Factory,
        address uniV2Router,
        address tokenA,
        address tokenB,
        uint256 amountTokenA,
        uint256 amountTokenB,
        uint256 liquidityAmountTokenA,
        uint256 liquidityAmountTokenB
    ) external {
        _uniV2Factory = IUniswapV2Factory(uniV2Factory);
        _uniV2Router = IUniswapV2Router(uniV2Router);
        _tokenA = IERC20Mintable(tokenA);
        _tokenB = IERC20Mintable(tokenB);
        _tokenA.mint(address(this), amountTokenA);
        _tokenB.mint(address(this), amountTokenB);
        _tokenA.approve(address(_uniV2Router), liquidityAmountTokenA);
        _tokenB.approve(address(_uniV2Router), liquidityAmountTokenB);
        _uniV2Router.addLiquidity(
            tokenA,
            tokenB,
            liquidityAmountTokenA,
            liquidityAmountTokenB,
            0, 0,
            address(this),
            block.timestamp + 100
        );
    }

    function swapAtoB(uint256 amountTokenA) public {
        address[] memory path = new address[](2);
        path[0] = address(_tokenA);
        path[1] = address(_tokenB);
        _tokenA.approve(address(_uniV2Router), amountTokenA);
        _uniV2Router.swapExactTokensForTokens(
            amountTokenA,
            0,
            path,
            address(this),
            block.timestamp + 100
        );
    }

    function swapBtoA(uint256 amountTokenB) public {
        address[] memory path = new address[](2);
        path[0] = address(_tokenB);
        path[1] = address(_tokenA);
        _tokenB.approve(address(_uniV2Router), amountTokenB);
        _uniV2Router.swapExactTokensForTokens(
            amountTokenB,
            0,
            path,
            address(this),
            block.timestamp + 100
        );
    }

}
