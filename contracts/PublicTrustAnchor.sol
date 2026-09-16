// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title PublicTrustAnchor
/// @notice Minimal reference contract for anchoring Merkle roots.
/// @dev Do not deploy without independent audit, signer policy and operational review.
contract PublicTrustAnchor {
    address public owner;

    struct Anchor {
        uint64 anchoredAt;
        uint64 leafCount;
        bytes32 metadataHash;
    }

    mapping(bytes32 => Anchor) public anchors;

    event RootAnchored(
        bytes32 indexed merkleRoot,
        uint64 leafCount,
        bytes32 indexed metadataHash,
        uint64 anchoredAt
    );

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    error Unauthorized();
    error InvalidRoot();
    error AlreadyAnchored();
    error InvalidOwner();

    constructor(address initialOwner) {
        if (initialOwner == address(0)) revert InvalidOwner();
        owner = initialOwner;
        emit OwnershipTransferred(address(0), initialOwner);
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    function anchorRoot(bytes32 merkleRoot, uint64 leafCount, bytes32 metadataHash) external onlyOwner {
        if (merkleRoot == bytes32(0) || leafCount == 0) revert InvalidRoot();
        if (anchors[merkleRoot].anchoredAt != 0) revert AlreadyAnchored();

        uint64 timestamp = uint64(block.timestamp);
        anchors[merkleRoot] = Anchor({
            anchoredAt: timestamp,
            leafCount: leafCount,
            metadataHash: metadataHash
        });

        emit RootAnchored(merkleRoot, leafCount, metadataHash, timestamp);
    }

    function isAnchored(bytes32 merkleRoot) external view returns (bool) {
        return anchors[merkleRoot].anchoredAt != 0;
    }

    function transferOwnership(address newOwner) external onlyOwner {
        if (newOwner == address(0)) revert InvalidOwner();
        address previousOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(previousOwner, newOwner);
    }
}
