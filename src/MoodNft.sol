// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;
import {ERC721} from "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import {Base64} from "@openzeppelin/contracts/utils/Base64.sol";

contract MoodNft is ERC721 {
    uint256 private s_tokenCounter;
    // mapping(uint256 => string) private s_tokenIdToUri;
    mapping(uint256 => Mood) private s_tokenIdToMood;
    string private s_happySvgImageUri;
    string private s_sadSvgImageUri;
    // error
    error MoodNft__CanFlipMoodIfNotOwner();
    enum Mood {
        HAPPY,
        SAD
    }

    constructor(
        string memory happySvg,
        string memory sadSvg
    ) ERC721("Mood Nft", "MDN") {
        s_happySvgImageUri = happySvg;
        s_sadSvgImageUri = sadSvg;
        s_tokenCounter = 0;
    }

    function mintNft() public {
        _safeMint(msg.sender, s_tokenCounter);
        s_tokenCounter++;
    }

    function _baseURI() internal pure override returns (string memory) {
        return "data:application/json;base64,";
    }

    function flipMood(uint256 tokenId) public {
        address owner = _ownerOf(tokenId);
        if (!_isAuthorized(owner, msg.sender, tokenId)) {
            revert MoodNft__CanFlipMoodIfNotOwner();
        }
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            s_tokenIdToMood[tokenId] = Mood.SAD;
        } else {
            s_tokenIdToMood[tokenId] = Mood.HAPPY;
        }
    }

    function tokenURI(
        uint256 tokenId
    ) public view override returns (string memory) {
        string memory imageUri;
        if (s_tokenIdToMood[tokenId] == Mood.HAPPY) {
            imageUri = s_happySvgImageUri;
        } else {
            imageUri = s_sadSvgImageUri;
        }

        return
            string(
                abi.encodePacked(
                    _baseURI(),
                    Base64.encode(
                        bytes(
                            abi.encodePacked(
                                '{"name": "',
                                name(),
                                '", "description": "An Nft that reflects mood I guess", "attribute": [{"trait_type":"moodiness","value":100}], "image": "',
                                imageUri,
                                '"'
                            )
                        )
                    )
                )
            );
    }

    function getTokenCount() public view returns (uint256) {
        return s_tokenCounter;
    }
}
