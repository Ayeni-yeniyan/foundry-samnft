// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.19;

import {Test} from "forge-std/Test.sol";
import {BasicNft} from "src/BasicNft.sol";
import {DeployScript} from "script/DeployScript.s.sol";
import {MintBasicNft} from "script/Interactions.s.sol";

contract BasicNftTest is Test {
    DeployScript public deployer;
    BasicNft public basicNft;
    // MintBasicNft public mintBasicNft;
    // string  public constant SHIBA="ipfs://";
    string public constant PUG_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG.json";
    string public constant PUG2_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=0-PUG2.json";
    string public constant SHIBA_URI =
        "ipfs://bafybeig37ioir76s7mg5oobetncojcm3c3hxasyd4rvid4jqhy4gkaheg4/?filename=1-SHIBA.json";

    address public USER1 = makeAddr("USER1");
    address public USER2 = makeAddr("USER2");

    function setUp() public {
        deployer = new DeployScript();
        basicNft = deployer.run();
        // mintBasicNft = new MintBasicNft();
        // mintBasicNft.run();
    }

    function testNameIsCorrect() public view {
        string memory expectedName = "DoggieFt";
        string memory actualName = basicNft.name();

        string memory expectedSymbol = "Dog";
        string memory actualSymbol = basicNft.symbol();

        assert(
            keccak256(abi.encodePacked(expectedName)) ==
                keccak256(abi.encodePacked(actualName))
        );
        assert(
            keccak256(abi.encodePacked(expectedSymbol)) ==
                keccak256(abi.encodePacked(actualSymbol))
        );
    }

    function testCanMintAndHaveABalance() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        assert(basicNft.balanceOf(USER1) == 1);
        assert(
            keccak256(abi.encodePacked(PUG_URI)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
    }

    // function testMinContractIsCalled() public {
    //     assert(basicNft.balanceOf(address(mintBasicNft)) == 1);
    //     assert(
    //         keccak256(abi.encodePacked(PUG2_URI)) ==
    //             keccak256(abi.encodePacked(basicNft.tokenURI(0)))
    //     );
    // }

    // New tests start here

    function testTokenCounterIncrement() public {
        uint256 initialCount = basicNft.getTokenCount(); // After setup, we already have 1 token

        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.prank(USER2);
        basicNft.mintNft(SHIBA_URI);

        assert(basicNft.balanceOf(USER1) == 1);
        assert(basicNft.balanceOf(USER2) == 1);

        assert(
            keccak256(abi.encodePacked(PUG_URI)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(0)))
        );
        assert(
            keccak256(abi.encodePacked(SHIBA_URI)) ==
                keccak256(abi.encodePacked(basicNft.tokenURI(1)))
        );
        assert(initialCount + 2 == basicNft.getTokenCount());
        assert(basicNft.getTokenCount() == 2);
    }

    // function testOwnerOf() public {
    //     vm.prank(USER1);
    //     basicNft.mintNft(PUG_URI);

    //     assert(basicNft.ownerOf(1) == USER1);
    //     assert(basicNft.ownerOf(0) == address(mintBasicNft));
    // }

    function testMultipleMints() public {
        vm.startPrank(USER1);
        basicNft.mintNft(PUG_URI);
        basicNft.mintNft(SHIBA_URI);
        vm.stopPrank();

        assert(basicNft.balanceOf(USER1) == 2);
    }

    function testTransferFrom() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.startPrank(USER1);
        basicNft.approve(USER2, 0);
        vm.stopPrank();

        vm.prank(USER2);
        basicNft.transferFrom(USER1, USER2, 0);

        assert(basicNft.ownerOf(0) == USER2);
        assert(basicNft.balanceOf(USER1) == 0);
        assert(basicNft.balanceOf(USER2) == 1);
    }

    function testSafeTransferFrom() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.startPrank(USER1);
        basicNft.approve(USER2, 0);
        vm.stopPrank();

        vm.prank(USER2);
        basicNft.safeTransferFrom(USER1, USER2, 0);

        assert(basicNft.ownerOf(0) == USER2);
    }

    function testApproveAndGetApproved() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.prank(USER1);
        basicNft.approve(USER2, 0);

        assert(basicNft.getApproved(0) == USER2);
    }

    function testSetApprovalForAll() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.prank(USER1);
        basicNft.setApprovalForAll(USER2, true);

        assert(basicNft.isApprovedForAll(USER1, USER2));

        vm.prank(USER1);
        basicNft.setApprovalForAll(USER2, false);

        assert(!basicNft.isApprovedForAll(USER1, USER2));
    }

    function testNonOwnerCannotApprove() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.prank(USER2);
        vm.expectRevert();
        basicNft.approve(USER2, 1);
    }

    function testNonApprovedCannotTransfer() public {
        vm.prank(USER1);
        basicNft.mintNft(PUG_URI);

        vm.prank(USER2);
        vm.expectRevert();
        basicNft.transferFrom(USER1, USER2, 1);
    }

    function testQueryNonExistentToken() public {
        uint256 nonExistentTokenId = 999;

        vm.expectRevert();
        basicNft.ownerOf(nonExistentTokenId);

        vm.expectRevert();
        basicNft.getApproved(nonExistentTokenId);
    }
}
