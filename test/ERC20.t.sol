// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.13;

import "foundry-huff/HuffDeployer.sol";
import "forge-std/Test.sol";
import "forge-std/console.sol";

contract ERC20Test is Test {
    /// @dev Address of the SimpleStore contract.  
    ERC20 public erc20;

    /// @dev Setup the testing environment.
    function setUp() public {
        erc20 = ERC20(HuffDeployer.deploy("ERC20"));
    }

    /// @dev Ensure that you can set and get the value.
    function testTransfer(uint256 value) public {
        uint256 oldBalance = erc20.balanceOf(address(this));
        erc20.mint(value);
        console.log("after mint - 1", erc20.balanceOf(address(this)));

        uint256 newBalance = erc20.balanceOf(address(this));
        assertEq(newBalance, oldBalance + value);

        address sender = msg.sender;
        erc20.transfer(sender, newBalance);
        uint256 newBalanceThis = erc20.balanceOf(address(this));
        uint256 newBalanceSender = erc20.balanceOf(sender);
        
        assertEq(newBalanceThis, 0, "NewBalance not zero");
        assertEq(newBalanceSender, newBalance, "NewBalanceSender not correct");
    }

    function testApprove(address spender, uint256 amount) public {
        erc20.approve(spender, amount);
        assertEq(erc20.allowance(address(this), spender), amount);
    }

    function testTransferFrom(address spender, address to, uint256 amount) public {
        vm.assume(spender != 0x0000000000000000000000000000000000000000);
        vm.assume(spender != to);

        uint256 ownerPrevBalance = erc20.balanceOf(address(this));
        console.log("ownerPrevBalance", ownerPrevBalance);
        erc20.mint(amount);
        console.log("after mint", erc20.balanceOf(address(this)));
        erc20.approve(spender, amount);
        vm.prank(spender);
        erc20.transferFrom(address(this), to, amount);

        uint256 ownerNewBalance = erc20.balanceOf(address(this));
        console.log("ownerNewBalance", ownerNewBalance);


        console.log("from %s to %s amount %s", address(this), to, amount);
        assertEq(ownerPrevBalance, ownerNewBalance );
        assertEq(erc20.balanceOf(to), amount);
        assertEq(erc20.allowance(address(this), spender), 0);
    }
}

interface ERC20 {
    function balanceOf(address) external view returns(uint256);
    function mint(uint256) external ;
    function transfer(address, uint256) external returns(bool);
    function approve(address, uint256) external returns(bool);
    function transferFrom(address, address, uint256) external returns(bool);
    function allowance(address, address) external view returns(uint256);
}
