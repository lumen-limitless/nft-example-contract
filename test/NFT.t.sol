// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

import {NFT} from "src/NFT.sol";

import "lib/forge-std/src/Test.sol";

contract NFTTest is Test {
    address deployer;
    address owner;
    NFT nft;

    function setUp() public {
        deployer = vm.addr(69);
        owner = vm.addr(420);
        vm.startPrank(deployer);
        vm.deal(deployer, 1000 ether);

        nft = new NFT(owner);
        vm.stopPrank();
    }

    function testOwner() public {
        assertEq(nft.owner(), owner);
    }

    function testBuyPublic() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        uint256 initialBalance = address(1).balance;
        uint256 tokensToBuy = 5;
        uint256 cost = tokensToBuy * nft.MINT_PRICE();

        nft.buyPublic{value: cost}(tokensToBuy);

        assertEq(nft.balanceOf(address(1)), tokensToBuy);
        assertEq(nft.totalSupply(), tokensToBuy);
        assertEq(address(1).balance, initialBalance - cost);
        vm.stopPrank();
    }

    function testBuyPublicMaxMintable() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 100 ether);

        uint256 maxMintable = nft.MAX_MINTABLE();
        uint256 cost = maxMintable * nft.MINT_PRICE();

        nft.buyPublic{value: cost}(maxMintable);

        assertEq(nft.balanceOf(address(1)), maxMintable);
        assertEq(nft.totalSupply(), maxMintable);
        vm.stopPrank();
    }

    function testFailBuyPublicExceedMaxMintable() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 100 ether);

        uint256 maxMintable = nft.MAX_MINTABLE();
        uint256 cost = (maxMintable + 1) * nft.MINT_PRICE();

        nft.buyPublic{value: cost}(maxMintable + 1);
        vm.stopPrank();
    }

    function testFailBuyPublicInsufficientPayment() public {
        vm.startPrank(address(1));
        vm.deal(address(1), 1 ether);

        uint256 tokensToBuy = 5;
        uint256 cost = tokensToBuy * nft.MINT_PRICE() - 1 wei;

        nft.buyPublic{value: cost}(tokensToBuy);
        vm.stopPrank();
    }

    function testSetBaseURI() public {
        string memory newBaseURI = "https://example.com/metadata/";

        vm.prank(owner);
        nft.setBaseURI(newBaseURI);
    }

    function testFailSetBaseURINotOwner() public {
        string memory newBaseURI = "https://example.com/metadata/";

        vm.expectRevert(abi.encodeWithSignature("OwnableUnauthorizedAccount(address)"));
        nft.setBaseURI(newBaseURI);
    }

    function testWithdraw() public {
        vm.deal(address(nft), 1 ether);
        uint256 initialBalance = owner.balance;

        vm.prank(owner);
        nft.withdraw();

        assertEq(address(nft).balance, 0);
        assertEq(owner.balance, initialBalance + 1 ether);
    }

    function testFailWithdrawNotOwner() public {
        vm.deal(address(nft), 1 ether);

        vm.prank(address(1));
        nft.withdraw();
    }
}
